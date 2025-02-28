import { LightningElement, api, track, wire } from "lwc";
import getCurrentUserProgramServices from "@salesforce/apex/ServiceEnrollment.getCurrentUserProgramServices";
import validateAccountStatus from "@salesforce/apex/ServiceEnrollment.validateAccountStatus";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getNameSpace from "@salesforce/apex/OCRFormCtrl.getNameSpace";
import getServiceConfigRecords from "@salesforce/apex/ServiceEnrollment.getServiceConfigRecords";
import { openTab } from "lightning/platformWorkspaceApi";
import {CurrentPageReference} from 'lightning/navigation';
import { updateRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import getServiceConfigs from "@salesforce/apex/OCRFormCtrl.getServiceConfigRecords";
import getAccountStatus from "@salesforce/apex/OCRRemsAccountCreation.getAccountStatus";
import getCasesForStakeholder from "@salesforce/apex/OCRFormCtrl.getCasesForStakeholder";
import kaDuplicateError from "@salesforce/label/c.KA_duplicate_Case_Error";
import PARTICIPANTTYPEAPPLICABLEMSG from "@salesforce/label/c.ParticipantTypeApplicableMsg";

export default class NewServiceEnrollment extends LightningElement {
  @api selectedServiceValue;
  @api selectedParticipantValue;
  @api recordTypeName;
  @api pageLayoutConfigId;
  @api accountId;
  @track programRecords = [];
  @track programService = [];
  @track participantTypeList = [];
  @track accountRecordTypeList = [];
  programUserName;
  selectedCaseValue;
  showServicesRadioButton = false;
  showParticipantRadioButton = false;
  showFormLayout = false;
  showNewCmp = false;
  isLoading = false;
  subParticipantType;
  subParticipantList;
  subParticipantValues = [];
  selectedSubParticipant;
  showSubParticipantRadioButton = false;
  participantToCase;
  @api programId;
  accountError = false;
  @api currentUserProgramName;
  serviceConfigRecord;
  serviceRecord = {};
  namespaceVar;
   validatedSuccessfully = false ;
  documentId;
  urlStateParameters;
  isCaseOpen = false;
  @api participantType;
  redirectTonewCmp = false;

  label = {
    PARTICIPANTTYPEAPPLICABLEMSG
  };

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
      if (currentPageReference) {
        this.urlStateParameters = currentPageReference.state;
        this.setParametersBasedOnUrl();
      }
  }
  setParametersBasedOnUrl() {
       this.documentId = this.urlStateParameters.uid || null;
  }
  connectedCallback() {
    this.handleNameSpace();
    this.isLoading = true;
    this.fetchLoggedInUserActiveProgramService();
    window.addEventListener('popstate', () => {
        this.isLoading = true;
        this.fetchLoggedInUserActiveProgramService();
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

  handleServiceCreation() {
    getServiceConfigRecords({
      serviceType: this.selectedServiceValue,
      programName: this.currentUserProgramName,
      accountId: this.accountId
    })
      .then((result) => {
        this.serviceRecord = result;
        let nameSpace = this.namespaceVar;
        this.serviceConfigRecord =result[`${nameSpace}Warning_Message__c`];
      })
      .catch((error) => {
       console.log('Error message'+error)
      });
    }

  fetchLoggedInUserActiveProgramService = async (event) => {
    try {
      let result = await getCurrentUserProgramServices();
      if (result) {
        this.showServicesRadioButton = true;
        this.programRecords = result;
        this.programUserName = result[0].programName;
        this.programRecords.forEach((element) => {
          if(element.participantType.includes(this.participantType)){
          const serviceList = {
            label: element.serviceName,
            value: element.serviceName
          };
          this.programService = [...this.programService, serviceList];
          }
          else if(this.participantType==null && this.participantType == undefined){
            const serviceList = {
            label: element.serviceName,
            value: element.serviceName
          };
          this.programService = [...this.programService, serviceList];
          }
        });
      }
      this.programService.sort((a, b) =>
        a.label > b.label ? 1 : b.label > a.label ? -1 : 0
      );
      this.timeOutInterval();
    } catch (ex) {
      this.showToastNotification(
        "Error",
        "No Active Program is associated with your user",
        "error"
      );
      this.timeOutInterval();
    }
  };

  fetchServiceParticipantType = async (event) => {
    try {
      //this.isLoading = true;
      this.programRecords.forEach((element) => {
        if (element.serviceName === this.selectedServiceValue) {
          
          let participant = element.participantType.split(";");
          participant.forEach((ele) => {
            const participantList = {
              label: ele,
              value: ele
            };
            this.participantTypeList = [
              ...this.participantTypeList,
              participantList
            ];
          });
          this.participantTypeList.sort((a, b) =>
            a.label > b.label ? 1 : b.label > a.label ? -1 : 0
          );
        }
      });
      //this.showServicesRadioButton = false;
      //this.showParticipantRadioButton = true;
      this.timeOutInterval();
    } catch (ex) {
      this.showToastNotification(
        "Error",
        "No Active Program is associated with your user",
        "error"
      );
      this.timeOutInterval();
    }
  };

  handleChange = async (event) => {
    this.selectedServiceValue = event.detail.value;
    this.isCaseOpen = false;
    if(this.selectedServiceValue == "Change Authorized Representative" ){
      this.ShowSpinner = true;
      getAccountStatus({ accountId: this.accountId })
        .then((result) => {
          let blockedStatus = ['Decertified','Cancelled','Deactivated']
          if(blockedStatus.includes(result)){
            this.ShowSpinner = false;
            this.accountError = true;
            this.showToastNotification(
              "Error",
              'A Change Authorized Representative service cannot be opened due to the stakeholder status',
              "Error"
            );
          }
        })
        .catch((error) => {
          this.ShowSpinner = false;
        });
    }
    
    this.handleServiceCreation();
    this.validatedSuccessfully = false;
      if (this.selectedServiceValue) {
        try{
      let result = await validateAccountStatus({
        accountId: this.accountId,
        programName:this.currentUserProgramName,
        serviceType:this.selectedServiceValue 
      });
      if (result) {
         this.validatedSuccessfully = true;
      } else {
       this.participantTypeList = [] ;
      await this.fetchServiceParticipantType();
      }
     }catch (error) {
        this.showToastNotification(
          "Error",
           this.label.PARTICIPANTTYPEAPPLICABLEMSG,
          "Error"
      );
    }
    }

    if(this.selectedServiceValue.toLowerCase() === 'knowledge assessment'.toLowerCase() && this.accountId != null){
      this.isLoading = true;
      await this.getCases();
      this.isLoading = false;
      if(this.isCaseOpen){
          this.showToastNotification(
              "Error",
              kaDuplicateError,
              "Error"
          );
          return;
      }
    }
    
  };



  handleParticipantChange = async (event) => {
    this.selectedParticipantValue = event.detail.value;
    this.participantToCase = event.detail.value;
    await this.getParticipantConfig();
    this.timeOutInterval();
  };

  handlePrevious = (event) => {
    this.showFormLayout = false;
    this.showParticipantRadioButton = true;
    this.showNewCmp = false;
  };

  handleParticipantPreviousClick = (event) => {
    this.showServicesRadioButton = true;
    this.showParticipantRadioButton = false;
  };

  handleParticipantNextClick = async (event) => {
    if(this.isCaseOpen){
        this.showToastNotification(
            "Error",
            kaDuplicateError,
            "Error"
        );
        return;
    }
    if(this.accountError){
      return this.showToastNotification(
        "Error",
        'A Change Authorized Representative service cannot be opened due to the stakeholder status',
        "Error"
      );
    }
    if(this.selectedServiceValue ==='Change of Information' || this.selectedServiceValue ==='Disenrollment'){
      this.closeQuickSubtab(this.accountId);
    }else{
      if (this.selectedParticipantValue !== undefined) {
        this.isLoading = true;
        if(this.subParticipantValues.length>0 && !this.selectedSubParticipant) {
          this.showToastNotification(
            "Error",
            "Please Select Sub participant value",
            "Error"
          );
    
        }else{
        this.showFormLayout = true;
        this.showNewCmp = false;
        this.showParticipantRadioButton = false;
        this.showServicesRadioButton = false;
        if(this.redirectTonewCmp){
          this.showNewCmp = true;
          this.showFormLayout = false;
        }
        }
      }else{
        this.showToastNotification("Error",'Please select the participant type to proceed!!', "Error");
      }
      this.timeOutInterval();
    }
};

  handleServicePreviousClick = (event) => {
    this.dispatchEvent(new CustomEvent("previous"));
    this.showServicesRadioButton = false;
  };

  handleServiceNextClick = (event) => {
    if(this.accountError){
      return this.showToastNotification(
        "Error",
        'A Change Authorized Representative service cannot be opened due to the stakeholder status',
        "Error"
      );
    }
    if(this.isCaseOpen){
      this.showToastNotification(
          "Error",
          kaDuplicateError,
          "Error"
      );
      return;
    }
    if(this.validatedSuccessfully){
      this.showToastNotification("Something went wrong",this.serviceConfigRecord, "Error"
      );
    }else {
        this.selectedParticipantValue= this.participantType;
      if (this.selectedServiceValue !== undefined) {
        this.participantToCase = this.selectedParticipantValue;
        this.getParticipantConfig();
        this.showParticipantRadioButton = true;
        this.showServicesRadioButton = false;
        }else{
          this.showToastNotification("Error",'Please select the service to proceed!!', "Error");
        }
      this.timeOutInterval();
    }
  };
  
   async closeQuickSubtab(result) {
    let nameSpace = this.namespaceVar;
    const fields ={};
    fields['Id'] = result;
    fields[`${nameSpace}FaxId__c`] = this.documentId;
    const recordInput = {fields};
    await updateRecord(recordInput);
    this.invokeWorkspaceAPI("isConsoleNavigation").then((isConsole) => {
      if (isConsole) {
        this.invokeWorkspaceAPI("getFocusedTabInfo").then(
          async (focusedTab) => {
            openTab({ 
              recordId: result, 
              focus: true 
              })
              .then((_) => {
                this.invokeWorkspaceAPI("closeTab", {
                  tabId: focusedTab.tabId
                });
              })
              .catch((error) =>
                this.showToastNotification(
                  "Error",
                  reduceErrors(error).join(", "),
                  "Error"
                )
              );
          }
        );
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
  showToastNotification = (title, message, variant) => {
    const evt = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(evt);
  };
  async getCases(){
    await getCasesForStakeholder({accountId:this.accountId, serviceConfigObj : this.serviceRecord})
      .then(result =>{
        this.isCaseOpen = result.length > 0;
      })
  }

  timeOutInterval = (event) => {
    setInterval(() => {
      this.isLoading = false;
    }, 4000);
  };

  async getParticipantConfig(){
    let nameSpace = this.namespaceVar;
    this.subParticipantValues = [];
    this.showSubParticipantRadioButton = false;
    await getServiceConfigs({
    participantType: this.selectedParticipantValue,
    serviceType: this.selectedServiceValue,
    programName: this.currentUserProgramName
  })
    .then((result) => {
      this.serviceRecord = result;
      this.redirectTonewCmp = result[`${nameSpace}SwitchtoNewCaseCmp__c`];
      this.subParticipantType = result[`${nameSpace}Sub_Participant_Type__c`];
        if(this.subParticipantType){
            this.subParticipantList = this.subParticipantType.split(";");
          if(this.subParticipantList){
            this.subParticipantList.forEach((element) => {
              const subParticipant = {
                label: element,
                value: element
              };
              this.subParticipantValues = [...this.subParticipantValues, subParticipant];
            });
            this.showSubParticipantRadioButton = true;
          }
        }
        if(this.showParticipantRadioButton && result[`${nameSpace}Service_Record_Type__c`] == 'Change_Authorized_Representative' ){
          getAccountStatus({ accountId: this.accountId })
            .then((result) => {
              let blockedStatus = ['Decertified','Cancelled','Deactivated']
              if(blockedStatus.includes(result)){
                this.ShowSpinner = false;
                this.accountError = true;
                this.showToastNotification(
                  "Error",
                  'A Change Authorized Representative service cannot be opened due to the stakeholder status',
                  "Error"
                );
              }
            })
            .catch((error) => {

            });
        }
    })
    .catch((error) => {
      this.showToastNotification(
        "Error",
        reduceErrors(error).join(", "),
        "Error"
      );
    });
  }

  handleSubParticipantChange(event){
    this.selectedSubParticipant = event.detail.value;
    this.participantToCase = event.detail.value;
  }
}