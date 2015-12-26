//
//  DateTimeHelper.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "DateTimeHelper.h"

@implementation DateTimeHelper

+ (NSArray *)getWeekdays{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSRange range;
    range.location = 1; // Exclude Sunday because temples are always closed.
    range.length = 6;
    
    return [formatter.weekdaySymbols subarrayWithRange:range];
}

+ (NSString *)getDisplayDateRangeWithStart: (NSString *) militaryStart End: (NSString *) militaryEnd{
    if ([militaryStart isEqualToString: militaryEnd]) { // Also handles closed case.
        return [DateTimeHelper getDisplayDateWithMilitaryTime: militaryStart];
    }
    return [NSString stringWithFormat:@"%@ - %@", [DateTimeHelper getDisplayDateWithMilitaryTime: militaryStart], [DateTimeHelper getDisplayDateWithMilitaryTime: militaryEnd]];
}

+ (NSString *)getDisplayDateWithMilitaryTime: (NSString *) time{
    if ([time  isEqual: @"Closed"] || [time isEqualToString:@""]) {
        return time;
    }
    BOOL isAfternoon = NO;
    NSRange colonPosition = [time rangeOfString:@":"];
    NSInteger hour = [[time substringToIndex:colonPosition.location] integerValue];
    NSString *minutes = [time substringFromIndex:colonPosition.location + 1];
    if (hour == 12) {
        isAfternoon = YES;
    }
    if (hour > 12) {
        hour = hour - 12;
        isAfternoon = YES;
    }
    NSString *postfix = @"am";
    if (isAfternoon) {
        postfix = @"pm";
    }
    return [NSString stringWithFormat:@"%ld:%@ %@", (long)hour, minutes, postfix];

}
@end
