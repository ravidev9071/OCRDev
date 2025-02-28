import { LightningElement, track, api, wire } from "lwc";
import getPrescriberAccountList from "@salesforce/apex/OfficeContactMappingController.getPrescriberAccountList";
import createAffiliationRecords from "@salesforce/apex/OfficeContactMappingController.createAffiliationRecords";
import validateAffiliationRecords from "@salesforce/apex/OfficeContactMappingController.validateAffiliationRecords";
import fetchRecordTypeData from "@salesforce/apex/OfficeContactMappingController.fetchRecordTypeData";
import validateAccount from "@salesforce/apex/OfficeContactMappingController.validateEnrollmentCase";
import { CloseActionScreenEvent } from "lightning/actions";
import customListBox from "@salesforce/resourceUrl/customListBox";
import { loadStyle } from "lightning/platformResourceLoader";
import { CurrentPageReference } from "lightning/navigation";


import {
  showToastMessage,
  ERROR_VARIANT,
  ERROR_TITLE,
  WARNING_TITLE,
  WARNING_VARIANT,
  SAVE_TITLE,
  SUCCESS_VARIANT,
  REQUEST_PROCESS_ERROR,
  NO_RECORD_ERROR,
  SELECTION_ERROR,
  FILTER_CRITERIA_ERROR,
  OFFICE_CONTACT_ERROR,
  DUPLICATE_OFFICE_CONTACT_ERROR,
  OFFICE_CONTACT_SUCCESS_MESSAGE,
  PRESCRIBER_ERROR,
  DUPLICATE_PRESCRIBER_ERROR,
  PRESCRIBER_SUCCESS_MESSAGE,
  REMOVAL_SUCCESS_MESSAGE,
  SAVE_ERROR_MESSAGE,
  NO_RECORD_SELECTED_MESSAGE,
  HCS_ERROR,
  DUPLICATE_HCS_ERROR,
  HCS_SUCCESS_MESSAGE,
  PHARMACY_ERROR,
  DUPLICATE_PHARMACY_ERROR,
  PHARMACY_SUCCESS_MESSAGE,
  HCS_AR_ERROR,
  DUPLICATE_HCS_AR_ERROR,
  HCS_AR_SUCCESS_MESSAGE,
  AR_PHARMACY_ERROR,
  DUPLICATE_AR_PHARMACY_ERROR,
  AR_PHARMACY_SUCCESS_MESSAGE,
  NO_VALID_ENROLLMENT,
  SUCCESS_MESSAGE
} from "c/lwcUtilities";

const OFFICE_CONTACT_REC_TYPE = "Office_Contact";
const Health_Care_Setting_REC_TYPE = "Health_Care_Setting";
const PRESCRIBER_REC_TYPE = "Prescriber";
const InpatientPharm_REC_TYPE = "Inpatient_Pharmacy_Account";
const OutpatientPharm_REC_TYPE = "Outpatient_Pharmacy_Account";
const PharmacyParticipant_REC_TYPE = "Pharmacy_Participant";
const PRESCRIBER_DEL_REC_TYPE = "Prescriber_Delegate";//2166

const OFFICE_CONTACT_AFFILIATION = "Office Contact Affiliation";
const HCS_CONTACT_AFFILIATION = "Healthcare Setting Affiliation";
const PRESCRIBER_AFFILIATION = "Prescriber Affiliation";
const PHARMACY_AFFILIATION = "Pharmacy Affiliation";
const PHARMACY_STAFF_AFFILIATION = "AR/Pharmacy staff Affiliation";
const PRESCRIBER_DEL_AFFLIATION = "Prescriber Delegate Affiliation";//2166

const EMAIL_SEARCH = "Search By Email";
const NPI_SEARCH = "Search By NPI";
const NAME_SEARCH = "Search By Name";
const REMSID_SEARCH = "Search By REMS ID";//2166
const ADD_OFFICE_CONTACTS = "Add_Office_Contacts";
const ADD_HCS = "Add_HCS";
const ADD_AR_HCS = "Add_AR_HCS";
const ADD_PRESCRIBER = "Add_Prescriber";
const ADD_AR_PHARMACY = "Add_AR_Pharmacy";
const ADD_AR_PHARMACY_STAFF = "Add_AR_Pharmacy_staff";
const ADD_PRESCRIBER_DEL = "Add_Prescriber_Delegate";//2166 Quick Action Name

