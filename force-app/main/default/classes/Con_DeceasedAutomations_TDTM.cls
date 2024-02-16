/**
 * Created by chrisgibson on 2/12/24.
 */

global class Con_DeceasedAutomations_TDTM extends npsp.TDTM_RunnableMutable {
    global override void run(List<SObject> listNew, List<SObject> listOld,

            npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
        List<Contact> newContacts = (List<Contact>) listNew;
        List<Contact> oldConList = (List<Contact>) listOld;

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            runContactUpdates(newContacts, oldConList);
        }
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            runAccountAutomations(newContacts, oldConList);
        }
    }

    private static void runAccountAutomations(List<Contact> newContacts, List<Contact> oldConList) {
        System.debug('Acc_ContactHandler_TDTM trigger fired After Update');

        Map<String, String> additionalAccountToContactMap = new Map<String, String>();
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(oldConList);

        Map<String, Contact> accountToContactMap = getAccountsToProcess(newContacts, oldContactMap);


        if (accountToContactMap.size() > 0) {
            processAccounts(accountToContactMap);
            processRelatedOpportunities(accountToContactMap);
        }
    }

    private static Map<String, Contact> getAccountsToProcess(List<Contact> newContacts, Map<Id, Contact> oldContactMap) {
        Map<String, Contact> accountToContactMap = new Map<String, Contact>();
        for (Integer i = 0; i < newContacts.size(); i++) {
            Contact newContact = newContacts[i];
            Contact oldContact = oldContactMap.get(newContact.Id);

            // Trigger will fire if Deceased & Primary contact field checked on contact , Deceased Account should previously null before update and contact record type should not "Deceased".
            printInfo(newContact, oldContact);

            if (Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD)) == true &&
                    Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_PRIMARY_CHECKBOX)) <>
                            Boolean.valueOf(oldContact.get(DeceasedAutomationConstants.CONTACT_PRIMARY_CHECKBOX)) &&
                    Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD)) <>
                            Boolean.valueOf(oldContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD)) &&
                    String.valueOf(newContacts[i].get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP)) != null) {
                System.debug('New Contact AccountId: ' + newContacts[i].AccountId);

                accountToContactMap.put(String.valueOf(newContact.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP)), newContact);

            }
            //Additional check if contact is deceased but used in account lookup
            if (Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD)) == true && (
                    Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_PRIMARY_CHECKBOX)) ||
                            Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_SECONDARY_CHECKBOX)))) {

                accountToContactMap.put(String.valueOf(newContact.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP)), newContact);

            }
            System.debug('Record type is Deceased');
        }
        return accountToContactMap;
    }

    public static void processAccounts(Map<String, Contact> accountToContactMap) {
        System.debug('method:processAccounts');
        Set<String> listOfAccountIds = accountToContactMap.keySet();
        List<Account> listOfAccount = Database.query('SELECT Id, Name, ' + DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP + ',' + DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP + ', (SELECT Id, Name, CreatedDate FROM Contacts ORDER BY CreatedDate ASC) FROM Account WHERE Id IN :listOfAccountIds');
        for (Account acc : listOfAccount) {

            String decease_contactID = accountToContactMap.get(acc.Id).Id;

            System.debug('Count of account contacts: ' + acc.Contacts.size());
            System.debug('AccountId: ' + acc.Id);

            if (String.valueOf(acc.get(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP)) == decease_contactID) {
                if (acc.get(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP) != null) {
                    /// primary is deceased but secondary is populated, move to primary clear secondary
                    acc.put(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP, acc.get(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP));
                    acc.put(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP, null);
                } else {
                    /// primary is deceased but no secondary, just clear secondary
                    acc.put(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP, null);
                }
            }

            //if secondary contact deceased
            if (acc.get(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP) == decease_contactID) {
                acc.put(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP, null);
            }

            /// at the end of this processing if both primary and secondary are null - turn into estate account
            System.debug('Running check to see if account is an estate');
            System.debug(String.valueOf(acc.get(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP)) == null &&
                    String.valueOf(acc.get(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP)) == null);
            if (String.isEmpty(String.valueOf(acc.get(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP))) &&
                    String.isEmpty(String.valueOf(acc.get(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP)))) {
                acc.Estate_Account__c = true;
                acc.Name = 'The Estate of ' + acc.Name;
                acc.npo02__SYSTEM_CUSTOM_NAMING__c = 'Name';
            }

        }
        update listOfAccount;
    }

    private static void printInfo(Contact newContact, Contact oldContact) {
        if(DeceasedAutomationConstants.CONTACT_HAS_DECEASED_RECORD_TYPE){
            System.debug('New Contact RecordTypeId: ' + newContact.get('RecordTypeId'));
        }
        System.debug('Primary cbox: ' + Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_PRIMARY_CHECKBOX)));
        System.debug('old con Primary cbox: ' + Boolean.valueOf(oldContact.get(DeceasedAutomationConstants.CONTACT_PRIMARY_CHECKBOX)));
        System.debug('deceased: ' + newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD));
        if(DeceasedAutomationConstants.CONTACT_HAS_DECEASED_RECORD_TYPE) {
            System.debug('rtypeid is deceased: ' + newContact.get('RecordTypeId') == DeceasedAutomationConstants.CONTACT_DECEASED_RECORDTYPE_ID);
        }
        System.debug('contact lookup: ' + String.valueOf(newContact.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP)));
    }

    public static void processRelatedOpportunities(Map<String, Contact> contactByAccountIds) {
        List<String> listOfContactIdForOpportunities = new List<String>();
        for (String accountId : contactByAccountIds.keySet()) {
            Contact con = contactByAccountIds.get(accountId);
            listOfContactIdForOpportunities.add(con.Id);
        }

        String hauntedHouseAccId = DeceasedAutomationConstants.HAUNTED_HOUSE_RECORD_ID;
        List<Opportunity> opportunities = Database.query('SELECT Id, npsp__Primary_Contact__c, OpportunityId, ' + DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP + ' FROM Opportunity WHERE npsp__Primary_Contact__c IN :listOfContactIds AND AccountId = \'' + hauntedHouseAccId + '\'');

        for (Contact curCon : contactByAccountIds.values()) {
            for (Opportunity curOpp : opportunities) {
                if (String.valueOf(curOpp.get(DeceasedAutomationConstants.OPPORTUNITY_CONTACT_LOOKUP)) == curCon.Id){
                    curOpp.put(DeceasedAutomationConstants.OPPORTUNITY_CONTACT_LOOKUP,null);

                    if(String.isNotEmpty(String.valueOf(curCon.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP))) &&
                            curOpp.AccountId == DeceasedAutomationConstants.HAUNTED_HOUSE_RECORD_ID) {
                        curOpp.AccountId = String.valueOf(curCon.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP));
                    }
                }
            }
        }
        update opportunities;
    }

    /**
     * @description  -Moves deceased Contact to the “Haunted House” account
      *             -links back to the original Account through the Deceased Account field on the Contact
      *             -if deceased record type is not set and the contact is deceased, it will populate the deceased record type
     *
     * @param newContacts
     * @param oldConList
     */
    private static void runContactUpdates(List<Contact> newContacts, List<Contact> oldConList) {
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>(oldConList);
        System.debug('Acc_ContactHandler_TDTM trigger fired Before Update');
        for (Integer i = 0; i < newContacts.size(); i++) {
            Contact newContact = newContacts[i];
            Contact oldContact = oldContactMap.get(newContact.Id);
            System.debug('New Contact Deceased: ' + newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD));
            System.debug('Old Contact Deceased: ' + oldContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD));
            System.debug('New Contact Contact 1: ' + newContact.get(DeceasedAutomationConstants.CONTACT_PRIMARY_CHECKBOX));
            if(DeceasedAutomationConstants.CONTACT_HAS_DECEASED_RECORD_TYPE) {
                System.debug('New Contact Contact RecordTypeId: ' + newContact.get('RecordTypeId'));
            }
            System.debug('New Contact Contact Deceased Account: ' + newContact.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP));
            // Trigger will fire if Deceased & Primary contact field checked on contact , Deceased Account should null and contact record type should not "Deceased".

            if (DeceasedAutomationConstants.CONTACT_HAS_DECEASED_RECORD_TYPE) {
                setDeceasedRecordType(newContact);
            }
            runDeceasedAccountFieldPopulation(newContact, oldContact);
        }
    }

    private static void setDeceasedRecordType(Contact newContact) {
        if (Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD)) &&
                newContact.get('RecordTypeId') != DeceasedAutomationConstants.CONTACT_DECEASED_RECORDTYPE_ID) {
            newContact.put('RecordTypeId', DeceasedAutomationConstants.CONTACT_DECEASED_RECORDTYPE_ID);
        }
    }

    private static void runDeceasedAccountFieldPopulation(Contact newContact, Contact oldContact) {
        if (Boolean.valueOf(newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD)) &&
                (newContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD) <> oldContact.get(DeceasedAutomationConstants.CONTACT_DECEASED_FIELD) ||
                        newContact.AccountId != DeceasedAutomationConstants.HAUNTED_HOUSE_RECORD_ID ||
                        newContact.get(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP) != DeceasedAutomationConstants.HAUNTED_HOUSE_RECORD_ID)) {

            if (newContact.AccountId != DeceasedAutomationConstants.HAUNTED_HOUSE_RECORD_ID) {
                newContact.put(String.valueOf(DeceasedAutomationConstants.DECEASED_CONTACT_ACCOUNT_LOOKUP), newContact.AccountId);
            }
            newContact.AccountId = DeceasedAutomationConstants.HAUNTED_HOUSE_RECORD_ID;
        }
    }
}