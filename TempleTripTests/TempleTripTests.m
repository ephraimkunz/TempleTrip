//
//  TempleTripTests.m
//  TempleTripTests
//
//  Created by Ephraim Kunz on 8/6/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DetailTableViewController.h"

@interface TempleTripTests : XCTestCase

@end

@implementation TempleTripTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testParsePhoneNumber{
	NSString *input = @"1(435)512-1155";
	
	DetailTableViewController *target = [[DetailTableViewController alloc]init];
	
	NSString *result = [target parsePhoneNumber:input];
	XCTAssertTrue([result isEqualToString:@"14355121155"]);
}

-(void)testGetDisplayDate{
	NSString *input = @"14:34";
	
	NSString *result = [DetailTableViewController getDisplayDate:input];
	XCTAssertTrue([result isEqualToString:@"2:34 pm"]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
		NSString *result = [DetailTableViewController getDisplayDate:@"20:34"];
		XCTAssertNotNil(result);
    }];
}

@end
