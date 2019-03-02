//
//  MyQueryDBManager.h
//
//
//  Created by Roni Alam on 5/22/16.
//  Copyright © 2016 Roni Alam. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyQueryDBManager : NSObject{
    
    
}

+ (id)sharedManager;
- (void) closeDB;
- (Boolean)openDB;

- (Boolean) isTableExists:(NSString*) tableName;
- (NSArray*) getTableColumns:(NSString*) tableName;

- (NSArray*)getAllTransactions;
- (NSArray*)getAllTransactionsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;;

#pragma mark - Inventory & Categories
- (NSString*)getEnabledCategories;
- (NSArray*)getCategoriesWithSearchKey:(NSString *)searchKey;
- (NSArray*)getInventoryForCategories:(NSString *)catIds withSearchKey:(NSString *)searchKey;
- (NSArray*)getAllInventoryWithSearchKey:(NSString *)searchKey;

#pragma mark - Recieve Items
- (NSArray*)getRecieveBatchesWithSearchKey:(NSString *)searchKey;
- (NSArray*)getRecieveItemsForBatch:(NSString *)batchId;
- (float)getRecieveBatchTotalAmount:(NSString *)batchId;

#pragma mark - My Product List
- (NSArray*)getMyProductListWithSearchKey:(NSString *)searchKey;
- (NSArray*)getSaleProductListWithSearchKey:(NSString *)searchKey;
- (NSDictionary *)getMyProductInfo:(NSString *)productCode;

#pragma mark - sale Items
- (NSArray*)getSaleBatchesWithSearchKey:(NSString *)searchKey;
- (NSArray*)getSaleItemsForBatch:(NSString *)batchId;

#pragma mark - Companies & Customers
- (NSArray*)getCompaniesWithSearchKey:(NSString *)searchKey;
- (NSArray*)getCustomersWithSearchKey:(NSString *)searchKey;
- (NSDictionary *)getCompanyDetails:(NSString *)companyId;
- (NSDictionary *)getCustomerDetails:(NSString *)customerId;

#pragma mark - Sales & Profit Report
- (NSArray*)getSaleBatchesFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSArray*)getAllStockFor:(NSString *)productCode;
- (NSDictionary *)getProductInfo:(NSString *)productCode;

- (NSArray *)getProfitReportFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

#pragma mark - RECEIVE

- (int)getTotalReceiveItems;
- (int)getTotalReceiveItemsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getReceiveTotalPurchaseAmount;
- (float)getReceiveTotalPurchaseAmountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getReceiveTotalCashPaid;
- (float)getReceiveTotalCashPaidFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getReceiveTotalPaid;
- (float)getReceiveTotalPaidFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getReceiveTotalDiscount;
- (float)getReceiveTotalDiscountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSArray*)getRecieveBatchList;
- (NSArray*)getRecieveBatchListFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSArray*)getRecieveTransactions;
- (NSArray*)getRecieveTransactionsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSDictionary*)getReceiveBatchsAdditionalInfo:(NSString *)batchId;

- (float)getReceiveTotalPurchaseAmount:(NSString *)companyId;
- (float)getReceiveTotalCashPaid:(NSString *)companyId;
- (float)getReceiveTotalPaid:(NSString *)companyId;
- (float)getReceiveTotalDiscount:(NSString *)companyId;

- (float)getReceiveBatchPurchaseAmount:(NSString *)batchId;
- (float)getReceiveBatchCashPaid:(NSString *)batchId;
- (float)getReceiveBatchPaid:(NSString *)batchId;
- (float)getReceiveBatchDiscount:(NSString *)batchId;

- (NSArray*)getRecieveItemListForCompany:(NSString *)companyId;

#pragma mark - SALE

- (int)getTotalSaleItems;
- (int)getTotalSaleItemsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getSaleTotalReceiveAmount;
- (float)getSaleTotalReceiveAmountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getSaleTotalCashReceive;
- (float)getSaleTotalCashReceiveFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getSaleTotalReceive;
- (float)getSaleTotalReceiveFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (float)getSaleTotalDiscount;
- (float)getSaleTotalDiscountFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSArray*)getSaleBatchList;
- (NSArray*)getSaleBatchListFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSArray*)getSaleTransactions;
- (NSArray*)getSaleTransactionsFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSDictionary*)getSaleBatchsAdditionalInfo:(NSString *)batchId;

- (float)getSaleTotalReceiveAmount:(NSString *)customerId;
- (float)getSaleTotalCashReceive:(NSString *)customerId;
- (float)getSaleTotalReceive:(NSString *)customerId;
- (float)getSaleTotalDiscount:(NSString *)customerId;

- (float)getSaleBatchReceiveAmount:(NSString *)batchId;
- (float)getSaleBatchCashReceive:(NSString *)batchId;
- (float)getSaleBatchReceive:(NSString *)batchId;
- (float)getSaleBatchDiscount:(NSString *)batchId;

- (NSArray*)getSaleItemListForCustomer:(NSString *)customerId;

#pragma mark - additional helpers

- (NSDictionary*)getCategoryOfProduct:(NSString *)productId;
- (NSDictionary*)getBalanceInfoForCompanyId:(NSString *)cid;
- (NSDictionary*)getBalanceInfoForCustomerId:(NSString *)cid;
- (NSDictionary*)getOwnerBalanceInfo;

- (int)getMyProductId;
- (int)getCategoryId;
- (int)getCompanyId;
- (int)getCustomerId;
- (int)getReceiveBatchId;
- (int)getSaleBatchId;
- (int)getReceiveItemQuantity:(NSString *)productId;
- (int)getSaleItemQuantity:(NSString *)productId;

#pragma mark - Account Summery

- (float)getTotalCashInvestment;
- (float)getTotalCashIn;
- (float)getMyExpences;
- (float)getTotalPayableAmout;
- (float)getTotalReceivableAmout;

#pragma mark - profit report

- (NSDictionary*)getProfitInfo;
- (NSDictionary*)getProfitInfoFrom:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NSDictionary*)getSaleBatchsProfitInfo:(NSString *)batchId;

#pragma mark - Users

- (NSDictionary *)getUserInfo:(NSString *)email andPass:(NSString *)password;
- (NSArray*)getAllUsersInfoWithSearchKey:(NSString *)searchKey;
- (BOOL)phoneNumberVarification:(NSString *)phoneNumber forUser:(NSString *)user_id;
- (BOOL)emailVarification:(NSString *)email forUser:(NSString *)user_id;

@end
