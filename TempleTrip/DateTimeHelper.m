//
//  DateTimeHelper.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "DateTimeHelper.h"

@implementation DateTimeHelper

/*** Gets an array of the days of the week: Sunday through Saturday as strings. ***/

+ (NSArray *)getWeekdays{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    return formatter.weekdaySymbols;
}

/*** Gets the display date in the format 8:00 am - 1:00 pm given two dates in military time. ***/

+ (NSString *)getDisplayDateRangeWithStart: (NSString *) militaryStart End: (NSString *) militaryEnd{
    if ([militaryStart isEqualToString: militaryEnd]) { // Also handles closed case.
        return [DateTimeHelper getDisplayDateWithMilitaryTime: militaryStart];
    }
    return [NSString stringWithFormat:@"%@ - %@", [DateTimeHelper getDisplayDateWithMilitaryTime: militaryStart], [DateTimeHelper getDisplayDateWithMilitaryTime: militaryEnd]];
}


/*** Gets the display date in the format 8:00 am given a date in military time. ***/

+ (NSString *)getDisplayDateWithMilitaryTime: (NSString *) time{
    if ([time  isEqual: @"Closed"] || [time isEqualToString:@""]) {
        return time;
    }
    BOOL isAfternoon = NO;
    NSRange colonPosition = [time rangeOfString:@":"];
    NSInteger hour = [[time substringToIndex:colonPosition.location] integerValue];
    NSString *minutes = [time substringFromIndex:colonPosition.location + 1];
    if (hour >= 12 && hour < 24) {
        isAfternoon = YES;
        if (hour != 12) {
            hour -= 12;
        }
    }
    if (hour == 24) {
        isAfternoon = NO;
        hour -= 12;
    }
    NSString *postfix = @"am";
    if (isAfternoon) {
        postfix = @"pm";
    }
    return [NSString stringWithFormat:@"%ld:%@ %@", (long)hour, minutes, postfix];
}

/*** Gets a list of [count] date objects, representing startDay and the next [count - 1] days with the same day of the week after it in the calendar. ***/

+(NSArray *)getUpcomingDatesArrayWithDay:(NSString *)startDay count:(NSInteger)numToCalculate{
    NSMutableArray* results = [[NSMutableArray alloc]init];
    NSArray *mondayThroughFriday = [DateTimeHelper getWeekdays];
    
    //Get the current weekday number. This is the index of the day of the week of today.
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    long currentLiveWeekday = [comps weekday];
    
    //Get the weekday number of the day of the week the user is currently viewing.
    long viewingWeekday = [mondayThroughFriday indexOfObject:startDay] + 1; //NSDateComponents uses Sunday=1, Monday=2 ... So we must offset for 0 indexing.
    
    if (viewingWeekday < currentLiveWeekday) {
        viewingWeekday += 7; // Jump to the next soonest day this will be after today
    }
    long daysAhead = viewingWeekday - currentLiveWeekday;
    
    NSDateComponents* comps2 = [NSDateComponents new];
    comps2.day	= daysAhead;
    
    NSDate* first = [[NSCalendar currentCalendar]dateByAddingComponents:comps2 toDate:[NSDate date] options:0];
    [results addObject:first];
    
    //Get the calendar date of the next weekday for the view.
    
    for (int i = 0; i < numToCalculate - 1; ++i) {
        NSDateComponents *comps3 = [NSDateComponents new];
        comps3.day = 7; //Add each one exactly one week out.
        NSDate* weekAhead = [[NSCalendar currentCalendar]dateByAddingComponents:comps3 toDate:results[i] options:0];
        [results addObject:weekAhead];
    }
    return results;
}

/*** Gets a date from a string in the formate 1996-MM-dd ***/

+ (NSDate *)getDateFromString:(NSString *)aString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"]; //Following ISO-8601 format
    return [formatter dateFromString:aString];
}

+ (NSArray *)getAllDatesFromStringArray:(NSArray *)inputStringArray{
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    for (NSString *string in inputStringArray) {
        NSDate *date = [DateTimeHelper getDateFromString:string];
        if(date != nil)
            [results addObject:date];
        else
            NSLog(@"String %@ cannot be parsed into date", string);
    }
    return results;
}

/*** Compares on day, month, than year, stopping as soon as possible. ***/

+ (BOOL) datesAreEqual:(NSDate *)date1 Other:(NSDate *)date2{
    NSDateComponents *component1 = [[NSCalendar currentCalendar]components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *component2 = [[NSCalendar currentCalendar]components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2];
    return [component1 day] == [component2 day] && [component1 month] == [component2 month] && [component1 year] == [component2 year];
}



@end
