//
//  ScheduleViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 11/2/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
@import EventKit;

@interface ScheduleViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *ScheduleTableView;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@property (strong, nonatomic) NSDictionary * scheduleDict;
@property (strong, nonatomic) NSString *templeName;
@property(nonatomic) NSArray *daysOfWeek;
@property(nonatomic) NSString *dayTapped;
@property(nonatomic) NSArray *today;
@property(nonatomic) NSString *location;

-(BOOL)dateIsToday:(NSDate*) date;

@end
