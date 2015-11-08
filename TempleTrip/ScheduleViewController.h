//
//  ScheduleViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 11/2/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSDictionary * scheduleDict;
@property (strong, nonatomic) NSString *templeName;
@property(nonatomic) NSArray *daysOfWeek;
@property(nonatomic) NSString *dayTapped;
@property(nonatomic) NSArray *today;

@property (weak, nonatomic) IBOutlet UIPickerView *schedulePicker;

@end
