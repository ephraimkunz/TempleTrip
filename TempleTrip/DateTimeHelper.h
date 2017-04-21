//
//  DateTimeHelper.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateTimeHelper : NSObject

+ (NSArray *)getWeekdays;
+ (NSString *)getDisplayDateRangeWithStart: (NSString *) militaryStart End: (NSString *) militaryEnd;
+ (NSString *)getDisplayDateWithMilitaryTime: (NSString *) time;
+ (NSArray *)getUpcomingDatesArrayWithDay:(NSString *)startDay count:(NSInteger)numToCalculate;
+ (NSDate *)getDateFromString:(NSString *)aString;
+ (NSArray *)getAllDatesFromStringArray:(NSArray *)inputStringArray;
+ (BOOL) datesAreEqual:(NSDate *)date1 Other:(NSDate *)date2;
@end
