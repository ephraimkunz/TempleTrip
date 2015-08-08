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
@property (nonatomic, retain) NSDate * dedication;
@property (nonatomic, retain) NSString * place;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * imageLink;

@end
