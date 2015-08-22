//
//  TempleDetailTableViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/12/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Temple.h"

@interface TempleDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *detailImageView;
@property(strong, nonatomic) Temple *currentTemple;
@end
