//
//  MyQueryDBManager.m
//
//
//  Created by Roni Alam on 5/22/16.
//  Copyright © 2016 Roni Alam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "FMDB.h"
#import "MyQueryDBManager.h"
#import "AppDelegate.h"


@interface MyQueryDBManager (){
    int totalConnection;
    int totalAsyncConnection;
    FMDatabase *myDB;
}

@property (nonatomic, retain)FMDatabase *myDB;

@end


@implementation MyQueryDBManager

@synthesize myDB;


+ (id)sharedManager {
    static MyQueryDBManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        NSArray *pathsDocument = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *uniquePath = [NSString stringWithFormat:@"%@/%@", [pathsDocument objectAtIndex:0], @"hiseb.sqlite"];
        totalConnection = 0;
        totalAsyncConnection = 0;
        
        //myDB = [FMDatabase databaseWithPath:uniquePath];
        myDB = [[FMDatabase alloc] initWithPath:uniquePath];
        //myAsyncDB = [FMDatabaseQueue databaseQueueWithPath:uniquePath];
        
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
    
    //[myDB ]
}


- (Boolean)openDB {
    
    if (totalConnection == 0){
        //[myDB open];
        
        if (![myDB open]) {
            
            NSLog(@"Cannot Open Database");
            return NO;
        }
    }
    
    totalConnection++;
    return YES;
}

- (void) closeDB {
   
    totalConnection--;
    if (totalConnection == 0)
        [myDB close];
}

- (Boolean) isTableExists:(NSString*) tableName {
    
    FMResultSet *s = [myDB executeQuery:[NSString stringWithFormat:@"select DISTINCT tbl_name from sqlite_master where tbl_name='%@'",tableName]];
    while ([s next]) {
        //retrieve values for each record
        NSLog(@"%@", [s objectForColumnName:@"tbl_name"]);
    }
    
    return false;
}

