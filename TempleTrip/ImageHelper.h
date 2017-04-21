//
//  ImageHelper.h
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Temple.h"

@interface ImageHelper : NSObject

+ (UIImage *)imageWithImage: (UIImage *)sourceImage scaledToWidth: (float) width;
+ (UIImage *)getImageFromWebOrCacheForTemple: (Temple *) temple withContext: (NSManagedObjectContext *) context;
+ (UIImage *)getImageFromWebForTemple: (Temple *) temple;
+ (NSString *)getCacheImagePathForTemple: (Temple *) temple withContext: (NSManagedObjectContext *) context;
+ (void)saveTempleImage: (UIImage*)image forTemple: (Temple *) temple withContext: (NSManagedObjectContext *) context;
@end
