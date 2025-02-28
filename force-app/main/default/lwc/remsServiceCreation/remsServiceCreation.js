import { LightningElement, api, wire } from 'lwc';
import getNameSpace from "@salesforce/apex/OCRFormCtrl.getNameSpace";
import getPermissionSets from "@salesforce/apex/OCRFormCtrl.getPermissionSets";
import getServiceConfigRecords from "@salesforce/apex/OCRFormCtrl.getServiceConfigRecords";
import getServiceCreation from "@salesforce/apex/OCRFormCtrl.getServiceCreation";
import fetchRecordTypeId from "@salesforce/apex/OCRFormCtrl.fetchRecordTypeId";
import getStageHeaderDetails from '@salesforce/apex/OCRFormCtrl.getStageHeaderDetails';

export default class RemsServiceCreation extends LightningElement {

    showUI = false;
    ShowSpinner = true;
    accountCreationForm = true;
    serviceConfig;
    serviceConfigRecord = {};
    expandButton = true;
    serviceFields = [];
    orginalData = [];
    recordTypeData;
    documentCheckListId;
    setActiveSectionsList = [];
    headerTitle;
    secondCaseId;
    checkNPIDuplicateFound;
    serviceName;
    userPermissionSets;
    fieldmappingconfigmap = new Map();
    substakeHolderUpdateList = {};
    phoneFieldsList = [];

    @api showPopup = false;
    @api participantType;
    @api serviceType;
    @api accountId;
    @api incontactId;
    @api currentProgramId;
    @api currentUserProgramName;


    async connectedCallback() {
        this.handleGetPermissionSets();
        await this.handleNameSpace();
        this.ShowSpinner = true;
        var currentUrl = window.location.href;
        if (currentUrl.includes('DocumentReview')) {
            var currentUrl = window.location.href;
            let documentURL = new URL(currentUrl).searchParams;
            this.documentCheckListId = documentURL.get('uid');
        }

        getStageHeaderDetails({ documentCheckLsId: this.documentCheckListId }).then(result => {
            this.participantType = result ? result[0].RequestorType__c : '';
            this.serviceType = result ? result[0].ServiceType__c : '';
            this.handleServiceCreation();
        })


    }

    handleServiceCreation() {
        let nameSpace = this.namespaceVar;
        getServiceConfigRecords({
            participantType: this.participantType,
            serviceType: this.serviceType,
            programName: this.currentUserProgramName
        })
            .then((result) => {
                this.serviceConfigRecord = result;
                this.allowDuplicateNPI = this.serviceConfigRecord[`${this.namespaceVar}Allow_Duplicate_NPI__c`];
                this.getServiceCreationForm();
            })
            .catch((error) => {
                this.showToastNotification(
                    "Error",
                    reduceErrors(error).join(", "),
                    "Error"
                );
            });
    }

