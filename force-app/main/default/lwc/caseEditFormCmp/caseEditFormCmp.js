import { LightningElement, track, api, wire } from 'lwc';
import getCaseEditPage from '@salesforce/apex/OCRFormCtrl.getCaseEditPage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import RECORD_SUBMITTED from '@salesforce/label/c.Record_submitted';
import ACCOUNT_ERROR_MSG from '@salesforce/label/c.AccountErrorMsg';
import casePhoneValidation from '@salesforce/label/c.Case_Phone_Validation';
import caseDateValidation from '@salesforce/label/c.Case_Date_Validation';
import caseRequeriedErrorMsg from '@salesforce/label/c.Case_Requeried_Error_Msg';
import casePickListValidation from '@salesforce/label/c.Case_PickList_Validation';
import emailValidationMsg from '@salesforce/label/c.Email_Validation';
import nameCaseValidationMsg from '@salesforce/label/c.Name_Case_Validation_Msg';
import deaCaseValidationMsg from '@salesforce/label/c.DEA_Case_Validation_Msg';
import hinCaseValidationMsg from "@salesforce/label/c.HIN_Case_Validation_Msg";
import ncpdpCaseValidationMsg from "@salesforce/label/c.NCPDP_Case_Validation_Msg";
import extCaseValidationMsg from '@salesforce/label/c.EXT_Case_Validation_Msg';
import slnCaseValidationMsg from '@salesforce/label/c.SLN_Case_Validation_Msg';
import zipCodeCaseValidationMsg from '@salesforce/label/c.Zip_Code_Case_Validation_Msg';
import nipCaseValidationMsg from '@salesforce/label/c.NPI_Case_Validation_Msg';
import validationCheckForAllFields from '@salesforce/label/c.Validation_Check_For_All_Fields';
import cancleButtonConformationMessage from "@salesforce/label/c.CancleButtonConformationMessage";
import getPermissionSets from "@salesforce/apex/OCRFormCtrl.getPermissionSets";
import { openTab } from 'lightning/platformWorkspaceApi';
import getCaseFieldAndValueMap from "@salesforce/apex/OCRFormCtrl.getCaseFieldAndValueMap";
import getNameSpace from "@salesforce/apex/OCRFormCtrl.getNameSpace";
import validateNpiStatus from "@salesforce/apex/OCRFormCtrl.validateNpiStatus";
import checkNPIDuplicate from "@salesforce/apex/OCRFormCtrl.checkNPIDuplicate";
import duplicateEmailCheck from "@salesforce/apex/OCRFormCtrl.validateDuplicateEmail";
import handlerowActionMsg from "@salesforce/label/c.handlerowActionMsg";
import getAccountfieldMapping from "@salesforce/apex/OCRRemsAccountCreation.getAccountfieldMapping";
import getDuplicateAccount from "@salesforce/apex/OCRRemsAccountCreation.performDuplicateCheckup";
import createSubStakeHolderAccounts from "@salesforce/apex/OCRRemsAccountCreation.createSubStakeHolderAccounts";
import updateCase from "@salesforce/apex/OCRFormCtrl.updateCase";
import getProgramList from "@salesforce/apex/OCRFormCtrl.getCurrentUserProgram";
import { createRecord } from "lightning/uiRecordApi";
import getAssessmentResponse from "@salesforce/apex/OCRFormCtrl.getAssessmentResponse";
import onboardingdatesValMsg from "@salesforce/label/c.Onboarding_future_Date_validation";
import Non_compliance_service_typeMsg from "@salesforce/label/c.Non_compliance_service_type";
import Non_compliance_confirmation_msgval from "@salesforce/label/c.Non_compliance_confirmation_msg";
import Non_Compliance_Activityval from "@salesforce/label/c.Non_Compliance_Activity";
import updateSubstakeholderData from "@salesforce/apex/OCRFormCtrl.updateSubstakeholder";
import Age_validation_Messageval from "@salesforce/label/c.Age_validation_Message";
import deleteContentDocument from "@salesforce/apex/OCRFormCtrl.deleteContentDocument";
import relatedContentDocument from "@salesforce/apex/OCRFormCtrl.relatedContentDocument";
import { CurrentPageReference } from 'lightning/navigation';
import duplicateEmailError from "@salesforce/label/c.Duplicate_data_Msg";


export default class CaseEditFormCmp extends NavigationMixin(LightningElement) {

  label = {
    RECORD_SUBMITTED,
    ACCOUNT_ERROR_MSG,
    casePhoneValidation,
    caseDateValidation,
    caseRequeriedErrorMsg,
    casePickListValidation,
    emailValidationMsg,
    nameCaseValidationMsg,
    deaCaseValidationMsg,
    hinCaseValidationMsg,
    ncpdpCaseValidationMsg,
    extCaseValidationMsg,
    slnCaseValidationMsg,
    zipCodeCaseValidationMsg,
    nipCaseValidationMsg,
    validationCheckForAllFields,
    cancleButtonConformationMessage,
    handlerowActionMsg,
    onboardingdatesValMsg,
    Non_compliance_service_typeMsg,
    Non_compliance_confirmation_msgval,
    Non_Compliance_Activityval,
    Age_validation_Messageval,
    duplicateEmailError
  }
  @track accountRecordTypeList = [];
  @track selectedValue;
  showeAccountOption = false;
  showeAccountCreation = false;
  ShowSpinner = false;
  serviceConfig;
  serviceFields = [];
  fieldValues = [];
  activeSectionsList = [];
  expandButton = true;
  showUI = false;
  setActiveSectionsList = [];
  requeried;
  @api recordId;
  secFieldName;
  secFieldValue;
  orginalData = [];
  count = 0;
  isFirst = false;
  url;
  userPermissionSets;
  @track requestorTypeName;
  @api showPopup = false;
  headerTittle;
  recordTypeApiName;
  programName;
  namespaceVar;
  programId;
  storeRecordMap = {};
  knowledgeAssesmentPassFail;
  storeAccountFieldValues =[];
  isOpen = false;
  storeDuplicateAccounts ={};
  AccountCreationFields;
  officeContactRecords =[];
  PrescriberDelegateRecords =[];
  FacilityContactRecords =[];
  HCSRecords = [];
  prescriberRecords = [];
  byPassAccountSelection = false;
  showOffice = false
  showPrescriber = false
  showFacility = false
  showHCS = false;
  showPrescSubSt;
  dialogueOpened = false;
  stopCreation = false;
  fetchedNpiStatus;
  selectedAccountRecords = {
    Office_Contact:null,
    Facility_Account:null,
    Prescriber_Delegate:null,
    Pharmacy_Participant:null
  }
  fieldmappingconfigmap = new Map();
  substakeHolderUpdateList = {};
  overrideRequestorType = false;
  pageName;
  agecalFields = [];
  duplicatedataFldList = [];
  duplicatedataConfigList = [];

  @wire (getAccountfieldMapping) AccountCreationMetaData;

