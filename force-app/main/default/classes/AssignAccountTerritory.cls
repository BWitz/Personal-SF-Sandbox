public class AssignAccountTerritory {
        
    public static void updateAccountTerritories(List<Account> accs) {
    // This should be in custom settings / custom metadata / static resources..
        Map<String, Set<String>> stateZipCodeMap = new Map<String, Set<String>>{
            'New York' => new Set<String>{'10002', '10003', '10011', '10012', '100013', '100014'},
                'California' => new Set<String>{'90210', '90077', '90024', '90095', '90211', '90069'},
                    'Great Lakes' => new Set<String>{'Minnesota', 'Wisconsin', 'Indiana', 'Illinois', 'Michigan', 'Ohio'} 
        };
            
        for (Account acc : accs) {
            try {
                if (acc.BillingPostalCode != null && acc.BillingState != null) {
                    String billingState = acc.BillingState;
                    String billingZipCode = acc.BillingPostalCode;
                    
                    // New York - Strategic territory
                    if (stateZipCodeMap.containsKey(billingState) && stateZipCodeMap.get(billingState).contains(billingZipCode)) {
						acc.Territory__c = billingState + ' - Strategic';
                    }
                    // Other Territories
                    else if (stateZipCodeMap.containsKey(billingState)) {
                        acc.Territory__c = billingState;
                    }
                    // Unknown Territory
                    else {
                        acc.Territory__c = 'Unknown';
                    }
                } else {
                    acc.Territory__c = 'Unknown';
                }
            } catch (Exception e) {
                // Log the error and set the territory to an appropriate default value
                System.debug('Error assigning territory: ' + e.getMessage());
                acc.Territory__c = 'Error';
            }
        }
    }
}