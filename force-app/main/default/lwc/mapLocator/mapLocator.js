import { LightningElement, wire, track, api } from 'lwc';

export default class MapLocator extends LightningElement {
  @track center;
  @api recordId;
  @api paramMapMarkers;
  @api markerTitle;
  @api mapMarkers = [];
  @api selectedvalue;
  @api listViewType;
  @api zoomType;  
}