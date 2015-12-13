//
//  FavoritesDelegate.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/12/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//
#include "Temple.h"


@protocol FavoritesDelegate

-(void)addedToFavorites:(Temple*) temple;
-(void)removedFromFavorites:(Temple*) temple;

@end
