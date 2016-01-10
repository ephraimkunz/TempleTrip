//
//  GlobalSplitViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 1/9/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import "GlobalSplitViewController.h"

@interface GlobalSplitViewController ()

@end

@implementation GlobalSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    //self.preferredDisplayMode = UISplitViewControllerDisplayModeAutomatic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SplitView Controller Delegate

-(BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController{
    //Ensure that on smaller devices we show the Master View at app launch.
    //http://stackoverflow.com/questions/25875618/uisplitviewcontroller-in-portrait-on-iphone-shows-detail-vc-instead-of-master
    return YES;
}

//-(UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc{
//    if (svc.displayMode == UISplitViewControllerDisplayModePrimaryOverlay || svc.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
//        return UISplitViewControllerDisplayModeAllVisible;
//    }
//    return UISplitViewControllerDisplayModePrimaryHidden;
//}


@end
