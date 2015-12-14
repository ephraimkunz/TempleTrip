//
//  ScheduleViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 11/2/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "ScheduleViewController.h"
#import "DetailTableViewController.h"

@implementation ScheduleViewController{
	NSArray* upcomingDates;
	EKEventStore *store;
}

#pragma mark - ViewLifeCycle

-(void) viewDidLoad{
    [super viewDidLoad];
	self.today = self.scheduleDict[self.dayTapped];
	[self schedulePicker].delegate = self;
	upcomingDates = [ScheduleViewController getUpcomingDatesArrayWithDay: self.dayTapped count: 52 weekdays:self.daysOfWeek];
	
	store = [[EKEventStore alloc]init];
	[store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error){
		if (error != nil) {
			NSLog(@"There was an error granting access to Event entities:%@", error.description);
		}
	}];
	
	self.FullDateLabel.text = @"Choose a day and time";
}

#pragma mark -  PickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	switch (component) {
		case 0:
			return [upcomingDates count];
			break;
		case 1:
			return self.today.count;
			break;
			
		default:
			return 0; //Should never be hit
	}
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	switch (component) {
		case 0:{
			if (row == 0 && [self dateIsToday:upcomingDates[0]]) {
				return @"Today";
			}
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"EEEE dd MMM"];
			//[formatter setDateStyle:NSDateFormatterMediumStyle];
			
			NSString* formattedDate = [formatter stringFromDate:upcomingDates[row]];
			NSRange firstSpaceRange = [formattedDate rangeOfString:@" "];
			formattedDate = [NSString stringWithFormat:@"%@%@", [formattedDate substringToIndex:3], [formattedDate substringFromIndex:firstSpaceRange.location]];
			return formattedDate;
			break;
		}
		case 1:{
			NSString* militaryTime = self.today[row];
			return [DetailTableViewController getDisplayDate:militaryTime];
			break;
		}
		default:
			return @"Should never be hit";
	}
}

#pragma mark - PickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	NSDate *selectedDate;
	NSString *time;
	
	if (component == 0) {
		selectedDate = upcomingDates[row];
	}
	else{
		selectedDate = upcomingDates[[pickerView selectedRowInComponent:0]];
	}
	
	
	if (component == 1) {
		time = self.today[row];
	}
	else{
		time = self.today[[self.schedulePicker selectedRowInComponent:1]];
	}
	
	NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	
	NSString *labelText = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:selectedDate], [DetailTableViewController getDisplayDate:time]];
	
	self.FullDateLabel.text = labelText;
}


#pragma mark - Class Methods

+(NSArray *)getUpcomingDatesArrayWithDay:(NSString *)startDay count:(NSInteger)numToCalculate weekdays:(NSArray*) weekdays{
	NSMutableArray* results = [[NSMutableArray alloc]init];
	
	//Get the current weekday number
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
	long realWeekday = [comps weekday];
	long viewingWeekday = [weekdays indexOfObjectIdenticalTo:startDay] + 2; //To compare with realWeekDay, we can't be 0 indexed and we have to start on Sunday.
	
	if (viewingWeekday < realWeekday) {
		viewingWeekday += 7;
	}
	long daysAhead = viewingWeekday - realWeekday;
	
	NSDateComponents* comps2 = [NSDateComponents new];
	comps2.day	= daysAhead;
	
	NSDate* first = [[NSCalendar currentCalendar]dateByAddingComponents:comps2 toDate:[NSDate date] options:0];
	[results addObject:first];
	
	//Get the calendar date of the next weekday for the view.
	
	for (int i = 0; i < numToCalculate - 1; ++i) {
		NSDateComponents *comps3 = [NSDateComponents new];
		comps3.day = 7; //Add each one exactly one week out.
		NSDate* weekAhead = [[NSCalendar currentCalendar]dateByAddingComponents:comps3 toDate:results[i] options:0];
		[results addObject:weekAhead];
	}
	return results;
}


#pragma mark - IBActions

- (IBAction)cancelTapped:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTapped:(id)sender {
	EKEvent *event = [EKEvent eventWithEventStore:store];
	event.title = [NSString stringWithFormat:@"Trip to %@ temple", self.templeName];
	
	NSDate *dateWithoutTime = upcomingDates[[self.schedulePicker selectedRowInComponent:0]];
	NSString * time = self.today[[self.schedulePicker selectedRowInComponent:1]];
	long colonLocation = [time rangeOfString:@":"].location;
	NSInteger hour = [[time substringToIndex:colonLocation]integerValue];
	NSInteger minute = [[time substringFromIndex:colonLocation + 1]integerValue];
	
	NSDate *totalDate = [[NSCalendar currentCalendar]dateBySettingHour:hour minute:minute second:0 ofDate:dateWithoutTime options:0];
	
	event.startDate = totalDate;
	
	double secondsInTwoHours = 60 * 60 * 2;
	event.endDate = [event.startDate dateByAddingTimeInterval: (NSTimeInterval)secondsInTwoHours];
	
	event.calendar = [store defaultCalendarForNewEvents];
	
	
	//Confirm with user
	UIAlertController * confirmAddEventController = [UIAlertController alertControllerWithTitle:@"Add to calendar" message:@"Are you sure you want to add this event to your calendar?" preferredStyle:UIAlertControllerStyleAlert];
	
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

@end
