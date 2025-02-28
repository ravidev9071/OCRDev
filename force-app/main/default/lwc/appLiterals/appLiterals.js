const getAppLiterals= () => {
    return Object.freeze({
        STATE : {
            assesmentPassStatus : 'Passed',
        },
        PARTICIPANT_TYPE : {
            healthCareSetting : 'Health Care Setting',
            presriber : 'Prescriber',
            pharmacyParticipant : 'Pharmacy/HCS Participant',
            Pharmacy_Participant : 'Pharmacy_Participant',
            PharmacyHCSParticipant : 'Pharmacy/HCS Participant',
            OutPatientPharmacy : 'Outpatient Pharmacy',
            inpatientPharmacy : 'Inpatient Pharmacy'
        },
        REQUESTOR_TYPE : {
            healthCareSetting : 'Health Care Setting',
            HEALTH_CARE_SETTING_ROLE : 'Health Care Setting',
            OUTPATIENT_PHARMACY : 'Outpatient Pharmacy',
            INPATIENT_PHARMACY : 'Inpatient Pharmacy',
            PRESCRIBER_ROLE : 'Prescriber',
        },
        VALIDATION : {
            required : ' Required',
        },
        OBJECT_NAME:{
            case:'Case'
        },
        USER_ROLES : {
            PRESCRIBER_ROLE : 'Prescriber',
            PHARMACY_ROLE : 'Pharmacy',
            HEALTH_CARE_SETTING_ROLE : 'Health Care Setting',
            OUTPATIENT_PHARMACY : 'Outpatient Pharmacy',
            INPATIENT_PHARMACY : 'Inpatient Pharmacy',
        }
    });
}
export { getAppLiterals};