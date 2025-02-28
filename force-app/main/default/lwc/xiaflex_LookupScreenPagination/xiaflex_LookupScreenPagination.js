import { LightningElement,track,api } from 'lwc';

export default class Xiaflex_LookupScreenPagination extends LightningElement {
    @api allItems = []; // Entire dataset
    @api displayedItems = []; // Subset to display
    @track currentPage = 1;
    @api pageSize = 5;
    @track totalPages;

    connectedCallback() {
        // alert('connected callabakc of pagination');
        // this.displayedItems =  this.sliceData();
        this.totalPages =  Math.ceil(this.allItems.length / this.pageSize);
            this.updateRecords();
    }

    

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === Math.ceil(this.allItems.length / this.pageSize);
    }

    sliceData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        return this.allItems.slice(start, end);
    }

    previousPage() {
        if (!this.isFirstPage) {
            this.currentPage--;
            this.updateRecords();
        }
    }

    nextPage() {
        if (!this.isLastPage) {
            this.currentPage++;
                this.updateRecords();
        }
    }
        updateRecords(){ 
        const start = (this.currentPage-1)*this.pageSize
        const end = this.pageSize*this.currentPage
        this.displayedItems = this.allItems.slice(start, end)
        this.dispatchEvent(new CustomEvent('update',{ 
            detail:{ 
                records:this.displayedItems
            }
        }))
    }
}