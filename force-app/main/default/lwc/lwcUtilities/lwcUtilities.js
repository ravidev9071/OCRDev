import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export const showToastMessage = function(title, message, type){
    const successToast = new ShowToastEvent({
        title : title,
        message : message,
        variant : type
    });
    dispatchEvent(successToast);
};

export * from "./commonLiterals";