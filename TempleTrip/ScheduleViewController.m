//
//  ScheduleViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 11/2/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DetailTableViewController.h"
#import "TempleTrip-Swift.h"
#import "DateTimeHelper.h"

#define NUM_DAYS_IN_PICKER 52 // One year ahead
#define DATE_COMPONENT 0
#define TIME_COMPONENT 1

@implementation ScheduleViewController{
	NSArray* upcomingDates;
	EKEventStore *store;
    NSString * eventTitle;
    NSString * eventLocation; // Will change if the user modifies. So we keep this instance variable while the property will remain unchanged.
    BOOL shouldRemindForEvent;
    UITextField *textFieldToResign; // Holds a reference to the text field that we will resign when the user scrolls or taps outside of the currently edited text field.
    NSArray *closedDates;
}

#pragma mark - ViewLifeCycle

-(void) viewDidLoad{
    [super viewDidLoad];
    
    self.scheduleTableView.delegate = self;
    self.scheduleTableView.dataSource = self;
    
    closedDates = [DateTimeHelper getAllDatesFromStringArray:self.currentTemple.closedDates];

    eventTitle = [NSString stringWithFormat:@"Trip to %@ temple", self.currentTemple.name];
    eventLocation = self.currentTemple.address;
    shouldRemindForEvent = NO;
    
    self.sessionTimesForToday = self.scheduleDict[self.dayTapped];
    
    upcomingDates = [DateTimeHelper getUpcomingDatesArrayWithDay:self.dayTapped count:NUM_DAYS_IN_PICKER];
	
	store = [[EKEventStore alloc]init];
	[store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
		if (error != nil) {
			NSLog(@"There was an error granting access to Event entities:%@", error.description);
		}
	}];
    
    //Set up tap gesture to resign the textField.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(resignActiveTextField)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark -  PickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return upcomingDates.count;
			break;
		case 1:
			return self.sessionTimesForToday.count;
			break;
			
		default:
			return 0; //Should never be hit
	}
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
	switch (component) {
		case DATE_COMPONENT:{
			if (row == 0 && [self dateIsToday:upcomingDates[0]]) {
                return [[NSAttributedString alloc]initWithString:@"Today"];
			}
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			formatter.dateFormat = @"EEEE dd MMM";
			
			NSString* formattedDate = [formatter stringFromDate:upcomingDates[row]];
			NSRange firstSpaceRange = [formattedDate rangeOfString:@" "];
			formattedDate = [NSString stringWithFormat:@"%@%@", [formattedDate substringToIndex:3], [formattedDate substringFromIndex:firstSpaceRange.location]];
            
            NSDate *currentRow = upcomingDates[row];
            if ([self isClosedDate:currentRow]) {
                return [[NSAttributedString alloc]initWithString:formattedDate attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
            }
			return [[NSAttributedString alloc]initWithString:formattedDate];
			break;
		}
		case TIME_COMPONENT:{
			NSString* militaryTime = self.sessionTimesForToday[row];
			return [[NSAttributedString alloc] initWithString:[DateTimeHelper getDisplayDateWithMilitaryTime:militaryTime]];
			break;
		}
		default:
			return [[NSAttributedString alloc]initWithString:@"Should never be hit"];
	}
}

#pragma mark - PickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [self resignActiveTextField];

    //Handle closed days: scroll up or down to the next day.
    if(component == DATE_COMPONENT){
        NSDate *currentRow = upcomingDates[row];
        if([self isClosedDate:currentRow]){
            
//            if (row == 0)
//                [pickerView selectRow:row + 1 inComponent:component animated:YES];
//            else
//                [pickerView selectRow:row - 1 inComponent:component animated:YES];
            self.saveButton.enabled = NO;
        }
        else{
            self.saveButton.enabled = YES;
        }
    }
}

