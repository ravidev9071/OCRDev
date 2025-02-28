import { LightningElement,api,track,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import navStyles from '@salesforce/resourceUrl/aveed_navcss';
import getRelatedFilesByRecordId from '@salesforce/apex/REMSfileDownloadController.getRelatedFilesByRecordId';
import Redirect_URLs from '@salesforce/label/c.Redirect_URLs';
import { NavigationMixin } from 'lightning/navigation';
import getProgramId from '@salesforce/apex/REMSfileDownloadController.getProgramId';
import aveed_logo from "@salesforce/resourceUrl/aveed_logo";
import basePath from "@salesforce/community/basePath";
import { CurrentPageReference } from 'lightning/navigation';
export default class Aveed_Header extends NavigationMixin(LightningElement) {
    @api recordId;
    @api recordTypeDeveloperName;
    @api programId;
    @api portalRole;
    @api progId;
    @track isDisplayFiles = false;
    currentUrl;
    homeUrl;
    currentPageName;
    filesList = []; 
    
    redirectUrls = [];
    filename="Patient Counseling Tool: What You Need to Know About AVEED Treatment: A Patient Guide";
    previewurl;
    logo = aveed_logo;

    @wire(CurrentPageReference)
    getCurrentPageRef(pageRef) {
        if (pageRef) {
            // Get the current URL
            console.log(pageRef.attributes);
            this.currentPageName = pageRef.attributes.name;
            console.log('this.currentPageName ::', this.currentPageName);
        }
    }

    get aveedHome() {
        if (this.currentPageName === 'Home')
            return this.currentPageName === 'Home' ? 'highlightpanel' : 'aveedcss';  
    }
    get hcshcpLookup() {
        if (this.currentPageName === 'LookupHCS_HCP__c'){
        return this.currentPageName === 'LookupHCS_HCP__c' ? 'highlightpanel ' : 'aveedcss';
            }
        else if (this.currentPageName === 'Locator__c') {
            return this.currentPageName === 'Locator__c' ? 'highlightpanel' : 'aveedcss';
        }
    }
    get hcpPage() {
        if (this.currentPageName === 'hcpcertification__c'){
        return this.currentPageName === 'hcpcertification__c' ? 'highlightpanel' : 'aveedcss';
        }
        else if (this.currentPageName === 'NonPrescribingHCPTraining__c') {
            return this.currentPageName === 'NonPrescribingHCPTraining__c' ? 'highlightpanel' : 'aveedcss';
        }
    }
    get hcsPage() {
        return this.currentPageName === 'hcscertification__c' ? 'highlightpanel ' : 'aveedcss';
    }

    async connectedCallback() {
        try {
            loadStyle(this, customHomeStyles); 
            loadStyle(this, navStyles); 
            this.currentUrl = window.location.href;
            this.homeUrl = this.currentUrl.substring(0, this.currentUrl.indexOf('s/'))+'s';
            getProgramId({programName : this.programId}).then(res =>{
                
                this.progId = res;
                getRelatedFilesByRecordId({ recordTypeDevName: this.recordTypeDeveloperName,programId: this.progId,portalRole: this.portalRole })
                .then(result => {
                   
                const relatedFileResponse = result;
                const urls = Redirect_URLs.split(';');
                
                if (relatedFileResponse) {
                    
                    this.filesList = Object.keys(relatedFileResponse).map(item => ({
                        "label": relatedFileResponse[item].Name,
                        "value": item,
                        "url": relatedFileResponse[item].ContentDownloadUrl,
                        "previewurl":relatedFileResponse[item].DistributionPublicUrl,
                    }));
                    this.isDisplayFiles = true;
                   
                }
                this.redirectUrls = urls.map(url => ({label: url.split('|')[0], url: url.split('|')[1]}));
                
                })
                .catch(error => {
                    console.log(error);
                })
            })
            .catch(error => {
                console.log(error);
            })
            
        } catch (error) {
            console.log('error>>',error);
            this.isDisplayFiles = false;
        }

    }
    previewHandler(event) {
       
        for(var i=0;i< this.filesList.length;i++){
          
            if(this.filesList[i].label === this.filename){
                
             
                this.previewurl =this.filesList[i].previewurl;
                
                
            }
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:this.previewurl
            }}, false
        )
       
    }
    redirectURL(event){
        var value;
        var selectedvalue = event.target.dataset.id;
        var url = window.location.href; 
        value = url.substring(0,url.lastIndexOf('/') + 1);
        window.open(value+selectedvalue, '_self');
    }
    handleLoginClick(event) {
        window.open( "\login-signup","_self");
    }

    renderedCallback(){
        const anchorTagList = this.template.querySelectorAll('a.mainNavLink');
        let setHomeTagActive = true;
        let homeTag;
        for (var i = 0, len = anchorTagList.length; i < len; i++) {
            if(anchorTagList[i].dataset.name){
                const pathURL = basePath + '/' +anchorTagList[i].dataset.name;
                if( window.location.pathname == pathURL ){
                    anchorTagList[i].classList.add('active');
                    setHomeTagActive = false;
                } else {
                    if( anchorTagList[i].dataset.name == 'Home' ) {
                        homeTag = anchorTagList[i];
                    }
                }
            }
        }
        if( homeTag ){
            if(setHomeTagActive){
                homeTag.classList.add('active');
            } else {
                homeTag.classList.remove('active');
            }
        }
    }
//RT 10-10-24 changes
    handleHamburgerMenu(event) {
        console.log('inside hamger');
        console.log('--->',this.template.querySelector('[data-id="navBar"]').classList);
        if(this.template.querySelector('[data-id="navBar"]').classList && this.template.querySelector('[data-id="navBar"]').classList.value) {
            if(this.template.querySelector('[data-id="navBar"]').classList.value.includes("responsive")) {
                console.log('yes');
                this.template.querySelector('[data-id="navBar"]').classList.remove("responsive");
            } else {
                console.log('no');
                this.template.querySelector('[data-id="navBar"]').classList.add("responsive");
            }
        }
    }
}