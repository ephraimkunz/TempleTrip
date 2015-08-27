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



@interface DetailTableViewController ()

@end

@implementation DetailTableViewController{
	NSDictionary *scheduleDict;
	UIImage *scaledImage; // Use i-var because we need to both set the cell with it and calculate the cell height in 2 separate methods.
	CLGeocoder *geocoder;
	CLPlacemark *placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	geocoder = [[CLGeocoder alloc]init];
	//Set navigation bar title
	self.navigationItem.title = self.currentTemple.name;
	scheduleDict = self.currentTemple.endowmentSchedule;
	scaledImage = [DetailTableViewController imageWithImage:[self getImage] scaledToWidth:[self getTableViewCellWidth]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
		case 1:
			return 1;
			break;
		case 2:
			return [scheduleDict count];
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
	UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
	switch (indexPath.section) {
		case 0:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
			cell.textLabel.text = self.currentTemple.address;
			break;
		}
		case 1:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
			UIImageView *photo = [[UIImageView alloc]initWithImage:scaledImage];
			[cell addSubview:photo];
		}
			break;
		case 2:{
			cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
			cell.textLabel.text = @"Day of the week here";
			cell.detailTextLabel.text = @"Schedule goes here";
		}
		default:
			break;
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0:
			return @"Location";
			break;
		case 1:
			return nil;
			break;
		case 2:
			return @"Schedule";
			break;
		default:
			return @"Bad, bad, bad";
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 0){ // Address tapped
		__block NSString *currentLocation;
		[geocoder reverseGeocodeLocation:self.locationWhenPushed completionHandler:^(NSArray *placemarks, NSError *error){
			if (!error) {
    placemark = [placemarks lastObject];
				currentLocation = [NSString stringWithFormat:@"%@ %@, %@, %@ %@ %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.postalCode, placemark.locality, placemark.administrativeArea, placemark.country];
			}
		}
			];
		NSString *mapsString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&saddr=%@", self.currentTemple.address, currentLocation]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *mapsUrl = [NSURL URLWithString:mapsString];
		[[UIApplication sharedApplication]openURL:mapsUrl];
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
	//Get the image view from the Internet.
	NSURL *url = [NSURL URLWithString:self.currentTemple.imageLink];
	NSData *data = [NSData dataWithContentsOfURL:url];
	UIImage *img = [UIImage imageWithData:data];
	return img;
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

@end
