import { LightningElement, track, api } from 'lwc';

const columns = [
  { label: "Name", fieldName: "Name", hideDefaultActions: true },
  { label: "Phone", fieldName: "Phone", hideDefaultActions: true },
  { label: "Status", fieldName: "Status", hideDefaultActions: true },
  { label: "RemsId", fieldName: "RemsId", hideDefaultActions: true }
];

const prescriberColumns = [
  { label: "Name", fieldName: "Name", hideDefaultActions: true },
  { label: "Phone", fieldName: "Phone", hideDefaultActions: true },
  { label: "Status", fieldName: "Status", hideDefaultActions: true },
  { label: "RemsId", fieldName: "RemsId", hideDefaultActions: true },
  { label: "NPI", fieldName: "Npi", hideDefaultActions: true },
  { label: "Address", fieldName: "Address", hideDefaultActions: true },
  { label: "City", fieldName: "City", hideDefaultActions: true },
  { label: "State", fieldName: "State", hideDefaultActions: true },
];

export default class MaciOfficeContactMappingChild extends LightningElement {
  @track dataTabeData = [];
  @track paginatedRecords = [];
  @track newDataTableRecordsInitial = [];
  @api isOfficeContact = false ;
  
  hideCheckBox = true;
  selectedRows = [];


  page = 1; //initialize 1st page
  items = []; //contains all the records.
  data = []; //data  displayed in the table
  startingRecord = 1; //start record position per page
  endingRecord = 0; //end record position per page
  pageSize = 10; //default value we are assigning
  totalRecountCount = 0; //total record count received from all retrieved records
  totalPage = 0; //total number of page is needed to display all records

  connectedCallback() {
    if(this.isOfficeContact){
      this.columns = columns;
    } else {
      this.columns = prescriberColumns;
    }
  }
  // This is used to get the data
  @api get tableData() {
    return this.dataTabeData;
  }

  set tableData(data) {
    this.dataTabeData = data;
    this.totalRecountCount = data.length;
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
    this.data = this.dataTabeData.slice(0, this.pageSize);
    this.endingRecord = this.pageSize;
    if (this.data.length > this.pageSize) {
      this.isLastPage = false;
      this.page = 2;
    }
  }

   //press on previous button this method will be called
   previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1;
      this.displayRecordPerPage(this.page);
    }
  }

  //press on next button this method will be called
  nextHandler() {
    if ((this.page < this.totalPage) && this.page !== this.totalPage) {
      this.page = this.page + 1;
      this.displayRecordPerPage(this.page);
    }
  }

  displayRecordPerPage(page) {
    this.startingRecord = ((page - 1) * this.pageSize);
    this.endingRecord = (this.pageSize * page);
    this.endingRecord = (this.endingRecord > this.totalRecountCount)
      ? this.totalRecountCount : this.endingRecord;
    this.data = this.dataTabeData.slice(this.startingRecord, this.endingRecord);
    //increment by 1 to display the startingRecord count, 
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
    this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
  }

  handleRowSelection(event) {
    let updatedItemsSet = new Set();
    // List of selected items we maintain.
    let selectedItemsSet = new Set(this.selectedRows);
    // List of items currently loaded for the current view.
    let loadedItemsSet = new Set();

    this.data.map((ele) => {
      loadedItemsSet.add(ele.Id);
    });

    if (event.detail.selectedRows) {
      event.detail.selectedRows.map((ele) => {
        updatedItemsSet.add(ele.Id);
      });

      // Add any new items to the selectedRows list
      updatedItemsSet.forEach((id) => {
        if (!selectedItemsSet.has(id)) {
          selectedItemsSet.add(id);
        }
      });
    }

    loadedItemsSet.forEach((id) => {
      if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
        // Remove any items that were unselected.
        selectedItemsSet.delete(id);
      }
    });

    this.selectedRows = [...selectedItemsSet];
    if (this.selectedRows.length > 0) {
      var selectedEvent = new CustomEvent('rowselect', {
        detail:
          { isRowSelected: true }
      });
      this.dispatchEvent(selectedEvent);
    }
  }

  isLastPage = false;

  get disPre() {
    if (this.page == 1) {
      return true;
    } else {
      return false;
    }

  }

  @api handleRemoveAction (event) {
    let recordListToshow = [];
    for (let i = 0; i < this.dataTabeData.length; i++) {
      let foundElement = false;
      for (let j = 0; j < this.selectedRows.length; j++) {
        if (this.selectedRows[j] === this.dataTabeData[i].Id) {
          this.selectedRows.splice(j, 1);
          foundElement = true;
          break;
        }
      }
      if (!foundElement) {
        recordListToshow.push(this.dataTabeData[i]);
      }
    }
    this.data = [...recordListToshow];
    this.dispachEventForSelectedRecords();
    if (this.data.length < this.pageSize) {
      this.isLastPage = true;
      this.page = 1;
      this.previousHandler();
    } else {
      this.isLastPage = false;
    }
  }


  @api handleSaveAction(event) {
    let recordListToshow = [];
    for (let i = 0; i < this.dataTabeData.length; i++) {
      for (let j = 0; j < this.selectedRows.length; j++) {
        if (this.selectedRows[j] === this.dataTabeData[i].Id) {
          recordListToshow.push(this.dataTabeData[i]);
        }
      }
    }
    if (recordListToshow.length > 0) {
      this.dispatchEvent(
        new CustomEvent("saveselected", {
          detail: {
            records: recordListToshow,
            selected: true
          }
        })
      );
    }
  }

  // dispachEventForSelectedSpans : dispatch the custom event
  dispachEventForSelectedRecords = () => {
    this.dispatchEvent(
      new CustomEvent("recordevent", {
        detail: {
          records: this.data,
          disable: true
        }
      })
    );
  };

 
  updateRecordHandler = (event) => {
    this.dataTabeData = JSON.parse(JSON.stringify(event.detail.records));
    this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRecordsPagination;
  };

}