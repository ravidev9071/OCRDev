import { LightningElement, track, wire } from 'lwc';
import Id from "@salesforce/user/Id";
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/piasky_customSecure'
import searchPrescribers from '@salesforce/apex/PiaSky_PrescriberVerificationController.getPrescriberList'
import searchPicklistvalues from '@salesforce/apex/SYN_PiaSkyPharmacyLookupSearchCls.getPicklistValues';
import getOutpatientPharmacy from '@salesforce/apex/PiaSky_PrescriberVerificationController.getOutpatientPharmacy';
import checkOutpatientPharmacy from '@salesforce/apex/PiaSky_PrescriberVerificationController.checkOutpatientPharmacy';

export default class Piasky_remsVerification extends LightningElement {
    isDisplayNPIno = true;
    isDisplayPreName = false;

    @track npiNum = '';
    @track lastNme = '';
    @track firstNme = '';
    @track stateField = '';
    @track prescriberList = [];
    @track selectedPrescriberID = '';
    @track showPrescriberList = false;
    @track showNoPrescriber = false;
    @track showNoPrescriberbutton = false;
    @track outpatientPharmacy = false;
    @track disableContinue = false;
    selectedValue;
    @track sortDirection = 'utility:arrowdown';
    @track sortedBy = 'LastName'; // Initial sorting column
    @track sortedDirection = 'asc'; // Initial sorting direction


    connectedCallback() {
        loadStyle(this, customHomeStyles);
        this.optpatientPharmacy();
    }
    handleChangeNPI() {
        this.isDisplayNPIno = true;
        this.isDisplayPreName = false;
        this.prescriberList = [];
        this.firstNme = '';
        this.lastNme = '';
        this.stateField = '';
        this.showPrescriberList = false;
        this.showNoPrescriber = false;
        this.disableContinue = false;
        this.showNoPrescriberbutton = false;

    }
    handleChangePreName() {
        this.isDisplayNPIno = false;
        this.isDisplayPreName = true;
        this.prescriberList = [];
        this.npiNum = '';
        this.showPrescriberList = false;
        this.showNoPrescriber = false;
        this.disableContinue = false;
        this.showNoPrescriberbutton = false;
    }

    @wire(searchPicklistvalues, { objectApiName: 'Account', fieldApiName: 'US_WSREMS__State__c' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            // Filter out the last three specific values
            const excludeValues = ['AA', 'AE', 'AP'];
            this.picklistValues = data.filter(option => !excludeValues.includes(option.value));
        } else if (error) {
        }
    }

    optpatientPharmacy() {
        checkOutpatientPharmacy({ userId: Id })
            .then(result => {
                this.outpatientPharmacy = result;
            })
            .catch(error => {
                this.displaySpinner = false;
            })
    }

    handleInputChange(event) {
        this.displaySpinner = true;
        this.npiNum = event.target.value;
        let field1 = this.template.querySelector('.search');
        this.displayInvalidNpi = false;
        if (this.npiNum && (this.npiNum.length > 10 || !(/^\d+$/.test(this.npiNum)))) {
            this.displayInvalidNpi = true;
        } else {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
        }
        this.displaySpinner = false;

    }
    handleFNChange(event) {
        this.firstNme = event.target.value;
    }
    handleLNChange(event) {
        this.lastNme = event.target.value;
    }
    handleStateChange(event) {
        this.stateField = event.target.value;
    }
    handlePrescriberSelection(event) {
        this.selectedPrescriberID = event.target.value;
        this.selectedValue = true;
    }

