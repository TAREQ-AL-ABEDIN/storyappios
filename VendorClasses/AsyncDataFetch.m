//
//  AsyncDataFeth.m
//  DhakaFoodies
//
//  Created by Roni Alam on 5/29/16.
//  Copyright © 2016 AnnanovasIT. All rights reserved.
//

#import "AsyncDataFetch.h"
//#import "MyQueryDBManager.h"
#import "AppDelegate.h"

@interface AsyncDataFetch ()

@end

@implementation AsyncDataFetch

@synthesize index, sqlQuery, Id;
@synthesize asyncDataDelegate;

- (void) excuteBookCategoriesQuery {
    
    [appDelegate.myAsyncDB inDatabase:^(FMDatabase *db) {
        
        FMResultSet *s = [db executeQuery:sqlQuery];
        NSMutableArray *results = nil;
        
        while ([s next]) {
            //retrieve values for each record
            
            if (results == nil) {
                results = [NSMutableArray arrayWithObject:[s resultDictionary]];
            }
            else{
                [results addObject:[s resultDictionary]];
            }
            
            
        }
        //[s close];
        
        [asyncDataDelegate asyncDataLoaded:index withArray:results];
        
    }];
    
}



@end
