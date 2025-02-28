import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import LightningAlert from "lightning/alert"; //this module needs to import.
import retrievePortalButtonConfigurationData from "@salesforce/apex/SYN_MetadataVariablesService.retrievePortalButtonConfigurationData";

export default class SYN_PrescriberBannerMessage extends LightningElement {
    
        @api buttonConfigName;
        buttonLabel;
		    @api firstName;
		    @api lastName;
        configRecord;
        accountStatus;
        showErrorMessage = false;
        errorMessage;
      
        async connectedCallback() {
          try {
            // Retrieve the metadata configuration
            const portalConfiguration = await retrievePortalButtonConfigurationData({
              buttomName: this.buttonConfigName,
            });
            console.log('Chai-PresBAnner-'+portalConfiguration);
            this.configRecord = portalConfiguration;
            this.accountStatus = this.configRecord.status;
            this.errorMessage = this.configRecord.buttonerrorMessage;
          } catch (e) {
            console.log(e);
          }
        }
       
}