import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
export default class OCR_DocumentReview extends NavigationMixin(LightningElement) {

     @api recordId ;
    @api programId;
    @api currentUserProgramName;
    programUser;
    @wire(CurrentPageReference)
    async getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.currentUserProgramName = currentPageReference.state.c__programName;
            this.programId = currentPageReference.state.c__programId;
            this.recordId=currentPageReference.state.c__recordId;

    }
    }


}