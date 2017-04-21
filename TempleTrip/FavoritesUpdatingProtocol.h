//
//  FavoritesUpdatingProtocol.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 1/9/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Temple.h"

@protocol FavoritesUpdatingProtocol <NSObject>

-(void)favoritesDidUpdate;

@end