    getServiceCreationForm() {
        var currentUrl = window.location.href;
        if (currentUrl.includes('DocumentReview')) {
            var currentUrl = window.location.href;
            let documentURL = new URL(currentUrl).searchParams;
        }
        console.log('this.documentCheckListId ' + this.documentCheckListId);
        getServiceCreation({
            serviceConfigObj: this.serviceConfigRecord, documentCheckListId: this.documentCheckListId
        })
            .then((result) => {
                let nameSpace = this.namespaceVar;
                let hasNPIOverridePermission;
                this.showUI = true;
                this.ShowSpinner = true;
                this.orginalData = JSON.parse(JSON.stringify(result));
                if (!this.accountId) {
                    if (this.userPermissionSets) {
                        hasNPIOverridePermission = this.userPermissionSets.includes('REMS_NPI_Override');
                    }
                    for (const key in this.orginalData) {
                        this.orginalData[key].forEach((element) => {
                            if (element.fieldName) {
                                if (element.disableRelatedFields)
                                    this.fieldmappingconfigmap.set(element.fieldName, element.disableRelatedFields);

                                if (element.updateRelatedFields)
                                    this.substakeHolderUpdateList[element.fieldName] = element.updateRelatedFields;

                                if (element.reParent) {
                                    this.newParent = element.fieldName;
                                }
                            }
                            if (this.userPermissionSets && element.permissionSet && this.userPermissionSets.includes(element.permissionSet)) {
                                element.editable = false;
                            }
                            if (element.dependentField !== undefined && element.dependentField !== null && element.dependentField !== "") {
                                element.visible = false;
                            } else if (hasNPIOverridePermission && element.fieldName === `${nameSpace}NPI_Status__c`) {
                                element.editable = false;
                            }
                        });
                    }
                } else {
                    for (const key in this.orginalData) {
                        this.orginalData[key].forEach((element) => {
                            if (element.fieldName) {
                                if (element.disableRelatedFields)
                                    this.fieldmappingconfigmap.set(element.fieldName, element.disableRelatedFields);

                                if (element.updateRelatedFields)
                                    this.substakeHolderUpdateList[element.fieldName] = element.updateRelatedFields;

                                if (element.reParent)
                                    this.newParent = element.fieldName;

                                if (element.fieldDataType === 'Phone') {
                                    var fieldName = element.fieldName;
                                    this.phoneFieldsList.push(fieldName);
                                }

                            }
                        });
                    }
                }

                const sections = Object.keys(result);
                const arrayMapKeys = sections.map((key) => ({
                    key,
                    value: this.orginalData[key]
                }));
                this.serviceFields = arrayMapKeys;
                if (currentUrl.includes('DocumentReview') || this.serviceFromAccount) {
                    if (this.serviceFields[0].value[1].fieldName === `${nameSpace}Channel__c`) {
                        this.serviceFields[0].value[1].fieldValue = 'Fax';
                    }
                }

                this.fieldValues = arrayMapKeys.reduce(
                    (acc, field) => [...acc, ...field.value],
                    []
                );

                //   this.requeried = this.fieldValues.map((value) => value.required);
                this.activeSectionsList = sections;
                this.serviceConfig = this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`];
                this.headerTitle = this.serviceConfigRecord[`${nameSpace}Title__c`];
                this.serviceName = this.serviceConfigRecord[`${nameSpace}Service_Type__c`];
                /*   if(this.fileBoolean = true){
                      this.fileDisplay = true;
                    }*/
                let returnedData;
                let recordTypeName;
                if (this.accountId || (this.serviceType === 'Outbound_Communication' && !this.accountId)) {
                    recordTypeName = this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`];
                } else {
                    recordTypeName = this.serviceConfigRecord[`${nameSpace}Account_Record_Type__c`];
                }
                console.log('recordTypeName::: ' + recordTypeName);
                this.getRecordTypeDataHandler(recordTypeName, "Case")
                    .then((result) => {
                        returnedData = result;
                        this.recordTypeData = returnedData;
                        console.log('recordType::: ' + this.recordTypeData);
                        this.handleExpandAll();
                        this.handleCollapseAll();
                    })
                    .catch((error) => {
                        this.showToastNotification(
                            "Error",
                            reduceErrors(error).join(", "),
                            "Error"
                        );
                    });
                //this.recordTypeData = returnedData;
                this.ShowSpinner = false;

            })
            .catch((error) => {
                this.ShowSpinner = false;
                this.showToastNotification(
                    "Error",
                    reduceErrors(error).join(", "),
                    "Error"
                );
            });
    }
    handleOnLoad(event) {

    }
    async handleSubmit(event) {}

    async handleOnSuccess(event) {

        let nameSpace = this.namespaceVar;

       
        if (this.isInboundOutboundCall) {
            let recordId = event.detail.id;
            this.secondCaseId = event.detail.id;
            await this.handleCreateEnrollmentService();
            return this.closeQuickSubtab(recordId);
        }
        if (this.participantType && this.serviceType && !this.accountId) {
            let returnedData;

            if (this.enrollmentRecordType) {
                // Place createRecord inside the inner then block to ensure it uses enrollmentRecordType
                await createRecord({
                    apiName: "Case",
                    fields: { ...this.fields, RecordTypeId: this.enrollmentRecordType }
                })
                    .then((result) => {
                        this.secondCaseId = result.id;
                        // Further actions after creating the record
                    })
                    .catch((error) => {
                        this.ShowSpinner = false;
                        this.showToastNotification(
                            "Error",
                            this.label.accountErrorMsg,
                            "Error"
                        );
                    });
            }



        }
        

        if (this.isInputValid()) {
            const response = event.detail;
            var enrollCaseId;
            if (response.id) {
                const recordId = response.id;
                this.caseRecordId = recordId;
                if (this.secondCaseId) {
                    enrollCaseId = this.secondCaseId;
                } else {
                    enrollCaseId = recordId;
                }
                Object.keys(this.substakeHolderUpdateList).forEach(key => {
                    if (typeof this.substakeHolderUpdateList[key] === 'boolean') {
                        delete this.substakeHolderUpdateList[key];
                    }
                })
                if (Object.keys(this.substakeHolderUpdateList).length > 0) {
                    await updateSubstakeholderData({
                        caseId: enrollCaseId,
                        parentFldSet: this.substakeHolderUpdateList,
                        programName: this.programName,
                        requestorTypeName: this.participantType,
                        recordTypeName: this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`]
                    }).then(response => {

                    }).catch(errors => {
                        this.ShowSpinner = false;
                    });
                }
                if (this.serviceType && this.participantType && this.accountId) {
                    this.accountAvailable = true;
                    await this.handleCreateEnrollmentService();
                    await this.closeQuickSubtab(this.accountId);
                    this.ShowSpinner = false;
                } else if (
                    this.serviceType &&
                    this.participantType &&
                    (this.accountId === null || this.accountId === undefined || this.accountId == '')
                ) {
                    this.createServiceAccount();
                } else {
                    this.createAccount();
                }
            } else {
                this.showToastNotification(
                    "Error",
                    this.label.accountErrorMsg,
                    "Error"
                );
                this.ShowSpinner = false;
            }
        } else if (!this.isInputValid()) {
            this.showToastNotification(
                "Error",
                this.label.validationCheckForAllFields,
                "Error"
            );
            this.ShowSpinner = false;
        }
    }
    handleCreateEnrollmentService = async () => {
         let nameSpace = this.namespaceVar;
         this.ShowSpinner = true;
         
         if(this.serviceName == this.label.Non_compliance_service_typeMsg && this.impactedStakeholderAccId){
          this.accountId = this.impactedStakeholderAccId;
      }
        let result = await createEnrollmentService({
          programId: this.programId,
          accountId: this.accountId,
          participantType: this.participantType,
            ServiceRecordTypeName: this.serviceConfigRecord[`${nameSpace}Service_Record_Type__c`],
        });
        if (result) {
          this.secondService = result;
          if (this.accountId && !this.secondCaseId) {
            let fields = {
              Id: this.caseRecordId,
              [`${nameSpace}REMS_Service_Summary__c`]: this.secondService,
              [`${nameSpace}Participant__c`]: this.accountId
            };
            await updateRecord({ fields })
              .then(() => {
                console.log('Record updated successfully');
              })
              .catch(error => {
                console.error('Error updating record', error);
              });
              if(this.documentCheckListId !== undefined && this.documentCheckListId !== ''){
                this.updateDocumentCheckList(this.caseRecordId,this.secondService,this.accountId);
              }
          }
    
          if (this.secondCaseId) {
            let fields = {
              Id: this.secondCaseId,
              [`${nameSpace}REMS_Service_Summary__c`]: this.secondService,
              [`${nameSpace}Participant__c`]: this.accountId
            };
            await updateRecord({ fields })
              .then(() => {
    
              })
              .catch(error => {
                console.error('Error updating record', error);
              });
              if(this.documentCheckListId !== undefined && this.documentCheckListId !== ''){
                this.updateDocumentCheckList(this.secondCaseId,this.secondService,this.accountId);
              }
    
    
          }
          if(this.accountAvailable){
            this.showToastNotification(
              "Success",
              "Record saved successfully.",
              "success"
            );
            this.closeQuickSubtab(this.accountId);
            this.ShowSpinner = false;
          }
        }
        this.ShowSpinner = false;
      };
       handleCreateEnrollmentService = async () => {
           let nameSpace = this.namespaceVar;
           this.ShowSpinner = true;
           
           if(this.serviceName == this.label.Non_compliance_service_typeMsg && this.impactedStakeholderAccId){
            this.accountId = this.impactedStakeholderAccId;
        }
          let result = await createEnrollmentService({
            programId: this.programId,
            accountId: this.accountId,
            participantType: this.participantType,
              ServiceRecordTypeName: this.serviceConfigRecord[`${nameSpace}Service_Record_Type__c`],
          });
          if (result) {
            this.secondService = result;
            if (this.accountId && !this.secondCaseId) {
              let fields = {
                Id: this.caseRecordId,
                [`${nameSpace}REMS_Service_Summary__c`]: this.secondService,
                [`${nameSpace}Participant__c`]: this.accountId
              };
              await updateRecord({ fields })
                .then(() => {
                  console.log('Record updated successfully');
                })
                .catch(error => {
                  console.error('Error updating record', error);
                });
                if(this.documentCheckListId !== undefined && this.documentCheckListId !== ''){
                  this.updateDocumentCheckList(this.caseRecordId,this.secondService,this.accountId);
                }
            }
      
            if (this.secondCaseId) {
              let fields = {
                Id: this.secondCaseId,
                [`${nameSpace}REMS_Service_Summary__c`]: this.secondService,
                [`${nameSpace}Participant__c`]: this.accountId
              };
              await updateRecord({ fields })
                .then(() => {
      
                })
                .catch(error => {
                  console.error('Error updating record', error);
                });
                if(this.documentCheckListId !== undefined && this.documentCheckListId !== ''){
                  this.updateDocumentCheckList(this.secondCaseId,this.secondService,this.accountId);
                }
      
      
            }
            if(this.accountAvailable){
              this.showToastNotification(
                "Success",
                "Record saved successfully.",
                "success"
              );
              this.closeQuickSubtab(this.accountId);
              this.ShowSpinner = false;
            }
          }
          this.ShowSpinner = false;
        };
      
        async updateDocumentCheckList(caseId, serviceId, accountId){
          let nameSpace = this.namespaceVar;
          let fields = {
            Id: this.documentCheckListId,
            [`${nameSpace}Case__c`]: caseId,
            [`${nameSpace}REMS_Service__c`]: serviceId,
            [`${nameSpace}REMS_Account__c`]: accountId
          };
          await updateRecord({ fields })
            .then(() => {
      
            })
            .catch(error => {
              console.error('Error updating record', error);
            });
      
        }
        isInputValid() {
            let isValid = true;
            let inputFields = this.template.querySelectorAll(".slds-has-error");
            inputFields.forEach((inputField) => {
              if (inputField.classList.contains("slds-has-error")) {
                isValid = false;
              }
            });
            return isValid;
          } 

    handleInputChange(event) {
        let nameSpace = this.namespaceVar;
        const fieldName = event.target.fieldName;
        const fieldValue = event.target.value;
        const commonFieldId = event.target.dataset.id;
        const commonFieldType = event.target.name;
        const commonFieldDataType = event.target.dataset.name;
        const fieldErrorMsg = event.target.dataset.error;
        const isValueNull = !fieldValue;
        const inputFields = this.template.querySelectorAll(`[data-id="${commonFieldId}"]`);
        for (let i = 0; i < inputFields.length; i++) {
            const emailPattern = /^[a-zA-Z0-9_'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
            const phonePattern = /^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/;
            const namePattern = /^[A-Za-z'. -]+$/;
            const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9,}$/;
            const extPattern = /^[0-9]{1,10}$/;
            const slnPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]*$/;
            const npiPattern = /^\d{10}$/;
            const hinPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
            const ncpdpPattern = /^\d{7}$/;
            // let alphanumericPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9,}$/;
            let alphanumericPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]*$/;
            const zipPattern = /^\d{5}(-\d{4})?$/;
            if (fieldName === inputFields[i].fieldName) {

                if (commonFieldDataType === 'Phone') {
                    if (fieldValue != '' && !fieldValue.match(phonePattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'Fax') {
                    if (fieldValue != '' && !fieldValue.match(phonePattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'Name') {
                    if (fieldValue != '' && !fieldValue.match(namePattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'SLN') {
                    if (fieldValue != '' && !fieldValue.match(slnPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'DEA') {
                    if (fieldValue != '' && !fieldValue.match(deaPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'Number') {
                    if (fieldValue != '' && !fieldValue.match(npiPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'HIN') {
                    if (fieldValue != '' && !fieldValue.match(hinPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                }
                else if (commonFieldDataType === 'Zip') {
                    if (fieldValue != '' && !fieldValue.match(zipPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'NCPDP') {
                    if (fieldValue != '' && !fieldValue.match(ncpdpPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'Ext') {
                    if (fieldValue != '' && !fieldValue.match(extPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                } else if (commonFieldDataType === 'Email') {
                    if (fieldValue != '' && !fieldValue.match(emailPattern)) {
                        inputFields[i].classList.add('slds-has-error');
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                    }
                }
                if (fieldValue && (commonFieldDataType === 'Phone' || commonFieldDataType === 'Fax')) {
                    inputFields[i].value = this.formatPhoneNumber(fieldValue);
                }
            }
        }
        const patientInfo = this.template.querySelectorAll('[data-id="' + commonFieldId.substr(0, commonFieldId.indexOf('F')) + '"]');
        //const patientInfo = this.template.querySelectorAll('lightning-input-field');
        patientInfo.forEach((info, i) => {
            if (fieldName === info.title) {
                if (this.fieldValues[i].required && fieldValue === '--None--' &&
                    (commonFieldType === 'PICKLIST' || commonFieldType === 'MULTIPICKLIST')) {
                    info.classList.remove('slds-hide');
                    info.value = fieldErrorMsg;
                }
                else if (commonFieldDataType === 'Phone') {
                    const phonePatterns = /^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/;
                    if (!isValueNull && !fieldValue.match(phonePatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'Fax') {
                    const faxPattern = /^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/;
                    if (!isValueNull && !fieldValue.match(faxPattern)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'Name') {
                    const namePatterns = /^[A-Za-z'. -]+$/;
                    if (!isValueNull && !fieldValue.match(namePatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'SLN') {
                    const slnPatterns = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]*$/;
                    if (!isValueNull && !fieldValue.match(slnPatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'DEA') {
                    const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9,}$/;
                    if (!isValueNull && !fieldValue.match(deaPattern)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                }
                else if (commonFieldDataType === 'DOB') {
                    const today = new Date();
                    const birthDate = new Date(fieldValue);
                    if (birthDate > today) {
                        inputFields[i].classList.add('slds-has-error');
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        inputFields[i].classList.remove('slds-has-error');
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'Number') {
                    const npiPatterns = /^\d{10}$/;
                    if (!isValueNull && !fieldValue.match(npiPatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                }
                else if (commonFieldDataType === 'HIN') {
                    const hinPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
                    if (!isValueNull && !fieldValue.match(hinPattern)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'Zip') {
                    const zipPatterns = /^\d{5}(-\d{4})?$/;
                    if (!isValueNull && !fieldValue.match(zipPatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'NCPDP') {
                    const ncpdpPatterns = /^\d{7}$/;
                    if (!isValueNull && !fieldValue.match(ncpdpPatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'Ext') {
                    const extPatterns = /^[0-9]{1,10}$/;
                    if (!isValueNull && !fieldValue.match(extPatterns)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                } else if (commonFieldDataType === 'Email') {
                    const emailPattern = /^[a-zA-Z0-9_'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                    if (!isValueNull && !fieldValue.match(emailPattern)) {
                        info.classList.remove('slds-hide');
                        info.value = fieldErrorMsg;
                    } else {
                        info.value = '';
                    }
                }
            }

        });


    }
    formatPhoneNumber(phoneNumber) {
        phoneNumber = phoneNumber.replace(/\D/g, '');
        const formattedNumber = phoneNumber.replace(
            /(\d{3})(\d{3})(\d{4})/,
            '($1) $2-$3'
        );
        return formattedNumber;
    }
    getRecordTypeDataHandler = async (recordTypeName, objectName) => {
        let recordTypId;
        let result = await fetchRecordTypeId({
            recordTypeName: recordTypeName,
            objectName: objectName
        });
        if (result) {
            recordTypId = result;
        }
        return recordTypId;
    };

    async handleNameSpace() {
        await getNameSpace({})
            .then((result) => {
                this.namespaceVar = result;
            })
            .catch((error) => {
                this.showToastNotification(
                    "Error",
                    reduceErrors(error).join(", "),
                    "Error"
                );
            });
    }

    handleGetPermissionSets() {
        getPermissionSets({})
            .then((result) => {
                this.userPermissionSets = result;
            })
            .catch((error) => {
                this.showToastNotification(
                    "Error",
                    reduceErrors(error).join(", "),
                    "Error"
                );
            });
    }

    handleExpandAll() {
        this.expandButton = false;
        this.setActiveSectionsList = [...this.activeSectionsList];
    }

    handleCollapseAll() {
        this.expandButton = true;
        this.setActiveSectionsList = [];
    }
    handleCancel() {
        this.showPopup = true;
        //this.closeForm();
    }
    handleError(event) {
        console.log(JSON.stringify(event.detail));
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.ShowSpinner = false;
    } async closeQuickSubtab(result) {
        if(this.callingFrom === 'Task'){
          result = this.taskId;
        }
        this.invokeWorkspaceAPI("isConsoleNavigation").then(async(isConsole) => {
          if (isConsole) {
            if(this.isInboundOutboundCall){
                  this.invokeWorkspaceAPI("getFocusedTabInfo").then(
                  async (focusedTab) => {
                    if(result.startsWith('001')){
                      await refreshTab(focusedTab.tabId);
                    }else{
                      this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result,
                            actionName: 'view'
                        }
                    },true);   
                    }
                    
                    this.dispatchEvent(new CustomEvent('cancel'));
                    this.ShowSpinner = false;
              })
          }else{
              this.invokeWorkspaceAPI("getFocusedTabInfo").then(
                async (focusedTab) => {
                  openTab({ recordId: result, focus: true })
                    .then((_) => {
                      if(!this.serviceFromAccount){
                      this.invokeWorkspaceAPI("closeTab", {
                        tabId: focusedTab.tabId
                      });
                      if(this.isInboundOutboundCall){
                         this.closeForm();
                        this.invokeWorkspaceAPI("closeTab", {
                        tabId: focusedTab.tabId
                      });
                        this.dispatchEvent(new CustomEvent('cancel'));
                         this.closeForm();
                      }
                      this.ShowSpinner = false;
                    }else{
                      this.invokeWorkspaceAPI("getFocusedTabInfo").then(
                        async (newTab) => {
                          refreshTab(newTab.tabId);
      
                    });
                    this.ShowSpinner = false;
                    }
                    })
                    .catch((error) =>
                      this.showToastNotification(
                        "Error",
                        reduceErrors(error).join(", "),
                        "Error"
                      )
                    );
                    this.ShowSpinner = false;
                },true
              );
            }
          }
        },true);
      }

}