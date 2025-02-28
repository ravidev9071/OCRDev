import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piaSky_homecustomcss'
import getCaseRDA from '@salesforce/apex/SYN_PiaSkyRDAList.getCaseRDA';


export default class PiaSky_rdaPage extends LightningElement {
    @track allCases = [];
    @track sortDirection = 'utility:arrowdown';
    @track sortedBy = 'CreatedDate'; // Initial sorting column
    @track sortedDirection = 'asc'; // Initial sorting direction

    @track sortedCases = [];
    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.loadCases();
    }

    loadCases() {
        getCaseRDA()
            .then(result => {
                this.allCases = result;
                this.allCases = result.map(caseRecord => {
                    return {
                        ...caseRecord,
                        formattedCreatedDate: this.convertISOToDateFormat(caseRecord.CreatedDate)
                    };
                });
                this.allCases = this.allCases.map(cse => ({
                    ...cse,
                    SYN_PrescriberName: cse.SYN_Prescriber__r ? cse.SYN_Prescriber__r.Name : 'N/A'
                }));

            })
            .catch(error => {

            });

    }
    convertISOToDateFormat(isoDateTime) {
        // Create a new Date object from the ISO date-time string
        const date = new Date(isoDateTime);
        
        // Extract the day, month, and year
        const day = String(date.getUTCDate()).padStart(2, '0');
        const month = String(date.getUTCMonth() + 1).padStart(2, '0'); // Months are zero-indexed
        const year = date.getUTCFullYear();
        
        // Format the date as MM/DD/YYYY
        const formattedDate = `${month}/${day}/${year}`;
        
        return formattedDate;
    }
    
    sortByName() {
        this.sortDirection = this.sortDirection === 'utility:arrowdown' ? 'arrowup' : 'arrowdown';
        this.sortCases();
    }


    sortByColumn(event) {
        const clickedColumn = event.target.dataset.title; // Extract the column header text
        if (this.sortedBy === clickedColumn) {
            // Toggle sorting direction if the same column header is clicked again
         this.sortedDirection = this.sortedDirection === 'desc' ? 'asc' : 'desc';
        } else {
            // Update sorting column and set sorting direction to ascending
            this.sortedBy = clickedColumn;
            this.sortedDirection = 'asc';
        }
        this.sortData(this.sortedBy,this.sortedDirection);
        // Implement your sorting logic here...
    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.allCases));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === "desc" ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : "";
            y = keyValue(y) ? keyValue(y) : "";
            return isReverse * ((x > y) - (y > x));
        });
        this.allCases = parseData;
    }

}