- (BOOL) isClosedDate:(NSDate *)aDate{
    NSUInteger inClosedList = [closedDates indexOfObjectPassingTest:^BOOL(NSDate *obj, NSUInteger idx, BOOL *stop){
        return [DateTimeHelper datesAreEqual:obj Other:aDate];
    }];
    BOOL isClosed = (long)inClosedList != NSNotFound;
    return isClosed;
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
        case 1:
            return 2;
            break;
        default:
            return 5000; //Bad deal if we hit this.
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 0) {
        return 200;
    }
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section){
        case 0:{
            if (indexPath.row == 0) {
                EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditLabelCell"];
                cell.editableText.text = eventTitle;
                cell.editableText.placeholder = @"Title";
                cell.editableText.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else if(indexPath.row == 1){
                EditableTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EditLabelCell"];
                cell.editableText.text = eventLocation;
                cell.editableText.placeholder = @"Location";
                cell.editableText.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        case 1:{
            if (indexPath.row == 0) {
                SchedulePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SchedulePickerCell"];
                cell.SchedulePicker.dataSource = self;
                cell.SchedulePicker.delegate = self;
                return cell;
            }
            else{
                return [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            }
        }
        default:{ //Bad news if we hit this
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
            cell.textLabel.text = @"Out of bounds index path";
            NSLog(@"Out of bounds index path with section: %ld, row: %ld", (long)indexPath.section, (long)indexPath.row);
            
            return cell;
        }
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Ensure that tapping the cells with textFields opens up editing, even if they didn't hit the exact field
    if (indexPath.section == 0) {
        EditableTextTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        textFieldToResign = cell.editableText;
        [textFieldToResign becomeFirstResponder];
        //[tableView deselectRowAtIndexPath:indexPath animated:YES]; Not needed since cell selection styles for this section set to none.
    }
    
    
    if(indexPath.section == 1 && indexPath.row == 1){
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        if(shouldRemindForEvent){
            shouldRemindForEvent = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.footerLabel.text = @"";
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        else{
            shouldRemindForEvent = YES;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            NSInteger minutesBeforeAlert = [[NSUserDefaults standardUserDefaults]integerForKey:@"alert_preference"];
            self.footerLabel.text = [NSString stringWithFormat:@"You will be alerted %@ before the session.", [self getAlertTimeLabel: minutesBeforeAlert]];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

-(NSString *)getAlertTimeLabel: (NSInteger)minutesBeforeAlert{
    switch (minutesBeforeAlert) {
        case 0:
            return @"right";
        case 5:
        case 15:
        case 30:
        case 45:
            return [NSString stringWithFormat:@"%ld minutes", (long)minutesBeforeAlert];
            break;
        
        case 60:
            return @"1 hour";
            break;
        case 120:
            return @"2 hours";
            break;
            
        case 1440:
            return @"1 day";
            break;
        case 2880:
            return @"2 days";
            break;
        default:
            NSLog(@"Error with undefined minutesBeforeAlert variable");
            return @"some time";
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 0) {
//        return NO;
//    }
    return YES;
}

#pragma mark - IBActions

- (IBAction)cancelTapped:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender {
	EKEvent *event = [EKEvent eventWithEventStore:store];
    
    event.title = eventTitle;
    event.location = eventLocation;
    event.calendar = store.defaultCalendarForNewEvents;
    
    //Add alarm if cell selected
    if (shouldRemindForEvent) {
        NSTimeInterval interval = -([[NSUserDefaults standardUserDefaults]integerForKey:@"alert_preference"] * 60); //Get seconds from minutes.
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset: interval];
        [event addAlarm:alarm];
    }
	
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    SchedulePickerTableViewCell *cell = [self.scheduleTableView cellForRowAtIndexPath:indexPath];
    
	NSDate *dateWithoutTime = upcomingDates[[cell.SchedulePicker selectedRowInComponent:0]];
	NSString * time = self.sessionTimesForToday[[cell.SchedulePicker selectedRowInComponent:1]];
	long colonLocation = [time rangeOfString:@":"].location;
	NSInteger hour = [time substringToIndex:colonLocation].integerValue;
	NSInteger minute = [time substringFromIndex:colonLocation + 1].integerValue;
	
	NSDate *totalDate = [[NSCalendar currentCalendar]dateBySettingHour:hour minute:minute second:0 ofDate:dateWithoutTime options:0];
	
	event.startDate = totalDate;
	double secondsInTwoHours = 60 * 60 * 2;
	event.endDate = [event.startDate dateByAddingTimeInterval: (NSTimeInterval)secondsInTwoHours];
	
	//Confirm with user
	UIAlertController * confirmAddEventController = [UIAlertController alertControllerWithTitle:@"Add to Calendar" message:@"Are you sure you want to add this event to your calendar?" preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
		
		[store saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	[confirmAddEventController addAction:cancel];
	[confirmAddEventController addAction:confirm];
	
	[self presentViewController:confirmAddEventController animated:YES completion:nil];
}


-(BOOL)dateIsToday: (NSDate*) date{
	NSCalendar *current = [NSCalendar currentCalendar];
	
	NSDateComponents *today = [current components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
	NSDateComponents *passedIn = [current components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
	
	return today.month == passedIn.month && today.year == passedIn.year && today.day == passedIn.day;
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    //Find out which text view this is.
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    EditableTextTableViewCell *titleCell = [self.scheduleTableView cellForRowAtIndexPath:path];
    path = [NSIndexPath indexPathForRow:1 inSection:0];
    
    EditableTextTableViewCell *locationCell = [self.scheduleTableView cellForRowAtIndexPath:path];
    if ([textField isEqual: titleCell.editableText]) {
        if (textField.text != eventTitle)
            eventTitle = textField.text;
    }
    else if([textField isEqual:locationCell.editableText]){
        if(textField.text != eventLocation)
            eventLocation = textField.text;
    }
    else{
        NSLog(@"Error occured when unrecognized textField finished editing.");
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textFieldToResign = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:NO];
    [textField resignFirstResponder];
    return YES;
}

-(void) resignActiveTextField{
    [textFieldToResign resignFirstResponder];
}


@end