- (NSArray*) getTableColumns:(NSString*) tableName{
    FMResultSet *s = [myDB executeQuery:[NSString stringWithFormat:@" PRAGMA table_info('%@');",tableName]];
    
    NSMutableArray *columns = nil;
    while ([s next]) {
        //retrieve values for each record
        NSLog(@"%@", [s objectForColumnName:@"name"]);
        if (columns == nil) {
            columns = [NSMutableArray arrayWithObject:[s objectForColumnName:@"name"]];
        }
        else{
            [columns addObject:[s objectForColumnName:@"name"]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:columns];
    return array;
}

#pragma mark - Queries

- (NSString*)getEnabledCategories{
    NSString *qStr = [NSString stringWithFormat:@"select ZCATEGORIES.* from ZCATEGORIES where ZCATEGORIES.ZFILTERENABLE = '%@'",@"YES"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSString *catIds = @"";
    
    if(results.count > 0){
        for(NSDictionary *info in results){
            if([catIds length] > 0)
                catIds = [catIds stringByAppendingString:@","];
            
            catIds = [catIds stringByAppendingString:[NSString stringWithFormat:@"%d",[[info objectForKey:@"ZCID"] intValue]]];
        }
    }
    
    return catIds;
}


- (NSArray*)getCategoriesWithSearchKey:(NSString *)searchKey{
    
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    //NSLog(@"searchKey : %@",searchKey);
    
    NSString *qStr = [NSString stringWithFormat:@"select * from categories where  categories.name LIKE '%@' order by categories.name",searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getCompaniesWithSearchKey:(NSString *)searchKey{
    
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    //NSLog(@"searchKey : %@",searchKey);
    
    NSString *qStr = [NSString stringWithFormat:@"select * from companies where companies.company_name LIKE '%@' order by companies.company_name",searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getCustomersWithSearchKey:(NSString *)searchKey{
    
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    //NSLog(@"searchKey : %@",searchKey);
    
    NSString *qStr = [NSString stringWithFormat:@"select * from customer where (customer.name LIKE '%@' OR customer.phone LIKE '%@') order by customer.name",searchKey,searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSDictionary*)getCompanyDetails:(NSString *)companyId{
    NSString *qStr = [NSString stringWithFormat:@"select companies.* from companies where companies.cid = '%@'", companyId];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSDictionary*)getCustomerDetails:(NSString *)customerId{
    NSString *qStr = [NSString stringWithFormat:@"select customer.* from customer where customer.cid = '%@'", customerId];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSArray*)getInventoryForCategories:(NSString *)catIds withSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"select receive.*,my_product.name, my_product.image,my_product.pcode, my_product.purchase_price,my_product.sale_price,my_product.product_description from receive,my_product,myproduct_category where receive.mpid = my_product.mpid and myproduct_category.mpid=my_product.mpid and myproduct_category.cat_id in (%@) and (my_product.name like '%@' OR my_product.pCode like '%@') order by my_product.name", catIds,searchKey,searchKey];
    
    NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}


- (NSArray*)getAllInventoryWithSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"select receive.*,my_product.name, my_product.image,my_product.pcode, my_product.purchase_price,my_product.sale_price,my_product.product_description from receive,my_product where receive.mpid = my_product.mpid and (my_product.name like '%@' OR my_product.pCode like '%@') order by my_product.name",searchKey,searchKey];
    
    NSLog(@"qStr : %@",qStr);

    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getRecieveBatchesWithSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"Select receive_batch.batch_id, receive_batch.date,companies.company_name from receive_batch,companies where receive_batch.company_id=companies.cid and companies.company_name like '%@' order by companies.company_name",searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

/*- (float)getRecieveBatchTotalAmount:(NSString *)batchId{
    
    NSString *qStr = [NSString stringWithFormat:@"Select ZRECEIVEBATCHITEMS.ZBID, SUM(ZITEM.ZPRICE * ZITEM.ZQUANTITY) as total from ZITEM,ZRECEIVEBATCHITEMS where ZRECEIVEBATCHITEMS.ZUSERID = '%@' and ZRECEIVEBATCHITEMS.ZPID=ZITEM.ZPID and  ZRECEIVEBATCHITEMS.ZBID = %@ Group by ZRECEIVEBATCHITEMS.ZBID",[prefs objectForKey:@"userId"],batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        return [[info objectForKey:@"total"] floatValue];
    }
    
    return 0.0;
}*/

- (NSArray*)getRecieveItemsForBatch:(NSString *)batchId{
    
    NSString *qStr = [NSString stringWithFormat:@"Select receive_batch.batch_id, receive.quantity, receive.purchase_price, my_product.name, my_product.image, my_product.pcode, receive.note as product_description, my_product.sale_price from receive,receive_batch,my_product where receive_batch.batch_id=receive.batch_id and receive.mpid=my_product.mpid and receive_batch.batch_id='%@'",batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getSaleItemsForBatch:(NSString *)batchId{
    
    NSString *qStr = [NSString stringWithFormat:@"Select sale_batch.batch_id, sales.quantity, sales.purchase_price,sales.sale_price, my_product.name, my_product.image, my_product.pcode, my_product.product_description from sales,sale_batch,my_product where sale_batch.batch_id=sales.batch_id and sales.mpid=my_product.mpid and sale_batch.batch_id='%@'",batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getMyProductListWithSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"select * from my_product where (my_product.name LIKE '%@' OR my_product.pCode LIKE '%@') order by my_product.name",searchKey,searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getSaleProductListWithSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"select * from my_product where my_product.sale_price > 0  and (my_product.name LIKE '%@' and my_product.pCode LIKE '%@') order by my_product.name",searchKey,searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSDictionary *)getMyProductInfo:(NSString *)productCode{
    
    NSString *addedString = @"";
    
    if (![productCode hasPrefix:@"0"] && [productCode length] > 1) {
        addedString = [@"0" stringByAppendingString:productCode];
    }
    
    NSString *qStr = [NSString stringWithFormat:@"Select my_product.* from my_product where (my_product.pcode = '%@' or my_product.pcode = '%@')", productCode,addedString];
    NSLog(@"qStr : %@",qStr);
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSArray*)getSaleBatchesWithSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"Select sale_batch.batch_id, sale_batch.date,customer.name from sale_batch,customer where sale_batch.customer_id=customer.cid and customer.name like '%@' order by sale_batch.batch_id desc",searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

/*- (float)getSaleBatchTotalAmount:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select ZSALEBATCHITEMS.ZBID, SUM(ZSALES.ZPRICE * ZSALES.ZPQUANTITY) as total from ZSALES,ZSALEBATCHITEMS where ZSALES.ZUSERID = '%@' and ZSALEBATCHITEMS.ZPID=ZSALES.ZPID  and ZSALEBATCHITEMS.ZBID = '%@' Group by ZSALEBATCHITEMS.ZBID",[prefs objectForKey:@"userId"],batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"total"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"total"] floatValue];
    }
    
    return 0.0;
}*/

#pragma mark - Receive Summery

- (int)getTotalReceiveItems{
    
    NSString *qStr = @"Select SUM(receive.quantity) totalItems from receive";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalItems"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalItems"] floatValue];
    }
    
    return 0;
}

- (int)getTotalReceiveItemsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(receive.quantity) totalItems from receive,receive_batch where receive.batch_id = receive_batch.batch_id and (receive_batch.date >= %d and receive_batch.date <= %d)",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalItems"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalItems"] floatValue];
    }
    
    return 0;
}

- (float)getReceiveTotalPurchaseAmount{
    NSString *qStr = @"Select SUM(receive.purchase_price*receive.quantity) totalReceive from receive";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalPurchaseAmountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(receive.purchase_price*receive.quantity) totalReceive from receive,receive_batch where receive.batch_id = receive_batch.batch_id and (receive_batch.date >= %d and receive_batch.date <= %d)",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalCashPaid{
    NSString *qStr = @"Select SUM(transactions.amount) as totalCashPaid from transactions where transactions.company_id > 0 and (transactions.transaction_note='cashOut' and transactions.transaction_type='debit')";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashPaid"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalCashPaidFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCashPaid from transactions where transactions.company_id > 0 and (transactions.date >= %d and transactions.date <= %d) and (transactions.transaction_note='cashOut' and transactions.transaction_type='debit')",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashPaid"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalPaid{
    NSString *qStr = @"Select SUM(transactions.amount) as totalPaid from transactions where transactions.company_id > 0 and  ((transactions.transaction_note='cashOut' and transactions.transaction_type='debit') or (transactions.transaction_note='discount' and transactions.transaction_type='credit'))";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalPaid"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalPaidFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalPaid from transactions where transactions.company_id > 0 and (transactions.date >= %d and transactions.date <= %d) and  ((transactions.transaction_note='cashOut' and transactions.transaction_type='debit') or (transactions.transaction_note='discount' and transactions.transaction_type='credit'))",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalPaid"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalDiscount{
    NSString *qStr = @"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.company_id > 0 and  (transactions.transaction_note='discount' and transactions.transaction_type='credit')";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalDiscountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.company_id > 0 and (transactions.date >= %d and transactions.date <= %d) and  (transactions.transaction_note='discount' and transactions.transaction_type='credit')",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}


- (NSArray*)getRecieveBatchList{
    NSString *qStr = @"Select companies.company_name, companies.cid, receive_batch.batch_id, receive_batch.date from receive_batch, companies where receive_batch.company_id=companies.cid order by receive_batch.date DESC";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getRecieveBatchListFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select companies.company_name, companies.cid, receive_batch.batch_id, receive_batch.date from receive_batch, companies where receive_batch.company_id=companies.cid and (receive_batch.date >= %d and receive_batch.date <= %d) order by receive_batch.date DESC",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getAllTransactions{
    NSString *qStr = @"Select transactions.* from transactions where (transactions.company_id > 0 or transactions.customer_id > 0) order by transactions.date DESC";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getAllTransactionsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;

    NSLog(@"From : %@ <=====> To : %@",fromDate,toDate);
    NSLog(@"From : %d <=====> To : %d",fromTimeStamp,toTimeStamp);
    
    NSString *qStr = [NSString stringWithFormat:@"Select transactions.* from transactions where (transactions.date >= %d and transactions.date <= %d) order by transactions.date DESC",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getRecieveTransactions{
    NSString *qStr = @"Select transactions.* from transactions where transactions.company_id > 0 order by transactions.date DESC";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getRecieveTransactionsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select transactions.* from transactions where transactions.company_id > 0 and (transactions.date >= %d and transactions.date <= %d) order by transactions.date DESC",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}


- (NSArray*)getSaleTransactions{
    NSString *qStr = @"Select transactions.* from transactions where transactions.customer_id > 0 order by transactions.date DESC";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getSaleTransactionsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select transactions.* from transactions where transactions.customer_id > 0 and (transactions.date >= %d and transactions.date <= %d) order by transactions.date DESC",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSDictionary*)getReceiveBatchsAdditionalInfo:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(receive.purchase_price*receive.quantity) as purchaseAmount, SUM(receive.quantity) as totalItem from receive where receive.batch_id='%@'", batchId];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

#pragma mark - Receive summery for company

- (float)getReceiveTotalPurchaseAmount:(NSString *)companyId{
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(receive.purchase_price*receive.quantity) as totalReceive from receive, receive_batch where receive_batch.batch_id = receive.batch_id and receive_batch.company_id='%@'", companyId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalCashPaid:(NSString *)companyId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCashPaid from transactions where transactions.company_id='%@'  and  (transactions.transaction_note='cashOut' and transactions.transaction_type='debit')", companyId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashPaid"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalPaid:(NSString *)companyId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalPaid from transactions where transactions.company_id ='%@' and  ((transactions.transaction_note='cashOut' and transactions.transaction_type='debit') or (transactions.transaction_note='discount' and transactions.transaction_type='credit'))", companyId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalPaid"] floatValue];
    }
    
    return 0.0;
}

- (float)getReceiveTotalDiscount:(NSString *)companyId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.company_id = '%@' and (transactions.transaction_note='discount' and transactions.transaction_type='credit')", companyId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

- (NSArray*)getRecieveBatchList:(NSString *)companyId{

    NSString *qStr = [NSString stringWithFormat:@"Select companies.company_name, receive_batch.batch_id, receive_batch.date from receive_batch, companies where receive_batch.company_id=companies.cid and companies.cid='%@'",companyId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getRecieveItemListForCompany:(NSString *)companyId{
    NSString *qStr = [NSString stringWithFormat:@"Select companies.company_name, receive_batch.batch_id, receive_batch.date from receive_batch, companies where receive_batch.company_id=companies.cid and companies.cid='%@'",companyId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (float)getReceiveBatchPurchaseAmount:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(receive.purchase_price*receive.quantity) as totalReceive from receive, receive_batch where receive_batch.batch_id = receive.batch_id and receive_batch.batch_id='%@'", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}
- (float)getReceiveBatchCashPaid:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCashPaid from transactions where transactions.batch_id='%@'  and  (transactions.transaction_note='cashOut' and transactions.transaction_type='debit')", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashPaid"] floatValue];
    }
    
    return 0.0;
}
- (float)getReceiveBatchPaid:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalPaid from transactions where transactions.batch_id ='%@' and  ((transactions.transaction_note='cashOut' and transactions.transaction_type='debit') or (transactions.transaction_note='discount' and transactions.transaction_type='credit'))", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalPaid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalPaid"] floatValue];
    }
    
    return 0.0;
}
- (float)getReceiveBatchDiscount:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.batch_id = '%@' and (transactions.transaction_note='discount' and transactions.transaction_type='credit')", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

#pragma mark - Sales Summery

- (int)getTotalSaleItems{
    
    NSString *qStr = @"Select SUM(sales.quantity) totalItems from sales";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalItems"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalItems"] floatValue];
    }
    
    return 0;
}

