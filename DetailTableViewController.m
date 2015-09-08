//
//  DetailTableViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/26/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "DetailTableViewController.h"
#import "Temple.h"

#define kDefaultRowHeight 44
#define kAddressSection 0
#define kPhotoSection 1
#define kScheduleSection 2
#define kAddToFavoritesSection 3



@interface DetailTableViewController ()

@end

@implementation DetailTableViewController{
	
	NSDictionary *scheduleDict;
	NSArray *scheduleKeys;
	NSArray *weekdays;
	
	UIImage *scaledImage; // Use i-var because we need to both set the cell with it and calculate the cell height in 2 separate methods.
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

	locationManager = [[CLLocationManager alloc]init];
	[self setupLocationTracking];
	
	//Set navigation bar title
	self.navigationItem.title = self.currentTemple.name;
	
	scheduleKeys = [[NSArray alloc]initWithArray:[self.currentTemple.endowmentSchedule allKeys]];
	
	NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc]init];
	
	//Exlude Sunday. Temples always closed.
	NSRange range;
	range.location = 1;
	range.length = 6;
	
	weekdays = [weekdayFormatter.weekdaySymbols subarrayWithRange:range];

	
	// Sort the schedule into correct day of the week order
	scheduleDict = [self scheduleDictFromKeys:scheduleKeys];
	
	scaledImage = [DetailTableViewController imageWithImage:[self getImage] scaledToWidth:self.tableView.frame.size.width];
	}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
	// Change the image width if we rotate in the detail view.
	scaledImage = [DetailTableViewController imageWithImage:[self getImage] scaledToWidth:size.width];
	[self.tableView reloadData];
}

