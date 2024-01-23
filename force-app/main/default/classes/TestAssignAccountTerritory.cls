@isTest
public class TestAssignAccountTerritory {
	@isTest
    public static void testAssignAccountNewYorkTerritory() {
        Account testAcc = new Account(
        Name = 'Test1',
        BillingState = 'New York',
        BillingPostalCode = '10002'
        );
        
        Test.startTest();
        insert testAcc;
        Test.stopTest();
        
        Account insertedTestAcc = [Select Id, BillingState, BillingPostalCode, Territory__c FROM Account][0];
        Assert.areEqual('New York - Strategic', insertedTestAcc.Territory__c, 'testAcc territory was not New York - Strategic!');
    }
    @isTest
    public static void testAssignAccountOtherTerritories() {
        Account testAcc = new Account(
        Name = 'Test2',
        BillingState = 'California',
        BillingPostalCode = '90210'
        );
        
        Test.startTest();
        insert testAcc;
        Test.stopTest();
        
        Account insertedTestAcc = [Select Id, BillingState, BillingPostalCode, Territory__c FROM Account][0];
        Assert.areEqual('California - Strategic', insertedTestAcc.Territory__c, 'testAcc territory was not California - Strategic!');
    }
    @isTest
    public static void testAssignAccountErrorTerritory() {
        Account testAcc = new Account(
        Name = 'Test3',
        BillingState = 'Miami',
        BillingPostalCode = '12345'
        );
        
        Test.startTest();
        insert testAcc;
        Test.stopTest();
        
        Account insertedTestAcc = [Select Id, BillingState, BillingPostalCode, Territory__c FROM Account][0];
        Assert.areEqual('Unknown', insertedTestAcc.Territory__c, 'testAcc territory was not Unknown');
    }
}