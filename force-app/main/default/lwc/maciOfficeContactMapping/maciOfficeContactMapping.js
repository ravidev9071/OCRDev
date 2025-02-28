import { LightningElement, track, api, wire } from 'lwc';
import getPrescriberAccountList from "@salesforce/apex/MaciOfficeContactMappingController.getPrescriberAccountList";
import createPrescriberAffiliationRecords from "@salesforce/apex/MaciOfficeContactMappingController.createPrescriberAffiliationRecords";
import validateAffiliationRecords from "@salesforce/apex/MaciOfficeContactMappingController.validateAffiliationRecords";
import fetchRecordTypeData from "@salesforce/apex/MaciOfficeContactMappingController.fetchRecordTypeData";
import { CloseActionScreenEvent } from "lightning/actions";
import customListBox from "@salesforce/resourceUrl/MaciCustomListBox";
import { loadStyle } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
const ACTIVE_SECTION = [
  "Prescriber Information",
  "Selected Prescriber",
  "Office Contact Information",
  "Selected Office Contact",
  "Select Filter Criteria"
];
export default class MaciOfficeContactMapping extends LightningElement {
  @api recordId;
  activeSections = ACTIVE_SECTION;
  isLoading = false;

  @track prescriberList = [];
  @track accountList = [];

  showDropDown = false;
  @track returnedPrescriberList = [];

  inputValue;
  selectedRecordId;
  selectedRecordRemsId;
  officeContactType = false;
  showTable = false;
 
  hideDefault = false;

  value = '';
  @track selectedValue = 'Search By Name';
  get options() {
    return this.recordTypeName == 'Office Contact' ? [
      { label: 'Search By Name', value: 'Search By Name' },
      { label: 'Search By Email', value: 'Search By Email' },
    ]: [
      { label: 'Search By Name', value: 'Search By Name' },
      { label: 'Search By NPI', value: 'Search By NPI' },
    ]
  }

  isSearchByEmail = false;
  isSearchByNPI = false;
  isSearchByName = false;

  get modalTitle() {
    return this.recordTypeName == 'Office Contact' ? 'Office Contact Affiliation' : 'Prescriber Affiliation'
  }

  notificationValue = 'Opt-in';
  phoneNumber = null;
    get notificationOptions() {
        return [
            { label: 'Opt-in', value: 'Opt-in' },
            { label: 'Opt-out', value: 'Opt-out' },
        ];
    }

    handleNotificationChange(event) {
        this.notificationValue = event.detail.value;
    }

    phoneNumberChange(event) {
      this.phoneNumber = event.detail.value;
    }

  handleSelected(event) {
    this.selectedValue = event.target.value;
    if (this.selectedValue === 'Search By Email') {
      this.isSearchByEmail = true;
    } else if (this.selectedValue === 'Search By NPI') {
      this.isSearchByNPI = true;
    } else {
      this.isSearchByEmail = false;
    }
  }

  // Initial fetch in ConnectedCallback
  connectedCallback() {
    this.isLoading = true;
  }

  // interval for setting timeout for loader
  timeOutInterval = (event) => {
    setInterval(() => {
      this.isLoading = false;
    }, 2000);
  };

  //load custom css to override original css
  renderedCallback() {
    Promise.all([loadStyle(this, customListBox)]);
  }