- (int)getTotalSaleItemsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(sales.quantity) totalItems from sales,sale_batch where sales.batch_id = sale_batch.batch_id and (sale_batch.date >= %d and sale_batch.date <= %d)",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalItems"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalItems"] floatValue];
    }
    
    return 0;
}

- (float)getSaleTotalReceiveAmount{
    NSString *qStr = @"Select  SUM(sales.sale_price*sales.quantity) as totalSale from sales";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalSale"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalSale"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalReceiveAmountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(sales.sale_price*sales.quantity) as totalSale from sales,sale_batch where sales.batch_id = sale_batch.batch_id and (sale_batch.date >= %d and sale_batch.date <= %d)",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalSale"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalSale"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalCashReceive{
    NSString *qStr = @"Select SUM(transactions.amount) as totalCashReceive from transactions where transactions.customer_id > 0 and  (transactions.transaction_note='cashIn' and transactions.transaction_type='credit')";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalCashReceiveFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCashReceive from transactions where transactions.customer_id > 0 and (transactions.date >= %d and transactions.date <= %d) and  (transactions.transaction_note='cashIn' and transactions.transaction_type='credit')",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalReceive{
    NSString *qStr = @"Select SUM(transactions.amount) as totalReceive from transactions where transactions.customer_id > 0 and  ((transactions.transaction_note='cashIn' and transactions.transaction_type='credit') or (transactions.transaction_note='discount' and transactions.transaction_type='debit'))";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalReceiveFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalReceive from transactions where transactions.customer_id > 0 and (transactions.date >= %d and transactions.date <= %d) and  ((transactions.transaction_note='cashIn' and transactions.transaction_type='credit') or (transactions.transaction_note='discount' and transactions.transaction_type='debit'))",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalDiscount{
    NSString *qStr = @"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.customer_id > 0 and  (transactions.transaction_note='discount' and transactions.transaction_type='debit')";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalDiscountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.customer_id > 0 and (transactions.date >= %d and transactions.date <= %d) and  (transactions.transaction_note='discount' and transactions.transaction_type='debit')",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

- (NSArray*)getSaleBatchList{
    NSString *qStr = @"Select customer.name,customer.cid, sale_batch.batch_id, sale_batch.date from sale_batch, customer where sale_batch.customer_id=customer.cid order by sale_batch.date DESC";
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSArray*)getSaleBatchListFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select customer.name,customer.cid, sale_batch.batch_id, sale_batch.date from sale_batch, customer where sale_batch.customer_id=customer.cid and (sale_batch.date >= %d and sale_batch.date <= %d) order by sale_batch.date DESC",fromTimeStamp,toTimeStamp];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (NSDictionary*)getSaleBatchsAdditionalInfo:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(sales.sale_price* sales.quantity) as receiveAmount, SUM(sales.quantity) as totalItem from sales where sales.batch_id='%@'", batchId];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

