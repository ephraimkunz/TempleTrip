
//
//  MasterViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/6/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import "MasterViewController.h"
#import "Temple.h"
#import "DetailTableViewController.h"
#import "CTFeedbackViewController.h"
#import <Parse/Parse.h>

@import Crashlytics;

#define kFavoritesSection 0 //What section we keep favorite temples in.

@interface MasterViewController ()

@property(strong, nonatomic) NSArray *filteredList;
@property(strong, nonatomic) NSMutableArray *favoritesList;

@end

@implementation MasterViewController
{
	BOOL shouldUpdateFetchedResultsController;
	NSString * sortTableBy;
}

#pragma mark - View Lifecycle
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[Crashlytics sharedInstance] setObjectValue:@"" forKey:@"currentTemple"];
    [[Crashlytics sharedInstance]setIntValue:(int)[self.favoritesList count] forKey:@"numberOfFavorites"];
    
    //Reload favorites after visiting detail screen.
    [self loadFavoritesList];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.definesPresentationContext = YES;
    self.title = @"Temples";
    [self setupSearchBar];
	[self loadFavoritesList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDetail"]) {
        
        UINavigationController *navController = [segue destinationViewController];
        DetailTableViewController *nextViewController = (DetailTableViewController *)[navController topViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSManagedObject *object;
		
        if (self.searchController.active) {
            nextViewController.currentTemple = self.filteredList[[indexPath row]];
        }else{
			if (indexPath.section == kFavoritesSection) {
				object = [self.favoritesList objectAtIndex:indexPath.row];
			}
			else{
				NSIndexPath *modified = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
				object = [[self fetchedResultsController] objectAtIndexPath:modified];
			}
            nextViewController.currentTemple = (Temple *)object;
        }
		
		//Create dependency injection: http://stackoverflow.com/questions/21050408/how-to-get-managedobjectcontext-for-viewcontroller-other-than-getting-it-from-ap to pass managedObjectContext along
		nextViewController.managedObjectContext = self.managedObjectContext;
	}
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchController.active)
        return 1;
    else
        return [[self.fetchedResultsController sections] count] + 1; // For favorites
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return [self.filteredList count];
	}else if(section == kFavoritesSection){
		return [self.favoritesList count];
	}else{
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section - 1];
        return [sectionInfo numberOfObjects];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (self.searchController.active) {
        Temple *filteredTemple = [self.filteredList objectAtIndex:[indexPath row]];
        cell.textLabel.text = [filteredTemple name];
        
        //Configure dedication date as detail label.
        NSString *dateCandidate = filteredTemple.dedication;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSDate *date = [formatter dateFromString:dateCandidate];
        
        if (date) {
            NSString *formattedDate = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
            cell.detailTextLabel.text = formattedDate;
        }
        
        else{
            cell.detailTextLabel.text = filteredTemple.dedication;
        }
    }else{
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == kFavoritesSection; // All items in the first section (favorites) will be editable.
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (self.searchController.active) {
		return nil; // No names of any sections in the search view.
	}else if(section == kFavoritesSection){
		return @"Favorites";
	}else{
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section  - 1];
		return [sectionInfo name];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
	if(self.searchController.active) return nil;
	NSArray *letters = [self.fetchedResultsController sectionIndexTitles];
	NSString *search = UITableViewIndexSearch;
	NSMutableArray *indexTitles = [[NSMutableArray alloc]initWithArray:letters];
	[indexTitles insertObject:search atIndex:0];
	return indexTitles;
	
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
	if (index == 0) {
		CGRect searchBarFrame = self.searchController.searchBar.frame;
		[tableView scrollRectToVisible:searchBarFrame animated:NO];
		return -1;
	}
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index - 1] + 1; // Because magnifying glass takes up index 0, and we don't have an index icon for favorites.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		//Fix core data.
		[self removeFavoritesDesignation:self.favoritesList[indexPath.row]];
		//Change the data source for this section
		[self.favoritesList removeObjectAtIndex:indexPath.row];
		//Remove row on the list
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *object;
	
	if(indexPath.section == kFavoritesSection){
		object = self.favoritesList[indexPath.row];
	}
	else{
		NSIndexPath *modified = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - 1];
		object = [self.fetchedResultsController objectAtIndexPath:modified];
	}
	
    cell.textLabel.text = [[object valueForKey:@"name"] description];
    
    //Configure dedication date as detail label.
    NSString *dateCandidate = [object valueForKey:@"dedication"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateCandidate];
    
    if (date) {
        NSString *formattedDate = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
        cell.detailTextLabel.text = formattedDate;
    }
    else{
        cell.detailTextLabel.text = [object valueForKey:@"dedication"];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController // Custom getter.
{
    if (_fetchedResultsController != nil && !shouldUpdateFetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Temple" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"firstLetter" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
	
	shouldUpdateFetchedResultsController = NO;
	
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    return _fetchedResultsController;
}    

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
	NSString *searchString = searchController.searchBar.text;
	[self searchForText:searchString];
	[self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchString{
    if (self.managedObjectContext)
    {
		NSFetchRequest *request = [self createSearchFetchRequest];
        NSString *predicateFormat = @"%K CONTAINS[cd] %@";
        NSString *searchAttribute = @"name";
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchString];
        if (![searchString isEqualToString:@""]) {
            [request setPredicate:predicate];
        }
        
        NSError *error = nil;
        self.filteredList = [self.managedObjectContext executeFetchRequest:request error:&error];
    }
}

- (NSFetchRequest *)createSearchFetchRequest{ // Create a new one each time so we can be sure it is "clean" when all text is deleted (returns everything).
	NSFetchRequest *searchFetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Temple" inManagedObjectContext:self.managedObjectContext];
	[searchFetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[searchFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    return searchFetchRequest;
}

#pragma mark - Utility Methods

- (void)setupSearchBar {
	self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
	self.tableView.tableHeaderView = self.searchController.searchBar;
	self.searchController.searchResultsUpdater = self;
	self.searchController.dimsBackgroundDuringPresentation = NO;
	[self.searchController.searchBar sizeToFit];
}

- (void)loadFavoritesList{
	NSFetchRequest *favoritesFetch = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
	[favoritesFetch setPredicate:predicate];
	
	NSSortDescriptor *alphaName = [[NSSortDescriptor alloc]initWithKey:@"name" ascending:YES];
	[favoritesFetch setSortDescriptors:@[alphaName]];

	NSError *error;
	if(!(self.favoritesList = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:favoritesFetch error:&error]])){
		NSLog(@"Failed to fetch favorites");
	};
}

- (void)removeFavoritesDesignation:(Temple*)temple{
	NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", temple.name];
	[request setPredicate:predicate];
	Temple *object = [self.managedObjectContext executeFetchRequest:request error:nil][0];
	object.isFavorite = [NSNumber numberWithBool:NO];
	[self.managedObjectContext save:nil];
}
- (IBAction)refresh:(UIRefreshControl *)sender {
    
    //Get the new temple JSON from the server
    PFQuery *allTemplesQuery = [PFQuery queryWithClassName:@"Temple"];
    [allTemplesQuery setLimit:1000];
    
    [allTemplesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSLog(@"Success fetching %lu temples from Parse server", (unsigned long)[objects count]);
            NSInteger successUpdated = 0;
            
            //Load them into core data. If there is a temple in the JSON that we don't have, create it.
            for(PFObject *temple in objects){
                
                NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
                [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", temple[@"name"]]];
                NSError *fetchError;
                NSArray *fetchedTemples;
                if (!(fetchedTemples = [self.managedObjectContext executeFetchRequest:request error:&fetchError])){
                    NSLog(@"Error fetching core data temple for updated temple from Parse with name: %@, error: %@. Maybe it is a new temple.", temple[@"name"], fetchError.description);
                }
                
                if (fetchedTemples.count > 1) {
                    NSLog(@"More than one temple in Core Data for name: %@", temple[@"name"]);
                }
                
                Temple *cdTemple;
                
                if (fetchedTemples.count == 0) { //New temple, we need to add it the DB.
                    cdTemple = [NSEntityDescription insertNewObjectForEntityForName:@"Temple" inManagedObjectContext:self.managedObjectContext];
                    cdTemple.name = [temple valueForKey:@"name"];
                }
                else{ //Update an existing temple.
                    cdTemple = fetchedTemples[0];
                }
                
                cdTemple.dedication = [temple valueForKey:@"dedication"];
                cdTemple.place = [temple valueForKey:@"place"];
                cdTemple.address = [temple valueForKey:@"address"];
                cdTemple.imageLink = [temple valueForKey:@"photoLink"];
                cdTemple.telephone = [temple valueForKey:@"telephone"];
                cdTemple.endowmentSchedule = [temple valueForKey:@"endowmentSchedule"];
                cdTemple.firstLetter = [[temple valueForKey:@"name"] substringToIndex:1];
                
                NSString *firstTwoLetters = [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Cafeteria"] substringToIndex:2] == nil ? @"No" : [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Cafeteria"] substringToIndex:2];
                cdTemple.hasCafeteria = ![firstTwoLetters isEqualToString:@"No"];
                
                firstTwoLetters = [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Clothing"] substringToIndex:2] == nil ? @"No" : [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Clothing"] substringToIndex:2];
                cdTemple.hasClothing = ![firstTwoLetters isEqualToString:@"No"];
                
                NSMutableArray *closedDatesArray = [[NSMutableArray alloc]initWithArray:[[temple valueForKey:@"closures"]valueForKey:@"Maintenance Dates"]];
                [closedDatesArray addObjectsFromArray:[[temple valueForKey:@"closures"]valueForKey:@"Other Dates"]];
                cdTemple.closedDates = [closedDatesArray copy];
                
                cdTemple.existsOnServer = YES;
                
                NSError *saveError;
                if (![self.managedObjectContext save:&saveError]){
                    NSLog(@"Error saving updated temple with name: %@ to CD, %@", cdTemple.name, saveError.description);
                }
                else{
                    successUpdated ++;
                }
                
            }
            NSLog(@"Success updating or adding %ld out of %lu temples in core data from Parse server", (long)successUpdated, (unsigned long)[objects count]);
            
            //Remove temples not on the server;
            NSFetchRequest *toDelete = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
            [toDelete setPredicate:[NSPredicate predicateWithFormat:@"existsOnServer = NO"]];
            NSArray *notOnServer;
            if((notOnServer = [self.managedObjectContext executeFetchRequest:toDelete error:nil])){
                NSLog(@"Success deleting %ld temples in core data", (unsigned long)notOnServer.count);
                for(Temple *temple in notOnServer){
                    [self.managedObjectContext deleteObject:temple];
                }
            }
            [self.managedObjectContext save:nil];
            
            //Reset existsOnServer to NO for everything
            NSArray *everything = [self.managedObjectContext executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Temple"] error:nil];
            for(Temple* temple in everything){
                temple.existsOnServer = NO;
            }
            [self.managedObjectContext save:nil];
        }
        else{
            NSLog(@"Error fetching all temples from the server");
        }
        
        [sender endRefreshing];
    }];
}

#pragma mark - FavoritesUpdatingProtocol

-(void)favoritesDidUpdate{
    [self loadFavoritesList];
    [self.tableView reloadData];
}


- (IBAction)feedbackTapped:(id)sender {
    CTFeedbackViewController *feedbackViewController = [CTFeedbackViewController controllerWithTopics:CTFeedbackViewController.defaultTopics localizedTopics:CTFeedbackViewController.defaultLocalizedTopics];
    feedbackViewController.toRecipients = @[@"ephraimkunz@me.com"];
    
    feedbackViewController.useHTML = NO;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
}

@end


