/**
 * @description       : Apex class supports the VF component to retrieve the affiliation related records.
 * @author            : Utthirakumar
 * @group             : 
 * @last modified on  : 20-11-2024
 * @last modified by  : Utthirakumar
**/
public without sharing class GenerateAffiliationRelatedDetails {

    private List<Account> accountDetails;
    private Account hcsAR;

    /*
    *********************************************************
    @Property Name    : accountRecordId
    @author           : Utthirakumar
    @description      : Statkeholder's Id value is passed dynamically from the VF component.
    ********************************************************
    */
    public String accountRecordId {
        get { return accountRecordId; }
        set { accountRecordId = value; }
    }

    /*
    *********************************************************
    @Property Name    : programType
    @author           : Utthirakumar
    @description      : programType value is passed dynamically from the VF component.
    ********************************************************
    */
    public String programType {
        get { return programType; }
        set { programType = value; }
    }
    
    /*
    *********************************************************
    @Property Name    : retrieveHCPInfos
    @author           : Utthirakumar
    @description      : Boolean value is passed dynamically from the VF component.
                        True - To retrieve related HCP Infos
                        False - To do nothing
    ********************************************************
    */
    public Boolean retrieveHCPInfos {
        get { return retrieveHCPInfos; }
        set { retrieveHCPInfos = value; }
    }

    /*
    *********************************************************
    @Property Name    : retrieveHCSInfos
    @author           : Utthirakumar
    @description      : Boolean value is passed dynamically from the VF component.
                        True - To retrieve related HCS Infos
                        False - To do nothing
    ********************************************************
    */
    public Boolean retrieveHCSInfos {
        get { return retrieveHCSInfos; }
        set { retrieveHCSInfos = value; }
    }

    /*
    *********************************************************
    @Method Name    : getAccountDetails
    @author         : Utthirakumar
    @description    : method is used to retrieve related HCP or HCS details based on the boolean value passed from VF component.
    @return         : return the list<account> stakeholder details.
    ********************************************************
    */
    public List<Account> getAccountDetails(){

        accountDetails = new List<Account>();

        List<US_WSREMS__Affiliation__c> affList;
        
        if( !String.isBlank(accountRecordId) ) {
            if( retrieveHCPInfos ){
                affList = [ SELECT Id, CreatedDate, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Prescriber__c, CreatedById FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Health_Care_Setting__c =: accountRecordId AND US_WSREMS__Prescriber__c != NULL ORDER BY CreatedDate DESC Limit 1 ];
            } else if( retrieveHCSInfos ){
                affList = [ SELECT Id, CreatedDate, US_WSREMS__Health_Care_Setting__c, US_WSREMS__Prescriber__c, CreatedById FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c =: accountRecordId AND US_WSREMS__Health_Care_Setting__c != NULL ORDER BY CreatedDate DESC Limit 1 ];
            }

            if( affList != NULL && affList.size() > 0 ){
                if( retrieveHCPInfos ){
                    accountDetails = [ SELECT Id, FirstName, LastName FROM Account Where Id IN  ( SELECT US_WSREMS__Prescriber__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Health_Care_Setting__c =: affList[0].US_WSREMS__Health_Care_Setting__c AND CreatedById =: affList[0].CreatedById AND CreatedDate =: affList[0].CreatedDate ) ];
                }
        
                if( retrieveHCSInfos ){
                    accountDetails = [ SELECT Id, FirstName, LastName, Name, US_WSREMS__REMS_ID__c FROM Account Where Id IN ( SELECT US_WSREMS__Health_Care_Setting__c FROM US_WSREMS__Affiliation__c WHERE US_WSREMS__Prescriber__c =: affList[0].US_WSREMS__Prescriber__c AND CreatedById =: affList[0].CreatedById AND CreatedDate =: affList[0].CreatedDate ) ];
                }
            }
        }
        return accountDetails;
    }

    /*
    *********************************************************
    @Method Name    : gethcsAR
    @author         : Utthirakumar
    @description    : method is used to retrieve related AR details based on the HCS Id passed.
    @return         : return the AR stakeholder details.
    ********************************************************
    */
    public Account gethcsAR(){
        
        List<Account> accList = new List<Account>();
        Account accRec;
        if( !String.isBlank(accountRecordId) ){
            accList = [ Select Id, FirstName, LastName From Account Where Id IN (Select US_WSREMS__Authorized_Representative__c From US_WSREMS__Affiliation__c Where US_WSREMS__Health_Care_Setting__c =: accountRecordId AND US_WSREMS__Authorized_Representative__c != NULL AND US_WSREMS__isActive__c = TRUE )];
            if( accList != NULL && accList.size() > 0 ) {
                accRec = accList[0];
            }
        }
        return accRec;
    }
    
}