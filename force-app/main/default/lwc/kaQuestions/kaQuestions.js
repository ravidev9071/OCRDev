import { LightningElement, wire, api, track } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import getQuestions from '@salesforce/apex/KAController.getQuestions';
import SUBMIT_RESPONSE from '@salesforce/apex/KAController.getSubmitResponse';
const CASE_FIELDS = ['CASE.US_WSREMS__REMS_Program__r.LastModifiedDate', 'CASE.US_WSREMS__REMS_Program__c', 'CASE.US_WSREMS__REMS_Program__r.Name', 'CASE.US_WSREMS__Service_Requestor_Type__c'];
const SUBMISSION_FIELDS = ['US_WSREMS__Assessment_Submission__c.US_WSREMS__Assessment__c', 'US_WSREMS__Assessment_Submission__c.US_WSREMS__Assessment_Result__c', 'US_WSREMS__Assessment_Submission__c.US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c', 'US_WSREMS__Assessment_Submission__c.US_WSREMS__Assessment__r.US_WSREMS__Show_Wrong_Answers_Only__c'];
const RESPONSE_FIELDS = ['US_WSREMS__Assessment_Response__c.US_WSREMS__Assessment_Question__c', 'US_WSREMS__Assessment_Response__c.US_WSREMS__Answer__c', 'US_WSREMS__Assessment_Response__c.US_WSREMS__Response_Result__c'];
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import customHomeStyles_secure from '@salesforce/resourceUrl/aveed_customcssSecure';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import getCaseAndRelatedData from '@salesforce/apex/KAController.getCaseAndRelatedData';
import { refreshApex } from '@salesforce/apex';
import { getAppLiterals } from 'c/appLiterals';
const GET_LITERALS = getAppLiterals();
const STATE = GET_LITERALS.STATE;
const PARTICIPANT_TYPE = GET_LITERALS.PARTICIPANT_TYPE;
import communityPath from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
const REQUESTOR_TYPE = GET_LITERALS.REQUESTOR_TYPE;
const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".knowledgeProgram"], [2, ".completeProgram"]]);
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import USER_ACCOUNT_ID from '@salesforce/schema/User.AccountId';
import USER_CONTACT_ID from '@salesforce/schema/User.ContactId';

import USER_ID from '@salesforce/user/Id';
import updatePortalStageForAccount from "@salesforce/apex/Aveed_HCPEnrollmentCtrl.updatePortalStageForAccount";

export default class KaQuestions extends NavigationMixin(LightningElement) {
    @api recordId;
    relatedListId;
    @api programName;
    programId;
    @api fileURL;

    participantType;
    caseRecord;
    showResponse;
    submissionRecords;
    @track responseRecords = [];
    maximumAttemptsAllowed;
    showWrongQuestionsOnly;
    lastSubmittedRecordId;
    requestorTypeConst = REQUESTOR_TYPE;
    @api requestorType;
    @api assessmentLabel;
    @api assessment;
    @track questions = [];
    @track isInputsCorrect;
    @track attemptsCount = 0;
    @track maxAttemptCount = 0;
    @track isCheckAttempt;
    @api displayCard = false;
    displaySpinner = false;
    state = STATE;
    participantState = PARTICIPANT_TYPE;
    currentPath = 1;
    completedPath = 1;

    userId = USER_ID;

    @wire(getRecord, { recordId: "$userId", fields: [USER_ACCOUNT_ID, USER_CONTACT_ID] })
    user;

    get userAccountId() {
        return getFieldValue(this.user.data, USER_ACCOUNT_ID);
    }