const ACTIVE_SECTION = [
  "Prescriber Information",
  "Office Contact Information",
  "HCS Information",
  "Pharmacy Information",
  "AR/Pharmacy Staff Information",
  "Prescriber Delegate Information",
  "Selected AR/Pharmacy Staff",
  "Selected Prescriber",
  "Selected Office Contact",
  "Selected HCS Account",
  "Selected Pharmacy",
  "Selected Prescriber Delegate",
  "Select Filter Criteria"
];
export default class officeContactMapping extends LightningElement {

  @api recordId;
  activeSections = ACTIVE_SECTION;
  isLoading = false;
  showDropDown = false;
  @track prescriberList = [];
  @track accountList = [];
  @track returnedPrescriberList = [];
  @track selectedValue;
  searchButtonLabel;
  selectedRecTypeInfo;
  searchRecTypeInfo;
  inputValue;
  selectedRecordId;
  selectedRecordRemsId;
  officeContactType = false;
  showTable = false;
  quickActionAPIName;
  errorMsg;
  duplicateMsg;
  successMsg;
  programId;

  // Initial fetch in ConnectedCallback
  connectedCallback() {
    this.isLoading = true;
  }

  //load custom css to override original css
  renderedCallback() {
    Promise.all([loadStyle(this, customListBox)]);
  }

