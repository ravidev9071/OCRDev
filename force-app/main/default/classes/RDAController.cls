/**************************************************************************
    ----------------------------------------------------------------------------------
    Developer               Date                   Description         Story
    Vijay Kumar             19/09/2024             Initial Version     2349
    -----------------------------------------------------------------------------------
*********************************************************************************/
public without sharing  class RDAController {  
    /**
     * @description: Fetches a list of Cases based on provided parameters like accountId, remsId, sorting, pagination, etc.
     * @param paramJson: A JSON string containing filtering and sorting parameters such as accountId, remsId, sortBy, sortDirection, userAccountId, pageSize, pageNumber, startDate, and endDate.
     * @return: A List of Case records matching the provided filters.
     * @throws: AuraHandledException if an error occurs during query execution.
     * @developer: RT
     * @date: 09/10/2024
     */                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
    @AuraEnabled
    public static List<Case> getCasesByAccount(String paramJson) {
        List<Case> caseList = new List<Case>();
        try {
            Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(paramJson);
            
            // Using temporary objects to check for null values
            Object accIdObj = paramMap.get('accountId');
            String accountId = (accIdObj != null) ? (String) accIdObj : null;
    
            Object remsIdObj = paramMap.get('remsId');
            String remsId = (remsIdObj != null) ? (String) remsIdObj : null;
    
            Object sortByObj = paramMap.get('sortBy');
            String sortBy = (sortByObj != null) ? (String) sortByObj : null;
    
            Object sortDirectionObj = paramMap.get('sortDirection');
            String sortDirection = (sortDirectionObj != null) ? (String) sortDirectionObj : null;
    
    
            Object pageSizeObj = paramMap.get('pageSize');
            Integer pageSize = (pageSizeObj != null) ? (Integer) pageSizeObj : null;
    
            Object pageNumberObj = paramMap.get('pageNumber');
            Integer pageNumber = (pageNumberObj != null) ? (Integer) pageNumberObj : null;
    
            Date startDate = null;
            Date endDate = null;
            Object startDateObj = paramMap.get('startDate');
            Object endDateObj = paramMap.get('endDate');
            
            if (startDateObj != null && endDateObj != null) {
                startDate = Date.valueOf((String) startDateObj);
                endDate = Date.valueOf((String) endDateObj);
            }

            Object isDownloadObj = paramMap.get('isDownload');
            Boolean isDownload = (isDownloadObj != null) ? (Boolean) isDownloadObj : null;
    
            List<String> queryParts = new List<String>();
            //RT 10-11-24 Defect changes Querying for cases with 'Approved' and 'Reversed' outcomes in US_WSREMS__Outcome__c
            queryParts.add('SELECT RDA_Authorization_Code__c, Status, US_WSREMS__Outcome__c, US_WSREMS__Patient_Risk_Category__c, ' +
                           'Monthly_Pregnancy_Test_Recorded__c, Manufacturer__c, RDA_Authorization_Code_Date__c, CreatedDate, ' +
                           'Pharmacy_Participant__r.Name, SYN_Prescriber__r.Name, NDC_Code__c, SYN_Days_Supply__c, ' +
                           'Prescriber_NPI__c, SYN_Patient_REMS_ID_Number__c, Counseling_Recorded__c ' +
                           'FROM Case WHERE Status = \'Complete\' AND US_WSREMS__Outcome__c IN (\'Approved\',\'Reversed\') ' +
                           'AND RecordType.Name = \'RDA\' AND US_WSREMS__Pharmacy__c = :accountId  ');
    
            if (startDate != null && endDate != null) {
                DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23, 59, 59, 999));
                queryParts.add(' AND CreatedDate >= :startDate AND CreatedDate <= :endDateTime ');
            }
            
            // Add REMS ID filter if provided
            if (remsId != null && remsId != '') {
                queryParts.add(' AND SYN_Patient_REMS_ID_Number__c = :remsId ');
            }
    
            // Handle sorting
            if (sortBy != null && sortBy != '') {
                queryParts.add(' ORDER BY ' + sortBy + ' ' + sortDirection + ' ');
            } else {
                queryParts.add(' ORDER BY CreatedDate DESC ');
            }
    
            // Handle pagination
            if(!isDownload){
                Integer pageOffset = (pageNumber != null ? (pageNumber - 1) * pageSize : 0);
                queryParts.add(' LIMIT :pageSize OFFSET :pageOffset');
            }
            
            String query = String.join(queryParts, '');
            
            // Run the final query
            caseList = Database.query(query);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error while retrieve cases. Error Message = ' + e.getMessage()); 
            throw new AuraHandledException('Error fetching data.');
        }
        return caseList;
    }
    /**
     * @description: Fetches the Account record based on the given account Id.
     * @param accId: Id of the Account to be fetched.
     * @return: An Account record if found, otherwise null.
     * @developer: RT
     * @date: 09/10/2024
     */
    @AuraEnabled
    public static Account getAccount(Id accId){ 
        Account acc = null;
        if(accId != null){
            acc = [SELECT Id, Name, ShippingStreet, CreatedDate, US_WSREMS__NPI__c, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Phone, City_Secondary_Office__c, State_Secondary_Office__c, Zip_Secondary_Office__c, Address_1_Secondary_Office__c 
                   FROM Account WHERE Id = :accId LIMIT 1];
        }
        return acc;
    }
    
    /**
     * @description: Creates a new Reverse RDA case by updating an existing case's outcome to "Reversed" and then creating a reverse case based on the original.
     * @param accId: Id of the Account (pharmacy) for which the Reverse RDA case is being created.
     * @param caseId: Id of the existing Case that is being reversed.
     * @param userAccId: Id of the Account with which the user is associated
     * @return: The newly created Reverse RDA Case record.
     * @throws: AuraHandledException if an error occurs during case creation.
     * @developer: RT
     * @date: 09/10/2024
     */
    @AuraEnabled
    public static Case createReverseRDA(String accId, String caseId, String userAccId) {
        try {
            Id pharmacyId = accId;
            if (userAccId != null && pharmacyId != null) {
                // Step 1: Query existing cases for the provided account (pharmacyId)
                Case relatedCase = [SELECT Id, US_WSREMS__Outcome__c,CreatedDate,Program_Record_Type_Control__c,US_WSREMS__REMS_Program__r.Name,US_WSREMS__REMS_Service_Summary__c, Pharmacy_Participant__c FROM Case  WHERE Id = :caseId LIMIT 1];
                // Step 2: Update Service Outcome and Case Outcome to "Reversed"
                    if (relatedCase != null) {
                        relatedCase.US_WSREMS__Outcome__c = 'Reversed';
        
                        // Query the REMS service summary
                        US_WSREMS__REMS_Service_Summary__c remsService = [SELECT Id, US_WSREMS__Service_Outcome__c 
                                                                         FROM US_WSREMS__REMS_Service_Summary__c 
                                                                         WHERE Id = :relatedCase.US_WSREMS__REMS_Service_Summary__c LIMIT 1];
                        
                        List<SObject> list2update = new List<SObject>();
                        list2update.add(relatedCase);
        
                        // If the REMS service exists, update it as well
                        if (remsService != null) {
                            remsService.US_WSREMS__Service_Outcome__c = 'Reversed';
                            list2update.add(remsService);
                        }
        
                    // Update both the related case and remsService in one DML statement
                    Database.update(list2update);
                    
                    // Step 3: Create and insert a new Reverse RDA case using inline initialization
                    Case reverseRDACase = new Case(
                        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Reverse RDA').getRecordTypeId(),
                        Status = 'Complete',
                        US_WSREMS__Program_Picklist__c = relatedCase.US_WSREMS__REMS_Program__r.Name,
                        US_WSREMS__Outcome__c = 'Complete',
                        X1_Pharmacy_Participant__c = relatedCase.Pharmacy_Participant__c,  // MR 02OCT24 Bug Fix
                        Program_Record_Type_Control__c = relatedCase.Program_Record_Type_Control__c,
                        US_WSREMS__Pharmacy__c = pharmacyId,
                        US_WSREMS__REMS_Service_Summary__c = relatedCase.US_WSREMS__REMS_Service_Summary__c
                    );
                    List<Database.SaveResult> listResult = Database.insert(new List<Case>{reverseRDACase}, true);
                    for (Database.SaveResult result : listResult) {
                        if (!result.isSuccess()) {
                            for (Database.Error error : result.getErrors()) {
                                System.debug(LoggingLevel.ERROR, 'Error Inserting Reverse RDA Case. Error Message = ' + error.getMessage());
                                throw new AuraHandledException('An error occurred while creating the Reverse RDA case. Error Message = ' + error.getMessage());
                            }
                        }
                    }

                    return reverseRDACase;
                }
            }
        }catch (Exception e) {   
            // RT 04-10-24 comment - since you're using Database.insert() without passing the allOrNone flag, it will throw an exception if there is a failure, and it will be caught in your catch block
            System.debug(loggingLevel.Error , 'Error occurred while creating the Reverse RDA case. Error Message = ' + e.getMessage());
            throw new AuraHandledException('An error occurred while creating the Reverse RDA case. Error Message = ' + e.getMessage());
        }
        return null;
    }
    /**
     * @description: Retrieves the latest Case record for the given Account and Case ID, along with associated Shipping and Tracking records. 
     *               Also checks if any of the Shipping and Tracking records have a status of "Accepted".
     * @param accountId: The Id of the Account (pharmacy) associated with the Case.
     * @param caseId: The Id of the Case to be fetched.
     * @return: A Map<String, Object> containing the Case record, list of Shipping and Tracking records, and a boolean indicating if any record has an "Accepted" status.
     * @throws: AuraHandledException if an error occurs during query execution.
     * @developer:RT
     * @date: 09/10/2024
     */
   @AuraEnabled
    public static Map<String, Object> getLatestCaseAndShippingTracking(String accountId,String caseId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            // Fetch the latest Case record related to the Account
            Case currentCase = [SELECT Id, Subject, Status FROM Case 
                WHERE US_WSREMS__Pharmacy__c = :accountId AND Id = :caseId  AND RecordType.Name = 'RDA' 
                AND US_WSREMS__Outcome__c = 'Approved'
                AND Status = 'Complete' LIMIT 1];
            if(currentCase != null){
                resultMap.put('currentCase', currentCase);
                // Fetch all Shipping and Tracking records related to the Case
                List<US_WSREMS__Shipping_and_Tracking__c> shippingTrackingRecords = [ SELECT Id, US_WSREMS__Status__c FROM US_WSREMS__Shipping_and_Tracking__c WHERE US_WSREMS__Case__c = :currentCase.Id ORDER BY CreatedDate DESC];
                // Add the list of Shipping and Tracking records to the result map
                resultMap.put('shippingTrackingRecords', shippingTrackingRecords);
                // Check if any record has a status of "Accepted"
                Boolean hasAcceptedStatus = false;
                if(shippingTrackingRecords.size() > 0){
                    for (US_WSREMS__Shipping_and_Tracking__c shippingTracking : shippingTrackingRecords) {
                        if (shippingTracking.US_WSREMS__Status__c == 'Accepted') {
                            hasAcceptedStatus = true;
                            break;
                        }
                    }
                }
                // Add the acceptance status to the result map
                resultMap.put('hasAcceptedStatus', hasAcceptedStatus);
            }
        } catch (Exception e) {
            System.debug(loggingLevel.Error , 'Error occurred while fetching the latest case and shipping tracking. Error Message = ' + e.getMessage());
            throw new AuraHandledException('Error fetching data. Error Message = ' + e.getMessage());
        }
        return resultMap;
    }
}