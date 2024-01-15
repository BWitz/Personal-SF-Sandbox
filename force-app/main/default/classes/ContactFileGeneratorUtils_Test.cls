@isTest
public with sharing class ContactFileGeneratorUtils_Test {
    @isTest
    static void testGetLastBusinessDays() {
        Test.startTest();
        List<Datetime> lastTenBusinessDays = ContactFileGeneratorUtils.getLastBusinessDays(10);
        List<Datetime> lastZeroBusinessDays = ContactFileGeneratorUtils.getLastBusinessDays(0);
        List<Datetime> lastNegativeIntBusinessDays = ContactFileGeneratorUtils.getLastBusinessDays(-5);
        List<Datetime> last101BusinessDays = ContactFileGeneratorUtils.getLastBusinessDays(101);
        Test.stopTest();

        System.assertEquals(10, lastTenBusinessDays.size(), '10 prior business days were not found');
        System.assertEquals(1, lastZeroBusinessDays.size(), 'When the last 0 business days were requested, a list size other than 1 returned.');
        System.assertEquals(1, lastNegativeIntBusinessDays.size(), 'When the last negative integer of business days were requested, a list size other than 1 returned.');
        System.assertEquals(false, last101BusinessDays.size() > 100, 'When over 100 business days were requested, the list size exceeded 100 stored days.');
    }

    @isTest
    static void testGetBusinessDayStartEndTimes() {
        Datetime today = Datetime.now();
        Test.startTest();
        List<Datetime> todayStartEndTimes = ContactFileGeneratorUtils.getBusinessDayStartEndTimes(today);
        Test.stopTest();
        System.assertEquals(Datetime.newInstance(today.year(), today.month(), today.day(), 0, 0, 0), todayStartEndTimes[0], 'The return value of ContactFileGeneratorUtils.getBusinessDayStartEndTimes did not return the very beginning of today when passed a Datetime value of Today.');
        System.assertEquals(Datetime.newInstance(today.year(), today.month(), today.day(), 23, 59, 59), todayStartEndTimes[1], 'The return value of ContactFileGeneratorUtils.getBusinessDayStartEndTimes did not return the very end of today when passed a Datetime value of Today.');
    }

    @isTest
    static void testIsValidPhoneNumber() {

        String validPhoneNumber1 = '917-416-0932';
        String validPhoneNumber2 = '5348763456';
        String validPhoneNumber3 = '+44 191 4956203';
        String validPhoneNumber4 = '(718)-919-2353';
        String validPhoneNumber5 = '123 456-7890';
        String validPhoneNumber6 = '(123) 456-7890';

        String invalidPhoneNumber1 = 'Hello';
        String invalidPhoneNumber2 = '132';
        String invalidPhoneNumber3 = '!@#-$%^-&*()';
        String invalidPhoneNumber4 = '1234 21 9021';
        String invalidPhoneNumber5 = 'abc-def-ghij';
        String invalidPhoneNumber6 = 'Phonecall';

        Test.startTest();
        Boolean validPhoneNumberTest1 = ContactFileGeneratorUtils.isValidPhoneNumber(validPhoneNumber1);
        Boolean validPhoneNumberTest2 = ContactFileGeneratorUtils.isValidPhoneNumber(validPhoneNumber2);
        Boolean validPhoneNumberTest3 = ContactFileGeneratorUtils.isValidPhoneNumber(validPhoneNumber3);
        Boolean validPhoneNumberTest4 = ContactFileGeneratorUtils.isValidPhoneNumber(validPhoneNumber4);
        Boolean validPhoneNumberTest5 = ContactFileGeneratorUtils.isValidPhoneNumber(validPhoneNumber5);
        Boolean validPhoneNumberTest6 = ContactFileGeneratorUtils.isValidPhoneNumber(validPhoneNumber6);
        Boolean invalidPhoneNumberTest1 = ContactFileGeneratorUtils.isValidPhoneNumber(invalidPhoneNumber1);
        Boolean invalidPhoneNumberTest2 = ContactFileGeneratorUtils.isValidPhoneNumber(invalidPhoneNumber2);
        Boolean invalidPhoneNumberTest3 = ContactFileGeneratorUtils.isValidPhoneNumber(invalidPhoneNumber3);
        Boolean invalidPhoneNumberTest4 = ContactFileGeneratorUtils.isValidPhoneNumber(invalidPhoneNumber4);
        Boolean invalidPhoneNumberTest5 = ContactFileGeneratorUtils.isValidPhoneNumber(invalidPhoneNumber5);
        Boolean invalidPhoneNumberTest6 = ContactFileGeneratorUtils.isValidPhoneNumber(invalidPhoneNumber6);

        Test.stopTest();

        System.assertEquals(true, validPhoneNumberTest1, 'validPhoneNumberTest1 was evaluated as an invalid phone number ');
        System.assertEquals(true, validPhoneNumberTest2, 'validPhoneNumberTest2 was evaluated as an invalid phone number ');
        System.assertEquals(true, validPhoneNumberTest3, 'validPhoneNumberTest3 was evaluated as a invalid phone number ');
        System.assertEquals(true, validPhoneNumberTest4, 'validPhoneNumberTest4 was evaluated as a invalid phone number ');
        System.assertEquals(true, validPhoneNumberTest5, 'validPhoneNumberTest5 was evaluated as a invalid phone number ');
        System.assertEquals(true, validPhoneNumberTest6, 'validPhoneNumberTest5 was evaluated as a invalid phone number ');
        System.assertEquals(false, invalidPhoneNumberTest1, 'invalidPhoneNumberTest1 was evaluated as a valid phone number ');
        System.assertEquals(false, invalidPhoneNumberTest2, 'invalidPhoneNumberTest2 was evaluated as a valid phone number ');
        System.assertEquals(false, invalidPhoneNumberTest3, 'invalidPhoneNumberTest3 was evaluated as a valid phone number ');
        System.assertEquals(false, invalidPhoneNumberTest4, 'invalidPhoneNumberTest4 was evaluated as a valid phone number ');
        System.assertEquals(false, invalidPhoneNumberTest5, 'invalidPhoneNumberTest5 was evaluated as a valid phone number ');
        System.assertEquals(false, invalidPhoneNumberTest6, 'invalidPhoneNumberTest6 was evaluated as a valid phone number ');

    }

    @isTest
    static void testIsValidEmailAddress() {
        String validEmailAddress1 = 'john.doe@example.com';
        String validEmailAddress2 = 'jane.doe@sub.example.co.uk';
        String validEmailAddress3 = 'alice+123@example.net';
        String validEmailAddress4 = 'bob-smith@example-site.org';

        String invalidEmailAddress1 = 'johndoe.example.com';
        String invalidEmailAddress2 = 'sarah@';
        String invalidEmailAddress3 = 'mike@example.';
        String invalidEmailAddress4 = '#invalid@email.com';
        String invalidEmailAddress5 = 'jack@doe@example.com';
        String invalidEmailAddress6 = 'john doe@example.com';
        String invalidEmailAddress7 = '.start@example.com';
        String invalidEmailAddress8 = 'john..doe@example.com';
        String invalidEmailAddress9 = 'test@ex--ample.com';

        Test.startTest();
        Boolean validEmailAddressTest1 = ContactFileGeneratorUtils.isValidEmailAddress(validEmailAddress1);
        Boolean validEmailAddressTest2 = ContactFileGeneratorUtils.isValidEmailAddress(validEmailAddress2);
        Boolean validEmailAddressTest3 = ContactFileGeneratorUtils.isValidEmailAddress(validEmailAddress3);
        Boolean validEmailAddressTest4 = ContactFileGeneratorUtils.isValidEmailAddress(validEmailAddress4);

        Boolean invalidEmailAddressTest1 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress1);
        Boolean invalidEmailAddressTest2 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress2);
        Boolean invalidEmailAddressTest3 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress3);
        Boolean invalidEmailAddressTest4 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress4);
        Boolean invalidEmailAddressTest5 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress5);
        Boolean invalidEmailAddressTest6 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress6);
        Boolean invalidEmailAddressTest7 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress7);
        Boolean invalidEmailAddressTest8 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress8);
        Boolean invalidEmailAddressTest9 = ContactFileGeneratorUtils.isValidEmailAddress(invalidEmailAddress9);
        Test.stopTest();

        System.assertEquals(true, validEmailAddressTest1, 'validEmailAddressTest1 was expected to return true, but returned false instead.');
        System.assertEquals(true, validEmailAddressTest2, 'validEmailAddressTest2 was expected to return true, but returned false instead.');
        System.assertEquals(true, validEmailAddressTest3, 'validEmailAddressTest3 was expected to return true, but returned false instead.');
        System.assertEquals(true, validEmailAddressTest4, 'validEmailAddressTest4 was expected to return true, but returned false instead.');

        System.assertEquals(false, invalidEmailAddressTest1, 'invalidEmailAddressTest1 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest2, 'invalidEmailAddressTest2 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest3, 'invalidEmailAddressTest3 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest4, 'invalidEmailAddressTest4 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest5, 'invalidEmailAddressTest5 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest6, 'invalidEmailAddressTest6 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest7, 'invalidEmailAddressTest7 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest8, 'invalidEmailAddressTest8 was expected to return false, but returned true instead.');
        System.assertEquals(false, invalidEmailAddressTest9, 'invalidEmailAddressTest9 was expected to return false, but returned true instead.');
    }

}