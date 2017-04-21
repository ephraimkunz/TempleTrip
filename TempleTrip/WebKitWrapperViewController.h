//
//  WebKitWrapperViewController.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 9/17/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface WebKitWrapperViewController : UIViewController

@property(nonatomic) WKWebView *webView;

- (void)loadHTMLString: (NSString*) html;

@end
