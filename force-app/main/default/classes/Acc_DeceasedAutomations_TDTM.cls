/**
 * Created by chrisgibson on 2/12/24.
 */

global class Acc_DeceasedAutomations_TDTM extends npsp.TDTM_RunnableMutable {
    global override void run(List<SObject> listNew, List<SObject> listOld,
            npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) {
            System.debug('Account_EstateHandler_TDTM trigger fired Before Insert');

        }

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            System.debug('Account_EstateHandler_TDTM trigger fired Before Update');
            runAccountDeceasedAutomations(new Map<Id,Account>((List<Account>)listNew), new Map<Id,Account>((List<Account>)listOld));
        }

    }

    public void runAccountDeceasedAutomations(Map<Id, Account> newAccountsMap, Map<Id, Account> oldAccountsMap){
        for(Account newAccount: newAccountsMap.values()){
            Account oldAccount = oldAccountsMap.get(newAccount.Id);
            Boolean changeAccountToEstate = false;

            // if estate checkbox is changed to checked from not checked
            if(Boolean.valueOf(newAccount.get(DeceasedAutomationConstants.ACCOUNT_ESTATE_CHECKBOX)) &&
                    !Boolean.valueOf(oldAccountsMap.get(DeceasedAutomationConstants.ACCOUNT_ESTATE_CHECKBOX))){
                changeAccountToEstate = true;
            }

            // if account record type is changed to estate from something else and the estate checkbox was not checked
            if(DeceasedAutomationConstants.ACCOUNT_HAS_ESTATE_RECORD_TYPE &&
                    String.valueOf(newAccount.get('RecordTypeId')) == DeceasedAutomationConstants.ACCOUNT_ESTATE_RECORD_TYPE_ID &&
                    String.valueOf(newAccount.get('RecordTypeId')) != String.valueOf(oldAccount.get('RecordTypeId'))){
                changeAccountToEstate = true;
            }

            if(changeAccountToEstate){
                changeAccountToEstate(newAccount);
            }
        }
    }

    public void changeAccountToEstate(Account account){
        account.put(DeceasedAutomationConstants.PRIMARY_CONTACT_ACCOUNT_LOOKUP,null);
        account.put(DeceasedAutomationConstants.SECONDARY_CONTACT_ACCOUNT_LOOKUP,null);

        if(!Boolean.valueOf(account.get(DeceasedAutomationConstants.ACCOUNT_ESTATE_CHECKBOX))){
            account.put(DeceasedAutomationConstants.ACCOUNT_ESTATE_CHECKBOX,true);
        }
        if(!account.Name.contains('The Estate of')){
            account.Name = 'The Estate of ' + account.Name;
        }
        if(!String.isEmpty(DeceasedAutomationConstants.ACCOUNT_NAMING_CONTROL_FIELD)) {
            account.put(DeceasedAutomationConstants.ACCOUNT_NAMING_CONTROL_FIELD,'Name');
        }

    }
}