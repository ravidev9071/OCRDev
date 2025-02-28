import { LightningElement, wire, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import tryvioIconCheck from '@salesforce/resourceUrl/tryvioIconCheck';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import insertDataOnSubmit from '@salesforce/apex/TryvioEnrollmentCls.insertDataOnSubmit';
import tryvioProgramName from '@salesforce/label/c.Tryvio_REMS_Program_Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SuccessMsg from '@salesforce/label/c.Tryvio_SuccessMsg';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
export default class TryvioRemsReviewMaterialHCP extends NavigationMixin(LightningElement) {
    iconPrescriber = tryvioIconPrescriber;
    iconCheck = tryvioIconCheck;
    presnpi;
    presname;
    successMsg = SuccessMsg;
    label = {

        SuccessMsg,
    };
    recordId;
    navigation;
    showLoading = false;
    displaySpinner = false;
    @track iconchecketrue1 = false;
    @track iconchecketrue2 = false;
    @track disable = true;
    @track data;
    @api progId;
    @api portRole = 'Public';
    @api progName = 'TRYVIO REMS';
    programName = tryvioProgramName;
    participantType = 'Prescriber';
    @api recordTypeDeveloperName = 'Prescriber';
    guideUrl = '';

    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.recordId = pageRef.state.c__id;
            let updatenpirecord = pageRef.state.c__record;
            this.data = updatenpirecord;
            this.navigation = pageRef.state.c__navigation;
            console.log('updatenpirecord@@@@@@@@', updatenpirecord);
            console.log('data', this.data);

        }
    }

    connectedCallback() {
        try {
            loadStyle(this, customStyles);
            //this.template.querySelector('lightning-progress-step').classList.remove('slds-is-active');
            //console.log('hello', this.template.querySelector('.lighting-step').classList)
            getProgramId({ programName: this.progName }).then(res => {
                this.progId = res;
                console.log('this.progId ' + this.progId);
                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName, programId: this.progId, portalRole: this.portRole })
                    .then(result => {
                        console.log(JSON.stringify(result));
                        const relatedFileResponse = result;
                        if (relatedFileResponse) {
                            let filesList = Object.keys(relatedFileResponse).map(item => ({
                                "label": relatedFileResponse[item].Name,
                                "value": item,
                                "url": relatedFileResponse[item].ContentDownloadUrl,
                                "previewurl": relatedFileResponse[item].DistributionPublicUrl,
                            }));
                            for (let i = 0; i < filesList.length; i++) {
                                if (filesList[i].label == 'PRESCRIBER AND PHARMACY GUIDE') {
                                    this.guideUrl = filesList[i].previewurl;
                                }
                            }
                        }
                    })
                    .catch(error => {
                        console.log(error);
                    })
            })
        }
        catch (error) {
            console.log('error>>', error);
        }
    }
    iconchecke1(event) {
        this.iconchecketrue1 = true;
    }
    iconchecke2(event) {
        this.iconchecketrue2 = true;
        if (this.iconchecketrue1 && this.iconchecketrue2) {
            this.disable = false
        }
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    handleNext(event) {
        this.displaySpinner = true;
        if (this.navigation === 'registerPage') {
            console.log('updatenpirecord!!!!!!!@@@@@@@@', JSON.stringify(this.data));
            let inputRecords = {
                'recordDetails': this.data,
                'programName': this.programName,
                'participantType': this.participantType,
                'casecreation': 'kacase',
                'AccountId': this.recordId
            };

            console.log('inputRecords=>', inputRecords);
            insertDataOnSubmit({ 'inputRecords': inputRecords }).then((eachRec) => {
                console.log(eachRec)
                if (eachRec?.length > 15) {
                    //this.showToast('Success', this.successMsg, 'success');
                    try {
                        event.preventDefault();
                        event.stopPropagation();
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'tryvioRemsKAQuestions__c'
                            }, state: {
                                c__name: this.presname,
                                c__npi: this.presnpi,
                                c_id: eachRec
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                }

                if (eachRec === 'duplicateEmail') {
                    this.showToast('Error', this.label.DuplicateEmail, 'error');
                }

                if (eachRec === 'duplicateNPI') {
                    this.showToast('Error', this.label.duplicateNPI, 'error');
                }

                this.showLoading = false;
                this.displaySpinner = false;
            }).catch(error => {
                this.disabled = true;
                this.showLoading = false;
                this.displaySpinner = false;
                console.log('erroron submit --' + error.message);
                this.showToast('Error', JSON.stringify(error.message), 'error');
            });
        } else {
            this.showToast('Success', this.successMsg, 'success');
            try {
                event.preventDefault();
                event.stopPropagation();
                this[NavigationMixin.Navigate]({
                    type: 'comm__namedPage',
                    attributes: {
                        name: 'tryvioRemsKAQuestions__c'
                    }, state: {
                        c__name: this.presname,
                        c__npi: this.presnpi,
                        c_id: this.recordId
                    }
                });
            } catch (error) {
                console.log('error --' + error.message);
            }
        }
    }
}