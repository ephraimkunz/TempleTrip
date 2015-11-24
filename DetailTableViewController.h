//
//  DetailTableViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/26/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class Temple;

@interface DetailTableViewController : UITableViewController<CLLocationManagerDelegate>

@property(strong, nonatomic) Temple *currentTemple;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+(NSString*)getDisplayDate:(NSString*) militaryTime;
-(NSString *)parsePhoneNumber:(NSString *)number;
	
@end
