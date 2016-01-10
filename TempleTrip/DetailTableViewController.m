//
//  DetailTableViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/26/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "DetailTableViewController.h"
#import "Temple.h"
#import "ScheduleViewController.h"
#import "TempleTrip-Swift.h"
#import "ImageHelper.h"
#import "MasterViewController.h"

@import Crashlytics;

@implementation DetailTableViewController{
	NSString * dayTapped;
}

-(instancetype) initWithTemple: (Temple *) aTemple managedContext: (NSManagedObjectContext *) context{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self != nil) {
        self.currentTemple = aTemple;
        self.managedObjectContext = context;
    }
    return self;
}

#pragma mark - View Lifecycle

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[Crashlytics sharedInstance] setObjectValue:self.currentTemple.name forKey:@"currentTemple"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    
    if(self.currentTemple == nil){ // In the iPad split view controller, we have not yet selected one, so pick the first.
        UINavigationController *masterNav = self.splitViewController.viewControllers.firstObject;
        MasterViewController *masterController = (MasterViewController *)masterNav.topViewController;
        
        self.managedObjectContext = masterController.managedObjectContext;
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[descriptor]];
        
        NSArray *all = [self.managedObjectContext executeFetchRequest:request error:nil];
        self.currentTemple = all.firstObject;
    }

    //Set navigation bar title
    self.navigationItem.title = self.currentTemple.name;
    
    //Set up the call button in the navigation bar.
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"tel://"]]) {
        UIBarButtonItem *callButton =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"phoneIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(beginCall)];
        self.navigationItem.rightBarButtonItem = callButton;
    }
    
    //Set up table view
    UIImage *image = [ImageHelper getImageFromWebOrCacheForTemple:self.currentTemple withContext:self.managedObjectContext];
    [ImageHelper saveTempleImage:image forTemple:self.currentTemple withContext:self.managedObjectContext];
    
    self.detailDataSource = [[DetailDataSource alloc]initWithImage: image Temple:self.currentTemple ManagedObjectContext: self.managedObjectContext];
    self.tableView.delegate = self.detailDataSource;
    self.tableView.dataSource = self.detailDataSource;
    
    //Set up dataSource delegate (so it can tell the master view to update if a favorite is added.)
    UINavigationController *masterNav = self.splitViewController.viewControllers.firstObject;
    self.detailDataSource.delegate = (id)masterNav.topViewController;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    NSIndexPath *imagePath = [self.detailDataSource imageIndexPath];
    [self.detailDataSource setScaledImageIfNeededWithWidth:size.width];
    [self.tableView reloadRowsAtIndexPaths:@[imagePath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
	//Don't perform a segue if the temple is closed
    UITableViewCell *senderCell = sender;
	return [identifier isEqualToString:@"Schedule"] && !([senderCell.detailTextLabel.text isEqualToString:@"Closed"] || [senderCell.detailTextLabel.text isEqualToString:@""]);
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([[segue identifier] isEqualToString:@"Schedule"]) {
        
        UITableViewCell *senderCell = sender;
		NSString *weekdayTapped = senderCell.textLabel.text;
		UINavigationController *navController = [segue destinationViewController];
        ScheduleViewController *scheduleController = navController.viewControllers[0];
		scheduleController.dayTapped = weekdayTapped;
		scheduleController.templeName = self.currentTemple.name;
        scheduleController.location = self.currentTemple.address;
        scheduleController.scheduleDict = [DetailDataSource scheduleDictFromEndowmentDictionary:self.currentTemple.endowmentSchedule];
	}
}

#pragma mark - Helpers

-(void)beginCall{
	NSString *number = self.currentTemple.telephone;
	
	NSString *parsedNumber = [self parsePhoneNumber:number];
	NSString *callUri = [@"tel://" stringByAppendingString:parsedNumber];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:callUri]];
}

-(NSString *)parsePhoneNumber:(NSString *)number{
	NSString *cleanedString = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
	return cleanedString;
}

@end
