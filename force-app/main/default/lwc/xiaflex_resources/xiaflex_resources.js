import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflex_customSecure';
import xiaflex_logo from "@salesforce/resourceUrl/xiaflex_HeaderLogo";
import xiaflex_adobeReader from "@salesforce/resourceUrl/xiaflex_adobeReader";
import xiaflex_iconDownload from "@salesforce/resourceUrl/xiaflex_iconDownload";
import xiaflex_iconSearch from "@salesforce/resourceUrl/xiaflex_iconSearch";
import xiaflex_iconLink from "@salesforce/resourceUrl/xiaflex_iconLink";
import { NavigationMixin } from 'lightning/navigation';
export default class Xiaflex_resources extends NavigationMixin(LightningElement){
    logo = xiaflex_logo;
    iconSearch = xiaflex_iconSearch;
    adobeReader = xiaflex_adobeReader;
    iconDownload = xiaflex_iconDownload;

    connectedCallback() {
        loadStyle(this, customHomeStyles); 

    }

}