trigger AccountTriggerHandler on Account (before insert) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            AssignAccountTerritory.updateAccountTerritories(Trigger.new);
        }
    }
  
}