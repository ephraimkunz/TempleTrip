//
//  Temple.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 8/7/15.
//  Copyright (c) 2015 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface Temple : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * dedication;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * imageLink;
@property (nonatomic, retain) NSString * telephone;
@property (nonatomic, retain) NSDictionary * endowmentSchedule;
@property (nonatomic, retain) NSArray * closedDates;
@property (nonatomic, retain) NSString * firstLetter;
@property (nonatomic, retain) NSString * localImagePath;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic) BOOL hasCafeteria;
@property (nonatomic) BOOL hasClothing;
@property (nonatomic) BOOL existsOnServer;


@end
