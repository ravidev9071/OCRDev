import { LightningElement, track, api, wire } from "lwc";
  // Apex methods
  import getNameSpace from "@salesforce/apex/OCRFormCtrl.getNameSpace";
  import getPermissionSets from "@salesforce/apex/OCRFormCtrl.getPermissionSets";
  import getAccountfieldMapping from "@salesforce/apex/OCRRemsAccountCreation.getAccountfieldMapping";
  import getStakeHolderStatus from '@salesforce/apex/OCRRemsAccountCreation.getStakeHolderStatus';
  import checkDuplicate from "@salesforce/apex/OCRRemsAccountCreation.checkDuplicate";
  import createSubStakeHolderAccounts from "@salesforce/apex/OCRRemsAccountCreation.createSubStakeHolderAccounts";
  import getAssessmentResponse from "@salesforce/apex/OCRFormCtrl.getAssessmentResponse";
  import primaryARDetails from "@salesforce/apex/OCRFormCtrl.getPrimaryARDetails";
  import getReadonlyFields from "@salesforce/apex/OCRFormCtrl.getReadOnlyFields";
  import getStageHeaderDetails from '@salesforce/apex/OCRFormCtrl.getStageHeaderDetails';
  import createAccount from "@salesforce/apex/OCRFormCtrl.createAccount";
  import getProgramList from "@salesforce/apex/REMSUtils.getCurrentUserPrograms";
  import updateSubstakeholderData from "@salesforce/apex/OCRFormCtrl.updateSubstakeholder";
  import getCasesForStakeholder from "@salesforce/apex/OCRFormCtrl.getCasesForStakeholder";
  import getAccountData from '@salesforce/apex/OCRFormCtrl.getStakeholderrecord';
  import getRecordTypeMap from '@salesforce/apex/OCRFormCtrl.getRecordTypeMap';
  import createARAccount from "@salesforce/apex/OCRFormCtrl.createARAccount";
  import getServiceCreation from "@salesforce/apex/OCRFormCtrl.getServiceCreation";
  import validateNpiStatus from "@salesforce/apex/OCRFormCtrl.validateNpiStatus";
  import checkNPIDuplicate from "@salesforce/apex/OCRFormCtrl.checkNPIDuplicate";
  import createEnrollmentService from "@salesforce/apex/OCRFormCtrl.createEnrollmentService";
  import updateCase from "@salesforce/apex/OCRFormCtrl.updateCase";
  import fetchRecordTypeId from "@salesforce/apex/OCRFormCtrl.fetchRecordTypeId";
  import getCaseFieldAndValueMap from "@salesforce/apex/OCRFormCtrl.getCaseFieldAndValueMap";
  import retrieveCasePrograms from "@salesforce/apex/REMSUtils.getAllCaseProgramLinkedToCase";
  import getServiceConfigRecords from "@salesforce/apex/OCRFormCtrl.getServiceConfigRecords";

  import { createRecord, updateRecord } from "lightning/uiRecordApi";
  import { openTab,refreshTab } from "lightning/platformWorkspaceApi";

  //custom label
  import { ShowToastEvent } from "lightning/platformShowToastEvent";
  import accountErrorMsg from "@salesforce/label/c.AccountErrorMsg";
  import accountSuccessfullyMsg from "@salesforce/label/c.AccountSuccessfullyMsg";
  import casePickListValidation from "@salesforce/label/c.Case_PickList_Validation";
  import nameCaseValidationMsg from "@salesforce/label/c.Name_Case_Validation_Msg";
  import validationCheckForAllFields from "@salesforce/label/c.Validation_Check_For_All_Fields";
  import handlerowActionMsg from "@salesforce/label/c.handlerowActionMsg";
  import casesoftrequiredfieldsMsg from "@salesforce/label/c.casesoftrequiredfields";
  import Non_compliance_service_typeMsg from "@salesforce/label/c.Non_compliance_service_type";
  import Non_compliance_confirmation_msgval from "@salesforce/label/c.Non_compliance_confirmation_msg";
  import Non_Compliance_Activityval from "@salesforce/label/c.Non_Compliance_Activity";
  import Age_validation_Messageval from "@salesforce/label/c.Age_validation_Message";
  import Account_already_exist_with_the_same_NPI from "@salesforce/label/c.Account_already_exist_with_the_same_NPI";
  import Duplicate_NPI_Found_Do_you_still_want_to_proceed from "@salesforce/label/c.Duplicate_NPI_Found_Do_you_still_want_to_proceed";

  import LightningConfirm from 'lightning/confirm';
  import { reduceErrors,doDataCals, getCaseIncompleteValidationConfigs,getdataMappingConfigs,reSubmitChildObjects,sendPaeEmail } from "c/utils";
  import { CurrentPageReference } from 'lightning/navigation';
  import kaDuplicateError from "@salesforce/label/c.KA_duplicate_Case_Error";
  import { NavigationMixin } from 'lightning/navigation';

  export default class StakeHolderServiceCaseOcr extends NavigationMixin(LightningElement) {
    @api selectedValue;
    @api recordTypeName;
    @api participantType;
    @api callingFrom;
    @api outboundCallPhone;
    @api taskId;
    @api incontactId;
    @track phoneValue;
    @track DNIS;
    @track ivrpromptcode;
    @track direction;
    @track contacttype;
    @track contactid;
    @track callstarttime;
    readonlyFieldsList=[];
    phoneFieldsList = [];
    duplicateAccColumns = [];
    duplicatesFound = false;
    recordTypeMapping=new Map();       
    duplicateAccRecs = [];
    label = {
      accountErrorMsg,
      accountSuccessfullyMsg,
      
      casePickListValidation,
      nameCaseValidationMsg,
      validationCheckForAllFields,
      handlerowActionMsg,
      casesoftrequiredfieldsMsg,
      Non_compliance_service_typeMsg,
      Non_compliance_confirmation_msgval,
      Non_Compliance_Activityval,
      Age_validation_Messageval,
      Account_already_exist_with_the_same_NPI,
      Duplicate_NPI_Found_Do_you_still_want_to_proceed,
      kaDuplicateError
        };
    @api showAccountOption;
    accountCreationForm = true;
    ShowSpinner = true;
    serviceConfig;
    serviceFields = [];
    fieldValues = [];
    activeSectionsList = [];
    caseRecordId;
    @track
    draftCaseId;
    draftServiceId;
    expandButton = true;
    setActiveSectionsList = [];
    requeried;
    programId;
    programName;
    headerTitle;
    orginalData = [];
    showUI = false;
    isFirst = false;
    accountAvailable = false ;
    knowledgeAssesmentPassFail;
    @api serviceType;
    @api accountId;
    secondCaseId;
    storeRecordMap = {};
    defaultPicklistValue = 'Email';
    serviceConfigRecord = {};
    @api currentUserProgramName;
    secondService;
    namespaceVar;
    userPermissionSets;
    storeAccountFieldValues =[];
    isOpen = false;
    officeContactRecords =[];
    synAuthReps=[];
    PrescriberDelegateRecords =[];
    FacilityContactRecords = [];
    HCSRecords = [];
    PRESCRIBERRecords = [];
    byPassAccountSelection = false;
    showOffice = false
    showPrescriber = false
    showFacility = false
    showHCS = false;
    showsynAuthReps=false;
    showPrescriberSt = false;
    stopCreation = false;
    @api metadata;
    fetchedNpiStatus;
    serviceName;
    uploadedFiles = [];
    contentVersion = new Map();
    fieldmappingconfigmap = new Map();
    substakeHolderUpdateList = {};
    skipDupcheck = false;
    impactedStakeholderAccId;
    agecalFields = [];
    @track fields;
    recordTypeData;
    overrideRequestorType=false;
    @track mainstakeDupColumns = [];
    @track mainstakeDupAccounts = [];
    
    @track showMainstakeDupModal = false;
    mainstakeHolderType = 'Account';
    newParent;
    mapData = new Map();
    allowDuplicateNPI = false;
    fileBoolean;
    fileDisplay = false;
    documentCheckListId;
    duplicatedataFldList = [];
    duplicatedataConfigList = [];
    caseNumbers;
    mainStakeHolderStatus;
    stopHandleSuccessExec = false;
    formObjects=[];
    objectsSubmitted=[];
    objectParentFieldAPIMap = {};
    datacalMappingConfigs;
    validationMsgMap;    
    caseProgId;

    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
      if (currentPageReference) {
          let attributes = currentPageReference.attributes;
          let pageName = attributes.apiName;
          this.phoneValue = currentPageReference.state.c__ANI;
          this.DNIS = currentPageReference.state.c__DNIS;
          this.ivrpromptcode = currentPageReference.state.c__ivrpromptcode;
          this.direction = currentPageReference.state.c__direction;
          this.contacttype = currentPageReference.state.c__contacttype;
          this.contactid = currentPageReference.state.c__contactid;
          this.callstarttime = currentPageReference.state.c__callstarttime;
          this.handleNameSpace();
      }
    }
   
  
    @api serviceFromAccount;
    @wire (getAccountfieldMapping) AccountCreationMetaData;

  @api showPopup = false;
    async connectedCallback() {
      this.handleGetPermissionSets();
      await this.handleNameSpace();
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
  handleGetPermissionSets(){
      getPermissionSets({})
        .then((result) => {
          this.userPermissionSets =result;
        })
        .catch((error) => {
          this.showToastNotification(
            "Error",
            reduceErrors(error).join(", "),
            "Error"
          );
        });
      }
 

    async handleNameSpace(){
      await getNameSpace({})
        .then((result) => {
          this.namespaceVar =result;
        })
        .catch((error) => {
          this.showToastNotification(
            "Error",
            reduceErrors(error).join(", "),
            "Error"
          );
        });
      }

    

    preFillCaseLayout = async (event) => {
      let nameSpace = this.namespaceVar;
      if(this.phoneFieldsList != null){
        for(const s of this.phoneFieldsList){
          var fldNameKey = s;
          let Phone = this.template.querySelector(
        `lightning-input-field[data-field="${fldNameKey}"]`
      );
      if (Phone != null && this.phoneValue != null) {
        Phone.value = this.phoneValue;
      }
        
        }
      }
      
      let result = await this.fetchFieldValues(this.accountId, this.serviceConfigRecord[`${nameSpace}Participant_Field__c`], this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`]);
      if (result) {
        if (this.accountId) {
          await this.handleKnowledgeAssesmentPassFail(this.accountId)
        }
        if(this.substakeHolderUpdateList.hasOwnProperty(this.serviceConfigRecord[`${nameSpace}Participant_Field__c`])){
          this.substakeHolderUpdateList[this.serviceConfigRecord[`${nameSpace}Participant_Field__c`]]=this.accountId;
        }
        try {
          this.mapData = new Map(Object.entries(result));
          let response = Object.fromEntries(this.mapData);
          const hasNPIOverridePermission = this.userPermissionSets.includes('REMS_NPI_Override');

          for (const key in this.serviceFields) {
            this.serviceFields[key]['sectionVal'].forEach((element) => {
              element.value.forEach((item) => {
                if(!(item.dependentField && this.skipFieldVisibility && !response.hasOwnProperty(item.dependentField))){
                  item.visible = true;
                }

                if (hasNPIOverridePermission && item.fieldName === `${nameSpace}NPI_Status__c`) {
                  item.editable = false;
                }
                if(this.userPermissionSets.includes(item.permissionSet)){
                  item.editable = false;
                }
              });
            });
          }

          if (this.isInboundOutboundCall) {
            var fldNameKey = `${nameSpace}` + 'Same_as_Account__c';
            var fldNameKey2 = `${nameSpace}` + 'Requestor_Type__c';
            var fldNameKey3 = `${nameSpace}` + 'Rems_InContactID__c';
          
              let sameasinputField = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKey}"]`
            );
            let sameasParticipantField = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKey2}"]`
            );
            let InContactIdField = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKey3}"]`
            );
          
            if (sameasinputField != null) {
              sameasinputField.value = true;}
              if (sameasinputField != null) {
              sameasParticipantField.value =  this.participantType;
            }
            if (InContactIdField != null && this.incontactId != null) {
              InContactIdField.value = this.incontactId;
            }
          }
          if(this.serviceConfigRecord[`${nameSpace}Validate_AR_Info__c`]) {
              let arInfo = await primaryARDetails({
                accountId: this.accountId,
                caseRecordtypeName: this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`],
                programName: this.programName
              });
              if(arInfo){
                  for (var arkey in arInfo) {
                    var fldNameKey = `${nameSpace}`+arkey;
                    let arinputField = this.template.querySelector(
                      `lightning-input-field[data-field="${fldNameKey}"]`
                    );
                    if(arinputField!= null){
                      arinputField.value = arInfo[arkey];
                    }
                    this.handleLookUpValues(fldNameKey,arInfo[arkey],event);
                  }
              }
          }
          if(event!==''){setTimeout(_ => this.asyncUpdatePrimaryFieldValues(event),100);}
        } catch (ex) {
          console.log('exception ==>' + ex);
        }
      }
    };

    handleServiceCreation() {
      let nameSpace = this.namespaceVar;
      getServiceConfigRecords({
        participantType: this.participantType,
        serviceType: this.serviceType,
        programName: this.currentUserProgramName
      })
        .then((result) => {
          this.serviceConfigRecord =result;
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

       getReadonlyFields({objectName:this.serviceConfigRecord[`${this.namespaceVar}Object__c`]}).then((result) => {
        this.readOnlyFieldsList =result;
          getRecordTypeMap({sourceRecordType:this.serviceConfigRecord[`${this.namespaceVar}Account_Record_Type__c`],programName:this.currentUserProgramName}).then((result)=>{
           this.recordTypeMapping=result;
        })
       });
 
        getServiceCreation({serviceConfigObj: this.serviceConfigRecord,documentCheckListId:this.documentCheckListId
        })
          .then((result) => {
            let nameSpace = this.namespaceVar;
            let hasNPIOverridePermission;
            this.showUI = true;
            this.ShowSpinner = true;          
            var currentUrl = window.location.href;
            this.orginalData = JSON.parse(JSON.stringify(result));
            let sections = [];
            if(!this.accountId){
              if(this.userPermissionSets){
                hasNPIOverridePermission = this.userPermissionSets.includes('REMS_NPI_Override');
              }
            }
            
            if(currentUrl.includes('DocumentReview')){
              let documentURL = new URL(currentUrl).searchParams;
              this.documentCheckListId = documentURL.get('uid');
            }

            this.serviceConfig = this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`];
            this.headerTitle = this.serviceConfigRecord[`${nameSpace}Title__c`];
            this.serviceName = this.serviceConfigRecord[`${nameSpace}Service_Type__c`];
            this.fileBoolean = this.serviceConfigRecord[`${nameSpace}Upload_Attachments__c`];
            this.skipDupcheck = this.serviceConfigRecord[`${nameSpace}Validate_Dupcheck__c`];

            this.overrideRequestorType = this.serviceConfigRecord[`${nameSpace}Override_Requestor_Type__c`];
            if(this.fileBoolean = true){
              this.fileDisplay = true;
            }
            let returnedData;
            let recordTypeName =this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`];;
            console.log('recordTypeName : ',recordTypeName);
            this.getRecordTypeDataHandler(recordTypeName, "Case")
              .then((result) => {
                 returnedData =result;
                this.recordTypeData = returnedData;
                for(const objectName in this.orginalData){
                var objectMap = JSON.parse(objectName);
                  let arrayMapKeys = [];    
                  for (const key in this.orginalData[objectName]) {    
                    this.orginalData[objectName][key].forEach((element) => {
                      if(element.fieldName ){              
                        if(element.disableRelatedFields)
                          this.fieldmappingconfigmap.set(element.fieldName,element.disableRelatedFields);
              
                        if(element.updateRelatedFields)
                          this.substakeHolderUpdateList[element.fieldName]=element.updateRelatedFields;
              
                        if(element.reParent)
                          this.newParent = element.fieldName;
              
                        if(this.accountId){
                          if(element.fieldDataType ==='Phone'){
                            var fieldName = element.fieldName;
                            this.phoneFieldsList.push(fieldName);
                            }
                        }
                      }
                        if(this.userPermissionSets && element.permissionSet && this.userPermissionSets.includes(element.permissionSet)){
                          element.editable = false;
                        }
                      if(!this.accountId){
                        
                        if (element.dependentField !== undefined && element.dependentField !== null && element.dependentField !== "" ) {
                          element.visible = false;
                        }else if (hasNPIOverridePermission && element.fieldName === `${nameSpace}NPI_Status__c`) {
                        element.editable = false;
                        }
                      }
                      if (currentUrl.includes('DocumentReview') || this.serviceFromAccount) {
                         if (element.fieldName === `${nameSpace}Channel__c` && objectMap.objectName == 'Case') {
                            element.fieldValue = 'Fax';
                          }
                        }
                        this.fieldValues.push(element);
                    });
                    arrayMapKeys.push({'key':key,'value': this.orginalData[objectName][key]});
                    
                    sections.push(key);
                  }
                    if(objectMap.objectName == 'Case' && objectMap.additionalInfoSec==false){
                      objectMap['recordTypeId'] = returnedData;
                      objectMap['topborder'] = true;
                    }else{
                      objectMap['topborder'] = false;
                      this.objectParentFieldAPIMap[objectMap.objectName+objectMap.recordTypeId] = {'Case':objectMap.caseApi,'Account':objectMap.accountApi,'Program':objectMap.programApi};
                    }
                    this.serviceFields.push({'Object':objectMap.objectName,'recordTypeId':objectMap.recordTypeId,'topborder':objectMap.topborder,'caseField':objectMap.caseApi,'accountField':objectMap.accountApi,'additionalSec':objectMap.additionalInfoSec,'sectionVal':arrayMapKeys});
                    this.formObjects.push(objectName);
                }
                
                this.requeried = this.fieldValues.map((value) => value.required);
                this.activeSectionsList = sections;
                this.handleExpandAll();
                this.handleCollapseAll();
              })
              .catch((error) => {
                
                console.log('arrayMapKerroreys:: ',error);
                this.showToastNotification(
                  "Error",
                  reduceErrors(error).join(", "),
                  "Error"
                );
              });
            //this.recordTypeData = returnedData;
            getdataMappingConfigs(this,this.currentUserProgramName, this.participantType, this.serviceConfig);
            getCaseIncompleteValidationConfigs (this,this.currentUserProgramName,this.serviceConfig);
            this.ShowSpinner = false;
            this.handleProgramChange();
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
      if (!this.isFirst) {
        setTimeout(() => {
          var record = event.detail.records;
          var fields;
          if(record && record[this.recordId] && record[this.recordId].fields){
            fields = record[this.recordId].fields;
          
          for (const key in this.serviceFields) {
            this.serviceFields[key]['sectionVal'].forEach((element) => {
              element.value.forEach((element) => {
                if (
                  element.dependentField !== undefined &&
                  element.dependentField !== null &&
                  element.dependentField !== ""
                ) {
                  if (
                    fields.hasOwnProperty(element.dependentField) &&
                    element.dependentValue !== undefined &&
                    element.dependentValue !== "" &&
                    element.dependentValue ===
                    fields[element.dependentField].value
                  ) {
                    element.visible = true;
                  } else {
                    element.visible = false;
                  }
                }
              });
            });

            let nameSpace = this.namespaceVar;
            let key = [`${nameSpace}Preferred_Contact_Method__c`] ;
            let inputField = this.template.querySelector(
              `lightning-input-field[data-field="${key}"]`
            );
            inputField.value = this.defaultPicklistValue;
            this.isFirst = true;
          }
          }
        }, 500);
      }
    }

    handleProgramChange() {
      getProgramList()
        .then((result) => {
          let nameSpace = this.namespaceVar;
          this.programId = result[0][`${nameSpace}REMS_Program__c`];
          this.programName = result[0][`${nameSpace}REMS_Program__r`][`Name`];
          if (this.serviceType && this.participantType) {
            if(this.accountId){
              this.preFillCaseLayout();
              if(this.isKAHCS){
                this.handleLookUpValues('REMS_Authorized_Rep__c',this.accountId,null)
              }
            }
          }
          if(this.outboundCallPhone && this.serviceType === 'Outbound_Communication'){
            let phoneField = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Phone__c"]`);
            phoneField.value = this.outboundCallPhone;
          }
          if(this.serviceConfigRecord[`${nameSpace}Service_Record_Type__c`] == 'Change_Authorized_Representative' && !this.isNullOrEmpty(this.accountId) ){
            this.serviceFields[1].value[0].fieldValue = this.accountId;
            this.handleLookUpValues(this.serviceFields[1].value[0].fieldName,this.accountId,null)
          }
          
        })
        .catch((error) => {
          this.showToastNotification(
            "Error",
            this.label.accountErrorMsg,
            "Error"
          );
        });
    }

    enrollmentRecordType;
    setNPIValue ='';
    checkNPIDuplicateFound = false;
    async handleDuplicateNPI(NPIValue, recordType, programName){
      await checkNPIDuplicate({ NPIValue : NPIValue, recordType:recordType, program:programName})
        .then(async(result) => {
          if(result){
            this.checkNPIDuplicateFound = true;
            if(this.checkNPIDuplicateFound && !this.accountId){
              if(this.allowDuplicateNPI){
                const result = await LightningConfirm.open({
                  message: this.label.Duplicate_NPI_Found_Do_you_still_want_to_proceed,
                  variant: 'headerless',
                  label: '',
                });
                if(result){
                  this.checkNPIDuplicateFound = false;
                }
              }else{
                this.showToastNotification(
                    "Error",
                    this.label.Account_already_exist_with_the_same_NPI,
                    "Error"
                );
              }
            }else{
              this.checkNPIDuplicateFound = false;
            }
          }
        })
        .catch(error => {
          this.checkNPIDuplicateFound = false;
        });

      }

      isObjectEmpty(obj) {
        // Check if the object is empty
        if (Object.keys(obj).length === 0) {
            return true;
        }

        // Check if any key is empty or undefined
        for (let key in obj) {
            if (obj[key].length != 0) {
                return false;
            }
        }

        return true;
    }
    isCaseOpen = false;
    async getCases(){
      await getCasesForStakeholder({accountId:this.accountId, serviceConfigObj : this.serviceConfigRecord})
        .then(result =>{
           this.caseNumbers = '';
          let caseNumberArray = [];
          for (let i = 0; i < result.length; i++) {
            if(result[i].Status=='Draft'){
              this.draftCaseId=result[i].Id;
              this.draftServiceId=result[i].US_WSREMS__REMS_Service_Summary__c;
            }else{
              this.isCaseOpen=true;
            }
            caseNumberArray.push(result[i].CaseNumber);
          }
          this.caseNumbers = caseNumberArray.toString();
        })
    }
    @track currentDuplicateConfigs;
    @track duplicateAccounts;
    async isDuplicateHoldersAvailable (fields){
      let nameSpace = this.namespaceVar;
      let serviceConfig = typeof this.serviceConfig == 'object'?this.serviceConfig: this.serviceConfigRecord;
      this.mainstakeHolderType = serviceConfig.Label || serviceConfig[`${nameSpace}Participant_Type__c`];
      this.currentDuplicateConfigs =await this.allMatchingDuplicateConfigs();
      this.duplicateAccounts = await checkDuplicate({duplicateConfig:JSON.stringify(this.currentDuplicateConfigs), fieldValues : fields, programId:this.programId});
      console.log('this.currentDuplicateConfigs:: ',JSON.stringify(this.currentDuplicateConfigs));
      console.log('this.isDuplicateHoldersAvailableisDuplicateHoldersAvailable:: ',JSON.stringify(this.duplicateAccounts));
      console.log('fieldVlaues: ',fields);
      this.generateDupColumns(this.currentDuplicateConfigs);
      this.OpenModelPopForDuplicateAccounts(this.duplicateAccounts);
    }
    generateDupColumns(configs){
      let participantColumnsMap = {
        "Pharmacy_Participant": "HCSColumns",
        "Facility_Account": "facilityColumns",
        "Office_Contact": "officeColumns",
        "Prescriber_Delegate": "prescriberColumns",
        "Prescriber":"prescriberColumns",
        "mainstake": "mainstakeDupColumns",
      };
      configs.forEach(config =>{
        let columns = JSON.parse(config[this.namespaceVar+'DataTable_Column__c']);
        columns.forEach(column =>{
          if((column.fieldName.toLowerCase()).indexOf('__c') !== -1){
            column.fieldName = this.namespaceVar+column.fieldName;
          }
        })
        let columnKey = config[this.namespaceVar+'Main_Stakeholder_Account__c']?'mainstake':config[this.namespaceVar+'Account_RecordTypeName__c'];
        this[participantColumnsMap[columnKey]] = columns;
      })
    }

      OpenModelPopForDuplicateAccounts(data){
        this.FacilityContactRecords = [];
        this.officeContactRecords = [];
        this.PrescriberDelegateRecords = [];
        this.HCSRecords = [];
        this.PRESCRIBERRecords = [];
        this.mainstakeDupAccounts = [];
        this.synAuthReps=[];
        for(const key of Object.keys(data)){
          if(key === 'mainstake' && data.hasOwnProperty('mainstake') && !this.accountId){
            this.mainstakeDupAccounts = data['mainstake']
          }else if(key === 'Office_Contact' && data.hasOwnProperty('Office_Contact')){
            this.officeContactRecords = data['Office_Contact']
          }else if(key ==='Facility_Account' &&  data.hasOwnProperty('Facility_Account')){
            this.FacilityContactRecords = data['Facility_Account']
          }else if(key ==='Prescriber_Delegate' &&  data.hasOwnProperty('Prescriber_Delegate')){
            this.PrescriberDelegateRecords = data['Prescriber_Delegate']
          }else if(key ==='Pharmacy_Participant' &&  data.hasOwnProperty('Pharmacy_Participant')){
            this.HCSRecords = data['Pharmacy_Participant']
          }else if(key ==='Prescriber' &&  data.hasOwnProperty('Prescriber')){
            this.PRESCRIBERRecords = data['Prescriber']
          }else if(key ==='SYN_Authorized_Rep__c' &&  data.hasOwnProperty('SYN_Authorized_Rep__c')){
            this.HCSRecords = data['SYN_Authorized_Rep__c']
          }

          }
        this.showFacility =  this.FacilityContactRecords.length > 0;
        this.showOffice = this.officeContactRecords.length > 0;
        this.showPrescriber = this.PrescriberDelegateRecords.length > 0;
        this.showHCS = this.HCSRecords.length > 0;
        this.showPrescriberSt = this.PRESCRIBERRecords.length > 0;
        this.showsynAuthReps=this.synAuthReps.length>0;
        this.showMainstakeDupModal = this.mainstakeDupAccounts.length > 0;
         this.isOpen = this.showFacility || this.showOffice || this.showPrescriber || this.showHCS || this.showMainstakeDupModal || this.showPrescriberSt;
        if(!this.isOpen){
          this.skipDupcheck = true;
          this.byPassAccountSelection = !this.isLooupPopulated;
          if(this.accountId && this.participantType && this.serviceType){
            this.recordTypeData = this.enrollmentRecordType;
          }
          for(let type in this.duplicateAccounts){
            console.log('Type:: '+type);
            const substakeConfig = this.currentDuplicateConfigs.filter((config) =>
                !config[this.namespaceVar + 'Main_Stakeholder_Account__c'] &&
                config[this.namespaceVar+'Account_RecordTypeName__c'] === type);

            if(substakeConfig.length > 0){
              let config = substakeConfig[0];
              this.createStakeHolder.push(config[`${this.namespaceVar}Source_Reference_Field__c`]);
            }
          }
        }
      }

      get isKAHCS(){
        return this.serviceType === 'Knowledge Assessment' && (this.participantType === 'Health Care Setting' || this.participantType === 'Outpatient Pharmacy');
      }

      get isKAPrescriber(){
        return this.serviceType === 'Knowledge Assessment' && this.participantType === 'Prescriber';
      }

      @track selectedDuplicateRecord={};
      handleRowSelection = event => {
        let targetId = event.target.dataset.targetId;
        let selectedRows = event.detail.selectedRows;
        console.log('Selected Rows: ',selectedRows);
        if(selectedRows.length > 0){
          this.selectedDuplicateRecord[targetId] = selectedRows[0];
        }
      }

      handleDuplicateRowSelection(event){
        var selectedRows=event.detail.selectedRows;
        if(selectedRows.length>0){
          this.accountId = selectedRows[0].Id;
          //Navigate function
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
        let nameSpace = this.namespaceVar;
        for (let fieldName in record) {
            if( RecordType ==='Pharmacy_Participant' && fieldName !== 'RecordType' && fieldName !== 'Id' && fieldName!=='RecordTypeId'){
              if(fieldName !=='FirstName' && fieldName !=='LastName') columns.push({label: 'Email',fieldName: fieldName,type: 'text'});
              if(fieldName ==='FirstName') columns.push({label: 'FirstName',fieldName: fieldName,type: 'text'});
              if(fieldName ==='LastName') columns.push({label: 'LastName',fieldName: fieldName,type: 'text'});

          }
          if(RecordType ==='' && fieldName !== 'RecordType' && fieldName !== 'Id' && fieldName!=='RecordTypeId'){
            if(fieldName === '${nameSpace}Email__c') {
              columns.push({label: 'Email',fieldName: fieldName,type: 'text'});
            }else{
              columns.push({label: fieldName,fieldName: fieldName,type: 'text'});
            }
          }
        }
        return columns;
      }
      async hideModal(){
        let mapping = {
          "mainstake": this.mainstakeHolderType,
          "Facility_Account": "Facility Account",
          "Prescriber_Delegate": "Prescriber Delegate",
          "Office_Contact": "Office Contact",
          "Pharmacy_Participant": "Pharmacy Participant",
          'synAuthReps':'Authorize Reps'
        }
        let nameSpace = this.namespaceVar;

        let isMainStakeNew = false;
        let isSubStakeNew = false;
        for (let type in this.duplicateAccounts) {

            if (type === 'mainstake' && this.showMainstakeDupModal) {
              this.accountId = '';
              isMainStakeNew = true;
            } else if (type !== 'mainstake'){
              if(this.serviceType === 'Knowledge Assessment') {
                this.accountId = '';
              }
              const substakeConfig = this.currentDuplicateConfigs.filter((config) =>
                  (!config[nameSpace + 'Main_Stakeholder_Account__c'] &&
                  config[nameSpace+'Account_RecordTypeName__c'] === type)||config[nameSpace+'Source_Reference_Field__c'] === type);
              this.createStakeHolder.push(substakeConfig[0][`${nameSpace}Source_Reference_Field__c`]);
              this.dupConfigIds.push(substakeConfig[0].Id);
              isSubStakeNew = true;
            }
          }


        const result = await LightningConfirm.open({
          message: "Are you sure, you want to continue with the account creation? It will create a potential duplicate records",
          variant: 'headerless',
          label: '',
          // setting theme would have no effect
        });
        if (result) {
          this.skipDupcheck = true;
          this.ShowSpinner = false;
          this.selectedDuplicateRecord = undefined;
          this.isOpen = false;
          this.byPassAccountSelection = isSubStakeNew;
        }

      }

      @track dupConfigIds = [];
      skipFieldVisibility = false;
      @track createStakeHolder = [];
      async save() {
        this.dupConfigIds = [];
        this.createStakeHolder = [];
        this.ShowSpinner = false;
        let nameSpace = this.namespaceVar;
        if (!this.selectedDuplicateRecord) {
          this.showToastNotification(
              "Error",
              "Please select at least one account",
              "Error"
          );
        } else {
          if (this.callingFrom === 'NewAccount') {
            this.mainstakeDupliatesFound = false;
            this.showMainstakeDupModal = false;
            this.closeQuickSubtab(this.selectedDuplicateRecord['mainstake'].Id);
            this.selectedDuplicateRecord = undefined;
          }
          else {
            let mapping = {
              "mainstake": this.mainstakeHolderType,
              "Facility_Account": "Facility Account",
              "Prescriber_Delegate": "Prescriber Delegate",
              "Office_Contact": "Office Contact",
              "Pharmacy_Participant": "Pharmacy Participant",
              "Prescriber":"Prescriber",
              'synAuthReps':'Authorized Reps'
            }
            let showConfirm = false;
            let confirmLabels = [];
            let isMainStakeNew = false;
            let isSubStakeNew = false;
            let selectedDupAccountTypes = Object.keys(this.selectedDuplicateRecord);
             for (let type in this.duplicateAccounts) {
              if(selectedDupAccountTypes.indexOf(type) === -1 && this.duplicateAccounts[type].length == 0){
                if(type !== 'mainstake'){
                  isSubStakeNew = true;
                }
              }else if (selectedDupAccountTypes.indexOf(type) === -1 && this.duplicateAccounts[type].length > 0) {
                showConfirm = true;
                confirmLabels.push(mapping[type]);
                if (type === 'mainstake') {
                  this.accountId = '';
                  isMainStakeNew = true;
                } else {
                  const substakeConfig = this.currentDuplicateConfigs.filter((config) =>
                      !config[nameSpace + 'Main_Stakeholder_Account__c'] &&
                      (config[nameSpace+'Account_RecordTypeName__c'] === type || config[`${nameSpace}Source_Reference_Field__c`] === type));
                  this.dupConfigIds.push(substakeConfig[0].Id);
                  isSubStakeNew = true;
                }
              } else if (type === 'mainstake' && this.duplicateAccounts[type].length > 0) {
                isMainStakeNew = false;
                this.checkNPIDuplicateFound = false;
                this.accountId = this.selectedDuplicateRecord[type].Id;
                let accountStatus=await getStakeHolderStatus({accountId:this.accountId}).then((result)=>{
                  return result;
                });
                 const result = await this.getCases()
               if(this.isCaseOpen) {
                  let message = this.serviceType === 'Knowledge Assessment'?kaDuplicateError+' ' + this.caseNumbers:"Account already exist with open case";
                  this.showToastNotification(
                      "Error",
                      message,
                      "Error"
                  );
                  return;
                }
                if(!this.validateEligibility(accountStatus)) {
                  let message ='Eligible Status can only '+this.serviceConfigRecord[`${nameSpace}Eligible_Status__c`];
                  this.showToastNotification(
                      "Error",
                      message,
                      "Error"
                  );
                  return;
                } 
              } else if(this.duplicateAccounts[type].length > 0) {
                if(this.serviceType === 'Knowledge Assessment') {
                  this.accountId = this.selectedDuplicateRecord[type].Id;
                 
                  const result = await this.getCases()
                  if (this.isCaseOpen) {
                    const kaDuplicateErrorWithCaseNumber = kaDuplicateError +' ' + this.caseNumbers;
                    this.showToastNotification( 
                        "Error",
                        kaDuplicateErrorWithCaseNumber,
                        "Error"
                    );
                    return;
                  }
                }

              }
            }
            let isConfirmed = false;
            if(showConfirm){
              const result = await LightningConfirm.open({
                message: "Are you sure, you want to continue with the account creation? It will create a potential duplicate records for "+confirmLabels.join(','),
                variant: 'headerless',
                label: '',
                // setting theme would have no effect
              });
              if(result){
                isConfirmed = true;
              }else{
                return;
              }
            }else{
              this.skipDupcheck = true;
            }
            if((showConfirm && isConfirmed) || this.skipDupcheck){
              for (let type in this.duplicateAccounts) {
               
                if (type === 'mainstake' && this.duplicateAccounts[type].length > 0 && !isMainStakeNew && !this.isCaseOpen) {
                  this.isCaseOpen = false;
                  this.recordTypeData = this.enrollmentRecordType;
                     const Configs = this.currentDuplicateConfigs.filter((config) =>
                        config[nameSpace + 'Main_Stakeholder_Account__c'] );
                    let config = Configs[0];

                    let sourceF=config[`${nameSpace}Source_Reference_Field__c`];
                    let source_fields=(sourceF.toLowerCase()!='syn_pharmacy__c' && sourceF.toLowerCase()!='syn_authorized_rep__c')?nameSpace + sourceF:sourceF;

                    let inputField = this.template.querySelector(
                        `lightning-input-field[data-field="${source_fields}"]`
                    );

                    if (inputField.fieldName === source_fields) {
                      inputField.value = this.selectedDuplicateRecord[type].Id;
                      await this.handleLookUpValues(source_fields, inputField.value, '');
                    }
                  
                }else if(this.duplicateAccounts[type].length > 0 && type !== 'mainstake') {
                  if(this.serviceType === 'Knowledge Assessment' && !this.isCaseOpen) {
                    this.isCaseOpen = false;
                    this.recordTypeData = this.enrollmentRecordType;
                  }
                  isSubStakeNew = false;
                  const substakeConfig = this.currentDuplicateConfigs.filter((config) =>
                      !config[nameSpace + 'Main_Stakeholder_Account__c'] &&
                  (config[nameSpace+'Account_RecordTypeName__c'] === type || config[`${nameSpace}Source_Reference_Field__c`] === type));
                  let config = substakeConfig[0];

                  let sourceF=config[`${nameSpace}Source_Reference_Field__c`];
                  let source_fields=(sourceF.toLowerCase()!='syn_pharmacy__c' && sourceF.toLowerCase()!='syn_authorized_rep__c')?nameSpace + sourceF:sourceF;
                  let inputField = this.template.querySelector(
                      `lightning-input-field[data-field="${source_fields}"]`
                  );

                  if(!this.selectedDuplicateRecord[type]){
                    this.createStakeHolder.push(config[`${nameSpace}Source_Reference_Field__c`]);
                  }
                  
                  if (this.selectedDuplicateRecord[type] && inputField.fieldName === source_fields) {
                    inputField.value = this.selectedDuplicateRecord[type].Id;
                    this.substakeHolderUpdateList[inputField.fieldName]=inputField.value;
                    await this.handleLookUpValues(source_fields, inputField.value, '');
                  }
                }
              }
            }
            this.byPassAccountSelection = isSubStakeNew || this.createStakeHolder.length !== 0;
          }
          if(!this.isCaseOpen){
            this.isOpen = false;
            this.skipDupcheck = true;
            this.selectedDuplicateRecord = undefined;
          }
        }
      }
      @track officeColumns = [];
      @track facilityColumns = [];
      @track prescriberColumns = [];
      @track HCSColumns = [];
      getUniqueAccountFields(storeAccountFieldValues){
        let uni ={};
        let uniqueKeys = storeAccountFieldValues.filter(obj =>{
          if(!uni[obj.fieldApiName]){
            uni[obj.fieldApiName] = true;
            return true;
          }
          return false;
        });
        return uniqueKeys;
      }

      async getCaseCreateRecord(fields,recordtypeId,accountId){
        await createRecord({
          apiName: "Case",
          fields: { ...fields, RecordTypeId: recordtypeId }
        })
          .then((result) => {
            updateCase({ caseRecordId: result.id, accountId: accountId})
            
            console.log('subStakeHolder result:: ',result);
            // Further actions after creating the record
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


    async handleSubmit(event) {
      
      event.preventDefault();
      this.objectsSubmitted.push(event.currentTarget.objectApiName);
      if(event.currentTarget.objectApiName == 'Case' && this.objectsSubmitted.length == this.formObjects.length){
     // const fields = event.detail.fields;
     let objinputFields={};
     this.template.querySelectorAll(
         `lightning-input-field[data-objectkey="Case"]`
     ).forEach(element=>{
       if(element && element.fieldName && element.fieldName.toLowerCase()!='ownerid' &&  (!this.readOnlyFieldsList.includes(element.fieldName.toLowerCase()))){
         objinputFields[element.fieldName]= element.value;
         const fieldName = element.fieldName;
         const fieldValue = element.value;
         const commonFieldId = element.dataset.id;
         const commonFieldDataType = element.dataset.name;
         const fieldErrorMsg = element.error;
         this.validateInputField(element, fieldName, fieldValue, commonFieldDataType, fieldErrorMsg);
 
       }
     });


     let fields= objinputFields;
     this.recordfields = fields;
      this.fieldNameService = [];
      let nameSpace = this.namespaceVar;
      if (this.checkNPIDuplicateFound && !this.accountId) {
        this.showToastNotification(
          "Error",
          this.label.Account_already_exist_with_the_same_NPI,
          "Error"
        );
      }
      if(fields['Status'] === 'Complete' || (this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`] === 'PAE' 
        && this.validationMsgMap.has(fields['Status']+'#'+fields[`${nameSpace}Outcome__c`]))){
        this.validateIncompleteReasons(event);
        if (this.validFieldValues) {
          event.preventDefault();
          if(this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`] === 'PAE' 
            && this.validationMsgMap.has(fields['Status']+'#'+fields[`${nameSpace}Outcome__c`])){
              this.showToastNotification(
                "Error",
                this.validationMsgMap.get(fields['Status']+'#'+fields[`${nameSpace}Outcome__c`]),
                "Error"
              );
          }else{
          const missingFieldsMessage = this.fieldNameService.length > 0 //1789
              ? ` Missing fields: ${this.fieldNameService.join(', ')}`//1789
              : '';//1789
          this.showToastNotification(
            "Error",
            `${this.label.casesoftrequiredfieldsMsg}${missingFieldsMessage}`,//1789
            "Error"
          );
          }
        }
        }else{
              this.validFieldValues = false;
        }

        
      if(!this.validFieldValues && this.isInputValid()){
        this.isCaseOpen = false;
        if(this.isKAHCS || this.isKAPrescriber){
          if(this.isNullOrEmpty(this.accountId)){
            this.accountId = fields[`${nameSpace}Healthcare_Setting__c`] || fields[`${nameSpace}Pharmacy__c`] || fields[`${nameSpace}Prescriber__c`]
          }
          if(!this.isNullOrEmpty(this.accountId)){
            await this.getCases();
          }
          if (this.isCaseOpen) {
            this.showToastNotification(
                "Error",
                kaDuplicateError +' ' + this.caseNumbers,
                "Error"
            );
            return;
          }
        }
        if(this.serviceConfigRecord){
          await this.getRecordTypeDataHandler(this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`], "Case")
          .then(async (result) => {
            this.enrollmentRecordType = result;
            if(this.serviceConfigRecord[`${nameSpace}Service_Record_Type__c`] == 'Change_Authorized_Representative' ){
              fields[`${nameSpace}Participant__c`] = fields[`${nameSpace}Healthcare_Setting__c`] || fields[`${nameSpace}Pharmacy__c`] ||  fields[`${nameSpace}Distributor__c`] ;
              this.recordTypeData = this.enrollmentRecordType;
              if(this.isNullOrEmpty(fields[`${nameSpace}Authorized_Representative_New_Primary_AR__c`]) && fields[`${nameSpace}Change_Primary_AR__c`]){
                fields[`${nameSpace}Authorized_Representative_New_Primary_AR__c`] = await this.createARAcc(fields,`${nameSpace}Authorized_Representative_New_Primary_AR__c`)
              }
              if(this.isNullOrEmpty(fields[`${nameSpace}AR_New_Secondary_AR__c`])&& fields[`${nameSpace}Change_Secondary_AR__c`] ){
                fields[`${nameSpace}AR_New_Secondary_AR__c`] = await this.createARAcc(fields,`${nameSpace}AR_New_Secondary_AR__c`)
              }
            }
          })
          .catch((error) => {
            console.log(error)
            this.showToastNotification(
              "Error",
              reduceErrors(error).join(", "),
              "Error"
            );
          });
        }
        if(!this.skipDupcheck && !this.isInboundOutboundCall){
            await this.isDuplicateHoldersAvailable(fields);    
      }
      
    }
    if(this.accountId){
        fields[this.serviceConfigRecord[`${nameSpace}Participant_Field__c`]]=this.accountId;
    }
    
      
    if (!this.validFieldValues && this.isInputValid() && !this.checkNPIDuplicateFound && !this.isOpen && this.skipDupcheck) {

        this.ShowSpinner = true;
        event.preventDefault();
        let remsProgramField = `${nameSpace}REMS_Program__c`;
        let channel = fields[`${nameSpace}Channel__c`];
        fields[remsProgramField] = this.programId;
        if(this.byPassAccountSelection && !this.isOpen && `${nameSpace}Case_Record_Type__c` in this.serviceConfigRecord && !this.isKAPrescriber && !this.isInboundOutboundCall){
          this.storeAccountFieldValues = [];
          let configs = this.allMatchingDuplicateConfigs();
          configs.forEach(config =>{
            if(!config[nameSpace+'Main_Stakeholder_Account__c']){
              const targetFields = config[`${nameSpace}Target_Specific_Fields__c`].split(',');
              targetFields.forEach(targetField =>{
                let val = nameSpace+targetField;
                let sourceReferenceField = config[nameSpace+'Source_Reference_Field__c'];
                
            //&& this.createStakeHolder.indexOf(sourceReferenceField) !== -1
                if(fields[val]!==null && fields[val]!==undefined ){
                  this.storeAccountFieldValues.push({recordtype: sourceReferenceField,fieldApiName: targetField, feildValue: fields[val]});
                }
              });
            }
          })
          console.log('  this.storeAccountFieldValues ',  JSON.stringify(this.storeAccountFieldValues));
          await createSubStakeHolderAccounts({fieldMapValue: this.storeAccountFieldValues, RequestRecordType: this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`] , programId: this.programId, programName: this.programName , channel : channel})
            .then((result) => {
              if (result) {
                for(const key in result){
                  const array = key.split('-');
                  if(this.isKAHCS){
                    this.accountId = result[key];
                    this.byPassAccountSelection = false;
                    this.recordTypeData = this.enrollmentRecordType;
                  }
                  fields[array[0]] = result[key];
                  console.log('array[1]:: ',array[1]);
                  this.getCaseCreateRecord(fields, array[1], result[key]);
                  fields[`${nameSpace}Knowledge_Assessment__c`] = 'Not Started';

                }
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
        this.fields = fields;
        fields['RecordTypeId'] = this.recordTypeData;
        if(this.draftCaseId){
          fields['Id']=this.draftCaseId;
        }
        console.log('Field:: ',fields);
         this.template.querySelector(`lightning-record-edit-form[data-object="Case"]`).submit(fields);
      
      } else if(!this.isInputValid()) {
         this.ShowSpinner = false;
        this.showToastNotification(
          "Error",
          this.label.validationCheckForAllFields,
          "Error"
        );
      }
    }
    }

    isNullOrEmpty(str) {
      // Explicitly check for null and undefined
      if (str === null || str === undefined) {
        return true;
      }

      // Check for an empty string or a string that contains only whitespace
      return str.trim() === '';
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

    handlePrevious() {
      this.dispatchEvent(new CustomEvent("previous"));
    }

    async handleOnSuccess(event) {
      if(this.draftCaseId){
       await this.updateDocumentCheckList(this.draftCaseId,this.draftServiceId,this.accountId)
        this.handleSuccess('success','Success!','Case update Successfully!') 
        this.handleNavigateToRecord('Case',this.draftCaseId);
        return;
      }
      if(!this.stopHandleSuccessExec){
      let nameSpace = this.namespaceVar;

      if (this.participantType && this.serviceType && !this.accountId ) {
        let returnedData;

        if(this.enrollmentRecordType){
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
                console.log('error:: ',error);
              this.ShowSpinner = false;
              this.showToastNotification(
                "Error",
                this.label.accountErrorMsg,
                "Error"
              );
            });
        }



      }
     
      if (this.isInputValid() && !this.checkNPIDuplicateFound && !this.stopCreation && !this.isOpen) {
        const response = event.detail;
        var enrollCaseId ;
        if (response.id) {
          const recordId = response.id;
          this.caseRecordId = recordId;
          if(this.secondCaseId){
            enrollCaseId = this.secondCaseId;
          }else{
            enrollCaseId = recordId;
          }
          Object.keys(this.substakeHolderUpdateList).forEach(key =>{
            if(typeof this.substakeHolderUpdateList[key] === 'boolean'){
              delete this.substakeHolderUpdateList[key];
            }
          })
          if( Object.keys(this.substakeHolderUpdateList).length>0){
            await updateSubstakeholderData({
                                      caseId:enrollCaseId,
                                      parentFldSet:this.substakeHolderUpdateList,
                                      programName:this.programName,
                                      requestorTypeName:this.participantType,
                                      recordTypeName: this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`]
                                    }).then(response =>{
              
            }).catch(errors=>{
              this.ShowSpinner = false;
            });
          }
          if (this.serviceType && this.participantType && this.accountId) {
            this.accountAvailable = true ;
            await this.handleCreateEnrollmentService();
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
          console.log('error:: ',error);
          this.showToastNotification(
            "Error",
            this.label.accountErrorMsg,
            "Error"
          );
          this.ShowSpinner = false;
        }
      } else if(!this.isInputValid()){
        this.showToastNotification(
          "Error",
          this.label.validationCheckForAllFields,
          "Error"
        );
        this.ShowSpinner = false;
      }

      }

    }

    handleError(event){
      console.log('error:: ',error);
      const evt = new ShowToastEvent({
          title: 'Error!',
          message: event.detail.detail,
          variant: 'error',
          mode:'dismissable'
      });
      this.dispatchEvent(evt);
      this.ShowSpinner = false;
  }
    handleFieldVisibility(fieldName, fieldValues, event) {
        try {
          fieldValues = fieldValues?.toString()
          this.showUI = false;
          for (const key in this.serviceFields) {
              this.serviceFields[key]['sectionVal'].forEach((element) => {
              element.value.forEach((item) => {
            if (
              item.dependentField !== undefined &&
              item.dependentField !== null &&
              item.dependentField !== ""
            ) {
              if (item.dependentValue && 
                item.dependentField === fieldName && fieldValues 
                && fieldValues!=null && 
                (fieldValues.includes(item.dependentValue)
                || item.dependentValue.includes(fieldValues)) // Check if dependentValue is in fieldValues array
              ) {
                item.visible = true;
              } else if (item.dependentField === fieldName) {
                item.visible = false;
                item.fieldValue = ""; // Reset fieldValue for elements not matching dependentValue
              }
            }
          });
        });
      }
      this.ShowSpinner = false;
      this.showUI = true;
      } catch (error) {
        console.error(error);
        this.ShowSpinner = false;
      }

    }
    isLooupPopulated = false;
    allMatchingDuplicateConfigs(){
      let nameSpace = this.namespaceVar;
      this.isLooupPopulated = false;
      let serviceConfig = typeof this.serviceConfig == 'object'?this.serviceConfig: this.serviceConfigRecord;
      const matchingConfigsMain = [];
      let matchingConfigsSub = [];
      this.AccountCreationMetaData.data.forEach(config =>{
        
        if((config[`${nameSpace}Program__r`].MasterLabel).toLowerCase() === (this.programName).toLowerCase()){
        
          let sourceF=config[`${nameSpace}Source_Reference_Field__c`];
          let sourceRefField=(sourceF.toLowerCase()!='syn_pharmacy__c' && sourceF.toLowerCase()!='syn_authorized_rep__c')?nameSpace + sourceF:sourceF;

          
          let inputField = this.template.querySelector(
              `lightning-input-field[data-field="${sourceRefField}"]`
          );
     
          if(!config[nameSpace+'Main_Stakeholder_Account__c'] &&
              config[`${nameSpace}Participant_Type__c`] === serviceConfig[`${nameSpace}Participant_Type__c`] &&
              config[`${nameSpace}Requestor_Type__c`] === serviceConfig[`${nameSpace}Case_Record_Type__c`]){
                if(inputField && !inputField.value){
                  matchingConfigsSub.push(config);
                }else{
                  this.isLooupPopulated = true;
                }
          }else if(!this.isKAHCS && config[this.namespaceVar+'Main_Stakeholder_Account__c'] && config[`${this.namespaceVar}Requestor_Type__c`] === serviceConfig[`${this.namespaceVar}Requestor_Type__c`]){
            
            if(!this.isKAPrescriber)
              matchingConfigsMain.push(config);
            else{
              let inputField = this.template.querySelector(
                `lightning-input-field[data-field="${sourceRefField}"]`
              );
              console.log('inputField.value###### ',inputField.value);
              if(!inputField.value){
                matchingConfigsMain.push(config);
              }else{
                this.accountId = inputField.value;
              }
            }

          }
        }
      })
      console.log('serviceConfig :',serviceConfig);
      console.log('d ',matchingConfigsMain.concat(matchingConfigsSub));
      return matchingConfigsMain.concat(matchingConfigsSub);
    }

    handleInputChange(event) {
      let nameSpace = this.namespaceVar;
      const fieldName = event.target.fieldName;
      const fieldValue = event.target.value;
    
      doDataCals(this,fieldName,fieldValue);
      if(this.serviceType == 'Enrollment' || this.callingFrom === 'NewAccount' || this.serviceType === 'Knowledge Assessment'){
        let allDuplicateConfigs = this.allMatchingDuplicateConfigs();
        if(allDuplicateConfigs && allDuplicateConfigs.length > 0){
          allDuplicateConfigs.forEach(config =>{
            let dupJSON = JSON.parse(config[nameSpace+'Dublicate_Matching_Fields_JSON__c']);
            dupJSON.forEach(field=>{
              if(fieldName === nameSpace+field.source_field){
                this.skipDupcheck = false;
                if(config[this.namespaceVar+'Main_Stakeholder_Account__c']){
                  this.accountId = '';
                }
              }
            })
          })
        }
      }

      if (fieldName === `${nameSpace}NPI_Status__c`) {
        if (fieldValue === this.fetchedNpiStatus) {
          this.handleFieldDisplay(false);
        } else {
          this.handleFieldDisplay();
        }
      }

      if(fieldName==`${nameSpace}Patient_DOB__c` || fieldName==`${nameSpace}Age__c` || fieldName==`${nameSpace}Patient2__c`){
        this.validateAge();
      }

      const commonFieldId = event.target.dataset.id;
      const commonFieldType = event.target.name;
      const commonFieldDataType = event.target.dataset.name;
      const fieldErrorMsg = event.target.dataset.error;
      this.handleFieldVisibility(fieldName, fieldValue, event);
      const isValueNull = !fieldValue;
      const inputFields = this.template.querySelectorAll(`[data-id="${commonFieldId}"]`);
      
      
      inputFields.forEach(inputField => {

        if (fieldName === inputField.fieldName) {
          if(commonFieldType ==="REFERENCE"){
            var parentAccountId;
            if(this.substakeHolderUpdateList.hasOwnProperty(fieldName)){
              this.substakeHolderUpdateList[fieldName]=fieldValue;
            }
            if((this.serviceName == this.label.Non_compliance_service_typeMsg && fieldName == `${nameSpace}Investigated_Stakeholder__c`)){
            this.impactedStakeholderAccId = fieldValue;
            parentAccountId = this.impactedStakeholderAccId;
          }
          if(this.newParent && fieldName == this.newParent){
            this.accountId = fieldValue;
            parentAccountId = this.accountId;
            if(this.serviceName == this.label.Non_compliance_service_typeMsg){
              this.impactedStakeholderAccId = this.accountId;
            }
          }
          if(parentAccountId){
            getAccountData({
              accountId: parentAccountId
            })
            .then((result) => {
              this.participantType =  result[`${nameSpace}Recordtype_Label__c`];
            })
            .catch((error) => {
            });
          }
            this.handleLookUpValues(fieldName,fieldValue,event);
            this.handleKnowledgeAssesmentPassFail(fieldValue);
          }else {
            this.validateInputField(inputField, fieldName, fieldValue, commonFieldDataType, fieldErrorMsg);

          }
        }
      });
      var distributor = 'Distributor';
      if (this.participantType != distributor && this.serviceType !='Knowledge Assessment') {
        if (fieldName === `${nameSpace}NPI__c` && fieldValue.length === 10) {
          this.validateNpi(fieldValue);
        }
      }
      if(this.serviceType){
        if (this.isInboundOutboundCall) {
          var fldNameKeyLastName = `${nameSpace}` + 'Last_Name__c';
          var fldNameKeyFirstName = `${nameSpace}` + 'First_Name__c';
          var fldNameKeyRelation = `${nameSpace}` + 'Relationship__c';
          var fldNameKeyPhone = `${nameSpace}` + 'Phone__c';
            let firstname = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKeyFirstName}"]`
            );
            let lastname = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKeyLastName}"]`
            );
            let relation = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKeyRelation}"]`
            );
            let phone = this.template.querySelector(
              `lightning-input-field[data-field="${fldNameKeyPhone}"]`
            );
          if (fieldName === `${nameSpace}Same_as_Account__c` && fieldValue === false) {

            lastname.value = '';
            lastname.required = true;
            firstname.value = '';
            firstname.required = true;
            relation.required = true;
            phone.value = '';

        }
        if (fieldName === `${nameSpace}Same_as_Account__c` && fieldValue === true) {

            lastname.required = false;
            firstname.required = false;
            relation.required = false;

          this.preFillCaseLayout();
        }
      }
    }
    if (fieldName === `${nameSpace}NPI__c`) {
      if(fieldValue.length === 10){
        let serviceConfig = typeof this.serviceConfig == 'object'?this.serviceConfig: this.serviceConfigRecord;
        let recordType = serviceConfig[this.namespaceVar+'Requestor_Type__c'];
        this.handleDuplicateNPI(fieldValue,recordType,this.programId);
      }else{
        this.checkNPIDuplicateFound = false;
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
          }else if (commonFieldDataType === 'AlphaNumeric') {
            const alphaNumCharPattern = /^[A-Za-z0-9'. -]+$/;
              if (!isValueNull && !fieldValue.match(alphaNumCharPattern)) {
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
              const emailPattern = /^[a-zA-Z0-9_'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
              if (!isValueNull && !fieldValue.match(emailPattern)) {
                   info.classList.remove('slds-hide');
                   info.value = fieldErrorMsg;
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
      if((fieldName==`${nameSpace}Unknown__c` || fieldName==`${nameSpace}First_Name_ar__c` || fieldName==`${nameSpace}Last_Name_ar__c`)
         && (this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`] != 'PAE')){
        this.validateUnknown();
      }
      const allInputFields = this.template.querySelectorAll('lightning-input-field');
      if (fieldName === `${nameSpace}Ship_to_Address_Same_as_Above__c` && fieldValue == true) {

        if (allInputFields) {
          allInputFields.forEach(field => {
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
            if  (field.fieldName == `${nameSpace}Shipping_Address_Line_1__c` || field.fieldName == `${nameSpace}Shipping_Address_Line_2__c` ||
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


  validateInputField(inputFields, fieldName, fieldValue, commonFieldDataType, fieldErrorMsg) {
    const patterns = {
        'Phone': /^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/,
        'Fax': /^(\(\d{3}\) \d{7}|\(\d{3}\) \d{3}-\d{4}|\d{10}|\d{3}-\d{3}-\d{4})$/,
        'Name': /^[A-Za-z'. -]+$/,
        'SLN': /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]*$/,
        'DEA': /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9,}$/,
        'Number': /^\d{10}$/,
        'HIN': /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{9}$/,
        'Zip': /^\d{5}(-\d{4})?$/,
        'NCPDP': /^\d{7}$/,
        'Ext': /^[0-9]{1,10}$/,
        'Email': /^[a-zA-Z0-9_'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
        'AlphaNumeric': /^[A-Za-z0-9'. -]+$/
    };
    
    if (fieldValue != '' && !fieldValue.match(patterns[commonFieldDataType])) {
        inputFields.classList.add('slds-has-error');
         return;
    } else {
        inputFields.classList.remove('slds-has-error');
     }
}

  async handleLookUpValues(fieldName,fieldValue,event){
      let nameSpace = this.namespaceVar;
        try {
          const getFieldValues = await this.fetchFieldValues(fieldValue,fieldName,this.serviceConfigRecord ? this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`] : '');
          this.mapData = new Map(Object.entries(getFieldValues));
          if(fieldValue == '' || fieldValue == undefined){
            this.skipDupcheck = false;
            this.byPassAccountSelection = true;
          }else{
            if(this.isKAHCS && fieldName.toLowerCase() === (nameSpace+'REMS_Authorized_Rep__c').toLowerCase()){
              this.accountId = fieldValue;
            }
          }
          await this.handleKnowledgeAssesmentPassFail(fieldValue);
          for (const key in this.serviceFields) {
            this.serviceFields[key]['sectionVal'].forEach((element) => {
              element.value.forEach((item) => {
                if (this.mapData.has(item.fieldName)) {
                  element.visible = true;
                }
              });
            });
          }
          setTimeout(_ => this.asyncUpdateFieldValues(event,fieldValue,fieldName),100);
        } catch(exception) {
          console.log(exception);
        }
    }

    asyncUpdateFieldValues(event,parent,parentName) {
      let nameSpace = this.namespaceVar;
      console.log('this.mapData =>',this.mapData);
      console.log('this.parentName =>',this.accountId);
      for (const [key, value] of this.mapData.entries()) {
              if(key != `${nameSpace}REMS_Program__c`) {
                let field = this.template.querySelector(`lightning-input-field[data-field="${key}"]`);
              try{
                if(field) {
                  if(!(this.serviceConfigRecord[`${nameSpace}Validate_AR_Info__c`] && key.includes('Signature') && parent)){
                  if(key !== parentName || !this.accountId)
                  field.value = value;
                  if((!value) && field.value){
                    field.value =null;
                    }
                  }


                  if(key==`${nameSpace}Patient_DOB__c` || key==`${nameSpace}Age__c` || field.fieldName==`${nameSpace}Patient2__c`){
                    this.validateAge();
                  }

                  if((key==`${nameSpace}Unknown__c` || key==`${nameSpace}First_Name_ar__c` || key==`${nameSpace}Last_Name_ar__c`)
                     && (this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`] != 'PAE')){
                    this.validateUnknown();
                  }
                }
                }catch(exception) {
                  console.log(exception);
                }

                this.handleFieldVisibility(key,value,event);
                if(key == `${nameSpace}NPI__c`){
                this.validateNpi(value);
              }
            }
      }

      for (const key in this.serviceFields) {
        this.serviceFields[key]['sectionVal'].forEach((element) => {
      element.value.forEach((item) => {
        //Code to update knowledgeassesment pass fail
        if(this.serviceConfigRecord[`${nameSpace}Service_Record_Type__c`] == 'Change_Authorized_Representative' && parentName == `${nameSpace}Authorized_Representative_New_Primary_AR__c` && item.fieldName == `${nameSpace}KA_New_Primary_AR__c`){
          if(this.knowledgeAssesmentPassFail == 'Passed' || this.knowledgeAssesmentPassFail == 'Failed'){
            item.fieldValue = this.knowledgeAssesmentPassFail;
          }else{
            item.fieldValue = 'Failed';
          }
        }
        if(this.serviceConfigRecord[`${nameSpace}Service_Record_Type__c`] == 'Change_Authorized_Representative' && (parentName == `${nameSpace}Healthcare_Setting__c` || parentName == `${nameSpace}Pharmacy__c` || parentName == `${nameSpace}Distributor__c`) && item.fieldName == `Status`){
          let field = this.template.querySelector(`lightning-input-field[data-field="${item.fieldName}"]`);
          this.mainStakeHolderStatus = field.value;
          field.value = 'Draft'
          item.fieldValue = 'Draft';
        }
        if(this.mapData.has(item.fieldName) && (this.serviceName == this.label.Non_compliance_service_typeMsg
          || (this.fieldmappingconfigmap.has(parentName) && this.fieldmappingconfigmap.get(parentName)))){
          if(parent){
            item.editable = true;
          }else{
            item.editable = false;
          }
        }
      });
    });
  }
    this.ShowSpinner = false;

  }
    async handleKnowledgeAssesmentPassFail(accountId) {
      try {
          const result = await getAssessmentResponse({
              accountId: accountId,
          });
          let nameSpace = this.namespaceVar;
          this.knowledgeAssesmentPassFail = result;
          for (const key in this.serviceFields) {
            this.serviceFields[key]['sectionVal'].forEach((element) => {
              element.value.forEach((item) => {
                  if (item.fieldName === `${nameSpace}Knowledge_Assessment__c`) {
                      if (this.knowledgeAssesmentPassFail != null && this.knowledgeAssesmentPassFail != undefined) {
                        item.fieldValue = this.knowledgeAssesmentPassFail;
                    }

                  }
                });
              });
            }

      } catch (error) {
          console.log('Error ', error);
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

    showToastNotification(title, message, variant) {
      const evt = new ShowToastEvent({
        title,
        message,
        variant
      });
      this.dispatchEvent(evt);
    }

    createServiceAccount = async () => {
      this.ShowSpinner = true;
      let result = await createAccount({
        caseRecordId: this.caseRecordId,
        serviceReqType: this.serviceType,
        servicerecordType: this.participantType,
        TarObject: "Case",
        TarRecordType: this.recordTypeData,
        programName: this.programName
      });
      if (result) {
        this.accountId = result;
        this.showToastNotification(
          "Success",
          this.label.accountSuccessfullyMsg,
          "success"
        );
        this.handleCreateEnrollmentService();
        this.closeQuickSubtab(result);
        this.ShowSpinner = false;
      } else {
        console.log('error result: ',result);
        this.showToastNotification("Error", this.label.accountErrorMsg, "Error");
        this.ShowSpinner = false;
      }
    };

    async createAccount() {
      this.ShowSpinner = true;
      let nameSpace = this.namespaceVar;
        createAccount({
        caseRecordId: this.caseRecordId,
          serviceReqType: this.serviceConfig[`${nameSpace}Requestor_Type__c`],
        servicerecordType: this.serviceConfig[`${nameSpace}Rems_Service_RCtype__c`],
        TarObject: this.serviceConfig[`${nameSpace}Object_Name__c`],
        TarRecordType: this.serviceConfig[`${nameSpace}RecordType_Name__c`],
        programName: this.serviceConfig[`${nameSpace}Program_Name__r`][`Label`]
      })
        .then((result) => {
          if (result) {
            this.showToastNotification(
              "Success",
              this.label.accountSuccessfullyMsg,
              "success"
            );
          if(this.contactid){
            this[NavigationMixin.Navigate]({
              type: 'standard__component',
              attributes: {
                componentName: "c__newCaseFormForRedirection"
              },
              state: {
                  c__contactid: this.contactid ,
                  c__ANI: this.phoneValue,
                  c__accountid: result,
                  c__participant: this.serviceConfig[`${nameSpace}Requestor_Type__c`],
                  c__programname: this.serviceConfig[`${nameSpace}Program_Name__r`][`Label`]           
                }
          },true);
        this.dispatchEvent(new CustomEvent('cancel'));
        this.dispatchEvent(new CustomEvent("locationChange"));
        }
        else{
          this.closeQuickSubtab(result);
          }
          this.ShowSpinner = false; 
          } 
          else {
            this.ShowSpinner = false;
            this.showToastNotification(
              "Something went wrong",
              this.label.accountErrorMsg,
              "Error"
            );
          }
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

    validateNpi = async (value) => {
      let nameSpace = this.namespaceVar;
      let fieldName = `${nameSpace}NPI_Status__c`;
      try {
        let result = await validateNpiStatus({
          npiValue: value
        });
        if(value != null){
          if (result) {
            let inputField = this.template.querySelector(
              `lightning-input-field[data-field="${fieldName}"]`
            );
            inputField.value = "Valid";
            this.fetchedNpiStatus = inputField.value;
          } else {
            let inputField = this.template.querySelector(
              `lightning-input-field[data-field="${fieldName}"]`
            );
            inputField.value = "Invalid";
            this.fetchedNpiStatus = inputField.value;
          }
        }
      } catch (ex) {
        let inputField = this.template.querySelector(
          `lightning-input-field[data-field="${fieldName}"]`
        );
        if(inputField){
          this.showToastNotification("Error", "Unable to Validate NPI", "error");
        }
      }
    };

    handleFieldDisplay(fieldVisible) {
      let visible = fieldVisible === undefined ? true : false;
      let nameSpace = this.namespaceVar;
      let npiOverrideField = `${nameSpace}NPI_Override_Comments__c`;
      for (const key in this.serviceFields) {
        this.serviceFields[key]['sectionVal'].forEach((element) => {
          element.value.forEach((item) => {
            if (item.fieldName === npiOverrideField) {
              item.visible = visible;
            }
          });
        });
      }
    }

    handleCancelClick() {
      this.AccountCreationScreen = true;
      this.closeForm();
  }
    handleCancel(){
           this.handleNavigateToRecord('DocumentChecklistItem',this.documentCheckListId);
          
        //this.closeForm();
      }
      handleYes() {
          // Handle cancellation logic here
          // Call an Apex method to perform cancellation
          // Hide the popup
          if(this.callingFrom === 'Task'){
            this.invokeWorkspaceAPI("getFocusedTabInfo").then(
              async (focusedTab) => {
                openTab({ recordId: this.taskId, focus: true })
                  .then((_) => {
                    this.invokeWorkspaceAPI("closeTab", {
                      tabId: focusedTab.tabId
                    });
                  this.ShowSpinner = false;
                  })
                  .catch((error) =>
                    this.showToastNotification(
                      "Error",
                      reduceErrors(error).join(", "),
                      "Error"
                    )
                  );
                  this.ShowSpinner = false;
              }
            );
          }else if(this.serviceFromAccount || this.isInboundOutboundCall){
            this.dispatchEvent(new CustomEvent("cancel"));
            this.closeForm();
          }else{
            this.showPopup = false;
            this.dispatchEvent(new CustomEvent("cancel"));
            this.handleCancelClick();
          }

      }
      handleNo() {
          // Hide the popup
          this.showPopup = false;
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

    closeForm() {
      this.invokeWorkspaceAPI("isConsoleNavigation").then((isConsole) => {
        if (isConsole) {
          this.invokeWorkspaceAPI("getFocusedTabInfo").then(
            async (focusedTab) => {
              this.invokeWorkspaceAPI("closeTab", {
                tabId: focusedTab.tabId
              });
            }
          );
        }
      });
    }

    async closeQuickSubtab(result) {
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

    secondService;

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
              console.log('Error updating record', error);
            });
            if(this.documentCheckListId !== undefined && this.documentCheckListId !== ''){
              this.updateDocumentCheckList(this.caseRecordId,this.secondService,this.accountId);
            }
            await sendPaeEmail(this,this.caseRecordId);
            await this.getCaseProgramRecords(this.caseRecordId,this.programName);

            await reSubmitChildObjects(this,this.caseRecordId,this.accountId);  
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
              console.log('Error updating record', error);
              console.error('Error updating record', error);
            });
            if(this.documentCheckListId !== undefined && this.documentCheckListId !== ''){
              this.updateDocumentCheckList(this.secondCaseId,this.secondService,this.accountId);
            }
            await sendPaeEmail(this,this.caseRecordId);
            await this.getCaseProgramRecords(this.caseRecordId,this.programName);
            await reSubmitChildObjects(this,this.secondCaseId,this.accountId);
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
          console.log('Error updating record', error);
        });

    }

    updateCasewithAccountAndService = async (caseId) => {
      let result = await updateCase({
        caseRecordId: caseId,
        accountId: this.accountId
      }).then(() => {

      })
      .catch(error => {
        console.error('Error updating record', error);
      });
      //this.closeQuickSubtab(this.accountId);
    };

    timeOutInterval = (event) => {
      setInterval(() => {
        this.ShowSpinner = false;
      }, 4000);
    };

    async asyncUpdatePrimaryFieldValues(event) {

      this.ShowSpinner = true;
      let nameSpace = this.namespaceVar;

      let fieldMap = this.mapData,
          result = Object.fromEntries(this.mapData);
      let hasNPIOverridePermission;
      if(this.userPermissionSets){
        hasNPIOverridePermission = this.userPermissionSets.includes('REMS_NPI_Override');
      }

      this.template.querySelectorAll('lightning-input-field').forEach(ele => {

        //Assign Values to fields
        if(fieldMap.has(ele.fieldName) && fieldMap.get(ele.fieldName)) {
          switch (ele.name) {
            case 'BOOLEAN':
              ele.value =  (fieldMap.get(ele.fieldName) == "true") ? true : false;
              break;
            case 'REFERENCE':
              ele.value = this.accountId;
              break;
            case 'DATE':
              var dateValue = fieldMap.get(ele.fieldName);
              if(fieldMap.get(ele.fieldName).includes(' ')){
                dateValue = dateValue.split(' ')[0];
                ele.value = dateValue;
              }else{
                ele.value = fieldMap.get(ele.fieldName);
              }
              break;
            default:
              ele.value = fieldMap.get(ele.fieldName);
          }

          //Relace space with blank
          if(fieldMap.get(ele.fieldName) == ' ') {
          ele.value = '';
          }
          }


        //Validate NPI
        if(this.serviceConfigRecord[`${nameSpace}Validate_NPI__c`] == true){
          if(ele.fieldName == `${nameSpace}NPI__c`){
            this.validateNpi(ele.value);
          }
        }

      });


      for (const key in this.serviceFields) {
        this.serviceFields[key]['sectionVal'].forEach((elements) => {
        elements.value.forEach((element) => {
        if (element.dependentField && element.dependentValue && ((!result[element.dependentField] &&  !this.skipFieldVisibility)
          || (result.hasOwnProperty(element.dependentField) && !result[element.dependentField] ||
        (result[element.dependentField] && !(result[element.dependentField].includes(element.dependentValue)
      || element.dependentValue.includes(result[element.dependentField])))))) {
          element.visible = false;
        }else if (hasNPIOverridePermission && element.fieldName === `${nameSpace}NPI_Status__c`) {
        element.editable = false;
    }else if (element.fieldName === `${nameSpace}NPI_Override_Comments__c`){
      element.visible = false;
  }
        if(this.userPermissionSets && element.permissionSet && this.userPermissionSets.includes(element.permissionSet)){
          element.editable = false;
        }
      });
      });
    }
      this.skipFieldVisibility = false;
      this.ShowSpinner = false;

  }
  validateIncompleteReasons(event) {
    this.validFieldValues = false;
    let fieldNameService = []; //1789
    const allInputFields = this.template.querySelectorAll('lightning-input-field');
    var caseRecordData = {};
    if (allInputFields) {
            allInputFields.forEach(field => {
            caseRecordData[field.fieldName] = field.value;
        });

        for (const key in this.serviceFields) {
          this.serviceFields[key]['sectionVal'].forEach((element) => {
            element.value.forEach((item) => { // 1789 Changed from 'element' to 'item' for clarity
                if ((item?.softrequired || (item?.required && !item?.editable)) && item?.visible) { //1789 Changed 'element' to 'item' for clarity
                    if (caseRecordData && item.fieldName &&
                        ((!caseRecordData[item.fieldName]) || (caseRecordData[item.fieldName] && (caseRecordData[item.fieldName] === item?.inCompleteValue || (item?.inCompleteValue != undefined && item?.inCompleteValue.includes(caseRecordData[item.fieldName])))))
                    ) {
                        this.validFieldValues = true;//1789
                        this.fieldNameService.push(item.fieldLabel);//1789
                }
              }
            });
          });
        }
      }
    }

    validateAge (){
      let nameSpace = this.namespaceVar;
      let DOBField = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Patient_DOB__c"]`);
      let ageField = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Age__c"]`);
      let patField = this.template.querySelector(`lightning-input-field[data-field="${nameSpace}Patient2__c"]`);
      const ageFldVal = this.template.querySelector(`[title="${nameSpace}Age__c"]`);
      if(patField && !patField.value){
        ageField.disabled = false;
        ageField.classList.remove('slds-has-error');
        ageField.value = '';
        ageFldVal.classList.add('slds-hide');
      }
      if(DOBField.value || ageField.value){
        ageField.classList.remove('slds-has-error');
        ageFldVal.classList.add('slds-hide');
        if(DOBField.value){
          ageField.value = '';
          ageField.disabled = true;
          var dob = new Date(DOBField.value); 
          var month_diff = Date.now() - dob.getTime(); 
          var age_dt = new Date(month_diff);   
          var year = age_dt.getUTCFullYear();  
          var age = Math.abs(year - 1970);
          ageField.value = age;
        }else{
          ageField.disabled = false;
        }

      }else{
        ageField.disabled = false;
        if(patField && patField.value){
        ageField.classList.add('slds-has-error');
        ageFldVal.classList.remove('slds-hide');
        ageFldVal.value = this.label.Age_validation_Messageval;
        }
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

    async createARAcc(fields,parentFieldType){
      let nameSpace = this.namespaceVar;
      let id = ''
      await createARAccount({
        fieldValues: fields,
        tarObject:'Account',
        sourceRecordType: this.serviceConfigRecord[`${nameSpace}Case_Record_Type__c`],
        servicerecordType: this.serviceConfig[`${nameSpace}Rems_Service_RCtype__c`],
        sourceObject: 'Case',
        programName:this.programName,
        parentFieldType:parentFieldType
      })
        .then((result) => {
          if (result) {
            id =  result
          } else {
            this.showToastNotification(
              "Something went wrong",
              this.label.accountErrorMsg,
              "Error"
            );
          }
        })
        .catch((error) => {
          this.ShowSpinner = false;
          this.showToastNotification(
            "Error",
            reduceErrors(error).join(", "),
            "Error"
          );
        });

      return id;

    }

    async fetchFieldValues(fieldValue,fieldName,sourceRecordType) {
      this.ShowSpinner = true;
      try {
          // Prepare the parameters for the call
          let nameSpace = this.namespaceVar;
          const params = {
              accountId: fieldValue,
              requestorType: this.participantType,
              targetObject: "Account",
              sourceObject: "Case",
              sourceRecordType: sourceRecordType,
              parentFieldType: fieldName,
              programName: this.programName,
              overrideReqType: this.overrideRequestorType
          };
          let fieldValues;
          fieldValues = await getCaseFieldAndValueMap(params);
          
          // Return the result
          this.ShowSpinner = false;
          return fieldValues;
      } catch (error) {
        this.ShowSpinner = false;
          console.error('Error fetching field values:', error);
          throw error;
      }

    }

    handleSubmitAll(){
      let caseBtn ;
      this.objectsSubmitted = [];
    this.template.querySelectorAll( ".hidden" ).forEach(btn=>{
      if( btn.dataset.btnkey == "Case" && btn.dataset.addsec == "false"){ 
        caseBtn = btn;
    }else{
      btn.click();
    }
    });
    if(caseBtn){
      caseBtn.click();
    }
  }

  async getCaseProgramRecords(caseId,programName){
    await retrieveCasePrograms({
      caseId: caseId,
      programId: programName,
    })
      .then((result) => {
        if (result) {
          this.caseProgMap =   new Map(Object.entries(result));
        }
    });
  }
  validateEligibility(accountStatus){
    let nameSpace=this.namespaceVar;
    let eligibleStatus=this.serviceConfigRecord.hasOwnProperty(`${nameSpace}Eligible_Status__c`)?(this.serviceConfigRecord[`${nameSpace}Eligible_Status__c`]?.split(',')):'';
    return eligibleStatus.includes(accountStatus);
  }
  handleNavigateToRecord(objectName,recordId) {
    
    // Use the navigate function to navigate to the record page
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            objectApiName: objectName, // Object API Name (e.g., 'Account', 'Contact')
            actionName: 'view' // Action name (e.g., 'view', 'edit')
        }
    });
}
handleSuccess(variant,title,message) {
  // Show success toast message
  const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant, // Can be 'success', 'error', 'info', or 'warning'
  });
  this.dispatchEvent(toastEvent);
}

  }