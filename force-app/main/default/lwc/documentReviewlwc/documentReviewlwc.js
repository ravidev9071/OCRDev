import { LightningElement, api, wire, track } from 'lwc';
import retriveExistingRemsServices from '@salesforce/apex/DocumentReviewController.retriveExistingRemsServices';
import getREMSServiceViewConfig from '@salesforce/apex/DocumentReviewController.getREMSServiceViewConfig';
import validateLoggedInUserProgram from '@salesforce/apex/DocumentReviewController.validateLoggedInUserProgram';
import { comparator, NUMBER_VALUE } from "c/directiveComparator";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Account_Search_Msg from "@salesforce/label/c.Account_Search_Msg";
import Account_Search_Message_2 from "@salesforce/label/c.Account_Search_Message_2";
import Account_Search_Message_3 from "@salesforce/label/c.Account_Search_Message_3";
import Account_Search_Message_For_Inbound_Call from "@salesforce/label/c.Account_Search_Message_For_Inbound_Call";
import Service_Creation_Msg from "@salesforce/label/c.Service_Creation_Msg";
import Existing_Service_Selection_Msg from "@salesforce/label/c.Existing_Service_Selection_Msg";
import New_Account_Button from "@salesforce/label/c.New_Account_Button";
import New_Service_Button from "@salesforce/label/c.New_Service_Button";
import DocumentFieldWarningMessage from "@salesforce/label/c.DocumentFieldWarningMessage";
import DocumentDOBFieldWarningMessage from "@salesforce/label/c.DocumentDOBFieldWarningMessage";
import No_Accounts_Search_Msg from "@salesforce/label/c.No_Accounts_Search_Msg";
import casePhoneValidation from "@salesforce/label/c.Case_Phone_Validation";
import inboundDateValidation from "@salesforce/label/c.InboundDateValidation";
import npiCaseValidationMsg from "@salesforce/label/c.NPI_Case_Validation_Msg";
import deaCaseValidationMsg from "@salesforce/label/c.DEA_Case_Validation_Msg";
import inboundNameValidation from "@salesforce/label/c.Name_Validation";
import inboundEmailValidation from "@salesforce/label/c.Email_Validation";
import getNameSpace from "@salesforce/apex/DocumentReviewController.getNameSpace";
import { NavigationMixin } from 'lightning/navigation';
import ProgramsEnrolledMsg from '@salesforce/label/c.ProgramsEnrolledMsg';
import getActiveProgram from '@salesforce/apex/DocumentReviewController.getActiveProgram';
import { CurrentPageReference } from 'lightning/navigation';
import {encodeDefaultFieldValues} from 'lightning/pageReferenceUtils';

export default class DocumentReviewlwc extends NavigationMixin(LightningElement) {

    retrievedAccounts = null;
    displayServices = true;
    isCollapsed = true;
    expandButton = true;
    gridColumns = {};
    columnMap = {};
    @api recordId ;
    showCaseCreation = false;
    accountIDstring;
    participantString;
    participant;
    @api accFieldList;
    @api programId;
    @api currentUserProgramName;
    programUser;
    displaySpinner = false;
    @track phoneValue;
    @track DNIS;
    @track ivrpromptcode;
    @track direction;
    @track contacttype;
    @track contactid;
    @track callstarttime;
    @track accountidcreated;
    checkRendered = true;

    searchDisabled = true;

    isDocumentReview = false;

    caseId;
    accountId;
    recordTypeName;
    displayRecordCreation = false;
    displayAccountCreation = false;
    displayCaseCreation = false;
    noDataFoundAfterSearch = false;
    namespaceVar;
    $ = comparator(this, {
        fieldId: NUMBER_VALUE,
        accFieldList: [
            {
                US_WSREMS__Field_Name__c: NUMBER_VALUE,
                US_WSREMS__DataType__c: ["Combobox"]
            }
        ]
    });

