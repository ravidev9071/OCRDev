import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getQuestions from '@salesforce/apex/TryvioKAAssessmentController.getQuestions';
import getCaseAndRelatedData from '@salesforce/apex/TryvioKAAssessmentController.getCaseAndRelatedData';
export default class TryvioRemsKAQuestionsMarked extends NavigationMixin(LightningElement) {
    presname;
    presnpi;
    recordId;
    responseRecords;
    displayCard = false;
    @track attemptcount = 0;
    @track questions = [];
    @track isLoading = false;
    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        console.log('pageRef', pageRef);
        if (pageRef) {
            this.presname = pageRef.state.c__name;
            this.presnpi = pageRef.state.c__npi;
            this.recordId= pageRef.state.c_id;
            this.attemptcount = pageRef.state.c_attempts;
            if (this.attemptcount == 1) {
                this.attemptcount = 2;
            } else if (this.attemptcount == 2) {
                this.attemptcount = 1;
            }
        }
    }
    async connectedCallback() {
        loadStyle(this, customStyles);
        await this.fetchrecords();
    }
    async fetchrecords() {
        this.laoding = true;
        try {
            let result = await getCaseAndRelatedData({ recordId: this.recordId, isSummary: false })
            if (result) {
                console.log('result@@', result);
                this.responseRecords = result.responseList;
                if (this.responseRecords) {
                    this.getassessment();
                } else {
                    wimdow.location.relaod();
                }
            } else {
                console.log('No data found');
            }
        } catch (error) {
            console.log('Errror', error);
        } finally {
            this.laoding = false;
        }
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
                        // Create a map of responseRecords for efficient lookup
                        const responseMap = new Map(this.responseRecords.map(record => [record.US_WSREMS__Assessment_Question__c, record]));
                        console.log('responseMap', responseMap);
                        // Update the questions array in place
                        this.questions.forEach(question => {
                            const responseRecord = responseMap.get(question.Id);
                            //console.log('quuestion', question.picklistOptions[parseInt(responseRecord.US_WSREMS__Answer__c - 1)].value);
                            //question.userValue = question.picklistOptions[parseInt(responseRecord.US_WSREMS__Answer__c - 1)].value;
                            console.log('quuestion answer', responseRecord.US_WSREMS__Answer__c);
                            question.userValue = responseRecord.US_WSREMS__Answer__c;
                            if (responseRecord && responseRecord.US_WSREMS__Response_Result__c === false) {
                                question.iscorrectanswer = 'kaQuestion kaQuestionIncorrect';
                            } else if (responseRecord && responseRecord.US_WSREMS__Response_Result__c === true) {
                                question.iscorrectanswer = 'kaQuestion kaQuestionCorrect';
                            }
                        });
                        this.displayCard = true;
                        console.log('questions', this.questions);
                    }
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
        let options = [];
        if(optionsString) {
            let optionsStringList = optionsString.split(';;');
            options = [];
            for(let i=0;i<optionsStringList.length;i++) {
                options.push({
                    label:optionsStringList[i],
                    value:optionsStringList[i].split('.')[0]
                });
            }
            console.log('options::::', options);
        }
        return options;
        //return optionsString ? optionsString.split(';;').map((option) => ({ label: option, value: option })) : [];
    }
    iconPrescriber = tryvioIconPrescriber;

    navigateToReviewMaterials(event) {
        try {
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'tryvioRemsKAQuestionsReviewMaterialHCP__c'
                }, state: {
                    c__name: this.presname,
                    c__npi: this.presnpi,
                    c__id: this.recordId,
                    c__record: 'sampaledata',
                    c__navigation: 'kaPage'
                }
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }
    navigateToRetakeAssessment(event) {
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
            }).then(() => {
                window.location.reload();
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }
}