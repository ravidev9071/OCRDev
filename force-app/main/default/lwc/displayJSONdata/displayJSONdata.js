import { LightningElement, track, api } from 'lwc';

export default class DisplayJSONData extends LightningElement {
    @track jsonData = [       
           {
                NPINumber: "123456",
                Fname: "Smith",
                Lname: "AB",
                Address: "3300 MERCY HEALTH BLVD",
                City: "Newport",
                State: "CINCINNATI",
                Postalcode: "45040-8341"
            },
        
        
    ];
    @track isEditing = {};
    
    handleEdit(event) {
        const rowId = event.target.dataset.id;
        this.isEditing[rowId] = !this.isEditing[rowId]; // Toggle edit mode
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        const rowId = event.target.dataset.id;
        this.jsonData = this.jsonData.map(row => {
            if (row.id === parseInt(rowId, 10)) {
                return { ...row, [field]: event.target.value };
            }
            return row;
        });
    }

    handleSave(event) {
        const rowId = event.target.dataset.id;
        this.isEditing[rowId] = false; // Exit edit mode
    }
}