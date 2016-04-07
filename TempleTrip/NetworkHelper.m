//
//  NetworkHelper.m
//  TempleTrip
//
//  Created by Ephraim Kunz on 4/5/16.
//  Copyright © 2016 Ephraim Kunz. All rights reserved.
//

#import "NetworkHelper.h"

@implementation NetworkHelper

+ (void) fetchAndUpdateTemplesFromParseWithManagedObjectContext:(NSManagedObjectContext *) context completionBlock:(void(^)(void)) block{
    //Get the new temple JSON from the server
    PFQuery *allTemplesQuery = [PFQuery queryWithClassName:@"Temple"];
    [allTemplesQuery setLimit:1000];
    [allTemplesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSLog(@"Success fetching %lu temples from Parse server", (unsigned long)[objects count]);
            NSInteger successUpdated = 0;
            
            //Load them into core data. If there is a temple in the JSON that we don't have, create it.
            for(PFObject *temple in objects){
                
                NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
                [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", temple[@"name"]]];
                NSError *fetchError;
                NSArray *fetchedTemples;
                if (!(fetchedTemples = [context executeFetchRequest:request error:&fetchError])){
                    NSLog(@"Error fetching core data temple for updated temple from Parse with name: %@, error: %@. Maybe it is a new temple.", temple[@"name"], fetchError.description);
                }
                
                if (fetchedTemples.count > 1) {
                    NSLog(@"More than one temple in Core Data for name: %@", temple[@"name"]);
                }
                
                Temple *cdTemple;
                
                if (fetchedTemples.count == 0) { //New temple, we need to add it the DB.
                    cdTemple = [NSEntityDescription insertNewObjectForEntityForName:@"Temple" inManagedObjectContext:context];
                    cdTemple.name = [temple valueForKey:@"name"];
                }
                else{ //Update an existing temple.
                    cdTemple = fetchedTemples[0];
                }
                cdTemple.dedication = [temple valueForKey:@"dedication"];
                cdTemple.place = [temple valueForKey:@"place"];
                cdTemple.address = [temple valueForKey:@"address"];
                cdTemple.imageLink = [temple valueForKey:@"photoLink"];
                cdTemple.telephone = [temple valueForKey:@"telephone"];
                cdTemple.endowmentSchedule = [temple valueForKey:@"endowmentSchedule"];
                cdTemple.firstLetter = [[temple valueForKey:@"name"] substringToIndex:1];
                cdTemple.webViewUrl = [temple valueForKey:@"detailLink"];
                
                NSString *firstTwoLetters = [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Cafeteria"] substringToIndex:2] == nil ? @"No" : [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Cafeteria"] substringToIndex:2];
                cdTemple.hasCafeteria = ![firstTwoLetters isEqualToString:@"No"];
                
                firstTwoLetters = [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Clothing"] substringToIndex:2] == nil ? @"No" : [[[temple valueForKey:@"servicesAvailable"]valueForKey:@"Clothing"] substringToIndex:2];
                cdTemple.hasClothing = ![firstTwoLetters isEqualToString:@"No"];
                
                NSMutableArray *closedDatesArray = [[NSMutableArray alloc]initWithArray:[[temple valueForKey:@"closures"]valueForKey:@"Maintenance Dates"]];
                [closedDatesArray addObjectsFromArray:[[temple valueForKey:@"closures"]valueForKey:@"Other Dates"]];
                cdTemple.closedDates = [closedDatesArray copy];
                
                cdTemple.existsOnServer = YES;
                
                NSError *saveError;
                if (![context save:&saveError]){
                    NSLog(@"Error saving updated temple with name: %@ to CD, %@", cdTemple.name, saveError.description);
                }
                else{
                    successUpdated ++;
                }
                
            }
            NSLog(@"Success updating or adding %ld out of %lu temples in core data from Parse server", (long)successUpdated, (unsigned long)[objects count]);
            
            //Remove temples not on the server;
            NSFetchRequest *toDelete = [[NSFetchRequest alloc]initWithEntityName:@"Temple"];
            [toDelete setPredicate:[NSPredicate predicateWithFormat:@"existsOnServer = NO"]];
            NSArray *notOnServer;
            if((notOnServer = [context executeFetchRequest:toDelete error:nil])){
                NSLog(@"Success deleting %ld temples in core data", (unsigned long)notOnServer.count);
                for(Temple *temple in notOnServer){
                    [context deleteObject:temple];
                }
            }
            [context save:nil];
            
            //Reset existsOnServer to NO for everything
            NSArray *everything = [context executeFetchRequest:[[NSFetchRequest alloc] initWithEntityName:@"Temple"] error:nil];
            for(Temple* temple in everything){
                temple.existsOnServer = NO;
            }
            [context save:nil];
        }
        else{
            NSLog(@"Error fetching all temples from the server");
        }
        
        block();
    }];
}

@end
