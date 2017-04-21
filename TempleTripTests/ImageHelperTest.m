//
//  ImageHelperTest.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ImageHelper.h"
#import "Temple.h"

@interface ImageHelperTest : XCTestCase

@end

@implementation ImageHelperTest{
    UIImage *testImage;
    Temple *testTemple;
}

- (void)setUp {
    [super setUp];
    testImage = [UIImage imageNamed:@"phoneIcon"];
    
    testTemple.imageLink = @"http://thebigboss.org/wp-content/uploads/2014/ios_logo.png";
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testImageWithImageScaledToWidth{
    UIImage *result = [ImageHelper imageWithImage:testImage scaledToWidth:1000];
    XCTAssertEqual(result.size.width, 1000);
    XCTAssertNotEqual(result.size.height, testImage.size.height);
}

- (void) testGetImageFromWebForTemple{
    XCTFail(@"Not implemented");
}

- (void) testGetCachedImagePathForTemple{
    XCTFail(@"Not implemented");
}

@end
