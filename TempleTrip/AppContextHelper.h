//
//  AppContextHelper.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 2/6/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface AppContextHelper : NSObject

+ (NSString *) platformString;
+ (NSString *)systemVersion;
+ (NSString *)appName;
+ (NSString *)appVersion;
+ (NSString *)appBuild;

@end
