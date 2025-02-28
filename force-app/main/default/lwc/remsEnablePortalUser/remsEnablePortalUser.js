import { LightningElement,api} from 'lwc';
import portalUserCreation from '@salesforce/apex/REMSEnablePortalUserController.portalUserCreation';
import LightningAlert from 'lightning/alert';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class RemsEnablePortalUser extends LightningElement {  

    @api set recordId(value) {
        this._recordId = value;

        this.handleClick();
    }
        
    get recordId() {
        return this._recordId;
    }

    handleClick(){  
        this.closeQuickAction();     
        portalUserCreation({ recordId: this.recordId })
        .then(result => {
           console.log('--->'+JSON.stringify(result));  
           console.log(result.split('#'));
           LightningAlert.open({
                message: result.split('#')[1],
                theme: result.split('#')[0],
                label: result.split('#')[0]+'!',                
            }).then((result) => {
               // this.closeQuickAction();
                console.log('alert is closed');
            });
        })
        .catch(error => {
            this.error = error;
            LightningAlert.open({
                message: 'Something went wrong. Please contact the administrator.',
                theme: 'error',
                label: 'Error!',                
            }).then((result) => {
                this.closeQuickAction();
                console.log('alert is closed');
            });
        });
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}