#pragma mark - profit report

- (NSDictionary*)getSaleBatchsProfitInfo:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select  (SUM(sales.sale_price* sales.quantity) - SUM(sales.purchase_price* sales.quantity)) as profitAmount, SUM(sales.sale_price* sales.quantity) as saleAmount,SUM(sales.quantity) as totalItem from sales where sales.batch_id='%@'", batchId];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSDictionary*)getProfitInfo{
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(sales.sale_price* sales.quantity) as saleAmount,SUM(sales.purchase_price* sales.quantity) as purchaseAmount, SUM(sales.quantity) as totalItem from sales"];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSDictionary*)getProfitInfoFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    int fromTimeStamp = (int)[fromDate timeIntervalSince1970];
    int toTimeStamp = [toDate timeIntervalSince1970];
    toTimeStamp += 86400;
    
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(sales.sale_price* sales.quantity) as saleAmount,SUM(sales.purchase_price* sales.quantity) as purchaseAmount, SUM(sales.quantity) as totalItem from sales,sale_batch where sales.batch_id = sale_batch.batch_id and (sale_batch.date >= %d and sale_batch.date <= %d)",fromTimeStamp,toTimeStamp];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

#pragma mark - Sales Summery for customer

- (float)getSaleTotalReceiveAmount:(NSString *)customerId{
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(sales.sale_price*sales.quantity) as totalSale from sales, sale_batch where sale_batch.batch_id = sales.batch_id and sale_batch.customer_id='%@'", customerId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalSale"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalSale"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalCashReceive:(NSString *)customerId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCashReceive from transactions where transactions.customer_id='%@' and (transactions.transaction_note='cashIn' and transactions.transaction_type='credit')", customerId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalReceive:(NSString *)customerId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalReceive from transactions where transactions.customer_id ='%@' and ((transactions.transaction_note='cashIn' and transactions.transaction_type='credit') or (transactions.transaction_note='discount' and transactions.transaction_type='debit'))", customerId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleTotalDiscount:(NSString *)customerId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.customer_id = '%@' and (transactions.transaction_note='discount' and transactions.transaction_type='debit')", customerId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleBatchReceiveAmount:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select  SUM(sales.sale_price*sales.quantity) as totalSale from sales, sale_batch where sale_batch.batch_id = sales.batch_id and sale_batch.batch_id='%@'", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalSale"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalSale"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleBatchCashReceive:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCashReceive from transactions where transactions.batch_id='%@' and (transactions.transaction_note='cashIn' and transactions.transaction_type='credit')", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        if(![[info objectForKey:@"totalCashReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCashReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleBatchReceive:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalReceive from transactions where transactions.batch_id ='%@' and ((transactions.transaction_note='cashIn' and transactions.transaction_type='credit') or (transactions.transaction_note='discount' and transactions.transaction_type='debit'))", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalReceive"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalReceive"] floatValue];
    }
    
    return 0.0;
}