    label = {
        Account_Search_Msg,
        Service_Creation_Msg,
        Existing_Service_Selection_Msg,
        New_Account_Button,
        New_Service_Button,
        DocumentFieldWarningMessage,
        DocumentDOBFieldWarningMessage,
        Account_Search_Message_For_Inbound_Call,
        No_Accounts_Search_Msg,
        Account_Search_Message_2,
        Account_Search_Message_3,
        casePhoneValidation,
        inboundDateValidation,
        npiCaseValidationMsg,
        deaCaseValidationMsg,
        ProgramsEnrolledMsg,
        inboundNameValidation,
        inboundEmailValidation
    };

    handleComplete() {
        this.displayRecordCreation = false;
        this.displayCaseCreation = false;
        this.displayAccountCreation = false; 
    }
    get displayNewAccount() {
        return !this.isDocumentReview;
    }

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
            this.accountidcreated = currentPageReference.state.c__accountid;
            this.handleNameSpace();
            try {
                this.displaySpinner = true;
                if (pageName && pageName.includes('Inbound_Call')) {
                    this.isDocumentReview = false;
                } else {
                    this.isDocumentReview = true;
                    this.getActiveProgram();
                }
                if(this.accountidcreated){
                    this.displaySpinner = false;
                    this.participantString = currentPageReference.state.c__participant;
                    this.currentUserProgramName = currentPageReference.state.c__programname;
                    this.accountIDstring = this.accountidcreated;
                    this.isDocumentReview = false;
                    this.contactid = currentPageReference.state.c__contactid;
                    this.showServiceCreation = false;
                    this.displayRecordCreation = true;
                    this.checkRendered = false;
                    this.showCaseCreation = true;
                    
                }
                if (this.displayNewAccount === false) {
                    const serviceConfig = await getREMSServiceViewConfig({ 'feature': 'REMSServiceTable' });
                    var remsColRes = [];
                    remsColRes.push({ type: 'button-icon', initialWidth: 105, typeAttributes: { name: 'Select_Service', variant: 'brand', class: { fieldName: 'btnCls' }, iconName: { fieldName: 'iconName' }, iconClass: { fieldName: 'iconClass' }, disabled: { fieldName: 'disabledValue' }, alternativeText: 'Create New Service' } });
                    remsColRes = [...remsColRes, ...serviceConfig];

                    for (var column in remsColRes) {
                        var columnAttr = {};
                        columnAttr['Parent'] = remsColRes[column].Parent;
                        columnAttr['typeAtt'] = remsColRes[column].typeAttributes;
                        this.columnMap[remsColRes[column].fieldName] = columnAttr;
                    }
                } else {
                    this.displayServices = false;
                    const serviceConfig1 = await getREMSServiceViewConfig({ 'feature': 'InboundCallTable' });
                    var remsColRes = [];
                    if( this.isDocumentReview == true){
                        remsColRes.push({ type: 'button-icon', initialWidth: 105, typeAttributes: { name: 'Select_Service', variant: 'brand', class: { fieldName: 'btnCls' }, iconName: { fieldName: 'iconName' }, iconClass: { fieldName: 'iconClass' }, disabled: { fieldName: 'disabledValue' }, alternativeText: 'Create New Service' } });
                        remsColRes = [...remsColRes, ...serviceConfig1];
                    }else{
                        remsColRes = serviceConfig1;
                    }
                    for (var column in remsColRes) {
                        var columnAttr = {};
                        columnAttr['Parent'] = remsColRes[column].Parent;
                        columnAttr['typeAtt'] = remsColRes[column].typeAttributes;
                        this.columnMap[remsColRes[column].fieldName] = columnAttr;
                    }
                }
                this.gridColumns = remsColRes;
                this.displaySpinner = false;
            } catch (e) {
                                console.log('error', e);
            }
        }
    }
    renderedCallback() {
        if (this.phoneValue != null && this.checkRendered === true) {
            this.displayServices = false;
            this.handleSearch();
            
        }

    }
    handleRowSelection(event) {
        this.displaySpinner = true;
        this.getActiveProgram();
        if(this.isDocumentReview == true){
            if (event.detail.row.CaseNumber) {
                this.caseId = event.detail.row.Id.split("force.com/")[1];
                this.displayRecordCreation = true;
                this.displayAccountCreation = false;
                this.showServiceCreation = false;
                this.displayCaseCreation = true;

            } else {
                this.accountId = event.detail.row.Id.split("force.com/")[1];
                this.recordTypeName = event.detail.row.RecordType.Name;
                this.displayRecordCreation = false;
                this.displayAccountCreation = false;
            }
        }else{

            this.participant = event.detail.selectedRows[0].RecordType.Name;
            this.accountId = event.detail.selectedRows.map(row => row.Id.split("force.com/")[1]);
            this.displayRecordCreation = false;
            this.displayAccountCreation = false;
        }


        this.displaySpinner = false;
        if (this.accountId && this.isDocumentReview && this.displayCaseCreation == false) {
            this.handleNewService();
        }
    }

    navigateToNextPage() {
        // Use the navigateToPage method to navigate to your desired page

        this.caseId   = '' ;
        

        this.participantString = this.participant;
        this.accountIDstring = this.accountId[0];
        this.showServiceCreation = false;
        this.displayRecordCreation = true;
        this.showCaseCreation = true;
    }

    handleNewAccount() {
        const deafultvalue = encodeDefaultFieldValues({
            contactid:this.contactid
        });
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: this.namespaceVar+"newAccountFromOverideNewButton"
            },
            state: {
                c__contactid: this.contactid ,
                c__ANI: this.phoneValue
                
            }
        },true);

    }

    showServiceCreation = false;

    handleNewService() {
        this.displaySpinner = true
        this.caseId = '';
        this.displayRecordCreation = true;
        this.displaySpinner = false;
        this.getActiveProgram();
        this.validateProgram();

    }
    handleNameSpace(){
        getNameSpace({})
            .then((result) => {
                this.namespaceVar =result;
            })
            .catch((error) => {
                this.displayServices = false;
                this.showToastNotification(
                    "Error",
                    reduceErrors(error).join(", "),
                    "Error"
                );
            });
    }
    getActiveProgram = async () => {
        let result = await getActiveProgram();
        if (result) {
            this.programUser = result;
            this.currentUserProgramName= result.US_WSREMS__REMS_Program__r.Name;
        }else {
            this.showToast('Error', this.label.ProgramsEnrolledMsg, 'error');
        }
    }

    validateProgram = async () => {
        let result = await validateLoggedInUserProgram();
        if (result) {
            if (result === true) {
                this.showServiceCreation = true;
                this.displayRecordCreation = true ;
            } else {
                this.showToast('Error', this.label.ProgramsEnrolledMsg, 'error');
            }
        }
    }

    handlePrevious = (event) => {
        this.displayRecordCreation = false;
        this.showServiceCreation = false ;
        this.searchDisabled = true;
    }
    handleCancel = (event) => {
        this.displayRecordCreation = false;
        this.showServiceCreation = false ;
        this.retrievedAccounts = null;
        this.displaySpinner = false;
        if (this.phoneValue != null && this.checkRendered === true) {
            this.handleSearch();
            
        }
    }

    handleInputChange(event) {

        switch (event.target.name) {
            case this.namespaceVar+'DEA__c':
                let field = this.template.querySelector(`[data-field='${this.namespaceVar}DEA__c']`);
                if (event.target.value.length > 9) {
                    field.validity = { valid: false };
                    field.setCustomValidity(this.label.deaCaseValidationMsg);
                    field.focus();
                    field.blur();
                    this.searchDisabled = true;
                } else if (event.target.value.length < 9) {
                    field.validity = { valid: false };
                    field.setCustomValidity(this.label.deaCaseValidationMsg);
                    field.focus();
                    this.searchDisabled = true;
                } else {
                    this.searchDisabled = false;
                    field.validity = { valid: true };
                    field.setCustomValidity('');
                }
                break;
            case this.namespaceVar+'NPI__c':
                let field1 = this.template.querySelector(`[data-field='${this.namespaceVar}NPI__c']`);
                if (event.target.value.length > 10) {
                    field1.validity = { valid: false };
                    field1.setCustomValidity(this.label.npiCaseValidationMsg);
                    field1.focus();
                    field1.blur();
                    this.searchDisabled = true;
                }
                else if (event.target.value.length < 10) {
                    field1.validity = { valid: false };
                    field1.setCustomValidity(this.label.npiCaseValidationMsg);
                    field1.focus();
                    this.searchDisabled = true;
                } else {
                    this.searchDisabled = false;
                    field1.validity = { valid: true };
                    field1.setCustomValidity('');
                }
                break;
            case this.namespaceVar+'HIN__c':
                let field2 = this.template.querySelector(`[data-field='${this.namespaceVar}HIN__c']`);
                if (event.target.value.length > 9) {
                    field2.validity = { valid: false };
                    field2.setCustomValidity(this.label.DocumentFieldWarningMessage);
                    field2.focus();
                    field2.blur();
                    this.searchDisabled = true;
                }else if(event.target.value.length < 9){
                    field2.validity = { valid: false };
                    field2.setCustomValidity(this.label.DocumentFieldWarningMessage);
                    field2.focus();
                    this.searchDisabled = true;
                } else {
                    this.searchDisabled = false;
                    field2.validity = { valid: true };
                    field2.setCustomValidity('');
                }
                break;
            case 'Phone':
                let field3 = this.template.querySelector("[data-field='Phone']");
                if (event.target.value.length > 10) {
                    field3.validity = { valid: false };
                    field3.setCustomValidity(this.label.casePhoneValidation);
                    field3.focus();
                    field3.blur();
                    this.searchDisabled = true;
                }else if (event.target.value.length < 10) {
                    field3.validity = { valid: false };
                    field3.setCustomValidity(this.label.casePhoneValidation);
                    field3.focus();
                    //field.blur();
                    this.searchDisabled = true;
                } else {
                    this.searchDisabled = false;
                    field3.validity = { valid: true };
                    field3.setCustomValidity('');
                }
                break;
            case this.namespaceVar+'DOB__c':
                let dateField = this.template.querySelector(`[data-field='${this.namespaceVar}DOB__c']`);
                let isValidDate = event.target.value;
                if (isValidDate == null && isValidDate == undefined && isValidDate == '') {
                    dateField.validity = { valid: false };
                    dateField.setCustomValidity(this.label.inboundDateValidation);
                    dateField.focus();
                    dateField.blur();
                    this.searchDisabled = true;
                } else if (isValidDate == null && isValidDate == undefined && isValidDate != '') {
                    dateField.validity = { valid: false };
                    dateField.setCustomValidity(this.label.inboundDateValidation);
                    dateField.focus();
                    this.searchDisabled = true;
                } else {
                    this.searchDisabled = false;
                    dateField.validity = { valid: true };
                    dateField.setCustomValidity('');
                }
                break;
            case 'Name':
                let field4 = this.template.querySelector("[data-field='Name']");
                let isValidName = event.target.value;
                if (!isValidName) {
                    field4.validity = { valid: false };
                    field4.setCustomValidity(this.label.inboundNameValidation);
                    field4.focus();
                    this.searchDisabled = true;
                }
                else{
                    field4.setCustomValidity('');
                    this.searchDisabled = false;
                }
                break;
            case this.namespaceVar+'Email__c':
                let field5 = this.template.querySelector(`[data-field='${this.namespaceVar}Email__c']`);
                const emailPattern = /^[a-zA-Z0-9_'.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
                let isValidEmail = event.target.value;
                if (!isValidEmail && !isValidEmail.match(emailPattern)) {
                    field5.validity = { valid: false };
                    field5.setCustomValidity(this.label.inboundEmailValidation);
                    field5.focus();
                    this.searchDisabled = true;
                }
                else{
                    field5.setCustomValidity('');
                    this.searchDisabled = false;
                }
                break;
            default:
                console.log(`no logic`);
        }

        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid) {
            this.searchDisabled = false;
        }



    }

    async handleSearch(event) {
        this.displaySpinner = true;
        let accountValues = {}
        this.template.querySelectorAll('lightning-input').forEach(ele => {
            if (ele.name == 'Name') {
                accountValues['MiddleName'] = ele.value;
            }
            accountValues[ele.name] = ele.value;
            if (ele.name == 'Phone' && this.phoneValue != null) {
                accountValues[ele.name] = this.phoneValue;
                this.checkRendered = false;
                this.displayServices = false;
            }
        });
        try {
            const remsRes = await retriveExistingRemsServices({ 'accountValues': JSON.stringify(accountValues) });

            let accountList = [];
            for (var acc in remsRes) {
                var account = remsRes[acc].accObj;
                account['btnCls'] = 'remsBtnCls';
                account['iconName'] = 'utility:add';
                account['iconClass'] = 'buttonIcon';
                account['selected'] = 'false';
                for (var fldName in account) {
                    if (this.columnMap[fldName]) {
                        if (this.columnMap[fldName]['typeAtt']) {
                            var fieldName = this.columnMap[fldName]['typeAtt']["label"]["fieldName"];
                            if (this.columnMap[fldName]['Parent']) {
                                var parent = this.columnMap[fldName]['Parent'];
                                if (account[parent]['Name']) {
                                    account[fieldName] = account[parent]['Name'];
                                } else {
                                    account[fieldName] = account[parent];
                                }
                                account[fldName] = window.location.origin + '/' + account[fldName];
                            }
                        }
                    }
                }

                var remsServList = remsRes[acc].remsServiceObjList;
                var remsChildList = [];
                for (var remService in remsServList) {
                    remsServList[remService].remsServiceObj['iconName'] = 'utility:add';
                    remsServList[remService].remsServiceObj['iconClass'] = 'buttonIcon';
                    remsServList[remService].remsServiceObj['btnCls'] = 'remsBtnCls';
                    remsServList[remService].remsServiceObj['selected'] = 'false';
                    for (var fldName in remsServList[remService].remsServiceObj) {
                        if (this.columnMap[fldName]) {
                            if (this.columnMap[fldName]['typeAtt']) {
                                var fieldName = this.columnMap[fldName]['typeAtt']["label"]["fieldName"];
                                if (this.columnMap[fldName]['Parent']) {
                                    var parent = this.columnMap[fldName]['Parent'];
                                    if (remsServList[remService].remsServiceObj[parent]['Name']) {
                                        remsServList[remService].remsServiceObj[fieldName] = remsServList[remService].remsServiceObj[parent]['Name'];
                                    } else {
                                        remsServList[remService].remsServiceObj[fieldName] = remsServList[remService].remsServiceObj[parent];

                                    }
                                    remsServList[remService].remsServiceObj[fldName] = window.location.origin + '/' + remsServList[remService].remsServiceObj[fldName];
                                }
                            }

                        }

                    }

                    for (var caseObj in remsServList[remService].caseList) {
                        if(remsServList[remService].caseList[caseObj].Status == 'Complete' &&
                            remsServList[remService].caseList[caseObj].US_WSREMS__Outcome__c == 'Complete') {
                            remsServList[remService].caseList[caseObj]['disabledValue'] = true;
                            remsServList[remService].caseList[caseObj]['iconName'] = 'action:edit';

                        }else if (remsServList[remService].caseList[caseObj].Status != 'Closed') {
                            remsServList[remService].caseList[caseObj]['iconName'] = 'action:edit';
                            remsServList[remService].caseList[caseObj]['iconClass'] = 'buttonIcon';
                            remsServList[remService].caseList[caseObj]['btnCls'] = 'remsBtnCls';
                            remsServList[remService].caseList[caseObj]['selected'] = 'false';

                        } else {
                            remsServList[remService].caseList[caseObj]['disabledValue'] = true;
                            remsServList[remService].caseList[caseObj]['iconName'] = 'action:edit';

                        }
                        for (var fldname in remsServList[remService].caseList[caseObj]) {
                            if (this.columnMap[fldname]) {
                                if (this.columnMap[fldname]['typeAtt']) {
                                    var fieldName = this.columnMap[fldname]['typeAtt']["label"]["fieldName"];
                                    if (this.columnMap[fldname]['Parent']) {
                                        var parent = this.columnMap[fldname]['Parent'];
                                        if (remsServList[remService].caseList[caseObj][parent]) {
                                            remsServList[remService].caseList[caseObj][fieldName] = remsServList[remService].caseList[caseObj][parent]['Name'];
                                        } else {
                                            if (fldname == 'Id') {
                                                remsServList[remService].caseList[caseObj][fieldName] = remsServList[remService].caseList[caseObj]['CaseNumber'];
                                            } else {
                                                remsServList[remService].caseList[caseObj][fieldName] = remsServList[remService].caseList[caseObj][parent];
                                            }

                                        }
                                        remsServList[remService].caseList[caseObj][fldname] = window.location.origin + '/' + remsServList[remService].caseList[caseObj][fldname];

                                    }
                                }
                            }
                        }
                    }
                    if (remsServList[remService].caseList.length > 0) {

                        remsServList[remService].remsServiceObj._children = remsServList[remService].caseList;
                        if (!account._children) {
                            account._children = [];
                        }

                        if (this.isDocumentReview) {
                            account._children.push(...remsServList[remService].caseList);
                        }
                    }


                    delete remsServList[remService].caseList;
                    remsChildList.push(remsServList[remService].remsServiceObj);
                }

                if (account['_children']) {

                    account['_children']?.forEach(ele => {
                        if (ele.ParentId) {
                            let parentIndex = account['_children'].findIndex(el => el.Id.split("force.com/")[1] === ele.ParentId);
                            if (parentIndex != -1) {
                                account['_children'][parentIndex]['_children'] = [ele];
                            }
                        }

                    });

                    let filteredChildren = [...account['_children']?.filter(ele => !ele.ParentId)];
                    account['_children'] = [];
                    account['_children'].push(...filteredChildren);

                }

                accountList.push(account);
            }

            if (accountList && accountList.length > 0) {
                //this.displayServices = false;
                this.retrievedAccounts = [...accountList];
            } else {
                if (!this.isDocumentReview) {
                    this.displayServices = false;
                } else {
                    this.displayServices = true;
                }
                this.retrievedAccounts = null;
                this.noDataFoundAfterSearch = true;
            }
            this.displaySpinner = false;

        } catch (e) {
            this.displaySpinner = false;
        }
    }

    handleReset() {
        this.displaySpinner = true;
        this.searchDisabled = true;
        this.template.querySelectorAll('lightning-input').forEach(ele => {
            if (ele.name != 'US_WSREMS__REMS_Program__c') {
                ele.value = '';
                ele.setCustomValidity('');
                ele.reportValidity();
            }
        });
        this.retrievedAccounts = null;

        this.displaySpinner = false;
    }

    toggleCollapse() {
        const grid = this.template.querySelector('lightning-tree-grid');
        if (this.isCollapsed) {
            this.isCollapsed = false;
            grid.expandAll();
        } else {
            this.isCollapsed = true;
            grid.collapseAll();
        }
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }


}