    handleSearch() {
        if (this.prescriberList.length > 0) {
            if (this.selectedValue) {

                const selectedPrescriber = this.prescriberList.find(prescriberAcc => prescriberAcc.Id === this.selectedPrescriberID);
                sessionStorage.setItem('selectedPrescriber', JSON.stringify(selectedPrescriber));
                sessionStorage.removeItem('prescriberAcc');
                sessionStorage.removeItem('nonExistingPrescriberVal');
                this.redirectBasedonAccStatus(selectedPrescriber);

            } else {
                this.showError('Please select a prescriber to proceed');
            }


        } else if ((this.handleChangeNPI && this.npiNum) || (this.isDisplayPreName && ((this.lastNme && this.stateField) || (this.lastNme && this.stateField && this.firstNme)))) {
            searchPrescribers({ npiNumber: this.npiNum, firstName: this.firstNme, lastName: this.lastNme, state: this.stateField })
                .then((result) => {
                    if (this.npiNum && result.length > 0) {
                        const prescriberAcc = result[0];
                        sessionStorage.removeItem('selectedPrescriber');
                        sessionStorage.setItem('prescriberAcc', JSON.stringify(prescriberAcc));
                        sessionStorage.removeItem('nonExistingPrescriberVal');
                        this.redirectBasedonAccStatus(prescriberAcc);
                    } else if (this.isDisplayPreName) {
                        this.prescriberList = [...result];
                        if (this.prescriberList.length > 0) {
                            this.showPrescriberList = true;
                            this.showNoPrescriber = false;
                            this.disableContinue = false;
                            this.showNoPrescriberbutton = true;
                        } else {
                            this.showPrescriberList = false;
                            this.showNoPrescriber = true;
                            this.showNoPrescriberbutton = true;
                            if (this.outpatientPharmacy) {
                                this.disableContinue = true;
                            }
                            if(!this.outpatientPharmacy){
                                this.handleNullPrescriber();
                            }
                        }

                    } else {

                        this.showNoPrescriber = true;
                        this.showNoPrescriberbutton = true;
                        if (this.outpatientPharmacy) {
                            this.disableContinue = true;
                        }
                        if(!this.outpatientPharmacy){
                            this.handleNullPrescriber();
                        }
                    }
                })
                .catch(error => {
                });
        }

    }

    handleNullPrescriber() {
        this.displaySpinner = true;
        if (this.outpatientPharmacy) {
            getOutpatientPharmacy({ userId: Id, npiNumber: this.npiNum, firstName: this.firstNme, lastName: this.lastNme, prescriberAcc: null })
                .then(result => {
                })
                .catch(error => {
                    this.displaySpinner = false;
                })
        }
        if (this.isDisplayNPIno) {
            var nullPrescriber = {};
            nullPrescriber['US_WSREMS__National_Provider_Identifier__c'] = this.npiNum;
            sessionStorage.setItem('nonExistingPrescriberVal', JSON.stringify(nullPrescriber));
        }
        else if (this.isDisplayPreName) {
            var nullPrescriber = {};
            nullPrescriber['LastName'] = this.lastNme;
            nullPrescriber['FirstName'] = this.firstNme;
            sessionStorage.setItem('nonExistingPrescriberVal', JSON.stringify(nullPrescriber));
        }
        sessionStorage.removeItem('selectedPrescriber');
        sessionStorage.removeItem('prescriberAcc');
        this.redirectToPage('notCertifiedPage');

    }


    redirectBasedonAccStatus(prescriberAcc) {
        if (prescriberAcc.US_WSREMS__Status__c === 'Certified') {
            this.redirectToPage('certifiedPage');
        } else {
            getOutpatientPharmacy({ userId: Id, npiNumber: prescriberAcc.US_WSREMS__National_Provider_Identifier__c, firstName: prescriberAcc.FirstName, lastName: prescriberAcc.LastName, prescriberAcc:  prescriberAcc})
                .then(result => {
                })
                .catch(error => {
                    this.displaySpinner = false;
                })
            this.redirectToPage('notCertifiedPage');
        }
    }

    redirectToPage(pageName) {
        this.currentUrl = window.location.href;
        if (pageName === 'certifiedPage') {
            this.contactusUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/')) + 's/remsverification-success';
        } else {
            this.contactusUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/')) + 's/rems-verification-not-certified';
        }
        window.open(this.contactusUrl, '_self');

    }
    showError(message) {
        alert(message);
    }

    sortByColumn(event) {
        const clickedColumn = event.target.dataset.title; // Extract the column header text
        if (this.sortedBy === clickedColumn) {
            // Toggle sorting direction if the same column header is clicked again
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
            this.sortDirection = this.sortDirection === 'utility:arrowdown' ? 'utility:arrowup' : 'utility:arrowdown';
        } else {
            // Update sorting column and set sorting direction to ascending
            this.sortedBy = clickedColumn;
            this.sortedDirection = 'asc';
            this.sortDirection = this.sortDirection === 'utility:arrowdown';
        }
        this.sortData(this.sortedBy, this.sortedDirection);
        // Implement your sorting logic here...
    }
    sortData(fieldname, direction) {

        let parseData = JSON.parse(JSON.stringify(this.prescriberList));
        let keyValue = (a) => {
            return a[fieldname];
        };


        let isReverse = direction === "asc" ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : "";
            y = keyValue(y) ? keyValue(y) : "";
            return isReverse * ((x > y) - (y > x));
        });
        this.prescriberList = parseData;

    }
}