  uploadedFiles = [];
  contentVersion = new Map(); 
  handleUploadFinished(event) {
        let uplodedfilelist = [...this.uploadedFiles];
        // Get the list of uploaded files
        event.detail.files.forEach(ele => {
            this.contentVersion.set(ele.documentId,ele);
            uplodedfilelist.push({'key':ele.documentId,'value':ele.name});
            this.uploadedFiles = [...uplodedfilelist];
        });
    }  

    get acceptedFormats() {
      return ['.pdf','.txt','.jpg'];
    }

    get displayUploadedFiles() {
      return this.uploadedFiles ? true : false;
    }

    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          let attributes = currentPageReference.attributes;
          this.pageName = attributes.apiName;   
          if(this.pageName && this.pageName.includes('Outbound_Call')){
            let caseId = currentPageReference.state.c__caseId;
            this.recordId = caseId;
          } 
       }
    }
  async handleFileDelete (event) {
    try{
      let recordToDelete = {Id:event.target.dataset.name};
      const response = await deleteContentDocument({recordToDelete});
      let uplodedfileFilterList = [...this.uploadedFiles].filter(ele => ele.key !== recordToDelete.Id);
      this.uploadedFiles = [...uplodedfileFilterList];
      this.contentVersion.delete(recordToDelete.Id);
    }catch(error) {
      console.log(error);
    }
  }


  handleCloseAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
  async handleOnLoad(event) {
    if (!this.isFirst) {
      setTimeout(() => {
        var record = event.detail.records;
        console.log('++++record' + JSON.stringify(record));
        var fields = record[this.recordId].fields;
        this.programName = fields['US_WSREMS__Program_Picklist__c']?.value;
        this.handleNameSpace();
        let nameSpace = this.namespaceVar;
        let npiOverrideField = `${nameSpace}NPI_Override_Comments__c`;
        let updatedServiceFields = [...this.serviceFields];
        let agebeloweighteen;
        for (const key in this.orginalData) {

          updatedServiceFields.forEach(element => {
            element.value.forEach(element => {
              if(element.fieldName){
                if(element.calculateAge){
                  if(fields[element.fieldName] && fields[element.fieldName].value){
                    var today = new Date();
                    var year = today.getFullYear();
                    var month = today.getMonth();
                    var day = today.getDate();
                    var yearsBack18= new Date(year - 18, month, day);
                    if(yearsBack18>Date.parse(fields[element.fieldName].value)){
                      agebeloweighteen = false;
                    }else{
                      agebeloweighteen = true;
                    }
                  }
                  this.agecalFields.push(element.fieldName);
                }

                if(element.duplicateEmailReferenceFlds){
                  this.duplicatedataFldList[element.fieldName] = element.duplicateEmailReferenceFlds;
                }

                if(element.duplicateAffPrimaryPtcpant && element.duplicateParentRef && element.duplicateParentEmailMap){
                  var dupEmailconfig={};
                  dupEmailconfig['fieldName'] = element.fieldName;
                  dupEmailconfig['duplicateAffPrimaryPtcpant'] = element.duplicateAffPrimaryPtcpant;
                  dupEmailconfig['duplicateParentRef'] = element.duplicateParentRef;
                  dupEmailconfig['duplicateParentEmailMap'] = element.duplicateParentEmailMap;
                  dupEmailconfig['fieldvalue'] = null;
                  this.duplicatedataConfigList[element.fieldName] = dupEmailconfig;
                }
                
                if(element.softRequiredBeloweighteen && agebeloweighteen){
                  element.softrequired = true;
                }
            }
              if(element.fieldName && element.updateRelatedFields && fields[element.fieldName] && fields[element.fieldName].value){
                  this.substakeHolderUpdateList[element.fieldName]=fields[element.fieldName].value;
              }
              if (element.dependentField !== undefined && element.dependentField !== null && element.dependentField !== '') {
                if (fields.hasOwnProperty(element.dependentField) && fields[element.dependentField].value && element.dependentValue !== undefined && element.dependentValue !== '' 
                &&  (String(fields[element.dependentField].value).includes(String(element.dependentValue))|| String(element.dependentValue).includes(String(fields[element.dependentField].value)))) {
                  element.visible = true;
                }else {
                  element.visible = false;
                }
              }
              if(this.userPermissionSets && element.permissionSet && this.userPermissionSets.includes(element.permissionSet)){
                element.editable = false;
              }
              if(element.fieldName && element.fieldName === npiOverrideField){
                element.visible = false;
               if(fields[npiOverrideField] && fields[npiOverrideField].value){
                 element.visible = true;
               }
                }else if(element.fieldName === `${nameSpace}NPI_Status__c`) {
               this.fetchedNpiStatus = fields[`${nameSpace}NPI_Status__c`].value;
             }
                if(element.fieldName==`${nameSpace}Patient_DOB__c` || element.fieldName==`${nameSpace}Age__c`){
                  this.validateAge();
                } 
                if(element.fieldName==`${nameSpace}Unknown__c` || element.fieldName==`${nameSpace}First_Name_ar__c` || element.fieldName==`${nameSpace}Last_Name_ar__c`){
                  this.validateUnknown();
                }
              
                if(element.fieldName && element.isParticipant){
                  this.parentfieldName = element.fieldName;
                }
            });
          });
         
        }
        this.isFirst = true;
        console.log('++++this.substakeHolderUpdateList'+JSON.stringify(this.substakeHolderUpdateList));
        this.serviceFields = [...updatedServiceFields];
      }, 4000);

    }
  }
  async getProgramData() {
    await getProgramList()
      .then((result) => {
        let nameSpace = this.namespaceVar;
        this.programId = result[0][`${nameSpace}REMS_Program__c`];
        this.programName = result[0][`${nameSpace}REMS_Program__r`][`Name`];
      })
      .catch((error) => {
        this.showToastNotification(
          "Error",
          this.label.accountErrorMsg,
          "Error"
        );
      });
  }

  handleNameSpace() {
    getNameSpace({})
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
  
  @wire(getCaseEditPage, { caseId: "$recordId" })
  retrieveData({ error, data }) {
    this.handleGetPermissionSets();
    this.handleNameSpace();
    this.showUI = true;
    this.ShowSpinner = true;
    var currentUrl = window.location.href;
    this.url = currentUrl;
    let namespace = this.namespaceVar;
    console.log('this.url' + this.url);
    if (data) {
      this.orginalData = JSON.parse(JSON.stringify(data));
      console.log('Line 184 original data--'+JSON.stringify(this.orginalData));
      var arrayMapKeys = [];
      var allDataMap = [];
      var sections = [];
      let hasNPIOverridePermission;
      if (this.userPermissionSets) {
        hasNPIOverridePermission = this.userPermissionSets.includes('REMS_NPI_Override');
      }
      for (const key in this.orginalData) {
        this.orginalData[key].forEach(element => {
          if(element.fieldName){
            if(element.calculateAge){
              this.agecalFields.push(element.fieldName);
            }
            if(element.disableRelatedFields)
              this.fieldmappingconfigmap.set(element.fieldName,element.disableRelatedFields);

            if(element.updateRelatedFields){
              if(!this.substakeHolderUpdateList[element.fieldName]){
                this.substakeHolderUpdateList[element.fieldName]=element.updateRelatedFields;
              }
            }
            
          }
          if(this.userPermissionSets && element.permissionSet && this.userPermissionSets.includes(element.permissionSet)){
            element.editable = false;
          }
          if (element.dependentField !== undefined && element.dependentField !== null && element.dependentField !== '') {
            element.visible = false;
          }
          if (element.fieldName === 'CreatedDate' || element.fieldName === 'LastModifiedDate') {
            element.visible = false;
          } else if (hasNPIOverridePermission && element.fieldName === `${namespace}NPI_Status__c`) {
            element.editable = false;
            
          } else if (element.fieldName === `${namespace}NPI_Override_Comments__c`) {
            element.visible = true;
          }
          this.requestorTypeName = element.requestorType;
          this.headerTittle = element.tittle;
          this.recordTypeApiName = element.recordType;
        });

        arrayMapKeys.push({ key: key, value: this.orginalData[key] });
        sections.push(key);
        var valueMap = this.orginalData[key];
        for (let i = 0; i < valueMap.length; i++) {
          allDataMap.push(valueMap[i]);
        }
      }
      this.serviceFields = arrayMapKeys;

      let requirements = [];
      for (let field of this.serviceFields) {
        for (let value of field.value) {
          requirements.push(value.required);
          this.requeried = requirements;
        }
      }
      console.log('++++this.servicefields'+JSON.stringify(this.serviceFields));
      this.fieldValues = allDataMap;
      console.log('this.fieldValues--' + JSON.stringify(this.fieldValues));
      this.showeAccountOption = false;
      this.activeSectionsList = sections;
      if(this.recordTypeApiName == 'PAE'){
        this.overrideRequestorType = true;
      }

    } else if (error) {
      this.ShowSpinner = false;
      this.showToastNotification('Error', JSON.stringify(error), 'error');
    }
    this.ShowSpinner = false;
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
  handleError(event) {
    const errorDetail = event.detail.detail;
    this.showToastNotification('Error', errorDetail, 'error');
  }

  handleFieldVisibility(fieldName, fieldValue, event) {
    this.showUI = false;
    for (const key in this.orginalData) {
      this.serviceFields.forEach(element => {
        element.value.forEach(element => {
          if (element.dependentField !== undefined && element.dependentField !== null && element.dependentField !== '') {
            if (element.dependentField === fieldName && element.dependentValue !== undefined && element.dependentValue !== '' 
            && fieldValue && (element.dependentValue.includes(fieldValue) || fieldValue.includes(element.dependentValue))) {
              element.visible = true;
            } else if (element.dependentField === fieldName) {
              element.visible = false;
              element.fieldValue = '';
            } 
          }
        });
      });
    }
    this.showUI = true;
  }

  showToastNotification(title, message, variant) {
    const evt = new ShowToastEvent({
      title,
      message,
      variant,
    });
    this.dispatchEvent(evt);
  }

  closeAction() {
    this.showPopup = true;
    //this.closeForm();
  }
  handleYes() {
    // Handle cancellation logic here
    // Call an Apex method to perform cancellation
    // Hide the popup
    this.showPopup = false;
    if (!this.url.includes('DocumentReview')) {
      this.handleCloseAction();
    } else {
      const recordId = this.recordId;
      this.closeQuickSubtab(recordId);
    }


  }
  handleNo() {
    // Hide the popup
    this.showPopup = false;
  }

  async handleInputChange(event) {
    let nameSpace = this.namespaceVar;
    const fieldName = event.target.fieldName;
    const fieldValue = event.target.value;
    var ErrorMessage;

    if(this.duplicatedataFldList && this.duplicatedataFldList[fieldName]){
      ErrorMessage = this.validateDuplicateDataInForm(fieldName,fieldValue);
    }
    if (fieldName === `${nameSpace}NPI_Status__c`) {
      if (fieldValue === this.fetchedNpiStatus) {
        this.handleFieldDisplay(false);
      } else {
        this.handleFieldDisplay(true);
      }
    }
    this.handleFieldVisibility(fieldName, fieldValue, event);
    if(fieldName==`${nameSpace}Patient_DOB__c` || fieldName==`${nameSpace}Age__c`){
      this.validateAge();
    }
    
    const commonFieldId = event.target.dataset.id;
    const commonFieldType = event.target.name;
      const commonFieldDataType = event.target.dataset.name;
        const fieldErrorMsg = event.target.dataset.error;
    const isValueNull = !fieldValue;
    const inputFields = this.template.querySelectorAll(`[data-id="${commonFieldId}"]`);
    //let nameSpace = this.namespaceVar;
    for (let i = 0; i < inputFields.length; i++) {
      const emailPattern = /^[a-zA-Z0-9_'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
      const phonePattern = /^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/;
      const namePattern = /^[A-Za-z'. -]+$/;
      const deaPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9,}$/;
      const hinPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
      const extPattern = /^[0-9]{1,10}$/;
      const slnPattern = /^[a-zA-Z0-9]*$/;
      const npiPattern = /^\d{10}$/;
      const zipPattern = /^\d{5}(-\d{4})?$/;
      const ncpdpPattern = /^\d{7}$/;
      if (fieldName === inputFields[i].fieldName) {
        if (commonFieldType === "REFERENCE") {
          this.handleLookUpValues(fieldName, fieldValue, event);
          this.handleKnowledgeAssesmentPassFail(fieldValue);
          if(this.substakeHolderUpdateList.hasOwnProperty(fieldName)){
            this.substakeHolderUpdateList[ele.fieldName]=fieldValue;
          }

          if(this.duplicatedataConfigList){
            var dupdatConfig = {};
            let DupparentFld;
            var parentrefFldObj;
            var affprimParticipant;
            var affEmailConfig;
            for(var dupfieldName in this.duplicatedataConfigList){
              if(this.duplicatedataConfigList[dupfieldName]['duplicateParentRef'] == fieldName){
                dupdatConfig[dupfieldName] = this.duplicatedataConfigList[dupfieldName];
                DupparentFld = this.template.querySelector(
                  `lightning-input-field[data-field="${fieldName}"]`
                );
                parentrefFldObj = fieldName;
                affprimParticipant = this.duplicatedataConfigList[dupfieldName]['duplicateAffPrimaryPtcpant'];
                affEmailConfig = this.duplicatedataConfigList[dupfieldName]['duplicateParentEmailMap'];
              }
            }
            
            if(DupparentFld && !DupparentFld.value){
              this.removeDuplicateErrorMessage(dupdatConfig);
            }
  
            if(DupparentFld && DupparentFld.value){
              this.validateDuplicateEmail(dupdatConfig,DupparentFld,affprimParticipant,affEmailConfig);
            }
          }
        } else if (commonFieldDataType === 'Phone') {
          if (fieldValue != '' && !fieldValue.match(phonePattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'Fax') {
          if (fieldValue != '' && !fieldValue.match(phonePattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'Name') {
          if (fieldValue != '' && !fieldValue.match(namePattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'SLN') {
          if (fieldValue != '' && !fieldValue.match(slnPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'DEA') {
          if (fieldValue != '' && !fieldValue.match(deaPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'Number') {
          if (fieldValue != '' && !fieldValue.match(npiPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'HIN') {
          if (fieldValue != '' && !fieldValue.match(hinPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }
        else if (commonFieldDataType === 'Zip') {
          if (fieldValue != '' && !fieldValue.match(zipPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'NCPDP') {
          if (fieldValue != '' && !fieldValue.match(ncpdpPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'Ext') {
          if (fieldValue != '' && !fieldValue.match(extPattern)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }else if (commonFieldDataType === 'Email') {
          if ((fieldValue != '' && !fieldValue.match(emailPattern)|| ErrorMessage)) {
            inputFields[i].classList.add('slds-has-error');
          }else {
            inputFields[i].classList.remove('slds-has-error');
          }
        }
        if (fieldValue && (commonFieldDataType === 'Phone' || commonFieldDataType === 'Fax' )) {
          inputFields[i].value = this.formatPhoneNumber(fieldValue);
      }
      }
    }

    if(fieldName === `${nameSpace}Same_as_Account__c` && this.parentfieldName) {
      let sameAsAccountValue = this.template.querySelector(
        `lightning-input-field[data-field="${fieldName}"]`
      ).value;
      let parentfieldValue;
      if(sameAsAccountValue){
        let parentinputfield = this.template.querySelector(
          `lightning-input-field[data-field="${this.parentfieldName}"]`
        );
        parentfieldValue = parentinputfield.value;
      }
      this.handleLookUpValues(this.parentfieldName, parentfieldValue, event);   
    }

    let distributorEnrollment = 'Distributor_Enrollment';
    if (fieldName === 'US_WSREMS__NPI__c' && fieldValue.length === 10) {
      if (!(this.recordTypeApiName === distributorEnrollment || this.recordTypeApiName === 'Knowledge_Assessment')) {
        this.validateNpi(fieldValue);
      }
      this.handleDuplicateNPI(fieldValue);
    }

    const patientInfo = this.template.querySelectorAll('[data-id="' + commonFieldId.substr(0, commonFieldId.indexOf('F')) + '"]');

    patientInfo.forEach((info, i) => {
      if (fieldName === info.title) {
        if (this.fieldValues[i].required && fieldValue === '--None--' &&
          (commonFieldType === 'PICKLIST' || commonFieldType === 'MULTIPICKLIST')) {
          info.classList.remove('slds-hide');
          info.value = fieldErrorMsg;
        }
        else if (commonFieldDataType === 'Phone') {
            const phonePatterns =/^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/;
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
        }else if (commonFieldDataType === 'Name') {
          const namePatterns = /^[A-Za-z'. -]+$/;
             if (!isValueNull && !fieldValue.match(namePatterns)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if (commonFieldDataType === 'SLN') {
          const slnPatterns = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]*$/;
             if (!isValueNull && !fieldValue.match(slnPatterns)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if (commonFieldDataType === 'DEA') {
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
        }else if (commonFieldDataType === 'Number') {
          const npiPatterns = /^\d{10}$/;
             if (!isValueNull && !fieldValue.match(npiPatterns)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if(this.serviceName == this.label.Non_compliance_service_typeMsg && fieldName === `${nameSpace}Noncompliance_Confirmation_Date__c` ){
          let inputFldOutcome = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Outcome__c"]`);
          let inputFldConDt = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Noncompliance_Confirmation_Date__c"]`);

          const today = new Date();
          const ncDate = new Date(fieldValue);
          if(inputFldOutcome.value == this.label.Non_Compliance_Activityval && !fieldValue){
            inputFldConDt.classList.add('slds-has-error');
            info.classList.remove('slds-hide');
            info.value = this.label.Non_compliance_confirmation_msgval;
          }else if(fieldValue && ncDate>today ){
                inputFldConDt.classList.add('slds-has-error'); 
                info.classList.remove('slds-hide');
                info.value = fieldErrorMsg;
                
          }else{
            info.value = '';
            inputFldConDt.classList.remove('slds-has-error'); 
          }
        }else if (commonFieldDataType === 'HIN') {
          const hinPattern = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/;
             if (!isValueNull && !fieldValue.match(hinPattern)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if (commonFieldDataType === 'Zip') {
          const zipPatterns = /^\d{5}(-\d{4})?$/;
             if (!isValueNull && !fieldValue.match(zipPatterns)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if (commonFieldDataType === 'NCPDP') {
          const ncpdpPatterns = /^\d{7}$/;
             if (!isValueNull && !fieldValue.match(ncpdpPatterns)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if (commonFieldDataType === 'Ext') {
          const extPatterns = /^[0-9]{1,10}$/;
             if (!isValueNull && !fieldValue.match(extPatterns)) {
               info.classList.remove('slds-hide');
               info.value = fieldErrorMsg;
             } else {
               info.value = '';
             }
         }else if (commonFieldDataType === 'Email') {
          var flderrMsg = fieldErrorMsg;
          const emailPattern = /^[a-zA-Z0-9'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
              if ((!isValueNull && !fieldValue.match(emailPattern)) || ErrorMessage) {
                if(ErrorMessage && (!isValueNull && !fieldValue.match(emailPattern))){
                  flderrMsg = ErrorMessage +flderrMsg;
                }else if(ErrorMessage && !((!isValueNull && !fieldValue.match(emailPattern)))){
                  flderrMsg = ErrorMessage;
                }
               info.classList.remove('slds-hide');
               info.value = flderrMsg;
             } else {
               info.value = '';
             }
         }
        }
        if(this.serviceName == this.label.Non_compliance_service_typeMsg && fieldName === `${nameSpace}Outcome__c`  && info.title === `${nameSpace}Noncompliance_Confirmation_Date__c`){
          let inputFldConDt = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Noncompliance_Confirmation_Date__c"]`);
          const today = new Date();
          const ncDate = new Date(inputFldConDt.value);
          if(fieldValue == this.label.Non_Compliance_Activityval && !inputFldConDt.value){
            inputFldConDt.classList.add('slds-has-error');
            info.classList.remove('slds-hide');
            info.value = this.label.Non_compliance_confirmation_msgval;
          }else if(inputFldConDt.value && ncDate>today){
                inputFldConDt.classList.add('slds-has-error'); 
                info.classList.remove('slds-hide');
                info.value = fieldErrorMsg;
          }else{
            info.value = '';
            inputFldConDt.classList.remove('slds-has-error');
          }
        }
    });
    if(fieldName==`${nameSpace}Unknown__c` || fieldName==`${nameSpace}First_Name_ar__c` || fieldName==`${nameSpace}Last_Name_ar__c`){
      this.validateUnknown();
    }
    const allInputFields = this.template.querySelectorAll('lightning-input-field');
    if (fieldName === `${nameSpace}Ship_to_Address_Same_as_Above__c` && fieldValue == true) {

      if (allInputFields) {
        allInputFields.forEach(field => {
          console.log('allInputFields :: ' + field.fieldName + '/' + field.value);
          if (field.value != null) {
            this.storeRecordMap[field.fieldName] = field.value;
          }
          if (field.fieldName == `${nameSpace}Shipping_Address_Line_1__c`) {
            field.value = this.storeRecordMap[`${nameSpace}Address_Line_1__c`];
          }
          if (field.fieldName == `${nameSpace}Shipping_Address_Line_2__c`) {
            field.value = this.storeRecordMap[`${nameSpace}Address_Line_2__c`];
          }
          if (field.fieldName == `${nameSpace}Participant_City__c`) {
            field.value = this.storeRecordMap[`${nameSpace}City__c`];
          }
          if (field.fieldName == `${nameSpace}SLN_Issued_State__c`) {
            field.value = this.storeRecordMap[`${nameSpace}State__c`];
          }
          if (field.fieldName == `${nameSpace}REMS_Zip_Code__c`) {
            field.value = this.storeRecordMap[`${nameSpace}Zip__c`];
          }
          if (field.fieldName == `${nameSpace}Shipping_Country__c`) {
            field.value = this.storeRecordMap[`${nameSpace}REMS_Country__c`];
          }
        });
      }
    }
    else if (fieldName === `${nameSpace}Ship_to_Address_Same_as_Above__c` && fieldValue == false) {
      if (allInputFields) {
        allInputFields.forEach(field => {
          if (field.fieldName == `${nameSpace}Shipping_Address_Line_1__c` || field.fieldName == `${nameSpace}Shipping_Address_Line_2__c` ||
            field.fieldName == `${nameSpace}Participant_City__c` || field.fieldName == `${nameSpace}SLN_Issued_State__c` ||
            field.fieldName == `${nameSpace}REMS_Zip_Code__c` || field.fieldName == `${nameSpace}Shipping_Country__c`) {
            field.value = '';
          }
        });
      }
    }
  }
  formatPhoneNumber(phoneNumber) {
    phoneNumber = phoneNumber.replace(/\D/g, '');
    const formattedNumber = phoneNumber.replace(
      /(\d{3})(\d{3})(\d{4})/,
      '($1) $2-$3'
    );
    return formattedNumber;
  }
  validateNpi = async (value) => {
    try {
      // this.ShowSpinner = true;
      let nameSpace = this.namespaceVar;
      let fieldName = `${nameSpace}NPI_Status__c`;
      let result = await validateNpiStatus({
        npiValue: value
      });
      if (result) {
        let inputField = this.template.querySelector(
          `lightning-input-field[data-field="${fieldName}"]`
        );
        this.fetchedNpiStatus = "Valid";
        inputField.value = "Valid";
      } else {
        let inputField = this.template.querySelector(
          `lightning-input-field[data-field="${fieldName}"]`
        );
        this.fetchedNpiStatus = "Invalid";
        inputField.value = "Invalid";
      }
    } catch (ex) {
      this.showToastNotification("Error", "Unable to Validate NPI", "error");
    }
  };

  handleFieldDisplay(fieldVisible) {
    let nameSpace = this.namespaceVar;
    let npiOverrideField = `${nameSpace}NPI_Override_Comments__c`;
    let field = this.template.querySelector(`lightning-input-field[data-field="${npiOverrideField}"]`);
    if(field){
      field.value=null;
    }
    setTimeout(_ => this.asyncUpdateNPIOverride(fieldVisible),100);   
  }

  asyncUpdateNPIOverride(visible){
    let nameSpace = this.namespaceVar;
    let npiOverrideField = `${nameSpace}NPI_Override_Comments__c`;
    for (const key in this.orginalData) {
      this.orginalData[key].forEach((element) => {
        if (element.fieldName && element.fieldName === npiOverrideField) {
          element.visible = visible;
          if(!visible){
            element.fieldValue = null;
            this.npiOverrideReset = true;
          }else{
            this.npiOverrideReset = false;
          }
        }
      });
    }

    const arrayMapKeys = Object.keys(this.orginalData).map((key) => ({
         key,
         value: this.orginalData[key]
       }));
       this.serviceFields = [...arrayMapKeys];
  }

  checkNPIDuplicateFound = false;
  handleDuplicateNPI(NPIValue) {
    checkNPIDuplicate({ NPIValue: NPIValue })
      .then(result => {
        if (result) {
          this.checkNPIDuplicateFound = true;
        }
      })
      .catch(error => {
        this.checkNPIDuplicateFound = false;
      });

  }

  async handleLookUpValues(fieldName, fieldValue, event) {
    // this.ShowSpinner = true;
    let nameSpace = this.namespaceVar;
    console.log('fieldValue' + fieldValue);

    try {
      const getFieldValues = await getCaseFieldAndValueMap({ accountId: fieldValue,
        requestorType: this.requestorTypeName,
        targetObject: "Account",
        sourceObject: "Case",
        sourceRecordType: this.recordTypeApiName,
        parentFieldType: fieldName,
        programName: this.programName,
        overrideReqType:this.overrideRequestorType
      });

      this.mapData = new Map(Object.entries(getFieldValues));
      await this.handleKnowledgeAssesmentPassFail(fieldValue);
      // for (const [key, value] of this.mapData.entries()) {
      //     if(key !== `${nameSpace}REMS_Program__c`) {
      //       this.template.querySelector(`lightning-input-field[data-field="${key}"]`)?.value = value;
      //     }

      //     setTimeout((key,value) => asyncUpdateFieldValues(key,value),1000);
      // } 
      for (const key in this.orginalData) {
        this.orginalData[key].forEach((element) => {
          if (this.mapData.has(element.fieldName)) {
            element.visible = true;
          }
        });
      }

      const arrayMapKeys = Object.keys(this.orginalData).map((key) => ({
        key,
        value: this.orginalData[key]
      }));
      this.serviceFields = [...arrayMapKeys];
      setTimeout(_ => this.asyncUpdateFieldValues(event,fieldValue,fieldName), 100);
    } catch(exception) {
      console.log(exception);
    }
  }

  asyncUpdateFieldValues(event,parent,parentName) {
    let nameSpace = this.namespaceVar;
    for (const [key, value] of this.mapData.entries()) {
      let field = this.template.querySelector(`lightning-input-field[data-field="${key}"]`);
      if(field && key!=parentName) {
        field.value = value;
        if(!value) {
          field.value = null;
        }
      }
      this.handleFieldVisibility(key, value, event);
      if(key==`${nameSpace}Patient_DOB__c` || key==`${nameSpace}Age__c`){
        this.validateAge();
      }
      if(key==`${nameSpace}Unknown__c` || key==`${nameSpace}First_Name_ar__c` || key==`${nameSpace}Last_Name_ar__c`){
        this.validateUnknown();
      }
    }

    for (const key in this.orginalData) {
      this.serviceFields.forEach((element) => {
        element.value.forEach((item) => {
          if(this.mapData.has(item.fieldName) && this.fieldmappingconfigmap.has(parentName) && this.fieldmappingconfigmap.get(parentName)){
            if(parent){
              item.editable = true;
            }else{
              item.editable = false;
            }
          }
        });
      });
    }
    

    //  this.ShowSpinner = false;

  }
  async handleKnowledgeAssesmentPassFail(accountId) {
    try {
      const result = await getAssessmentResponse({
        accountId: accountId,
      });
      let nameSpace = this.namespaceVar;
      this.knowledgeAssesmentPassFail = result;
      for (const key in this.orginalData) {
        if (Object.hasOwnProperty.call(this.orginalData, key)) {
          const data = this.orginalData[key];
          for (let i = 0; i < data.length; i++) {
            const element = data[i];
            if (element.fieldName === `${nameSpace}Knowledge_Assessment__c`) {
              if (this.knowledgeAssesmentPassFail != null && this.knowledgeAssesmentPassFail != undefined) {
                element.fieldValue = this.knowledgeAssesmentPassFail;
              }
            }
          }
        }
      }
    } catch (error) {
      console.log('Error ', error);
    }
  }
  isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll('.slds-has-error');
    inputFields.forEach(inputField => {
      if (inputField.classList.contains('slds-has-error')) {
        isValid = false;
      }
    });
    return isValid;
  }

  isObjectEmpty(obj) {
    // Check if the object is empty
    if (Object.keys(obj).length === 0) {
      return true;
    }

    // Check if any key is empty or undefined
    for (let key in obj) {
      console.log(obj[key].length)
      if (obj[key].length != 0) {
        return false;
      }
    }

    return true;
  }
  requestorType = '';
  async getDuplicateAccounts(fields) {
    let nameSpace = this.namespaceVar;
    this.AccountCreationFields = JSON.parse(JSON.stringify(this.AccountCreationMetaData.data));
    console.log('calling ' +JSON.stringify(this.AccountCreationMetaData.data))

    for (const key in this.AccountCreationFields) {
      console.log('key '+key+' >> ' +fields[key])
      if (fields[key] === null || fields[key] === '') {

        const arr = this.AccountCreationFields[key][`${nameSpace}Target_Specific_Fields__c`].split(',');
        this.requestorType = this.AccountCreationFields[key][`${nameSpace}Requestor_Type__c`]
        arr.forEach(value => {
          if (fields[value] !== null) {
            this.storeAccountFieldValues.push({ recordtype: key, fieldApiName: value, feildValue: fields[value] });
          }
        });
      }
    }
    console.log('calling ' + JSON.stringify(this.storeAccountFieldValues))
    this.getUniqueAccountFields(this.storeAccountFieldValues);
    if (!this.byPassAccountSelection && this.storeAccountFieldValues !== null) {
      await getDuplicateAccount({ RequestRecordType: this.requestorType, programName: this.programName, programId: this.programId, fieldMapValue: this.storeAccountFieldValues })
        .then(result => {
          if (result) {
            console.log('calling ' + JSON.stringify(result))
            this.OpenModelPopForDuplicateAccounts(result);
            this.isOpen = !this.isObjectEmpty(result);
            this.byPassAccountSelection = this.isObjectEmpty(result);
          }
        })
        .catch(error => {
          console.log(' Error ' + JSON.stringify(error));
          this.stopCreation = true;
        });
    }
    return this.byPassAccountSelection;
  }
  OpenModelPopForDuplicateAccounts(data) {
    this.storeDuplicateAccounts = JSON.parse(JSON.stringify(data));
    for (const key in this.storeDuplicateAccounts) {
      if (key === 'Office_Contact' && this.storeDuplicateAccounts.hasOwnProperty('Office_Contact')) {
        this.officeContactRecords = this.storeDuplicateAccounts['Office_Contact']
      } else if (key === 'Facility_Account' && this.storeDuplicateAccounts.hasOwnProperty('Facility_Account')) {
        this.FacilityContactRecords = this.storeDuplicateAccounts['Facility_Account']
      } else if (key === 'Prescriber_Delegate' && this.storeDuplicateAccounts.hasOwnProperty('Prescriber_Delegate')) {
        this.PrescriberDelegateRecords = this.storeDuplicateAccounts['Prescriber_Delegate']
      } else if (key === 'Pharmacy_Participant' && this.storeDuplicateAccounts.hasOwnProperty('Pharmacy_Participant')) {
        this.HCSRecords = this.storeDuplicateAccounts['Pharmacy_Participant']
      }else if (key === 'Prescriber' && this.storeDuplicateAccounts.hasOwnProperty('Prescriber')) {
        this.prescriberRecords = this.storeDuplicateAccounts['Prescriber']
      }
    }
    this.showFacility = this.FacilityContactRecords.length > 0;
    this.showOffice = this.officeContactRecords.length > 0;
    this.showPrescriber = this.PrescriberDelegateRecords.length > 0;
    this.showHCS = this.HCSRecords.length > 0;
    this.showPrescSubSt = this.prescriberRecords.lenght>0;
  }

  handleRowSelection = event => {
    var selectedRows = event.detail.selectedRows;
    let targetId = event.target.dataset.targetId;

    if(selectedRows.length > 1) {
      var el = this.template.querySelector('lightning-datatable');
      selectedRows = el.selectedRows = el.selectedRows.slice(1);
      this.showNotification();
      return;
    } else if(selectedRows.length > 0) {
      this.selectedAccountRecords[targetId] = selectedRows[0].Id
    } else {
      this.selectedAccountRecords[targetId] = null
    }
  }
  showNotification() {
    const event = new ShowToastEvent({
      title: 'Error',
      message: this.label.handlerowActionMsg,
      variant: 'warning',
      mode: 'pester'
    });
    this.dispatchEvent(event);
  }
  generateColumns(record,RecordType) {
    let columns = [];
    for (let fieldName in record) {
      console.log('fieldName ' + fieldName + '' + JSON.stringify(record))
      if (RecordType === 'Pharmacy_Participant' && fieldName !== 'RecordType' && fieldName !== 'Id' && fieldName !== 'RecordTypeId') {
        if (fieldName !== 'FirstName' && fieldName !== 'LastName') columns.push({ label: 'Email', fieldName: fieldName, type: 'text' });
        if (fieldName === 'FirstName') columns.push({ label: 'FirstName', fieldName: fieldName, type: 'text' });
        if (fieldName === 'LastName') columns.push({ label: 'LastName', fieldName: fieldName, type: 'text' });
      }
      if (RecordType === '' && fieldName !== 'RecordType' && fieldName !== 'Id' && fieldName !== 'RecordTypeId') {
        columns.push({
          label: fieldName,
          fieldName: fieldName,
          type: 'text'
        });
      }
    }
    return columns;
  }
  hideModal() {
    this.ShowSpinner = false;
    this.isOpen = false;
    this.byPassAccountSelection = true;
  }
  save() {
    this.ShowSpinner = false;
    this.isOpen = false;
    this.dialogueOpened = true;
    this.byPassAccountSelection = true;
    let nameSpace = this.namespaceVar;
    console.log('selectedAccountRecords ' + JSON.stringify(this.selectedAccountRecords))
    for(const selectfields in this.selectedAccountRecords) {
      for (const key in this.AccountCreationFields){
        if(selectfields === this.AccountCreationFields[key][`${nameSpace}Account_RecordTypeName__c`] && this.selectedAccountRecords[selectfields] !== null){
          console.log('inputField ' +selectfields);
          let inputField = this.template.querySelector(
            `lightning-input-field[data-field="${this.AccountCreationFields[key][`${nameSpace}Source_Reference_Field__c`]}"]`
          );
          inputField.value = this.selectedAccountRecords[selectfields];
          console.log('inputField ' + JSON.stringify(inputField))
          this.handleLookUpValues(this.AccountCreationFields[key][`${nameSpace}Source_Reference_Field__c`],inputField.value);
        }
      }
    }

  }
  get officeColumns() {
    return this.showOffice ? this.generateColumns(this.officeContactRecords[0], '') : columns;
  }
  get facilityColumns() {
    return this.showFacility ? this.generateColumns(this.FacilityContactRecords[0], '') : columns;
  }
  get prescriberColumns() {
    return this.showPrescriber ? this.generateColumns(this.PrescriberDelegateRecords[0], '') : columns;
  }
  get HCSColumns() {
    return this.showHCS ? this.generateColumns(this.HCSRecords[0], 'Pharmacy_Participant') : columns;
  }
  get PrescriberSubColumns() {
    return this.showPrescSubSt ? this.generateColumns(this.prescriberRecords[0], 'Prescriber') : columns;
  }
  getUniqueAccountFields(storeAccountFieldValues) {
    let uni = {};
    let uniqueKeys = storeAccountFieldValues.filter(obj => {
      if (!uni[obj.fieldApiName]) {
        uni[obj.fieldApiName] = true;
        return true;
      }
      return false;
    });
    return uniqueKeys;
  }

  getCaseCreateRecord(fields, recordtypeId, accountId) {
    createRecord({
      apiName: "Case",
      fields: { ...fields, RecordTypeId: recordtypeId }
    })
      .then((result) => {
        updateCase({ caseRecordId: result.id, accountId: accountId })
        // Further actions after creating the record
      })
      .catch((error) => {
        console.log('Error ' + error)
        this.stopCreation = true;
      });
  }

  async handleSubmit(event) {
    event.preventDefault();
    if (this.checkNPIDuplicateFound) {
      this.showToastNotification(
        "Error",
        "Account already exist with the same NPI",
        "Error"
      );
    }
    if (this.isInputValid() && !this.checkNPIDuplicateFound && !this.isOpen) {
      const fields = event.detail.fields;
      let nameSpace = this.namespaceVar;
      let npiOverrideField = `${nameSpace}NPI_Override_Comments__c`;
      if(this.npiOverrideReset){
        fields[npiOverrideField] = null;
      }
      if (!this.byPassAccountSelection) {
        const getprogram = await this.getProgramData();
        const resposnse = await this.getDuplicateAccounts(fields);
      }
      if (this.byPassAccountSelection && !this.isOpen && !this.dialogueOpened) {
        await createSubStakeHolderAccounts({ fieldMapValue: this.storeAccountFieldValues, RequestRecordType: this.requestorType, programId: this.programId, programName: this.programName })
          .then((result) => {
            if (result) {
              console.log('resultcreateSubStakeHolderAccounts ' + JSON.stringify(result));
              for (const key in result) {
                const array = key.split('-');
                console.log('array ' + array[0] + '>> ' + result[key])
                fields[array[0]] = result[key];
                this.getCaseCreateRecord(fields, array[1], result[key]);
              }
              // fields['US_WSREMS__Knowledge_Assessment__c'] = 'Not Started';
            }
          })
          .catch((error) => {
            this.showToastNotification(
              "Error",
              reduceErrors(error).join(", "),
              "Error"
            );
            this.stopCreation = true;
          });
      }
      this.template.querySelector('lightning-record-edit-form').submit(fields);
    } else if (!this.isInputValid()) {
      this.showToastNotification('Error', this.label.validationCheckForAllFields, 'Error');
    }
  }
  async handleSuccess(event) {
    const relatedDocument = await relatedContentDocument({'caseId':event.detail.id,'listContentDocumentId':Array.from( this.contentVersion?.keys() ) }); 
    if( Object.keys(this.substakeHolderUpdateList).length>0){
      updateSubstakeholderData({
                                caseId:this.recordId,
                                parentFldSet:this.substakeHolderUpdateList,
                                programName:this.programName,
                                requestorTypeName:this.requestorTypeName,
                                recordTypeName: this.recordTypeApiName
                              });
    }
    if (!this.url.includes('DocumentReview')) {
      if (this.isInputValid() && !this.stopCreation && !this.isOpen) {
        this.handleCloseAction();
        this.showToastNotification('Success', this.label.RECORD_SUBMITTED, 'Success');
        if(this.pageName && this.pageName.includes('Outbound_Call')){
          this.navigateToRecordDetailPage();
        }
        else{
        location.reload();
        }
      } else if (!this.isInputValid()) {
        this.showToastNotification('Error', this.label.validationCheckForAllFields, 'Error');
      }
    } else if (!this.stopCreation && !this.isOpen) {
      if (this.isInputValid()) {
        this.handleCloseAction();
        this.showToastNotification('Success', this.label.RECORD_SUBMITTED, 'Success');
        this.navigateToRecordDetailPage();
      } else {
        this.showToastNotification('Error', this.label.validationCheckForAllFields, 'Error');
      }
    }


  }

  handleExpandAll() {
    this.expandButton = false;
    this.setActiveSectionsList = [...this.activeSectionsList];
  }

  handleCollapseAll() {
    this.expandButton = true;
    this.setActiveSectionsList = [];
  }


  async navigateToRecordDetailPage() {
    const recordId = this.recordId;
    this.closeQuickSubtab(recordId);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: 'view'
      }
    });
  }

  invokeWorkspaceAPI(methodName, methodArgs) {
    return new Promise((resolve, reject) => {
      const apiEvent = new CustomEvent("internalapievent", {
        bubbles: true,
        composed: true,
        cancelable: false,
        detail: {
          category: "workspaceAPI",
          methodName: methodName,
          methodArgs: methodArgs,
          callback: (err, response) => {
            if (err) {
              return reject(err);

            } else {
              return resolve(response);
            }
          }
        }
      });

      this.dispatchEvent(apiEvent);
    });
  }


  async closeQuickSubtab(result) {
    this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
      console.log('WorkspaceAPI: isConsole: ', isConsole);
      if (isConsole) {
        this.invokeWorkspaceAPI('getFocusedTabInfo').then(async focusedTab => {
          openTab({ recordId: result, focus: true })
            .then(_ => {
              this.invokeWorkspaceAPI('closeTab', {
                tabId: focusedTab.tabId,
              })
            })
            .catch(error =>
              this.showToastNotification('Error', reduceErrors(error).join(', '), 'Error')
            );
        });
      }
    });
  }
  validateAge (){
    let nameSpace = this.namespaceVar;
    let DOBField = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Patient_DOB__c"]`);
    let ageField = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Age__c"]`);
    const ageFldVal = this.template.querySelector(`[title="${nameSpace}Age__c"]`);
    if(DOBField.value || ageField.value){
      ageField.classList.remove('slds-has-error');
      ageFldVal.value = ''; 
      ageFldVal.classList.add('slds-hide');
      if(DOBField.value){
        ageField.disabled = true;
      }else{
        ageField.disabled = false;
      }

    }else{
      ageField.disabled = false;
      ageField.classList.add('slds-has-error');
      ageFldVal.classList.remove('slds-hide');
      ageFldVal.value = this.label.Age_validation_Messageval;     
    }

  }

  validateUnknown (){
    let nameSpace = this.namespaceVar;
    let UnknownFld = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Unknown__c"]`);
    let firstNameFld = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}First_Name_ar__c"]`);
    let LastNameFld = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Last_Name_ar__c"]`);
    const FirstNameErrFld = this.template.querySelector(`[title="${nameSpace}First_Name_ar__c"]`);
    const LastNameErrFld = this.template.querySelector(`[title="${nameSpace}Last_Name_ar__c"]`);
    const namePatterns = /^[A-Za-z'. -]+$/;
    if(UnknownFld){
        firstNameFld.classList.remove('slds-has-error');
        FirstNameErrFld.value = ''; 
        FirstNameErrFld.classList.add('slds-hide');
      if(UnknownFld.value){
        if(firstNameFld && !firstNameFld.value){
          firstNameFld.classList.add('slds-has-error');
          FirstNameErrFld.classList.remove('slds-hide');
          FirstNameErrFld.value = this.label.casePickListValidation;  
        }
      }
    }
    if(LastNameFld){
      LastNameFld.classList.remove('slds-has-error');
      LastNameErrFld.value = ''; 
      LastNameErrFld.classList.add('slds-hide');
      if((LastNameFld.value && !LastNameFld.value.match(namePatterns))){
        LastNameFld.classList.add('slds-has-error');
        LastNameErrFld.classList.remove('slds-hide');
        LastNameErrFld.value = this.label.nameCaseValidationMsg;
      }else if(UnknownFld && UnknownFld.value && !LastNameFld.value){
        LastNameFld.classList.add('slds-has-error');
        LastNameErrFld.classList.remove('slds-hide');
        LastNameErrFld.value = this.label.casePickListValidation; 
      }
    }
  }


validateDuplicateDataInForm(fieldName,fieldValue){
  var nameSpace = this.namespaceVar;
  let duplicateCheckFields = [];
    duplicateCheckFields = this.duplicatedataFldList[fieldName].split('#');
    var ErrorMessage;
    for(var fld in duplicateCheckFields){
      var dupdatafieldLabel = duplicateCheckFields[fld].split(':')[0];
      var dupdatafieldName = duplicateCheckFields[fld].split(':')[1];
      var dupnamewithNS = nameSpace+dupdatafieldName;
      let duplicateCheckRefFields;
      var dupRefErrLabel;
      var dupRefErrMsg;
      if(this.duplicatedataFldList[dupnamewithNS]){
        duplicateCheckRefFields = this.duplicatedataFldList[dupnamewithNS].split('#');
        for(var refFld in duplicateCheckRefFields){
          var dupCheckRefFldName = nameSpace+duplicateCheckRefFields[refFld].split(':')[1];
          if(dupCheckRefFldName == fieldName){
            dupRefErrLabel =  duplicateCheckRefFields[refFld].split(':')[0];
            dupRefErrMsg = this.label.duplicateEmailError+' '+dupRefErrLabel+'\n';
          }
        }
      }
      let dupDataFld = this.template.querySelector(
        `lightning-input-field[data-field="${nameSpace}${dupdatafieldName}"]`
      );
      if(dupDataFld && dupDataFld.value ){
        if(dupDataFld.value == fieldValue){
        if(!ErrorMessage){
          ErrorMessage = this.label.duplicateEmailError+' '+dupdatafieldLabel+'\n';
        }else{
          ErrorMessage = ErrorMessage+this.label.duplicateEmailError+' '+dupdatafieldLabel+'\n';
        }
      }else{
        let dupRefFldObj = this.template.querySelector(`lightning-input-field[data-field="${dupnamewithNS}"]`);
        const dupRefFldErrObj = this.template.querySelector(`[title="${dupnamewithNS}"]`);
        if(dupRefFldErrObj.value){
          dupRefFldErrObj.value = dupRefFldErrObj.value.replace(dupRefErrMsg,'');
        }else{
          dupRefFldErrObj.value = '';
        }
        if(!dupRefFldErrObj.value){
          dupRefFldObj.classList.remove('slds-has-error');
          dupRefFldErrObj.classList.add('slds-hide');
        }
      }
      }

    }
    return ErrorMessage;
  }

  async handleInputFocusOut(event){
    let nameSpace = this.namespaceVar;
    const fieldName = event.target.fieldName;
    const fieldValue = event.target.value;
    this.handleDuplicateConfigs(fieldName,fieldValue);
  }

  handleDuplicateConfigs(fieldName,fieldValue){
    if(this.duplicatedataConfigList && this.duplicatedataConfigList.hasOwnProperty(fieldName)){
      var dupConfig = this.duplicatedataConfigList[fieldName];
      if(dupConfig['fieldvalue'] != fieldValue){
        dupConfig['fieldvalue'] = fieldValue;
        var parentrefFldObj = dupConfig['duplicateParentRef'];
        let parentFld = this.template.querySelector(
          `lightning-input-field[data-field="${parentrefFldObj}"]`
        );
        var emailObj = {fieldName:dupConfig};
        if(parentFld && parentFld.value){
          this.validateDuplicateEmail(emailObj,parentFld,dupConfig['duplicateAffPrimaryPtcpant'],dupConfig['duplicateParentEmailMap']);
        }
      }
    }
}
  async validateDuplicateEmail(emailObj,parentFld,affPrimaryprtcpnt,parentEmailMap){
    let duplicateEmailList = await duplicateEmailCheck({
      duplicateConfigs:emailObj,
      parentAccountId: parentFld.value,
      affPrimaryRef:affPrimaryprtcpnt,
      emailMap:parentEmailMap
    });
    for(var emailField in duplicateEmailList){
      var fieldLabel = emailField;
      var errorMap = duplicateEmailList[emailField];
      let emailFld = this.template.querySelector(`lightning-input-field[data-field="${fieldLabel}"]`);
      const emailErrFld = this.template.querySelector(`[title="${fieldLabel}"]`);
      emailFld.classList.add('slds-has-error');
      emailErrFld.classList.remove('slds-hide');
      if(emailErrFld.value){
        emailErrFld.value = emailErrFld.value+this.label.duplicateEmailError+' '+errorMap;
      }else{  
        emailErrFld.value = this.label.duplicateEmailError+' '+errorMap;
      }
    }
      
  }

  removeDuplicateErrorMessage(duplicateEmailList){
    for(var dupFieldName in duplicateEmailList){
      let emailFld = this.template.querySelector(`lightning-input-field[data-field="${dupFieldName}"]`);
      const emailErrFld = this.template.querySelector(`[title="${dupFieldName}"]`);
      if(emailErrFld.value.includes(this.label.duplicateEmailError)){
        emailErrFld.value = '';
        emailErrFld.classList.add('slds-hide');
        emailFld.classList.remove('slds-has-error');
      }
    }      
  }

}