- (float)getSaleBatchDiscount:(NSString *)batchId{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalDiscount from transactions where transactions.batch_id = '%@' and (transactions.transaction_note='discount' and transactions.transaction_type='debit')", batchId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalDiscount"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalDiscount"] floatValue];
    }
    
    return 0.0;
}

- (NSArray*)getSaleItemListForCustomer:(NSString *)customerId{
    NSString *qStr = [NSString stringWithFormat:@"Select customer.name, sale_batch.batch_id, sale_batch.date from sale_batch, customer where sale_batch.customer_id=customer.cid and customer.cid='%@'",customerId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

#pragma mark - additional helpers

- (NSDictionary*)getCategoryOfProduct:(NSString *)productId{
    
    NSString *qStr = [NSString stringWithFormat:@"Select categories.*,myproduct_category.rowid from categories,myproduct_category where categories.cat_id = myproduct_category.cat_id and myproduct_category.mpid = '%@'", productId];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSDictionary*)getBalanceInfoForCompanyId:(NSString *)cid{
    
    NSString *qStr = [NSString stringWithFormat:@"SELECT final_balance.* from final_balance where final_balance.company_id = '%@'", cid];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}



- (NSDictionary*)getBalanceInfoForCustomerId:(NSString *)cid{
    
    NSString *qStr = [NSString stringWithFormat:@"SELECT final_balance.* from final_balance where final_balance.customer_id = '%@'", cid];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSDictionary*)getOwnerBalanceInfo{
    
    NSString *qStr = [NSString stringWithFormat:@"SELECT final_balance.* from final_balance where final_balance.customer_id = '%@' and final_balance.company_id = '%@'", @"0",@"0"];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}


- (int)getMyProductId{
    NSString *qStr = [NSString stringWithFormat:@"SELECT my_product.mpid as mpid FROM my_product ORDER BY my_product.mpid DESC Limit 1"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"mpid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"mpid"] intValue];
    }
    
    return 0;

}

- (int)getReceiveBatchId{
    NSString *qStr = [NSString stringWithFormat:@"SELECT receive_batch.batch_id as batch_id FROM receive_batch ORDER BY receive_batch.batch_id DESC Limit 1"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"batch_id"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"batch_id"] intValue];
    }
    
    return 0;
    
}

