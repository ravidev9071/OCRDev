import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import LightningAlert from "lightning/alert"; //this module needs to import.
import retrievePortalButtonConfigurationData from "@salesforce/apex/SYN_MetadataVariablesService.retrievePortalButtonConfigurationData";

export default class PortalNavigationButtons extends NavigationMixin(
  LightningElement
) {
  @api buttonConfigName;
  buttonLabel;
  configRecord;
  accountStatus;
  showErrorMessage = false;
  errorMessage;

  async connectedCallback() {
    try {
      this.buttonLabel = this.buttonConfigName;
      // Retrieve the metadata configuration
      const portalConfiguration = await retrievePortalButtonConfigurationData({
        buttomName: this.buttonConfigName,
      });
      console.log('Chai--'+portalConfiguration);
      this.configRecord = portalConfiguration;
      //this.buttonLabel = this.configRecord.buttonLabelName;
    } catch (e) {
      console.log(e);
    }
  }
  handleButtonClick(event) {
    // Perform validations
    if (this.configRecord.status === false) {
      // show the error message via modal
      this.showErrorMessage = true;
      this.errorMessage = this.configRecord.buttonerrorMessage;
      this.handleAlertClick();
    } else {
      // navigate to the page that was clicked
      this.navigateToInternalPage(this.configRecord.buttonURL);
    }
  } 

  async handleAlertClick() {
    await LightningAlert.open({
      message: this.errorMessage,
      theme: "error",
      variant: "headerless"
    });
  }

  /**
   *
   * @param {*} pageUrl
   */
  navigateToInternalPage(pageUrl) {
    window.location.href = pageUrl;
  }
}