//
//  AsyncDataFeth.h
//  DhakaFoodies
//
//  Created by Roni Alam on 5/29/16.
//  Copyright © 2016 AnnanovasIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AsyncDataDelegate <NSObject>

@optional
- (void) asyncDataLoadedForId:(NSString*)Id withResults:(NSString*) resultstr;
- (void) asyncDataLoadedForId:(NSString*)Id withStatus:(Boolean) isTrue;

- (void) asyncDataLoadedForId:(NSString*)Id withStatus:(Boolean) isTrue forReason:(NSString*)reason;

- (void) asyncDataLoaded:(int)index withDitionary:(NSDictionary*) resultDic;
- (void) asyncDataLoaded:(int)index withArray:(NSArray*) resultArray;


@end

@interface AsyncDataFetch : NSObject {
    
    int index;
    NSString *Id;
    NSString *sqlQuery;
    id<AsyncDataDelegate> asyncDataDelegate;
    
}

@property (nonatomic, assign) int index;
@property (nonatomic, retain) NSString *sqlQuery;
@property (nonatomic, retain) NSString *Id;

@property  id<AsyncDataDelegate> asyncDataDelegate;

- (void) excuteBookCategoriesQuery;

@end