  get options() {
    var radioOptions =  [];
    //2166 Start
    switch (this.quickActionAPIName) {
      case ADD_OFFICE_CONTACTS:
          radioOptions.push({ label: NAME_SEARCH, value: NAME_SEARCH });
          radioOptions.push({ label: EMAIL_SEARCH, value: EMAIL_SEARCH ,checked:false});
        break;
      case ADD_PRESCRIBER_DEL :
          radioOptions.push({ label: NAME_SEARCH, value: NAME_SEARCH });
          radioOptions.push({ label: EMAIL_SEARCH, value: EMAIL_SEARCH ,checked:false});
        break;
      case ADD_HCS :
          radioOptions.push({ label: NAME_SEARCH, value: NAME_SEARCH });
          radioOptions.push({ label: EMAIL_SEARCH, value: EMAIL_SEARCH ,checked:false});     
        break;     
      default:
          radioOptions.push({ label: NAME_SEARCH, value: NAME_SEARCH });
          radioOptions.push({ label: EMAIL_SEARCH, value: EMAIL_SEARCH ,checked:false});
          radioOptions.push({ label: NPI_SEARCH, value: NPI_SEARCH ,checked:false});
          radioOptions.push({ label: REMSID_SEARCH, value: REMSID_SEARCH ,checked:false});
    }
    //2166 End
    if(this.selectedValue) {
      radioOptions.forEach(ele => ele.checked = (ele.value == this.selectedValue));
    }
    return radioOptions;
  }

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
      if (currentPageReference.type === "standard__quickAction") {
          let quickActionPath = currentPageReference.attributes.apiName; // ex: Opportunity.My_Quick_Action
          this.quickActionAPIName = quickActionPath.split('.')[1]; // Ex: My_Quick_Action
          //this.quickActionAPIName = org_quickAction.split('__')[1];
          console.log('fullquickActionAPIName',this.quickActionPath);
      }
      console.log('currentPageReference.type',currentPageReference.type);
      console.log('currentPageReference.type',currentPageReference.attributes);
      console.log('currentPageReference.type',currentPageReference);
      console.log('quickActionAPIName',this.quickActionAPIName);
  }

  get modalTitle() {
    if(this.quickActionAPIName== ADD_OFFICE_CONTACTS){
      return OFFICE_CONTACT_AFFILIATION;
    }else if(this.quickActionAPIName == ADD_HCS || this.quickActionAPIName == ADD_AR_HCS){
      return HCS_CONTACT_AFFILIATION;
    }else if(this.quickActionAPIName == ADD_PRESCRIBER){
      return PRESCRIBER_AFFILIATION;
    }else if(this.quickActionAPIName == ADD_AR_PHARMACY){
      return PHARMACY_AFFILIATION;
    }else if(this.quickActionAPIName == ADD_AR_PHARMACY_STAFF){
      return PHARMACY_STAFF_AFFILIATION;
    }else if(this.quickActionAPIName == ADD_PRESCRIBER_DEL){
      return PRESCRIBER_DEL_AFFLIATION;
    }
  }

  handleSelected(event) {
    this.selectedValue = event.target.value;
    let updatedOptions = this.options.forEach(ele => ele.checked = (ele.value == this.selectedValue));

    this.options = [...updatedOptions];
  }

  @wire(fetchRecordTypeData, {recordId: "$recordId"})
  async getRecordTypeDetails({ error, data }) {
    if (data) {
      let result = data;
      console.log();
      let validAccount = true;
      if(this.quickActionAPIName == ADD_AR_PHARMACY_STAFF){
        await validateAccount({recordId:this.recordId,quickActionName:this.quickActionAPIName}).then(caseResult => {
          validAccount = caseResult;
        })
      }
      if(validAccount) {
      this.selectedRecordRemsId = result.programId;
      this.programId = result.programId;
      this.currentRecordTypeName = result.recordTypeName;
      this.recordTypeName = Health_Care_Setting_REC_TYPE;
      console.log(this.quickActionAPIName);
      console.log(this.currentRecordTypeName);
      console.log(this.recordTypeName);

      if (this.quickActionAPIName== ADD_OFFICE_CONTACTS) {
        this.officeContactType = true;
        this.searchRecTypeInfo = 'Office Contact Information';
        this.selectedRecTypeInfo = 'Selected Office Contact';
        this.searchButtonLabel = 'Search Office Contact';
        this.recordTypeName = OFFICE_CONTACT_REC_TYPE;
      }else if(this.quickActionAPIName == ADD_HCS || this.quickActionAPIName == ADD_AR_HCS){
        this.searchRecTypeInfo = 'HCS Information';
        this.selectedRecTypeInfo = 'Selected HCS Account';
        this.searchButtonLabel = 'Search HCS';
        this.recordTypeName = Health_Care_Setting_REC_TYPE;
      }else if(this.quickActionAPIName == ADD_PRESCRIBER){
        this.searchRecTypeInfo = 'Prescriber Information';
        this.selectedRecTypeInfo = 'Selected Prescriber';
        this.searchButtonLabel = 'Search Prescriber';
        this.recordTypeName = PRESCRIBER_REC_TYPE;
      }else if(this.quickActionAPIName == ADD_AR_PHARMACY){
        this.searchRecTypeInfo = 'Pharmacy Information';
        this.selectedRecTypeInfo = 'Selected Pharmacy';
        this.searchButtonLabel = 'Search Pharmacy';
        this.recordTypeName = InpatientPharm_REC_TYPE+';'+OutpatientPharm_REC_TYPE;
      }else if(this.quickActionAPIName == ADD_AR_PHARMACY_STAFF){
        this.searchRecTypeInfo = 'AR/Pharmacy Staff Information';
        this.selectedRecTypeInfo = 'Selected AR/Pharmacy Staff';
        this.searchButtonLabel = 'Search AR/Pharmacy Staff';
        this.recordTypeName = PharmacyParticipant_REC_TYPE;
      }else if(this.quickActionAPIName == ADD_PRESCRIBER_DEL){//2166
        this.searchRecTypeInfo = 'Prescriber Delegate Information';
        this.selectedRecTypeInfo = 'Selected Prescriber Delegate';
        this.searchButtonLabel = 'Search Prescriber Delegate';
        this.recordTypeName = PRESCRIBER_DEL_REC_TYPE;
      }
      this.isLoading = false;
      }else{
        showToastMessage(ERROR_TITLE, NO_VALID_ENROLLMENT, ERROR_VARIANT);
        this.isLoading = true;
        this.dispatchEvent(new CloseActionScreenEvent());
      }
    } else if (error) {
      showToastMessage(ERROR_TITLE, REQUEST_PROCESS_ERROR, ERROR_VARIANT);
      this.isLoading = false;
    }
  }

  fetchPrescriberRecord = async (event) => {
    let searchTerm = event.target.value;
    if (searchTerm.length >= 1 && this.recordTypeName && this.selectedValue) {
      this.showDropDown = true;
      try {
        let result = await getPrescriberAccountList({
          searchKey: searchTerm,
          recordTypeName: this.recordTypeName,
          filterCriteria: this.selectedValue,
          programId: this.selectedRecordRemsId,
          currentRecordTypeName : this.currentRecordTypeName
        });
        if (result) {
               this.returnedPrescriberList = result;
        }
      } catch (ex) {
        if (searchTerm.length >= 5) {
          showToastMessage(WARNING_TITLE, NO_RECORD_ERROR, WARNING_VARIANT);
          this.isLoading = false;
          this.returnedPrescriberList = [];
        }
      }
    } else {
      this.showDropDown = false;
    }
  };

  handlePrescriberSelection = (event) => {
    this.selectedRecordId = event.currentTarget.dataset.id;
    this.inputValue = event.currentTarget.dataset.name;
    this.showDropDown = false;
    this.recordTypeName = event.currentTarget.dataset.recordtype;
  };

  addSelectedRecord = (event) => {
    if (this.selectedValue) {

      let foundElement = false;
      for (let i = 0; i < this.accountList.length; i++) {
        if (this.selectedRecordId === this.accountList[i].Id) {
          foundElement = true;
          break;
        }
      }
      if (foundElement) {
        showToastMessage(WARNING_TITLE, SELECTION_ERROR, WARNING_VARIANT);
      } else {
          this.addTargetRecord();
      }
    } else {
      showToastMessage(WARNING_TITLE, FILTER_CRITERIA_ERROR, WARNING_VARIANT);
    }
  };

  addTargetRecord = async (event) => {
    this.isLoading = true;
    this.recordTypeHandler();
    if (this.returnedPrescriberList.length == 0) {
      showToastMessage(WARNING_TITLE, this.errorMsg, WARNING_VARIANT);
      this.isLoading = false;
    } else {

      let result = await validateAffiliationRecords({
        currentRecord: this.recordId,
        targetRecord: this.selectedRecordId,
        remsProgramId: this.selectedRecordRemsId,
        currentRecordTypeName:this.currentRecordTypeName,
        targetRecordTypeName:this.recordTypeName,
        quickActionName: this.quickActionAPIName
      });
      if (result == true) {
        showToastMessage(
          WARNING_TITLE,
          this.duplicateMsg,
          WARNING_VARIANT
        );
        this.isLoading = false;
      } else {
        this.returnedPrescriberList.forEach((ele) => {
          if (ele.Id == this.selectedRecordId) {
            const userList = {
              Id: ele.Id,
              Name: ele.Name,
              Email: ele.US_WSREMS__productdi__Email__c,
              Phone: ele.Phone?ele.Phone:ele.US_WSREMS__productdi__Phone_Number__c,
              RemsId: ele.US_WSREMS__productdi__REMS_Program__c,
              Npi: ele.US_WSREMS__productdi__National_Provider_Identifier__c?ele.US_WSREMS__productdi__National_Provider_Identifier__c:null 
            };
            this.accountList = [...this.accountList, userList];
          }
        });
        if (this.accountList.length > 0) {
          this.showTable = true;
          showToastMessage(
            SUCCESS_MESSAGE,
            this.successMsg,
            SUCCESS_VARIANT
          );
          this.isLoading = false;
        }
      }
    }
  };

  recordTypeHandler(){
    
    if(this.recordTypeName == OFFICE_CONTACT_REC_TYPE){
      this.errorMsg=OFFICE_CONTACT_ERROR;
      this.duplicateMsg=DUPLICATE_OFFICE_CONTACT_ERROR;
      this.successMsg=OFFICE_CONTACT_SUCCESS_MESSAGE;
    }else if(this.recordTypeName == Health_Care_Setting_REC_TYPE){
      this.errorMsg=HCS_ERROR;
      this.duplicateMsg=DUPLICATE_HCS_ERROR;
      this.successMsg=HCS_SUCCESS_MESSAGE;
      if(this.quickActionAPIName == ADD_AR_HCS){
        this.errorMsg=HCS_AR_ERROR;
        this.duplicateMsg=DUPLICATE_HCS_AR_ERROR;
        this.successMsg=HCS_AR_SUCCESS_MESSAGE;
      }
    }else if(this.recordTypeName == PRESCRIBER_REC_TYPE){
      this.errorMsg=PRESCRIBER_ERROR;
      this.duplicateMsg=DUPLICATE_PRESCRIBER_ERROR;
      this.successMsg=PRESCRIBER_SUCCESS_MESSAGE;
    }else if(this.recordTypeName == InpatientPharm_REC_TYPE || this.recordTypeName == OutpatientPharm_REC_TYPE 
      || this.recordTypeName == InpatientPharm_REC_TYPE+';'+OutpatientPharm_REC_TYPE){
      this.errorMsg=PHARMACY_ERROR;
      this.duplicateMsg=DUPLICATE_PHARMACY_ERROR;
      this.successMsg=PHARMACY_SUCCESS_MESSAGE;
    }else if(this.recordTypeName == PharmacyParticipant_REC_TYPE){
      this.errorMsg=AR_PHARMACY_ERROR;
      this.duplicateMsg=DUPLICATE_AR_PHARMACY_ERROR;
      this.successMsg=AR_PHARMACY_SUCCESS_MESSAGE;
    }
  }

  // To close the quick Action
  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  disableRemove = true;

  handleRecordSelection = (event) => {
    this.accountList = event.detail.records;
    this.disableRemove = event.detail.disable;
  };

  handleChildEvent = (event) => {
    let isRecordSelected = event.detail.isRowSelected;
    if (isRecordSelected) {
      this.disableRemove = false;
    }
  };

  removeSelectedRecords(event) {
    this.isLoading = true;
    this.template
      .querySelector("c-office-contact-mapping-child")
      .handleRemoveAction();
    showToastMessage(SUCCESS_MESSAGE, REMOVAL_SUCCESS_MESSAGE, SUCCESS_VARIANT);
    this.isLoading = false;
    this.isRecordSelected = false;
  }

  doSave = false;

  handleSaveEvent = (event) => {
    this.accountList = event.detail.records;
    this.doSave = event.detail.selected;
    console.log(event.detail.records,event.detail.selected);
  };

  handleRecordSubmit = async (event) => {
    console.log(this.recordId);
    console.log(this.recordTypeName);
    console.log(this.currentRecordTypeName);
    console.log(this.accountList);
    console.log(this.quickActionAPIName);
    this.isLoading = true;
    if (this.recordId && this.accountList.length > 0 && this.recordTypeName) {
      this.template
        .querySelector("c-office-contact-mapping-child")
        .handleSaveAction();
      if (this.doSave) {
        console.log(this.recordId);
        console.log(this.recordTypeName);
        console.log(this.currentRecordTypeName);
        console.log(this.accountList);
        console.log(this.quickActionAPIName);

        try {
          let result = await createAffiliationRecords({
            recordId: this.recordId,
            recordTypeName: this.recordTypeName,
            currentRecordTypeName: this.currentRecordTypeName,
            accountRecords: this.accountList,
            quickActionName: this.quickActionAPIName,
            programName: this.programId
          });
          if (result == "SUCCESS") {
            showToastMessage(SUCCESS_MESSAGE, SAVE_TITLE, SUCCESS_VARIANT);
            this.isLoading = false;
            this.closeAction();
          } else {
            showToastMessage(ERROR_TITLE, result, ERROR_VARIANT);
            this.isLoading = false;
            this.closeAction();
          }
        } catch (error) {
          showToastMessage(ERROR_TITLE, SAVE_ERROR_MESSAGE, ERROR_VARIANT);
          this.isLoading = false;
          this.closeAction();
        }
      } else {
        showToastMessage(
          WARNING_TITLE,
          NO_RECORD_SELECTED_MESSAGE,
          WARNING_VARIANT
        );
        this.isLoading = false;
      }
    } else {
      showToastMessage(
        WARNING_TITLE,
        NO_RECORD_SELECTED_MESSAGE,
        WARNING_VARIANT
      );
      this.isLoading = false;
    }
  };
}