- (int)getSaleBatchId{
    NSString *qStr = [NSString stringWithFormat:@"SELECT sale_batch.batch_id as batch_id FROM sale_batch ORDER BY sale_batch.batch_id DESC Limit 1"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"batch_id"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"batch_id"] intValue];
    }
    
    return 0;
    
}

- (int)getCompanyId{
    NSString *qStr = [NSString stringWithFormat:@"SELECT companies.cid as cid FROM companies ORDER BY companies.cid DESC Limit 1"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"cid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"cid"] intValue];
    }
    
    return 0;
    
}

- (int)getCustomerId{
    NSString *qStr = [NSString stringWithFormat:@"SELECT customer.cid as cid FROM customer ORDER BY customer.cid DESC Limit 1"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"cid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"cid"] intValue];
    }
    
    return 0;
    
}

- (int)getCategoryId{
    NSString *qStr = [NSString stringWithFormat:@"SELECT categories.cat_id as cid FROM categories ORDER BY categories.cat_id DESC Limit 1"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"cid"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"cid"] intValue];
    }
    
    return 0;
    
}

- (int)getReceiveItemQuantity:(NSString *)productId{
    NSString *qStr = [NSString stringWithFormat:@"select SUM (receive.quantity) as quantity from receive where receive.mpid = '%@'",productId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"quantity"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"quantity"] intValue];
    }
    
    return 0;
}

