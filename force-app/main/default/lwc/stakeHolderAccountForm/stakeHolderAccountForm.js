import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class StakeHolderAccountForm extends LightningElement {
    completeScreen = true;
    accountRecordTypeSecelctionScreen = true;
    accountCreationScreen = false;
    @api selectedValue;
    @api recordTypeName;
    @api showPopup = false;
    handleSelected(event) {
        this.selectedValue = event.detail;
    }

    handleRecordType(event) {
        this.recordTypeName = event.detail;
    }
  
    handleNext() {
        if (this.selectedValue !== undefined) {
            this.accountRecordTypeSecelctionScreen = false;
            this.accountCreationScreen = true;
        } else {
            this.showToastNotification('Error', 'Please select recordtype', 'error');
        }
    }
    showToastNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }
    handlePrevious() {
        this.completeScreen = true;
        this.accountRecordTypeSecelctionScreen = true;
        this.accountCreationScreen = false;
    }
    handleCancel(){
        this.showPopup=true;
      //this.closeForm();
    }
    handleYes() {
        // Handle cancellation logic here
        // Call an Apex method to perform cancellation
        // Hide the popup
        this.showPopup = false;
        this.closeForm();
    }
    handleNo() {
        // Hide the popup
        this.showPopup = false;
    }

    invokeWorkspaceAPI(methodName, methodArgs) {
        return new Promise((resolve, reject) => {
            const apiEvent = new CustomEvent("internalapievent", {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    category: "workspaceAPI",
                    methodName: methodName,
                    methodArgs: methodArgs,
                    callback: (err, response) => {
                        if (err) {
                            return reject(err);
                        } else {
                            return resolve(response);
                        }
                    }
                }
            });

            this.dispatchEvent(apiEvent);
        });
    }

    closeForm() {
        this.invokeWorkspaceAPI('isConsoleNavigation').then(isConsole => {
            console.log('WorkspaceAPI: isConsole: ', isConsole);
            if (isConsole) {
                this.invokeWorkspaceAPI('getFocusedTabInfo').then(async focusedTab => {
                    this.invokeWorkspaceAPI('closeTab', {
                        tabId: focusedTab.tabId,
                    })
                });
            }
        });

    }
}