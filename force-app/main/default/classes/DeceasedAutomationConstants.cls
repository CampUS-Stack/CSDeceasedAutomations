/**
 * Created by chrisgibson on 2/12/24.
 */

public with sharing class DeceasedAutomationConstants {

    ///region record settings
    @TestVisible private static String hauntedHouseRecordIdSingleton;
    public static String HAUNTED_HOUSE_RECORD_ID {
        get {
            if (hauntedHouseRecordIdSingleton != null) {
                return hauntedHouseRecordIdSingleton;
            } else {
                String programId = getDeceasedAutomationSettingValue('Haunted_House_Account_Id');
                if (String.isNotBlank(programId)) {
                    hauntedHouseRecordIdSingleton = programId;
                    return hauntedHouseRecordIdSingleton;
                } else {
                    return '';
                }
            }
        }
    }
    //endregion

    //region record type settings
    private static String contactDeceasedRTDeveloperName;
    public static String CONTACT_DECEASED_RECORDTYPE_DEVELOPER_NAME{
        get{
            if (contactDeceasedRTDeveloperName != null) {
                return contactDeceasedRTDeveloperName;
            } else {
                String returnVal = getDeceasedAutomationSettingValue('Contact_Deceased_RT_DevName');
                if (String.isNotBlank(returnVal)) {
                    contactDeceasedRTDeveloperName = returnVal;
                    return contactDeceasedRTDeveloperName;
                } else {
                    return null;
                }
            }
        }
    }

    private static String contactDeceasedRecordTypeId;
    public static String CONTACT_DECEASED_RECORDTYPE_ID{
        get{
            if (contactDeceasedRecordTypeId != null) {
                return contactDeceasedRecordTypeId;
            } else {
                Map<String,Id> recordTypes = GetRecordTypeIdByDeveloperName(Contact.SObjectType);
                String returnVal = recordTypes.get(CONTACT_DECEASED_RECORDTYPE_DEVELOPER_NAME);
                if (String.isNotBlank(returnVal)) {
                    contactDeceasedRecordTypeId = returnVal;
                    return contactDeceasedRecordTypeId;
                } else {
                    contactDeceasedRecordTypeId = '';
                    return contactDeceasedRecordTypeId;
                }
            }
        }
    }

    private static String accountEstateRTDeveloperName;
    public static String ACCOUNT_ESTATE_RECORDTYPE_DEVELOPER_NAME{
        get{
            if (accountEstateRTDeveloperName != null) {
                return accountEstateRTDeveloperName;
            } else {
                String returnVal = getDeceasedAutomationSettingValue('Account_Estate_RT_DevName');
                if (String.isNotBlank(returnVal)) {
                    accountEstateRTDeveloperName = returnVal;
                    return accountEstateRTDeveloperName;
                } else {
                    accountEstateRTDeveloperName = null;
                    return accountEstateRTDeveloperName;
                }
            }
        }
    }

    private static String accountEstateRecordTypeId;
    public static String ACCOUNT_ESTATE_RECORD_TYPE_ID{
        get{
            if (accountEstateRecordTypeId != null) {
                return accountEstateRecordTypeId;
            } else {
                Map<String,Id> recordTypes = GetRecordTypeIdByDeveloperName(Account.SObjectType);
                String returnVal = recordTypes.get(ACCOUNT_ESTATE_RECORDTYPE_DEVELOPER_NAME);
                if (String.isNotBlank(returnVal)) {
                    accountEstateRecordTypeId = returnVal;
                    return accountEstateRecordTypeId;
                } else {
                    accountEstateRecordTypeId = '';
                    return accountEstateRecordTypeId;
                }
            }
        }
    }

    private static Boolean accountHasEstateRecordType;
    public static Boolean ACCOUNT_HAS_ESTATE_RECORD_TYPE {
        get {
            if(accountHasEstateRecordType != null){
                return accountHasEstateRecordType;
            }

            if(ACCOUNT_ESTATE_RECORDTYPE_DEVELOPER_NAME == null){
                accountHasEstateRecordType = false;
                return accountHasEstateRecordType;
            }
            List<RecordType> rts = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Account'];
            if (rts.size() > 0) {
                for(RecordType rt : rts){
                    if(rt.DeveloperName == CONTACT_DECEASED_RECORDTYPE_DEVELOPER_NAME){
                        accountHasEstateRecordType = true;
                    }
                }
            }
            return accountHasEstateRecordType;
        }
    }

    private static Boolean contactHasDeceasedRecordType;
    public static Boolean CONTACT_HAS_DECEASED_RECORD_TYPE{
        get{
            if(contactHasDeceasedRecordType != null){
                return contactHasDeceasedRecordType;
            }

            if(CONTACT_DECEASED_RECORDTYPE_DEVELOPER_NAME == null){
                contactHasDeceasedRecordType = false;
                return contactHasDeceasedRecordType;
            }

            List<RecordType> rts = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Contact'];
            if (rts.size() > 0) {
                for(RecordType rt : rts){
                    if(rt.DeveloperName == CONTACT_DECEASED_RECORDTYPE_DEVELOPER_NAME){
                        contactHasDeceasedRecordType = true;
                    }
                }
            }
            return contactHasDeceasedRecordType;
        }
    }
    //endregion

    //region field settings
    public static String PRIMARY_CONTACT_ACCOUNT_LOOKUP {
        get{
            if (primaryContactAccountLookupSingleton != null) {
                return primaryContactAccountLookupSingleton;
            } else {
                String lookupField = getDeceasedAutomationSettingValue('Primary_Contact_Lookup_Field');
                if (String.isNotBlank(lookupField)) {
                    primaryContactAccountLookupSingleton = lookupField;
                    return primaryContactAccountLookupSingleton;
                } else {
                    return 'npe01__One2OneContact__c';
                }
            }
        }
    }
    public static String primaryContactAccountLookupSingleton;
    public static String PRIMARY_CONTACT_ACCOUNT_RELATIONSHIP {
        get{
            String fieldName = PRIMARY_CONTACT_ACCOUNT_LOOKUP.replace('__c','__r');
            return fieldName;
        }
    }
    public static String SECONDARY_CONTACT_ACCOUNT_LOOKUP {
        get {
            if (secondaryContactAccountLookupSingleton != null) {
                return secondaryContactAccountLookupSingleton;
            } else {
                String lookupField = getDeceasedAutomationSettingValue('Secondary_Contact_Lookup_Field');
                if (String.isNotBlank(lookupField)) {
                    secondaryContactAccountLookupSingleton = lookupField;
                    return secondaryContactAccountLookupSingleton;
                } else {
                    return 'cs_npsp_pmm_base_contact_2__c';
                }
            }
        }
    }

    public static String secondaryContactAccountLookupSingleton;
    public static String SECONDARY_CONTACT_ACCOUNT_RELATIONSHIP {
        get{
            String fieldName = SECONDARY_CONTACT_ACCOUNT_LOOKUP.replace('__c','__r');
            return fieldName;
        }
    }

    public static String DECEASED_CONTACT_ACCOUNT_LOOKUP {
        get {
            if (deceasedContactAccountLookupSingleton != null) {
                return deceasedContactAccountLookupSingleton;
            } else {
                String lookupField = getDeceasedAutomationSettingValue('Deceased_Account_Lookup_Field');
                if (String.isNotBlank(lookupField)) {
                    deceasedContactAccountLookupSingleton = lookupField;
                    return deceasedContactAccountLookupSingleton;
                } else {
                    return 'Deceased_Account__c';
                }
            }
        }
    }

    public static String deceasedContactAccountLookupSingleton;
    public static String DECEASED_CONTACT_ACCOUNT_RELATIONSHIP {
        get{
            String fieldName = DECEASED_CONTACT_ACCOUNT_RELATIONSHIP.replace('__c','__r');
            return fieldName;
        }
    }


    public static String contactSecondaryCheckbox;
    public static String CONTACT_SECONDARY_CHECKBOX {
        get {
            if (contactSecondaryCheckbox != null) {
                return contactSecondaryCheckbox;
            } else {
                String lookupField = getDeceasedAutomationSettingValue('Checkbox_for_Secondary_Contact');
                if (String.isNotBlank(lookupField)) {
                    contactSecondaryCheckbox = lookupField;
                    return contactSecondaryCheckbox;
                } else {
                    return 'Secondary_Contact__c';
                }
            }
        }
    }

    public static String contactPrimaryCheckbox;
    public static String CONTACT_PRIMARY_CHECKBOX {
        get {
            if (contactPrimaryCheckbox != null) {
                return contactPrimaryCheckbox;
            } else {
                String lookupField = getDeceasedAutomationSettingValue('Checkbox_for_Primary_Contact');
                if (String.isNotBlank(lookupField)) {
                    contactPrimaryCheckbox = lookupField;
                    return contactPrimaryCheckbox;
                } else {
                    return 'Primary_Contact__c';
                }
            }
        }
    }

    public static String contactDeceasedField;
    public static String CONTACT_DECEASED_FIELD {
        get {
            if (contactDeceasedField != null) {
                return contactDeceasedField;
            } else {
                String lookupField = getDeceasedAutomationSettingValue('Contact_Deceased_Field');
                if (String.isNotBlank(lookupField)) {
                    contactDeceasedField = lookupField;
                    return contactDeceasedField;
                } else {
                    contactDeceasedField = 'npsp__Deceased__c';
                    return contactDeceasedField;
                }
            }
        }
    }

    public static String accountEstateCheckbox;
    public static String ACCOUNT_ESTATE_CHECKBOX{
        get{
            if(accountEstateCheckbox != null){
                return accountEstateCheckbox;
            }

            String retVal = getDeceasedAutomationSettingValue('Account_Estate_Checkbox');
            if (String.isNotBlank(retVal)) {
                accountEstateCheckbox = retVal;
                return accountEstateCheckbox;
            } else {
                accountEstateCheckbox = 'Estate_Account__c';
                return accountEstateCheckbox;
            }

        }
    }
    public static String accountNamingControlField;
    public static String ACCOUNT_NAMING_CONTROL_FIELD{
        get{
            if(accountNamingControlField != null){
                return accountNamingControlField;
            }

            String retVal = getDeceasedAutomationSettingValue('Account_Naming_Control_Field');
            if (String.isNotBlank(retVal)) {
                accountNamingControlField = retVal;
                return accountNamingControlField;
            } else {
                accountNamingControlField = '';
                return accountNamingControlField;
            }

        }
    }
    public static String opportunityContactLookup;
    public static String OPPORTUNITY_CONTACT_LOOKUP{
        get{
            if(opportunityContactLookup != null){
                return opportunityContactLookup;
            }

            String retVal = getDeceasedAutomationSettingValue('Opportunity_Contact_Lookup');
            if (String.isNotBlank(retVal)) {
                opportunityContactLookup = retVal;
                return opportunityContactLookup;
            } else {
                opportunityContactLookup = '';
                return opportunityContactLookup;
            }

        }
    }
    //endregion

    // region feature settings
    ////TODO: Create settings that enable certain option features for automation - like "Should use deceased RT, Should migrate opportunities, Should re-name accounts".
    //endregion

    //region helper functions
    @TestVisible private static String getDeceasedAutomationSettingValue(String settingDeveloperName){
        List<Deceased_Automation_Setting__mdt> setting = [SELECT Id, Description__c, Value__c FROM Deceased_Automation_Setting__mdt WHERE DeveloperName = :settingDeveloperName];
        if(setting.size() > 0 && String.isNotBlank(setting[0].Value__c)){
            return setting[0].Value__c;
        }
        else{
            return '';
        }
    }

    private static Map<Schema.SObjectType,Map<String,Id>> RECORD_TYPE_CACHE;
    @TestVisible private static Map<String, Id> GetRecordTypeIdByDeveloperName(Schema.SObjectType objectType) {
        Map<String, Id> mapRecordTypes = RECORD_TYPE_CACHE.get(objectType);
        // If not, build a map of RecordTypeIds keyed by DeveloperName
        if (mapRecordTypes == null) {
            mapRecordTypes = new Map<String, Id>();
            RECORD_TYPE_CACHE.put(objectType,mapRecordTypes);
        } else {
            // If we do, return our cached result immediately!
            return mapRecordTypes;
        }

        // Get the Describe Result
        Schema.DescribeSObjectResult obj = objectType.getDescribe();
        String soql =
                'SELECT Id, Name, DeveloperName '
                        + 'FROM RecordType '
                        + 'WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' '
                        + 'AND IsActive = TRUE';
        List<SObject> results;
        try {
            results = Database.query(soql);
        } catch (Exception ex) {
            results = new List<SObject>();
        }

        // Obtain the RecordTypeInfos for this SObjectType token
        Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosById();

        // Loop through all of the Record Types we found,
        //      and weed out those that are unavailable to the Running User
        for (SObject rt : results) {
            if (recordTypeInfos.get(rt.Id).isAvailable()) {
                // This RecordType IS available to the running user,
                //      so add it to our map of RecordTypeIds by DeveloperName
                mapRecordTypes.put(String.valueOf(rt.get('DeveloperName')),rt.Id);
            }
        }

        return mapRecordTypes;
    }

    //endregion
}