
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

#define kFavoritesSection 0 //What section we keep favorite temples in.

@interface MasterViewController ()

@property(strong, nonatomic) NSArray *filteredList;
@property(strong, nonatomic) NSMutableArray *favoritesList;
@property BOOL isSearching; // Is the user searching for something?

@end

@implementation MasterViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self setupSearchBar];
	
	UIColor *magnesium = [UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:1.0];
	self.tableView.sectionIndexColor = magnesium;
	
	[self loadFavoritesList];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	
	//Did we add to favorites list?
	NSMutableArray *oldFavorites = [self.favoritesList mutableCopy];
	[self loadFavoritesList];
	if ([oldFavorites count] > [self.favoritesList count]) { // Removed a favorite temple
		NSMutableArray *oldFavoritesBeforeDelete = [oldFavorites copy];
		[oldFavorites removeObjectsInArray:[self.favoritesList copy]];
		
		NSIndexPath *path = [NSIndexPath indexPathForItem:[oldFavoritesBeforeDelete indexOfObject:oldFavorites[0]] inSection:kFavoritesSection];
		[self.tableView deleteRowsAtIndexPaths: @[path] withRowAnimation:UITableViewRowAnimationFade];
	}
	else if([oldFavorites count] < [self.favoritesList count]){ // Added a favorite temple on the end
		NSIndexPath *path = [NSIndexPath indexPathForItem:[self.favoritesList count] - 1 inSection:kFavoritesSection];
		[self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
	}
	
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowDetail"]) {
        DetailTableViewController *nextViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		NSManagedObject *object;
		
        if (self.isSearching) {
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
    if (self.isSearching)
        return 1;
    else
        return [[self.fetchedResultsController sections] count] + 1; // For favorites
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearching) {
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
    if (self.isSearching) {
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
	if (self.isSearching) {
		return nil; // No names of any sections in the search view.
	}else if(section == kFavoritesSection){
		return @"Favorites";
	}else{
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section  - 1];
		return [sectionInfo name];
	}
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
	if (self.isSearching) {
		return nil;
	}
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
    if (_fetchedResultsController != nil) {
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



#pragma mark - UISearchResultsUpdating Delegate
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


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.isSearching = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
	self.isSearching = NO;
}

#pragma mark - Utility Methods

- (void)setupSearchBar {
	///Set up search bar in code since XCode search bar is deprecated: http://useyourloaf.com/blog/2015/02/16/updating-to-the-ios-8-search-controller.html
	self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
	self.tableView.tableHeaderView = self.searchController.searchBar;
	self.searchController.searchResultsUpdater = self; // This controller will respond to the UISearchResultsUpdating protocol.
	self.searchController.dimsBackgroundDuringPresentation = NO;
	self.searchController.searchBar.delegate = self;
	self.definesPresentationContext = YES;  //Allows the search view to cover the table view.
}

- (void)loadFavoritesList{
	NSFetchRequest *favoritesFetch = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
	[favoritesFetch setPredicate:predicate];

	NSError *error;
	self.favoritesList = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:favoritesFetch error:&error]];
	if (error != nil) {
		NSLog(@"Fetching favorites failed.");
	}
}

- (void)removeFavoritesDesignation:(Temple*)temple{
	NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", temple.name];
	[request setPredicate:predicate];
	Temple *object = [self.managedObjectContext executeFetchRequest:request error:nil][0];
	object.isFavorite = [NSNumber numberWithBool:NO];
	[self.managedObjectContext save:nil];
}
@end