  @wire(fetchRecordTypeData, {
    recordId: '$recordId'
  })
  getRecordTypeDetails({ error, data }) {
    if (data) {
      this.recordTypeName = data;
      if (this.recordTypeName == 'Office Contact') {
        this.hideDefault = true
        this.officeContactType = true;
      }
      this.isLoading = false;
    } else if (error) {
      const event = new ShowToastEvent({
        title: "Unable to Process the Request",
        variant: "error",
        message: ""
      });
      this.dispatchEvent(event);
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
          filterCriteria: this.selectedValue
        });
        if (result) {
          this.returnedPrescriberList = result;
        }
      } catch (ex) {
        if (searchTerm.length >= 5) {
          const event = new ShowToastEvent({
            title: "No Records with entered keywords found",
            variant: "warning",
            message: ""
          });
          this.dispatchEvent(event);
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
    this.selectedRecordRemsId = event.currentTarget.dataset.rems;
    this.showDropDown = false;
  };

  addSelectedRecord = (event) => {
    if (this.selectedValue) {
      if (this.recordTypeName == 'Office Contact') {
        if (this.accountList.length == 0) {
          this.addOfficeContact();
        } else {
          let foundElement = false;
          for (let i = 0; i < this.accountList.length; i++) {
            if (this.selectedRecordId === this.accountList[i].Id) {
              foundElement = true;
              break;
            }
          }
          if (foundElement) {
            const event = new ShowToastEvent({
              title: "Record already Added.",
              variant: "warning",
              message: ""
            });
            this.dispatchEvent(event);
          } else {
            this.addOfficeContact();
          }
        }
      } else {
        if (this.accountList.length == 0) {
          this.addPrescriber();
        } else {
          let foundElement = false;
          for (let i = 0; i < this.accountList.length; i++) {
            if (this.selectedRecordId === this.accountList[i].Id) {
              foundElement = true;
              break;
            }
          }
          if (foundElement) {
            const event = new ShowToastEvent({
              title: "Record already Added.",
              variant: "warning",
              message: ""
            });
            this.dispatchEvent(event);
          } else {
            this.addPrescriber();
          }
        }
      }
    } else {
      const custEvent = new ShowToastEvent({
        title: "No Filter Criteria Selected",
        variant: "warning",
        message: ""
      });
      this.dispatchEvent(custEvent);
    }
  }

  addOfficeContact = async (event) => {
    this.isLoading = true;
    if (this.returnedPrescriberList.length == 0) {
      const event = new ShowToastEvent({
        title: "No Office Contact selected! Please select atleast one Record to proceed further.",
        variant: "warning",
        message: ""
      });
      this.dispatchEvent(event);
      this.isLoading = false;
    } else {
      let result = await validateAffiliationRecords({
        officeContactAccountId: this.selectedRecordId,
        prescriberId: this.recordId,
        remsProgramId: this.selectedRecordRemsId
      })
      if (result == true) {
        const event = new ShowToastEvent({
          title: "Duplicate affiliation already exists with selected Office Contact for current Prescriber",
          variant: "warning",
          message: ""
        });
        this.dispatchEvent(event);
        this.isLoading = false;
      } else {
        this.returnedPrescriberList.forEach((ele) => {
          if (ele.Id == this.selectedRecordId) {
            const userList = {
              Id: ele.Id,
              Name: ele.Name,
              Email: ele.US_WSREMS__Email__c,
              Phone: ele.Phone,
              Status: ele.US_WSREMS__Status__c,
              RemsId: ele.SYN_Ref_Id__c,
			  RemsProgram: ele.US_WSREMS__REMS_Program__c
            };
            this.accountList = [...this.accountList, userList];
			if(this.phoneNumber == null) {
				this.phoneNumber = ele.Phone;
			}
          }
        })
        if (this.accountList.length > 0) {
          this.showTable = true;
          const event = new ShowToastEvent({
            title: "Office Contact added Successfully.",
            variant: "success",
            message: ""
          });
          this.dispatchEvent(event);
          this.isLoading = false;
        }
      }
    }
  }


  addPrescriber = async (event) => {
    this.isLoading = true;
    if (this.returnedPrescriberList.length == 0) {
      const event = new ShowToastEvent({
        title: "No Prescriber selected! Please select atleast one Record to proceed further.",
        variant: "warning",
        message: ""
      });
      this.dispatchEvent(event);
      this.isLoading = false;
    } else {
      let result = await validateAffiliationRecords({
        officeContactAccountId: this.recordId,
        prescriberId: this.selectedRecordId,
        remsProgramId: this.selectedRecordRemsId
      })
      if (result == true) {
        const event = new ShowToastEvent({
          title: "Duplicate affiliation already exists with selected prescriber for current office contact",
          variant: "warning",
          message: ""
        });
        this.dispatchEvent(event);
        this.isLoading = false;
      } else {
        this.returnedPrescriberList.forEach((ele) => {
          if (ele.Id == this.selectedRecordId) {
            const userList = {
              Id: ele.Id,
              Name: ele.Name,
              Phone: ele.Phone,
              Status: ele.US_WSREMS__Status__c,
              RemsId: ele.SYN_Ref_Id__c,
			  RemsProgram: ele.US_WSREMS__REMS_Program__c,
              Npi: ele.US_WSREMS__NPI__c,
              Address: ele.ShippingStreet,
              City: ele.ShippingCity,
              State: ele.ShippingState
            };
            this.accountList = [...this.accountList, userList];
			if(this.phoneNumber == null) {
				this.phoneNumber = ele.Phone;
			}
          }
        })
        if (this.accountList.length > 0) {
          this.showTable = true;
          const event = new ShowToastEvent({
            title: "Prescriber added Successfully.",
            variant: "success",
            message: ""
          });
          this.dispatchEvent(event);
          this.isLoading = false;
        }
      }
    }
  }

  // To close the quick Action
  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
   
  disableRemove = true;

  handleRecordSelection = (event) => {
    this.accountList = event.detail.records ;
    this.disableRemove = event.detail.disable;
  }

  handleChildEvent = (event) => {
    let isRecordSelected = event.detail.isRowSelected;
    if (isRecordSelected) {
      this.disableRemove = false;
    }
  }

  removeSelectedRecords (event) {
    this.isLoading = true;
    this.template.querySelector("c-maci-office-contact-mapping-child").handleRemoveAction();
    const custEvent = new ShowToastEvent({
      title: "Record Removed Successfully.",
      variant: "success",
      message: ""
    });
    this.dispatchEvent(custEvent);
    this.isLoading = false;
    this.isRecordSelected = false;
  }

  doSave = false;

  handleSaveEvent = (event) => {
    this.accountList = event.detail.records;
    this.doSave = event.detail.selected;
  }

  handleRecordSubmit = async (event) => {
    this.isLoading = true;
    if (this.recordId && this.accountList.length > 0 && this.recordTypeName) {
      this.template.querySelector("c-maci-office-contact-mapping-child").handleSaveAction();
      if (this.doSave) {
        console.log(this.notificationValue + ' '+ this.phoneNumber+ ' '+this.recordTypeName+ ' '+ this.recordId);
      try {
        let result = await createPrescriberAffiliationRecords({
          recordId: this.recordId,
          recordTypeName: this.recordTypeName,
          accountRecords: this.accountList,
          notification: this.notificationValue,
          phoneNumber: this.phoneNumber

        })
        console.log(result);
        if (result == 'SUCCESS') {
          const event = new ShowToastEvent({
            title: "Record Saved Successfully.",
            variant: "success",
            message: ""
          });
          this.dispatchEvent(event);
          this.isLoading = false;
          this.closeAction();
        } else {
          const event = new ShowToastEvent({
            title: result,
            variant: "error",
            message: ""
          });
          this.dispatchEvent(event);
          this.isLoading = false;
          this.closeAction();
        }
      } catch (error) {
        const event = new ShowToastEvent({
          title: "Error Occured While Saving the Record! Please try again later.",
          variant: "Error",
          message: error.body.message
        });
        this.dispatchEvent(event);
        this.isLoading = false;
      }
    } else {
      const event = new ShowToastEvent({
        title: "No Record selected! Please add atleast one Record to proceed further.",
        variant: "warning",
        message: ""
      });
      this.dispatchEvent(event);
      this.isLoading = false;
    }
  } else {
    this.isLoading = false;
    this.closeAction();
  }
}
}