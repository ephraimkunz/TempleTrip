//
//  DetailTableViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/26/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailDataSource.h"

@class Temple;

@interface DetailTableViewController : UITableViewController

@property(strong, nonatomic) Temple *currentTemple;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(strong, nonatomic) DetailDataSource *detailDataSource;
	
@end
