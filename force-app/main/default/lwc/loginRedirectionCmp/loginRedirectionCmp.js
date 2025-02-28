import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PicklistComponent extends NavigationMixin(LightningElement) {
    value = '';

    get options() {
        return [
            { label: 'Prescriber', value: 'Prescriber' },
            { label: 'PharmaPharmacy Participantcist', value: 'Pharmacy Participant' },
        ];
    }
    handleChange(event){
            this.value = event.detail.value;
    }
   /* handleSubmit() {
        //alert('Hello');
        if (this.value == 'Prescriber') {
           // alert('Prescriber');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://remsdigitaldev1-developer-edition.na211.force.com/remsdigital/s'
                }
            },
                true 
            );
            //window.open('https://google.com','_top');
        }
        else if (this.value == 'Pharmacist') {
          //  alert('Pharmacist');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: 'https://remsdigitaldev1-developer-edition.na211.force.com/s'
                }
            },
                true 
            );
        }
    }*/
    handlePharmacistSubmit(){
        window.open('https://hcsit-healthcloudtrialmaster-15a4d-17b988aeda0.cs211.force.com/Pharmacyportal/s/login/?startURL=%2FPharmacyportal%2Fs%2F%3Ft%3D1659642978045','_top');
    }
    handlePrescriberSubmit(){
        window.open('https://hcsit-healthcloudtrialmaster-15a4d-17b988aeda0.cs211.force.com/SOXPrescriberPortal/s/login/?startURL=%2FSOXPrescriberPortal%2Fs%2F%3Ft%3D1659642886358','_top');
    }
  
}