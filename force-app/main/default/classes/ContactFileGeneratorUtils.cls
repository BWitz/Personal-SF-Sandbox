public with sharing class ContactFileGeneratorUtils {

    public static List<Datetime> getLastBusinessDays(Integer amountOfDays) {
        // This cannot work with less than one day, so if the arg passed represents that, default to 1 prior business day.
        if (amountOfDays < 1) {
            amountOfDays = 1;
        }

        // Query for the default business hours
        businessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
        // Get today's datetime to use as a reference to create a datetime set at noon (consistent business hour), same date.
        Datetime today = Datetime.now();
        Datetime noonToday = Datetime.newInstanceGMT(today.year(), today.month(), today.day(), 12, 0, 0);
        // Create a list that will hold recent business days.
        // Size will be the arg presented to the method or 
        // the most recent business days within the last 100 days.
        List<Datetime> recentBusinessDays = new List<Datetime>();
        Integer iteratedDays = 1;

        // Checks to see if the prior day was a business day.
        // If it was, add it to recentBusinessDays. This loop
        // continues until 100 days have been iterated over or
        // the requested amount of business days are found.
        while (recentBusinessDays.size() < amountOfDays) {
            Datetime consideredDate = noonToday.addHours(-iteratedDays * 24);
            Boolean withinBusinessHours = BusinessHours.isWithin(bh.Id, consideredDate);
            if (withinBusinessHours) {
                recentBusinessDays.add(consideredDate);
            } 

            if (iteratedDays > 100) {
                break;
            }
            iteratedDays++;
        }
        System.debug(recentBusinessDays);
        return recentBusinessDays;
    }

    public static List<Datetime> getBusinessDayStartEndTimes(Datetime dt) {
        Datetime startTime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0, 0, 0);
        Datetime endTime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 23, 59, 59);
        List<Datetime> startendTimes = new List<Datetime>{startTime, endTime};
        return startendTimes;
    }

    public static boolean isValidPhoneNumber(String phoneNumber) {
        if (phoneNumber == null) {
            return false;
        }
        return Pattern.matches('^(\\+\\d{1,2}\\s?)?\\(?(\\d{3})\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}$', phoneNumber);

    }

    public static boolean isValidEmailAddress(String emailAddress) {
        if (emailAddress == null) {
            return false;
        }
        return Pattern.matches(('^(?!.*\\.\\.)(?!.*\\.$)(?!.*^\\.)[A-Za-z0-9][A-Za-z0-9!#$%&\\*+/=?^_`{|}~-]*((?<=\\.)[A-Za-z0-9!#$%&\\*+/=?^_`{|}~-]+)*(?:\\.[A-Za-z0-9!#$%&\\*+/=?^_`{|}~-]+)*@((?:[A-Za-z0-9](?!.*--)[A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$'), emailAddress);
    }    

}