    get userContactId() {
        return getFieldValue(this.user.data, USER_CONTACT_ID);
    }

    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        console.log('pageRef', pageRef);
        if (pageRef) {
            this.recordId = pageRef.state.c_recordId;
            this.programId = pageRef.state.c_programName;
            this.requestorType = pageRef.state.c_requestorType;
            this.fileURL = pageRef.state.c_fileURL;
        }
    }
    async connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, customHomeStyles_secure);
        await this.fetchrecords();
        this.getassessment();
    }

    renderedCallback() {
        setTimeout(() => {
            let currentElement = this.template.querySelector(PATH_MAP.get(this.currentPath));
            this.currentPathHandler(currentElement);
            for (let i = 0; i < this.completedPath; i++) {
                let element = this.template.querySelector(PATH_MAP.get(i));
                this.completePathHandler(element);
            }

        }, 100)
    }

    completePathHandler(element) {
        element.classList.remove('slds-is-current');
        element.classList.add('slds-is-complete');
        element.classList.remove('slds-is-incomplete');
    }

    currentPathHandler(element) {
        element.classList.add('slds-is-current');
        element.classList.remove('slds-is-complete');
        element.classList.add('slds-is-incomplete');
    }

    get isdisable() {
        return !this.questions.every(question => question.responseValue !== undefined);
    }
    async fetchrecords() {
        this.displaySpinner = true;
        await getCaseAndRelatedData({ recordId: this.recordId, isSummary: false })
            .then(data => {
                this.caseRecord = data.caseRecord;
                this.attemptsMade = this.caseRecord.US_WSREMS__Attempts_Made__c;
                this.submissionRecords = data.assessmentList;
                this.responseRecords = data.responseList;
                this.participantType = this.caseRecord.US_WSREMS__Service_Requestor_Type__c;
                this.programId = this.caseRecord.US_WSREMS__REMS_Program__c;
                let submittedRecordsCount = this.submissionRecords.length > 0 ? this.submissionRecords.length - 1 : 0;
                let submittedRecordsCountOrg = this.submissionRecords.length > 0 ? this.submissionRecords.length : 0;
                this.maximumAttemptsAllowed = submittedRecordsCount > 0 ? this.submissionRecords[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Maximum_Attempts__c : 0;
                if (this.submissionRecords.length > 0 && this.submissionRecords[submittedRecordsCount].US_WSREMS__Assessment_Result__c == 'Passed') {
                    
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'ka_success__c'
                            }, state: {
                                c_id: this.recordId
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                    return;
                }
                if (this.maximumAttemptsAllowed > 0 && this.maximumAttemptsAllowed <= this.attemptsMade) {
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'KAFail__c'
                            }, state: {

                                c_id: this.recordId
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                } else {
                    this.attemptsCount = this.attemptsMade + 1;
                    if (this.attemptsCount == 1) {
                        this.attemptone = true;
                        console.log('attemptone', this.attemptone);
                    } else if (this.attemptsCount > 1) {
                        this.attemptnext = true;
                        console.log('attemptsCount', this.attemptsCount);
                    }
                    console.log('attemptsCount@@@@', this.attemptsCount);
                    this.showWrongQuestionsOnly = submittedRecordsCountOrg > 0 && this.submissionRecords.length > 0 ? this.submissionRecords[submittedRecordsCount].US_WSREMS__Assessment__r.US_WSREMS__Show_Wrong_Answers_Only__c : false;
                    console.log('@@@showWrongQuestionsOnly', this.showWrongQuestionsOnly);
                    if (this.attemptsCount > 1 && this.showWrongQuestionsOnly && this.submissionRecords[submittedRecordsCount]) {
                        this.lastSubmittedRecordId = this.submissionRecords[submittedRecordsCount].Id;
                    } else {
                        this.participantType = this.caseRecord.US_WSREMS__Service_Requestor_Type__c;
                        this.programId = this.caseRecord.US_WSREMS__REMS_Program__c;
                    }
                }

                this.displaySpinner = false;
            })
            .catch(error => {
                this.displaySpinner = false;
                this.displayToast('dismissible', 'error', 'Error fetching records', error.message);
            });
    }

    getassessment() {
        this.displaySpinner = true;
        getQuestions()
            .then(data => {
                if (data) {
                    this.assessment = data[0];
                    this.maxAttemptCount = this.assessment?.US_WSREMS__Maximum_Attempts__c;
                    this.assessmentLabel = this.assessment?.Name;
                    if (this.assessment.US_WSREMS__Assessment_Questions__r === undefined || this.assessment.US_WSREMS__Assessment_Questions__r === null) {
                        return;
                    } else {
                        //Questions without dependent questions
                        this.questions = this.assessment.US_WSREMS__Assessment_Questions__r.map((question, index) => ({
                            Id: question.Id,
                            index: ++index,
                            type: question.US_WSREMS__Response_Data_Type__c,
                            label: question.US_WSREMS__Question_Text__c,
                            labelWithSequence: question.US_WSREMS__Question_Text__c,
                            defaultText: question.US_WSREMS__Default_Value__c,
                            dependentQuestion: question.US_WSREMS__Dependent_Question__c,
                            responseDependency: question.US_WSREMS__Response_Dependency__c,
                            required: question.US_WSREMS__Required__c,
                            picklistOptions: this.parsePicklistOptions(question.US_WSREMS__Response_Values__c),
                            selectedOption: question.US_WSREMS__Default_Value__c,
                            responseValue: question.US_WSREMS__Response_Dependency__c === 'Toggle' ? 'No' : question.US_WSREMS__Default_Value__c,
                            helpText: question.productdi__Help_Text__c,
                            isDate: question.US_WSREMS__Response_Data_Type__c === 'Date',
                            isText: question.US_WSREMS__Response_Data_Type__c === 'Text',
                            isTextArea: question.US_WSREMS__Response_Data_Type__c === 'Text Area',
                            isToggle: question.US_WSREMS__Response_Data_Type__c === 'Toggle',
                            isEmail: question.US_WSREMS__Response_Data_Type__c === 'Email',
                            isNumber: question.US_WSREMS__Response_Data_Type__c === 'Number',
                            isURL: question.US_WSREMS__Response_Data_Type__c === 'URL',
                            isPicklist: question.US_WSREMS__Response_Data_Type__c === 'Picklist',
                            isMultiSelectPicklist: question.US_WSREMS__Response_Data_Type__c === 'Picklist (Multi-Select)',
                            isRadioOption: question.US_WSREMS__Response_Data_Type__c === 'Radio Option',
                            isMultiSelectOption: question.US_WSREMS__Response_Data_Type__c === 'Multiselect Option',
                            showQuestion: question.US_WSREMS__Dependent_Question__c === undefined || question.US_WSREMS__Dependent_Question__c === null
                        }));
                        console.log('intial questions', this.questions);
                        if (this.attemptsCount > 1 && this.showWrongQuestionsOnly) {

                            // Create a map of responseRecords for efficient lookup
                            const responseMap = new Map(this.responseRecords.map(record => [record.US_WSREMS__Assessment_Question__c, record]));
                            console.log('responseMap', responseMap);
                            // Update the questions array in place
                            this.questions.forEach(question => {
                                const responseRecord = responseMap.get(question.Id);
                                if (responseRecord && responseRecord.US_WSREMS__Response_Result__c === false) {
                                    console.log('wrongquestions');
                                    question.showQuestion = true;
                                    if (question.dependentQuestion !== undefined) {
                                        const responseForDependentRecord = responseMap.get(question.dependentQuestion);
                                        if (responseForDependentRecord && responseForDependentRecord.US_WSREMS__Response_Result__c === false) {
                                            question.showQuestion = false;
                                        }
                                    }
                                } else if (responseRecord !== undefined) {
                                    question.responseValue = responseRecord.US_WSREMS__Answer__c;
                                    question.showQuestion = false;
                                }
                            });
                        }
                        console.log('After filter questions', this.questions);
                        this.displayCard = true;
                    }
                    this.refreshQuestionSequence();
                }
                else if (error) {
                    console.error('Error loading questions', error);
                } else {
                    console.error('Error while loading questions');
                }
                this.displaySpinner = false;
            })
            .catch(error => {
                console.error('Error loading questions1', error);
                this.displaySpinner = false;
            });
    }

    parsePicklistOptions(optionsString) {
        return optionsString ? optionsString.split(';;').map((option) => ({ label: option, value: option })) : [];
    }

    handleChangeEvent(event) {
        const questionId = event.target.dataset.questionId;
        let selectedValues;
        if (event.target.type == 'toggle') {
            selectedValues = event.detail.checked ? "Yes" : "No";
        }
        else if (event.target.type == 'radio') {
            // take the first character of selected answer. E.g 'A'
            selectedValues = event.detail.value.substring(0, 1);
        }
        else {
            selectedValues = event.detail.value;
        }

        // Update the selected values for the corresponding question
        this.updateQuestions(questionId, selectedValues);
        //Help to add/Remove dependent questions
        this.handleDependentQuestion(questionId, selectedValues, false);
    }

    handleMultiSelectChange(event) {

        const questionId = event.target.dataset.questionId;
        let selectedValues;
        if (event.target.type == 'multiPicklist') {
            selectedValues = event.detail.value.join(';;');
        }
        else if (event.target.type == 'comboBox') {
            selectedValues = event.detail.value.map(function (str) {
                return str[0];
            }).join(';;');
        }
        // Update the selected values for the corresponding question
        this.updateQuestions(questionId, selectedValues);
        //Help to add/Remove dependent questions
        this.handleDependentQuestion(questionId, selectedValues, true);
    }

    handleDependentQuestion(questionId, selectedValues, isDualBox) {

        if (isDualBox) {
            let filteredList = this.questions.filter(r => r.dependentQuestion === questionId &&
                (r.responseDependency.includes(selectedValues) || selectedValues.includes(r.responseDependency)));
            if (filteredList.length > 0) {
                if (this.responseRecords !== undefined && this.responseRecords.length > 0) {
                    filteredList = this.handleFilterQuestions(filteredList);
                }
                //Added the dependent questions if those match with response value
                this.questions.forEach((eachQuest) => {
                    filteredList.forEach((filteredQuest) => {
                        if (eachQuest.Id === filteredQuest.Id) {
                            eachQuest.showQuestion = true;
                        }
                    })
                })
            } else {
                //Remove the dependent questions if those are added and selected value does not match with response value
                this.handleHideDependentQuestions(questionId);
            }

        } else {
            let filteredList = this.questions.filter(r => r.dependentQuestion === questionId && r.responseDependency === selectedValues.trim());
            if (filteredList.length > 0) {
                if (this.responseRecords !== undefined && this.responseRecords.length > 0) {
                    filteredList = this.handleFilterQuestions(filteredList);
                }
                //Added the dependent questions if those match with response value
                this.questions.forEach((eachQuest) => {
                    filteredList.forEach((filteredQuest) => {
                        if (eachQuest.Id === filteredQuest.Id) {
                            eachQuest.showQuestion = true;
                        }
                    })
                })
            } else {
                //Remove the dependent questions if those are added and selected value does not match with response value
                this.handleHideDependentQuestions(questionId);
            }
        }

        this.refreshQuestionSequence();

        //Remove any duplicate questions
    }

    //Remove the dependent questions if those are added and selected value does not match with response value
    handleHideDependentQuestions(questionId) {
        this.questions = this.questions.map((question) => {
            if (question.dependentQuestion === questionId) {
                return { ...question, showQuestion: false };
            }
            return question;
        });
    }

    handleFilterQuestions(filteredList) {
        const responseMap = new Map(this.responseRecords.map(record => [record.fields.US_WSREMS__Assessment_Question__c.value, record]));
        // Update the questions array in place
        filteredList.forEach(question => {
            const responseRecord = responseMap.get(question.Id);
            if (responseRecord && responseRecord.fields.US_WSREMS__Response_Result__c.value === false) {
                question.showQuestion = true;
            } else {
                question.responseValue = responseRecord.fields.US_WSREMS__Answer__c.value;
                question.showQuestion = false;
            }
        });
        this.refreshQuestionSequence();
        return filteredList;
    }

    async handleSubmit() {

        this.displaySpinner = true;

        if (this.isInputValid()) {

            let response = this.questions.map(question => {
                return {
                    US_WSREMS__Assessment_Question__c: question.Id,
                    US_WSREMS__Question__c: question.label,
                    US_WSREMS__Answer__c: question.responseValue,
                    US_WSREMS__Response__c: question.responseValue === undefined ? question.responseValue : this.getAnswer(question)
                };
            });

            try {
                const responseResult = await SUBMIT_RESPONSE({
                    caseId: this.recordId, assessmentId: this.assessment.Id,
                    responseDetails: response, assessmentPassPer: this.assessment.US_WSREMS__Pass_Percentage__c, attemptsCount: this.attemptsCount
                });

                // Close the quick action popup when the record is saved successfully
                if (responseResult == 'Success - Passed') {
                    const statusResult = await updatePortalStageForAccount({ 'accountId': this.userAccountId, 'portalStage': '.completeProgram' });
                    this.displaySpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record created successfully',
                            variant: 'success'
                        })
                    );
                    window.location.reload();
                } else {
                    this.displaySpinner = false;
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'aveed_KAQuestionsMarked__c'
                            }, state: {
                                c_id: this.recordId,
                                c_attempts: this.attemptsCount,
                                c_programName: this.programId,
                                c_participantType: this.requestorType,
                                c_fileURL: this.fileURL
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                }
            } catch (error) {
                let errorMessage = 'Record creation unsuccessful';

                // Check if the error object contains a message
                if (error && error.body && error.body.message) {
                    errorMessage = 'Error: ' + error.body.message;
                }
                this.displaySpinner = false;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'All questions must be answered to submit the Knowledge Assessment',
                    variant: 'error'
                })
            );
            this.displaySpinner = false;
        }
    }


    isInputValid() {
        debugger;
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');

        inputFields.forEach(inputField => {

            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            this.questions[inputField.name] = inputField.value;
        });
        return isValid;
    }

    updateQuestions(questionId, selectedValues) {
        this.questions = this.questions.map((question) => {
            if (question.Id === questionId) {
                return { ...question, responseValue: selectedValues };
            }
            return question;
        });
    }

    refreshQuestionSequence() {
        let index = 0;

        this.questions = this.questions.map((question) => {
            if (question.showQuestion) {
                return { ...question, labelWithSequence: ++index + '. ' + question.label };
            }
            return question;
        });
    }
    getAnswer(question) {

        if (question.type == 'Radio Option' || question.type == 'Multiselect Option') {
            let result = '';

            let selValues = question.responseValue.split(';;');

            // Assuming you want to return the selected options without the prefix 'A.'
            selValues.forEach(value => {
                let selectedOption = question.picklistOptions.find(option => option.value.startsWith(value)).value;
                result += selectedOption ? selectedOption.slice(2).trim() + ';;' : ''; // Remove the first two characters ('A.')
            });

            // Remove the trailing ';'
            result = result.slice(0, -1);

            return result;
        }

        return question.responseValue;
    }

    get labelSytle() {
        return `font-size : ${this.fontSize}`;
    }
}