- (void)setupLocationTracking{
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	//locationManager.distanceFilter = 100; // Must move 100 meters before delegate is notified of new location.
	[locationManager startUpdatingLocation];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
		[locationManager requestWhenInUseAuthorization];
	
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case kAddressSection:
		case kPhotoSection:
			return 1;
			break;
		case kScheduleSection:
			return 6; // Number of schedule items: Monday - Saturday.
			break;
		case kAddToFavoritesSection:
			return 1;
			break;
		default:
			NSLog(@"Not a recognized tableview section.");
			return -1;
			break;
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 1) {
		return scaledImage.size.height;
	}
	else{
		return kDefaultRowHeight;
	}
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
    
	switch (indexPath.section) {
		case kAddressSection:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
			cell.textLabel.text = self.currentTemple.address;
			break;
		}
		case kPhotoSection:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
			UIImageView *photo = [[UIImageView alloc]initWithImage:scaledImage];
			[cell addSubview:photo];
		}
			break;
		case kScheduleSection:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
			
			//Load the appropriate schedule data.
			
			NSString *dayName = weekdays[indexPath.row];
			NSString *scheduleForDay = scheduleDict[dayName];
			cell.textLabel.text = dayName;
			
			cell.detailTextLabel.text = scheduleForDay;
		}
			break;
		case kAddToFavoritesSection:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"AddToFavoritesCell"];
			NSLog(@"%@", self.currentTemple.isFavorite);
			NSLog(@"%@", [NSNumber numberWithBool:YES]);
			if ([self.currentTemple.isFavorite isEqualToNumber:[NSNumber numberWithBool:YES]]) {
				cell.textLabel.text = @"Remove from Favorites";
			}
			else{
				
				cell.textLabel.text = @"Add to Favorites";
			}
		}
			break;
		default:
			break;
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case kAddressSection:
			return @"Address";
			break;
		case kPhotoSection:
			return nil;
			break;
		case kScheduleSection:
			return @"Schedule";
			break;
		case kAddToFavoritesSection:
			return nil;
			break;
		default:
			return @"Bad, bad, bad";
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == kAddressSection){ // Address tapped
		
		NSString *mapsString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&saddr=%f,%f", self.currentTemple.address, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSLog(@"The map query string: %@.", mapsString);
		NSURL *mapsUrl = [NSURL URLWithString:mapsString];
		[[UIApplication sharedApplication]openURL:mapsUrl];
	}
	else if(indexPath.section == kAddToFavoritesSection){
		NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", self.currentTemple.name];
		[request setPredicate:predicate];
		Temple *object = [self.managedObjectContext executeFetchRequest:request error:nil][0];
		if ([self.currentTemple.isFavorite isEqualToNumber:[NSNumber numberWithBool:YES]]) { // The button they tapped read Remove from Favorites
			object.isFavorite = [NSNumber numberWithBool:NO];
			[tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Add to Favorites";
		}
		else {// The button they tapped read Add to Favorites
			
		object.isFavorite = [NSNumber numberWithBool:YES];
			[self.managedObjectContext save:nil];
			[tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Remove from Favorites";
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Utility Methods

- (UIImage*)getImage{
	// Determine whether or not the image is cached. If cached, get from file. Else, send HTTP request.
	//Get the image view from the Internet.
	
	if ([self getCDLocalImagePath] == nil) { // None cached so get from web.
		return [self fetchImageFromWeb];
		//scaledImage = [DetailTableViewController imageWithImage:[self fetchImageFromWeb] scaledToWidth:[self getTableViewCellWidth]];
	}
	else{
		UIImage *cachedImage = [UIImage imageWithContentsOfFile:[self getCDLocalImagePath]];
		if (cachedImage == nil) {
			//Something went horribly wrong if this line is executed. Core data says we have a cached image but trying to get it fails. Should only happen when testing, when we reload the app and Core Data
			//has the old path but the filesystem is not preserved.
			NSLog(@"Failure to get image that has already been cached with current Temple: %@", self.currentTemple.name);
			return [self fetchImageFromWeb];
			//scaledImage	= [DetailTableViewController imageWithImage:[self fetchImageFromWeb] scaledToWidth:[self getTableViewCellWidth]];
		}
		else{
			return cachedImage;
		}
	}
}

- (UIImage *)fetchImageFromWeb{
	NSURL *url = [NSURL URLWithString:self.currentTemple.imageLink];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [UIImage imageWithData:data];
	[self saveImage:img];
	return img;
}

- (void)saveImage: (UIImage*)image{
	//This is the first solution to slow transitions to detail view that I was able to think of.
	//We will store the newly fetched image in the filesystem and fetch from there in the future. Core Data will
	//hold the filepath to this cache.
	//Lazy caching for the win.
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0]; // Path to picture directory.
	
	NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[self.currentTemple.name stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
	
	//Save new path to CoreData.
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
	[request setEntity:[NSEntityDescription entityForName:@"Temple" inManagedObjectContext:[self managedObjectContext]]];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", self.currentTemple.name];
	[request setPredicate:predicate];
	
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
	
	[results[0] setValue:imagePath forKey:@"localImagePath"];
	[self.managedObjectContext save:nil];
	
	//Profiling shows that we should do this in an operation queue so we don't take so long.
	
	NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
		NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
		[imageData writeToFile:imagePath atomically:NO];
	}];
	NSOperationQueue *queue = [[NSOperationQueue alloc]init];
	[queue addOperation:block];
}

- (NSString *)getCDLocalImagePath{
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
	[request setEntity:[NSEntityDescription entityForName:@"Temple" inManagedObjectContext:[self managedObjectContext]]];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", self.currentTemple.name];
	[request setPredicate:predicate];
	
	NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
	return [results[0] valueForKey:@"localImagePath"];
}

- (float)getTableViewCellWidth{
	return self.tableView.frame.size.width;
}

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
	float oldWidth = sourceImage.size.width;
	float scaleFactor = i_width / oldWidth;
	
	float newHeight = sourceImage.size.height * scaleFactor;
	float newWidth = oldWidth * scaleFactor;
	
	UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
	[sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (NSMutableDictionary*)scheduleDictFromKeys:(NSArray *)inputArray{
	
	NSMutableDictionary *expandedSchedule = [[NSMutableDictionary alloc]init];
	
	for (NSString * key in inputArray) {
		if ([key containsString:@"-"]) {
			NSArray *firstAndLast = [key componentsSeparatedByString:@"-"];
			NSInteger first = [weekdays indexOfObject:[firstAndLast firstObject]];
			NSInteger last = [weekdays indexOfObject:[firstAndLast lastObject]];
			for (int i = (int)first; i <= last; ++i) {
				expandedSchedule[weekdays[i]] = self.currentTemple.endowmentSchedule[key];
			}
		}
		else{
			expandedSchedule[key] = self.currentTemple.endowmentSchedule[key];
		}
	}
	return expandedSchedule;
}
	
//	NSArray *sortedArray = [inputArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
//		
//		//Break obj1 string into an array seperated by "-". Ex: "Monday-Thursday" becomes ["Monday", "Thursday"].
//		NSArray *weekday1Token = [obj1 componentsSeparatedByString:@"-"];
//		NSArray *weekday2Token = [obj2 componentsSeparatedByString:@"-"];
//		
//		//Find the index of the objects in the weekdays array, and compare them to see which comes first.
//		int obj1Index = [weekdays indexOfObject: weekday1Token[0]];
//		int obj2Index = [weekdays indexOfObject:weekday2Token[0]];
//		
//		if (obj1Index > obj2Index) { //First day later in the week than second.
//			return NSOrderedDescending;
//		}
//		
//		return NSOrderedAscending; //First day earlier in the week than second.
//	}];
//	return sortedArray;

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
	currentLocation = locations.lastObject; // Most recent location is last in the array.
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	UIAlertView *locationErrorAlert = [[UIAlertView alloc]initWithTitle:@"Location Failed" message:@"Failed to determine location. We don't know why." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[locationErrorAlert show];
}


@end