- (int)getSaleItemQuantity:(NSString *)productId{
    NSString *qStr = [NSString stringWithFormat:@"select SUM (sales.quantity) as quantity from sales where sales.mpid = '%@'",productId];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"quantity"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"quantity"] intValue];
    }
    
    return 0;
}

#pragma mark - Account Summery

- (float)getTotalCashInvestment{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCash from transactions where (transactions.transaction_note='cash_investment' and transactions.transaction_type='credit')"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalCash"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCash"] floatValue];
    }
    
    return 0.0;
}

- (float)getTotalCashIn{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalCash from transactions where (transactions.transaction_note='cashIn' and transactions.transaction_type='credit')"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalCash"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalCash"] floatValue];
    }
    
    return 0.0;
}

- (float)getMyExpences{
    NSString *qStr = [NSString stringWithFormat:@"Select SUM(transactions.amount) as totalExpences from transactions where  transactions.transaction_note='expenses' and transactions.transaction_type='debit'"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"totalExpences"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"totalExpences"] floatValue];
    }
    
    return 0.0;
}

- (float)getTotalPayableAmout{
    NSString *qStr = [NSString stringWithFormat:@"Select (SUM(final_balance.total_purchase) - SUM(final_balance.total_paid)) as payable from final_balance where  final_balance.company_id > 0"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"payable"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"payable"] floatValue];
    }
    
    return 0.0;
}

- (float)getTotalReceivableAmout{
    NSString *qStr = [NSString stringWithFormat:@"Select (SUM(final_balance.total_purchase) - SUM(final_balance.total_paid)) as receivable from final_balance where  final_balance.customer_id > 0"];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0){
        NSDictionary *info = [results lastObject];
        
        if(![[info objectForKey:@"receivable"] isKindOfClass:[NSNull class]])
            return [[info objectForKey:@"receivable"] floatValue];
    }
    
    return 0.0;
}

#pragma mark - Profit Report

/*- (NSArray *)getProfitReportFrom:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    NSString *qStr = [NSString stringWithFormat:@"select * from users where users.user_name LIKE '%@' order by users.user_type",searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}*/

#pragma mark - Users

- (NSDictionary *)getUserInfo:(NSString *)email andPass:(NSString *)password{
    NSString *qStr = [NSString stringWithFormat:@"select users.* from users where (users.email = '%@' or users.phone = '%@') and users.password = '%@'", email,email,password];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return [results lastObject];
    else
        return nil;
}

- (NSArray*)getAllUsersInfoWithSearchKey:(NSString *)searchKey{
    searchKey = [searchKey stringByAppendingString:@"%"];
    searchKey = [@"%" stringByAppendingString:searchKey];
    
    NSString *qStr = [NSString stringWithFormat:@"select * from users where users.user_name LIKE '%@' order by users.user_type",searchKey];
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        //retrieve values for each record
        //NSLog(@"%@", [s resultDictionary]);
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    NSArray *array = [NSArray arrayWithArray:results];
    return array;
}

- (BOOL)phoneNumberVarification:(NSString *)phoneNumber forUser:(NSString *)user_id{
    NSString *qStr = [NSString stringWithFormat:@"select users.* from users where users.phone = '%@' and users.user_id != %@", phoneNumber, user_id];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return YES;
    
    return NO;
}

- (BOOL)emailVarification:(NSString *)email forUser:(NSString *)user_id{
    NSString *qStr = [NSString stringWithFormat:@"select users.* from users where users.email = '%@' and users.user_id != %@", email, user_id];
    
    //NSLog(@"qStr : %@",qStr);
    
    FMResultSet *s = [myDB executeQuery:qStr];
    NSMutableArray *results = nil;
    while ([s next]) {
        if (results == nil) {
            results = [NSMutableArray arrayWithObject:[s resultDictionary]];
        }
        else{
            [results addObject:[s resultDictionary]];
        }
    }
    
    if(results.count > 0)
        return YES;
    
    return NO;
}

@end
