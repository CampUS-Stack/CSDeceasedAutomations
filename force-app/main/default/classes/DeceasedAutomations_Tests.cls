/**
 * Created by chrisgibson on 2/16/24.
 */

@IsTest
private class DeceasedAutomations_Tests {
    @IsTest
    static void testContactHandler() {
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'MyCMTriggerHandler';
        th.npsp__Class__c = 'Con_DeceasedAutomations_TDTM';
        th.npsp__Object__c = 'Contact';
        th.npsp__Trigger_Action__c = 'BeforeUpdate;AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        Account account = new Account();
        account.Name = 'Haunted House';
        insert account;

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.AccountId = acc.Id;
        insert contact;

        Contact contact1 = new Contact();
        contact1.FirstName = 'Test';
        contact1.LastName = 'Contact 2';
        contact1.AccountId = acc.Id;
        insert contact1;

        acc.put(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP,contact.Id);
        acc.put(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP,contact1.Id);
        update acc;

        Opportunity oppo = new Opportunity();
        oppo.Name = 'Test Opportunity';
        oppo.StageName = 'Prospecting';
        oppo.CloseDate = Date.today().addDays(10);
        oppo.ContactId = contact.Id;
        insert oppo;


        Test.startTest();
        contact.put('npsp__Deceased__c',true);
        update contact;

        Account accounts = Database.query('SELECT Id, Name , ' + DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP + ' FROM Account WHERE Id = \'' + acc.Id + '\'');
//        System.assertEquals( accounts.cs_npsp_pmm_base_contact_2__c , null);

        Test.stopTest();
    }

    @IsTest
    static void testAccountHandler() {
        // Retrieve default NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> triggerHandlers = npsp.TDTM_Config_API.getCachedRecords();

        // Add our Trigger Handler to cached Trigger Handlers
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'MyCMTriggerHandler';
        th.npsp__Class__c = 'Acc_DeceasedAutomations_TDTM';
        th.npsp__Object__c = 'Account';
        th.npsp__Trigger_Action__c = 'BeforeUpdate;AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;

        triggerHandlers.add(th);

        Account account = new Account();
        account.Name = 'Haunted House';
        insert account;

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;


        Test.startTest();

        account.put(DeceasedAutomationConstants.ACCOUNT_ESTATE_CHECKBOX,true);
        update account;
        Test.stopTest();
    }

    @IsTest
    static void runDeceasedConstantTestCoverage() {

        if(DeceasedAutomationConstants.CONTACT_HAS_DECEASED_RECORD_TYPE){
            DeceasedAutomationConstants.CONTACT_DECEASED_RECORDTYPE_ID;
        }
        if(DeceasedAutomationConstants.ACCOUNT_HAS_ESTATE_RECORD_TYPE){
            DeceasedAutomationConstants.ACCOUNT_ESTATE_RECORD_TYPE_ID;
        }
        DeceasedAutomationConstants.CONTACT_DECEASED_FIELD;
        DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP;
        DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_RELATIONSHIP;
        DeceasedAutomationConstants.CONTACT_HAS_DECEASED_RECORD_TYPE;
        DeceasedAutomationConstants.ACCOUNT_ESTATE_CHECKBOX;
        DeceasedAutomationConstants.ACCOUNT_NAMING_CONTROL_FIELD;
        DeceasedAutomationConstants.OPPORTUNITY_CONTACT_LOOKUP;
        DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP;
        DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP;
        DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_RELATIONSHIP;
        DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_RELATIONSHIP;
    }

}