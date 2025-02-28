import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import customHomeStyles_secure from '@salesforce/resourceUrl/aveed_customcssSecure';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getQuestions from '@salesforce/apex/KAController.getQuestions';
import getCaseAndRelatedData from '@salesforce/apex/KAController.getCaseAndRelatedData';
const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".knowledgeProgram"], [2, ".completeProgram"]]);

export default class Aveed_KAQuestionsMarked extends NavigationMixin(LightningElement) {
    recordId;
    @track responseRecords;
    programId;
    requestorType;
    fileURL;
    recordTypeDeveloperName = 'patient';
    portalRole = 'public';
    displayCard = false;
    @track assessment;
    @track attemptcount = 0;
    @track questions = [];
    @track isLoading = false;
    currentPath = 1;
    completedPath = 1;
    isloading = false;

    @wire(CurrentPageReference)
    CurrentPageReference(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c_id;
            this.attemptcount = pageRef.state.c_attempts;
            this.programId = pageRef.state.c_programName;
            this.requestorType = pageRef.state.c_participantType;
            this.fileURL = pageRef.state.c_fileURL;
            if (this.attemptcount == 1) {
                this.attemptcount = 2;
            } else if (this.attemptcount == 2) {
                this.attemptcount = 1;
            }
        }
    }
    async connectedCallback() {
        loadStyle(this, customHomeStyles);
        loadStyle(this, customHomeStyles_secure);

        await this.fetchrecords();
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

    async fetchrecords() {
        this.isloading = true;
        try {
            let result = await getCaseAndRelatedData({ recordId: this.recordId, isSummary: false })
            if (result) {
                this.responseRecords = result.responseList;
                if (this.responseRecords) {
                    this.getassessment();
                } else {
                    console.log('Something went wrong, please contact admin.')
                }
            } else {
                console.log('No data found');
            }
        } catch (error) {
            console.log('Errror', error);
        } finally {
            this.isloading = false;
        }
    }
    getassessment() {
        this.isloading = true;
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
                        // Update the questions array in place
                        this.questions.forEach(question => {
                            const responseRecord = responseMap.get(question.Id);
                            if (responseRecord && responseRecord.US_WSREMS__Response_Result__c === false) {
                                question.iscorrectanswer = 'kaQuestion kaQuestionIncorrect';
                            } else if (responseRecord && responseRecord.US_WSREMS__Response_Result__c === true) {
                                question.iscorrectanswer = 'kaQuestion kaQuestionCorrect';
                            }
                        });
                        this.displayCard = true;
                    }
                }
                else if (error) {
                    console.error('Error loading questions', error);
                } else {
                    console.error('Error while loading questions');
                }

                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading questions1', error);
                this.isLoading = false;
            });
    }

    parsePicklistOptions(optionsString) {
        return optionsString ? optionsString.split(';;').map((option) => ({ label: option, value: option })) : [];
    }

    navigateToReviewMaterials(event) {
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.fileURL
                }
            }, false
            )
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
                    name: 'KAQuestions__c'
                }, state: {
                    c_recordId: this.recordId,
                    c_participantType: this.requestorType,
                    c_programName: this.programId,
                    c_fileURL: this.fileURL
                }
            }).then(() => {
                window.location.reload();
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }
}