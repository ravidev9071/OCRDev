import { LightningElement,wire,api } from 'lwc';
import getProgramServices from '@salesforce/apex/ServiceEnrollment.getStakeholderProgramServiceConfigList';
import getAccountData from '@salesforce/apex/ServiceEnrollment.getStakeholderrecord';
import getNameSpace from "@salesforce/apex/OCRFormCtrl.getNameSpace";
import getActiveProgram from '@salesforce/apex/DocumentReviewController.getActiveProgram';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from 'lightning/actions';
import serviceSelectionMsg from "@salesforce/label/c.Existing_Service_Selection_Msg";
import NoActiveProgramMsgLabel from "@salesforce/label/c.NoActiveProgramMsg";
import getServiceConfigs from "@salesforce/apex/OCRFormCtrl.getServiceConfigRecords";
import validateAccountStatus from "@salesforce/apex/ServiceEnrollment.validateAccountStatus";
import getAccountStatus from "@salesforce/apex/OCRRemsAccountCreation.getAccountStatus";

export default class StakeholderServicesCmp extends LightningElement {
    programName;
    isLoading = false;
    participantType;
    programId;
    @api recordId;
    namespaceVar;
    programServices;
    selectedService;
    currentUserProgramName;
    showFormLayout=false;
    showNewCmp = false;
    label = {
        serviceSelectionMsg,
        NoActiveProgramMsgLabel
    }
  subParticipantType;
  subParticipantList;
  subParticipantValues = [];
  selectedSubParticipant;
  showSubParticipantRadioButton = false;
  participantToCase;
  validatedSuccessfully = false ;
  serviceConfigRecord;
  redirectTonewCmp = false;

    @wire(getAccountData, { accountId: "$recordId"})
   async wiredaccountData({ error, data }){
        if(data) {
            await this.handleNameSpace();
            let nameSpace = this.namespaceVar;

            this.programName = data[`${nameSpace}Program_Picklist__c`];
            this.participantType = data[`${nameSpace}Recordtype_Label__c`];
            this.programId = data[`${nameSpace}REMS_Program__c`];
            this.getActiveProgram();
            this.handleProgramServices();
        }
        if(error) {
            console.log('erro status -' + error);
        }
    }

    
  handleNameSpace= async () => {
    let result = await getNameSpace();

    if(result){
        this.namespaceVar =result;

      }
      
    }

    handleProgramServices(){
        getProgramServices({
            programId:this.programId,
            StakeHolderType:this.participantType
        })
          .then((result) => {
            let nameSpace = this.namespaceVar;
            let programServicesList = [];
            result.forEach(function (item, index) {
                var fields = { label: item[`${nameSpace}Service_Name__c`], value: item[`${nameSpace}Service_Name__c`] }
                programServicesList.push(fields);
            });
            this.programServices = programServicesList;
          })
          .catch((error) => {
            this.showToastNotification(
              "Error",
              reduceErrors(error).join(", "),
              "Error"
            );
          });
    }

    async handleProgramServiceChange(event){
        this.selectedService = event.detail.value;
        this.validatedSuccessfully = false;
        if (this.selectedService) {
          await this.getParticipantConfig();
        }
    }

    getActiveProgram = async () => {
        let result = await getActiveProgram();
        if (result) {
            let nameSpace = this.namespaceVar;
            this.programUser = result;
            this.currentUserProgramName= result[`${nameSpace}REMS_Program__r`][`Name`];
        }else {
            this.showToastNotification('Error', this.label.NoActiveProgramMsgLabel, 'error');
        }
    }

    async handleNextClick(event){
      if(this.selectedService){
        this.isLoading = true;
        let accountError = false;
        if(this.selectedService == "Change Authorized Representative" && this.recordId != null){
          await getAccountStatus({ accountId: this.recordId })
            .then((result) => {
              let allowedStatus = ['Certified']
              if(!allowedStatus.includes(result)){
                accountError = true;
                this.isLoading = false;
                return this.showToastNotification(
                  "Error",
                  'A Change Authorized Representative service cannot be opened due to the stakeholder status',
                  "Error"
                );
              }else{
                this.isLoading = false;
                accountError = false;
              }
            })
            .catch((error) => {
              this.isLoading = false;
              accountError = false;
              this.showToastNotification(
                "Error",
                error,
                "Error"
              );
            });
        }
        if(accountError == true){
          return this.showToastNotification(
            "Error",
            'A Change Authorized Representative service cannot be opened due to the stakeholder status',
            "Error"
          );
        }
        let result = await validateAccountStatus({
          accountId: this.recordId,
          programName:this.currentUserProgramName,
          serviceType:this.selectedService 
        });
        if (result) {
          this.validatedSuccessfully = true;
        } 
      if(this.validatedSuccessfully){
        this.showToastNotification("Something went wrong",this.serviceConfigRecord, "Error"
        );
        }else{
          this.isLoading = false;
      if(this.subParticipantValues.length>0){
        this.showSubParticipantRadioButton = true;
        this.showFormLayout = false;
            this.showNewCmp = false;
        }else{
            this.showFormLayout = true;
                this.showNewCmp = false;
                if(this.redirectTonewCmp){
                  this.showNewCmp = true;
                  this.showFormLayout = false;
                }
        }
        }
      }else{
        this.showToastNotification('Error', this.label.serviceSelectionMsg, 'error');
      }

    }

    handleSubPtNextClick(event){
    if(this.selectedSubParticipant){
            this.showFormLayout = true;
        }else{
            this.showToastNotification('Error',"Please Select Sub participant value", 'error');
        }
    }
    showToastNotification = (title, message, variant) => {
        const evt = new ShowToastEvent({
          title,
          message,
          variant
        });
        this.dispatchEvent(evt);
      };

      handleCancel(event){
        this.dispatchEvent(new CloseActionScreenEvent());
      }

      handlePrevious(event){
        this.showFormLayout = false;
        this.showNewCmp = false;
        if(this.selectedSubParticipant){
          this.showSubParticipantRadioButton = true;
        }else{
          this.showSubParticipantRadioButton = false;
        }
        
      }

      handleSubPtPrev(event){
        this.showFormLayout = false;
          this.showSubParticipantRadioButton = false;
      }

      async getParticipantConfig(){
        let nameSpace = this.namespaceVar;
        this.subParticipantValues = [];
        this.showSubParticipantRadioButton = false;
        await getServiceConfigs({
        participantType: this.participantType,
        serviceType: this.selectedService,
        programName: this.currentUserProgramName
      })
        .then((result) => {
          this.subParticipantType = result[`${nameSpace}Sub_Participant_Type__c`];
          this.serviceConfigRecord =result[`${nameSpace}Warning_Message__c`];
          this.redirectTonewCmp = result[`${nameSpace}SwitchtoNewCaseCmp__c`];
          this.showNewCmp = false;
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
              }
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
        this.participantType = event.detail.value;
      }
}