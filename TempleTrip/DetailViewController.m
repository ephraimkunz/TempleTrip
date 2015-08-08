//
//  DetailViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/6/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    self.DetailViewTopLabel.title = self.currentTemple.name;
    self.addressLabel.text = self.currentTemple.address;
    self.placeLabel.text = self.currentTemple.place;
    self.addressLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //Get the image view from the Internet.
    NSURL *url = [NSURL URLWithString:self.currentTemple.imageLink];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    self.templeImage.image = img;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
