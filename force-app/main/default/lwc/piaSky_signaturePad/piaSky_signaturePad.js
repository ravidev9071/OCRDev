import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
let saveType = 'SFFile'; //'SFFile' 'Attachment'
let sCanvas, context; //canvas and it context 2d
let mDown = false;
let currPos = { x: 0, y: 0 };
let prePos = { x: 0, y: 0 };

export default class PiaSky_signaturePad extends LightningElement { 
    @api recordId;
    @api imagedataofsign;

    constructor() {
        super();
        this.template.addEventListener('mousedown', this.handleMousedown.bind(this));
        this.template.addEventListener('mouseup', this.handleMouseup.bind(this));
        this.template.addEventListener('mousemove', this.handleMousemove.bind(this));
        this.template.addEventListener('mouseout', this.handleMouseend.bind(this));
    }

    renderedCallback() {
        sCanvas = this.template.querySelector('canvas');
        context = sCanvas.getContext('2d');
    }

    handleMousedown(evt) {
        evt.preventDefault();
        mDown = true;
        this.getPos(evt);
    }

    @api
    handleSaveSignature(evt) {
        // context.globalCompositeOperation = "destination-over";
        // context.fillStyle = "#FFF";
        // context.fillRect(0, 0, sCanvas.width, sCanvas.height);
        const canvas = this.template.querySelector('canvas');
        const context = canvas.getContext('2d');
        const imageData1 = context.getImageData(0, 0, canvas.width, canvas.height);

        const isEmpty = this.isCanvasEmpty(imageData1);
        let imageURL = sCanvas.toDataURL('image/png');
        let imageData = imageURL.replace(/^data:image\/(png|jpg);base64,/, "");
        imageData = imageURL.replace(/^data:image\/(png|jpg);base64,/, "");
        const Image = new CustomEvent('signimagedata', {
            detail: {
                signdata : isEmpty? null : imageData
            } 
        }); 
        this.dispatchEvent(Image);
    }

    isCanvasEmpty(imageData) {
        // Loop through pixel data to check if all alpha values are 0
        for (let i = 0; i < imageData.data.length; i += 4) {
            if (imageData.data[i + 3] !== 0) {
                // If any pixel has a non-zero alpha value, the canvas is not empty
                return false;
            }
        }
        return true;
    }
    
    handleMouseup(evt) {
        evt.preventDefault();
        mDown = false;
    }

    handleMousemove(evt) {
        evt.preventDefault();
        if (mDown) {
            this.getPos(evt);
            this.draw();
        }
    }

    getPos(evt) {
        let cRect = sCanvas.getBoundingClientRect();
        prePos = currPos;
        currPos = { x: (evt.clientX - cRect.left), y: (evt.clientY - cRect.top) };
    }

    handleMouseend(evt) {
        evt.preventDefault();
        mDown = false;
    }

    draw() {
        context.beginPath();
        context.moveTo(prePos.x, prePos.y);
        context.lineCap = 'round';//smooth line
        context.lineWidth = 1.5;
        context.strokeStyle = "#0000FF";//blue
        context.lineTo(currPos.x, currPos.y);
        context.closePath();
        context.stroke();
    }

    @api
    handleClear() {
        context.clearRect(0, 0, sCanvas.width, sCanvas.height);
    }

    handleRefresh() {
        
        this.dispatchEvent(new RefreshEvent());
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}