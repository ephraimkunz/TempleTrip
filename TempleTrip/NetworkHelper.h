//
//  NetworkHelper.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 4/5/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import "Temple.h"

@interface NetworkHelper : NSObject

+ (void) fetchAndUpdateTemplesFromParseWithManagedObjectContext:(NSManagedObjectContext *) context completionBlock:(void(^)(void)) block;

@end
