//
//  DetailDataSource.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FavoritesUpdatingProtocol.h"

@protocol LaunchWebViewProtocol;
@class Temple;

@interface DetailDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) id<FavoritesUpdatingProtocol> delegate;

- (instancetype) initWithTemple: (Temple *) newTemple ManagedObjectContext: (NSManagedObjectContext *) newContext;
- (instancetype) initWithImage: (UIImage*)Image Temple: (Temple *) newTemple ManagedObjectContext: (NSManagedObjectContext *) newContext NS_DESIGNATED_INITIALIZER;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSIndexPath *imageIndexPath;

-(void) setScaledImageIfNeededWithWidth: (float) width;

+ (NSMutableDictionary*)scheduleDictFromEndowmentDictionary: (NSDictionary *) dictionary;

@property(strong, nonatomic) NSDictionary *scheduleDict;
@property(strong, nonatomic) UIImage *image;
@property(strong, nonatomic) id<LaunchWebViewProtocol> webDelegate;
@end
