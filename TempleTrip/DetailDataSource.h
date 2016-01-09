//
//  DetailDataSource.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Temple;

@interface DetailDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>


- (instancetype) initWithImage: (UIImage *) newImage Temple: (Temple *) newTemple ManagedObjectContext: (NSManagedObjectContext *) newContext;

- (NSIndexPath *)imageIndexPath;

-(void) setScaledImageIfNeededWithWidth: (float) width;

+ (NSMutableDictionary*)scheduleDictFromEndowmentDictionary: (NSDictionary *) dictionary;

@property(strong, nonatomic) NSDictionary *scheduleDict;
@end
