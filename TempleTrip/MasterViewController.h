//
//  MasterViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/6/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UISearchController *searchController;


@end

