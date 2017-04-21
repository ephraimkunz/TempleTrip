//
//  WebKitWrapperViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 9/17/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import "WebKitWrapperViewController.h"

@interface WebKitWrapperViewController ()

@end

@implementation WebKitWrapperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Dedicatory Prayer";
    // Do any additional setup after loading the view.
}

-(void) loadView{
    self.webView = [[WKWebView alloc]init];
    self.view = self.webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadHTMLString: (NSString*) html{
    [(WKWebView *)self.view loadHTMLString:html baseURL:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
