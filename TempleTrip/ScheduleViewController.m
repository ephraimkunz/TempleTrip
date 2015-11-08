//
//  ScheduleViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 11/2/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "ScheduleViewController.h"

@implementation ScheduleViewController

#pragma mark - ViewLifeCycle

-(void) viewDidLoad{
	self.today = self.scheduleDict[self.dayTapped];
}

#pragma mark -  PickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return self.today.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	return self.today[row];
}

#pragma mark - IBActions

- (IBAction)cancelTapped:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}


@end
