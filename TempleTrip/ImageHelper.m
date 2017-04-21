//
//  ImageHelper.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 12/25/15.
//  Copyright © 2015 Ephraim Kunz. All rights reserved.
//

#import "ImageHelper.h"

@implementation ImageHelper

+ (UIImage *)imageWithImage: (UIImage *)sourceImage scaledToWidth: (float) width{
    if(sourceImage == nil){ //May happen if the async fetch hasn't finished yet.
        return nil;
    }
    float oldWidth = sourceImage.size.width;
    float scaleFactor = width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)getImageFromWebForTemple: (Temple *) temple{
    NSURL *url = [NSURL URLWithString: temple.imageLink];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:data];
    return img;
}

+ (NSString *)getCacheImagePathForTemple: (Temple *) temple withContext: (NSManagedObjectContext *) context{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = [NSEntityDescription entityForName:@"Temple" inManagedObjectContext: context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", temple.name];
    request.predicate = predicate;
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    return [results[0] valueForKey:@"localImagePath"];
}


+ (UIImage *)getImageFromWebOrCacheForTemple:(Temple *)temple withContext: (NSManagedObjectContext *) context{
    // Determine whether or not the image is cached. If cached, get from file. Else, fetch it from the web.
    
    if ([ImageHelper getCacheImagePathForTemple:temple withContext:context] == nil) {
        return [ImageHelper getImageFromWebForTemple:temple];
    }
    else{
        NSString *path = [ImageHelper getCacheImagePathForTemple:temple withContext:context];
        UIImage *cachedImage = [UIImage imageWithContentsOfFile:path];
        if (cachedImage == nil) {
            //Something went horribly wrong if this line is executed. Core data says we have a cached image but trying to get it fails. Should only happen when testing, when we reload the app and Core Data
            //has the old path but the filesystem is not preserved.
            NSLog(@"Failure to get cached image with path: %@. Now trying to fetch from web.", path);
            return [ImageHelper getImageFromWebForTemple:temple];
        }
        else{
            return cachedImage;
        }
    }
}

+ (void)saveTempleImage: (UIImage*)image forTemple: (Temple *) temple withContext: (NSManagedObjectContext *) context{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0]; // Path to picture directory.
    
    NSString *imagePath =[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",[temple.name stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    
    //Save new path to CoreData.
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    request.entity = [NSEntityDescription entityForName:@"Temple" inManagedObjectContext:context];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", temple.name];
    request.predicate = predicate;
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    
    [results[0] setValue:imagePath forKey:@"localImagePath"];
    [context save:nil];
    
    //Convert and save the image itself.
    //Profiling shows that we should do this in an operation queue so we don't take so long.
    NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        [imageData writeToFile:imagePath atomically:NO];
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:block];
}


@end
