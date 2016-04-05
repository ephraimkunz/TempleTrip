//
//  DetailDataSource.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "DetailDataSource.h"
#import "ImageHelper.h"
#import "Temple.h"
#import "TempleTrip-Swift.h"
#import "DateTimeHelper.h"

#define kDefaultRowHeight 44
#define kAddressSection 1
#define kPhotoSection 0
#define kScheduleSection 2
#define kAddToFavoritesSection 3

@implementation DetailDataSource{
    UIImage *scaledImage;
    Temple *temple;
    NSManagedObjectContext *context;
}
- (instancetype) initWithImage: (UIImage*)Image Temple: (Temple *) newTemple ManagedObjectContext: (NSManagedObjectContext *) newContext{
    self = [super init];
    if (self) {
        self.image = Image;
        temple = newTemple;
        context = newContext;
        //Convert a dictionary of the form dayName: string to the form dayname: array of military times.
        self.scheduleDict = [DetailDataSource scheduleDictFromEndowmentDictionary:temple.endowmentSchedule];
    }
    return self;
}

- (instancetype) initWithTemple: (Temple *) newTemple ManagedObjectContext: (NSManagedObjectContext *) newContext{
    return [self initWithImage:nil Temple:newTemple ManagedObjectContext:newContext];
}

-(void) setScaledImageIfNeededWithWidth: (float) width{
    if (scaledImage == nil || scaledImage.size.width != width) {
        scaledImage = [ImageHelper imageWithImage:self.image scaledToWidth:width];
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kAddressSection:
            return 2;
            break;
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
    if (indexPath.section == kPhotoSection) {
        //First time we see the image, we need to find correct height and scale it. Thereafter, the transition
        //coordinator will handle it.
        if (scaledImage == nil) {
            [self setScaledImageIfNeededWithWidth:tableView.frame.size.width];
        }
        
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
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
                cell.textLabel.text = temple.address;
            }
            else if(indexPath.row == 1){
                ServicesAvailableCell* servicesCell = [tableView dequeueReusableCellWithIdentifier:@"ServicesAvailableCell"];
                servicesCell.LeftLabel.text = temple.hasClothing ? @"Rental clothing" : @"No rental clothing";
                servicesCell.RightLabel.text = temple.hasCafeteria ? @"Cafeteria" : @"No cafeteria";
                return servicesCell;
            }
            break;
        }
        case kPhotoSection:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
            UIImageView *photo = [[UIImageView alloc]initWithImage:scaledImage];
            [cell addSubview:photo];
            break;
        }
        case kScheduleSection:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
            
            //Load the appropriate schedule data.
            
            NSString *dayName = [DateTimeHelper getWeekdays][indexPath.row + 1]; // Don't want to include Sunday
            NSArray *timesForWeekday = self.scheduleDict[dayName];
            NSString *displayTime = [DateTimeHelper getDisplayDateRangeWithStart:timesForWeekday[0] End:[timesForWeekday lastObject]];
            cell.detailTextLabel.text = displayTime;
            if ( [displayTime isEqualToString:@""]) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.textLabel.text = dayName;
            break;
        }
        case kAddToFavoritesSection:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddToFavoritesCell"];
            if ([temple.isFavorite isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                cell.textLabel.text = @"Remove from Favorites";
            }
            else{
                
                cell.textLabel.text = @"Add to Favorites";
            }
            break;
        }
        default:
            NSLog(@"Error trying to get cell from unrecognized section");
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case kAddressSection:
            return @"Information";
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

#pragma  mark - Table View Delegate

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == kScheduleSection) {
        if ([[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text isEqualToString:@"Closed"]
            || [[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text isEqualToString:@""]) {
            return false;
        }
    }
    return true;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.section == kAddressSection && indexPath.row == 0){ // Address tapped
        NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSString *mapsString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@", temple.address] stringByAddingPercentEncodingWithAllowedCharacters: set];
        
        NSURL *mapsUrl = [NSURL URLWithString:mapsString];
        [[UIApplication sharedApplication]openURL:mapsUrl];
    }
    
    else if(indexPath.section == kAddToFavoritesSection){
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", temple.name];
        [request setPredicate:predicate];
        Temple *object = [context executeFetchRequest:request error:nil][0];
        if ([temple.isFavorite isEqualToNumber:[NSNumber numberWithBool:YES]]) { // The button they tapped read Remove from Favorites
            object.isFavorite = [NSNumber numberWithBool:NO];
            [tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Add to Favorites";
        }
        else {// The button they tapped read Add to Favorites
            
            object.isFavorite = [NSNumber numberWithBool:YES];
            [context save:nil];
            [tableView cellForRowAtIndexPath:indexPath].textLabel.text = @"Remove from Favorites";
        }
        [context save:nil];
        
        if ([self.delegate respondsToSelector:@selector(favoritesDidUpdate)]) {
            [self.delegate favoritesDidUpdate];
        }
    }
}

#pragma mark - Utility Methods

+ (NSMutableDictionary*)scheduleDictFromEndowmentDictionary: (NSDictionary *) dictionary{
    
    NSMutableDictionary *expandedSchedule = [[NSMutableDictionary alloc]init];
    
    for (NSString * key in dictionary.allKeys) {
        NSString * values = dictionary[key];
        NSArray * distinctTimes = [values componentsSeparatedByString:@","];
        expandedSchedule[key] = distinctTimes;
    }
    return expandedSchedule;
}

- (NSIndexPath *)imageIndexPath{
    return [NSIndexPath indexPathForRow:0 inSection:kPhotoSection];
}


@end
