import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import getQuestions from '@salesforce/apex/TryvioKAAssessmentController.getQuestions';
import SUBMIT_RESPONSE from '@salesforce/apex/TryvioKAAssessmentController.getSubmitResponse';
import getCaseAndRelatedData from '@salesforce/apex/TryvioKAAssessmentController.getCaseAndRelatedData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class TryviokaQuestions extends NavigationMixin(LightningElement) {
    iconPrescriber = tryvioIconPrescriber;
    @api recordId;
    relatedListId;
    programId = 'TRYVIO REMS';
    participantType = 'Prescriber';
    caseRecord;
    submissionRecords;
    responseRecords;
    maximumAttemptsAllowed;
    showWrongQuestionsOnly;
    lastSubmittedRecordId;
    attemptsMade;
    presname;
    presnpi;
    caseId;
    @api requestortype;
    @api assessmentLabel;
    @api assessment;
    @track questions = [];
    @track isInputsCorrect;
    @track attemptsCount = 0;
    @track maxAttemptCount = 0;
    @track isCheckAttempt;
    @api displayCard = false;
    displaySpinner = false;
    showPreview = false;
    @api nextStep;
    @api previousStep;
    @api fontSize = '';
    @api fontColor = '';
    @track attemptone = false;
    @track attemptnext = false;

    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.recordId = pageRef.state.c_id;
        }
    }
    async connectedCallback() {
        loadStyle(this, customStyles)
        await this.fetchrecords();
        this.getassessment();
    }
    get isdisable() {
        return !this.questions.every(question => question.responseValue !== undefined);
    }
    async fetchrecords() {
        await getCaseAndRelatedData({ recordId: this.recordId, isSummary: false })
            .then(data => {
                console.log('data tryvioka Quetions.js', data);
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
                    this.displayCard = false;
                    this.modal = true;
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'tryvioRemsKASuccessForm__c'
                            }, state: {
                                c__name: this.presname,
                                c__npi: this.presnpi,
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
                                name: 'tryvioRemsKAFail__c'
                            }, state: {
                                c__name: this.presname,
                                c__npi: this.presnpi,
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
            })
            .catch(error => {
                this.displayToast('dismissible', 'error', 'Error fetching records', error.message);
            });
    }
    getassessment() {

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
            })
            .catch(error => {
                console.error('Error loading questions1', error);
                // this.displayToast('dismissible', 'error', 'Error fetching questions', error.message);
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
    handleChangeEventForTextArea(event) {
        const questionId = event.target.dataset.questionId;
        const selectedValues = event.target.value;
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
    }
    handleFilterQuestions(filteredList) {
        const responseMap = new Map(this.responseRecords.map(record => [record.productdi__Assessment_Question__c, record]));
        // Update the questions array in place
        filteredList.forEach(question => {
            const responseRecord = responseMap.get(question.Id);
            if (responseRecord && responseRecord.productdi__Response_Result__c === false) {
                question.showQuestion = true;
            } else {
                question.responseValue = responseRecord.productdi__Answer__c;
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
                console.log('responseResult', responseResult);
                console.log('attemptscount', this.attemptsCount);
                // Close the quick action popup when the record is saved successfully
                if (responseResult == 'Success - Passed - Not Enrolled') {
                    this.displaySpinner = false;
                    try {
                        console.log('successpage Not Enrolled');
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'tryvioRemsKASuccessForm__c'
                            }, state: {
                                c__name: this.presname,
                                c__npi: this.presnpi,
                                c_id: this.recordId
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                }else if (responseResult == 'Success - Passed - Enrolled') {
                    console.log('successpage Enrolled');
                    this.displaySpinner = false;
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Prescriber_Enrollment_Form_Success__c'
                            },state: {
                                c__name: this.presname,
                                c__npi: this.presnpi
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                }
                 else if (this.attemptsCount >= 3 && responseResult == 'Success - Failed') {
                    console.log('Failedpage');
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'tryvioRemsKAFail__c'
                            }, state: {
                                c__name: this.presname,
                                c__npi: this.presnpi,
                                c_id: this.recordId
                            }
                        });
                    } catch (error) {
                        console.log('error --' + error.message);
                    }
                } else {
                    console.log('retakenpage');
                    try {
                        this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'tryvioRemsKAQuestionsMarked__c'
                            }, state: {
                                c__name: this.presname,
                                c__npi: this.presnpi,
                                c_id: this.recordId,
                                c_attempts: this.attemptsCount
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
                    console.log('error.body.message', error.body.message);
                } else if (error && error.message) {
                    errorMessage = 'Error: ' + error.message;
                    console.log('error.message', error.message);
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
                    message: QuestionsLeftUnanswered,
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
                return { ...question, labelWithSequence: question.label };
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
}