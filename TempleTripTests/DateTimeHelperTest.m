//
//  DateTimeHelperTest.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DateTimeHelper.h"

@interface DateTimeHelperTest : XCTestCase

@end

@implementation DateTimeHelperTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetWeekdays {
    NSArray *weekDays = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSArray *results = [DateTimeHelper getWeekdays];
    
    for (int i = 0; i < weekDays.count; ++i) {
        XCTAssertEqualObjects(weekDays[i], results[i]);
    }
    XCTAssertEqual(results.count, weekDays.count);
}

- (void)testGetDisplayDateRangeWithStartEnd{
    NSString *result = [DateTimeHelper getDisplayDateRangeWithStart:@"2:00" End:@"4:00"];
    XCTAssertEqualObjects(result, @"2:00 am - 4:00 am");
    
    result = [DateTimeHelper getDisplayDateRangeWithStart:@"2:00" End:@"13:00"];
    XCTAssertEqualObjects(result, @"2:00 am - 1:00 pm");
    
    result = [DateTimeHelper getDisplayDateRangeWithStart:@"14:00" End:@"16:00"];
    XCTAssertEqualObjects(result, @"2:00 pm - 4:00 pm");
    
    result = [DateTimeHelper getDisplayDateRangeWithStart:@"23:00" End:@"1:00"];
    XCTAssertEqualObjects(result, @"11:00 pm - 1:00 am");
    
    result = [DateTimeHelper getDisplayDateRangeWithStart:@"13:00" End:@"13:00"];
    XCTAssertEqualObjects(result, @"1:00 pm");
}

- (void)testGetDisplayDateWithMilitaryTime{
    NSString *result = [DateTimeHelper getDisplayDateWithMilitaryTime:@"Closed"];
    XCTAssertEqualObjects(result, @"Closed");
    
    result = [DateTimeHelper getDisplayDateWithMilitaryTime:@""];
    XCTAssertEqualObjects(result, @"");
    
    result = [DateTimeHelper getDisplayDateWithMilitaryTime:@"14:25"];
    XCTAssertEqualObjects(result, @"2:25 pm");
    
    result = [DateTimeHelper getDisplayDateWithMilitaryTime:@"12:45"];
    XCTAssertEqualObjects(result, @"12:45 pm");
    
    result = [DateTimeHelper getDisplayDateWithMilitaryTime:@"24:45"];
    XCTAssertEqualObjects(result, @"12:45 am");
}

-(void)testGetDateFromString{
    NSDateComponents *components = [[NSDateComponents alloc]init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [components setYear:2016];
    [components setMonth:3];
    [components setDay:22];
    NSDate *expectedDate = [calendar dateFromComponents:components];
    
    NSDate *result = [DateTimeHelper getDateFromString:@"2016-03-22"];
    XCTAssertNotNil(result);
    XCTAssertEqual(expectedDate, result);
    
    
    result = [DateTimeHelper getDateFromString:@"01-21-23"];
    XCTAssertNil(result);
}

@end
