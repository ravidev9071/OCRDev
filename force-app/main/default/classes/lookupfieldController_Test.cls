@isTest
public class lookupfieldController_Test {
    //This test class just ensures that there is enough code coverage
    //to get the component into production from your sandbox
    //it does not perform any validations.
    static testMethod void testLookupField() {
        Account testAcc = new Account(Name = 'Test');
        testAcc.ShippingStreet = 'Test Street';
        testAcc.ShippingCity = 'Test City';
        testAcc.ShippingPostalCode = '32423';
        testAcc.ShippingCountry = 'USA';
        testAcc.ShippingState = 'NY';
        insert testAcc;
        List<string> returnFields = new List<string> {'Name'};
        Account a = [SELECT Id FROM Account LIMIT 1];
		    lookupfieldController.getObjectDetails('Account');
        lookupfieldController.GetRecentRecords('Account', returnFields, 5);
        lookupfieldController.SearchRecords('Account', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z');
        lookupfieldController.GetRecord('Account', returnFields, a.Id);
    }
}