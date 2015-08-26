//
//  TempleDetailTableViewController.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/12/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import "TempleDetailViewController.h"

@implementation TempleDetailViewController

-(void) configureView{
    //Get the image view from the Internet.
    NSURL *url = [NSURL URLWithString:self.currentTemple.imageLink];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    self.detailImageView.image = img;
	self.navigationItem.title = self.currentTemple.name;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    [self configureView];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    [cell layoutSubviews];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        //Get the image view from the Internet.
        NSURL *url = [NSURL URLWithString:self.currentTemple.imageLink];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data];

        cell.imageView.image = img;
    }
}

#pragma mark - Segues




@end
