//
//  SSJFundingTransferListStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJRegularManager.h"

NSString *SSJFundingTransferStoreMonthKey = @"SSJFundingTransferStoreMonthKey";
NSString *SSJFundingTransferStoreListKey = @"SSJFundingTransferStoreListKey";

@implementation SSJFundingTransferStore
+ (void)queryForFundingTransferListWithSuccess:(void(^)(NSArray <NSDictionary *>*result))success
                                       failure:(void (^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        
        NSError *error = nil;
        NSArray *oldTransferCharges = [self queryOldTransferChargesInDatabase:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        NSArray *newTransferCharges = [self queryNewTransferChargesInDatabase:db error:&error];
        if (error) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure(error);
                });
            }
            return;
        }
        
        NSMutableArray *tempList = [NSMutableArray arrayWithCapacity:oldTransferCharges.count + newTransferCharges.count];
        [tempList addObjectsFromArray:oldTransferCharges];
        [tempList addObjectsFromArray:newTransferCharges];
        
        // 按转账日期降序，若转账日期相同，则按金额降序
        [tempList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            SSJFundingTransferDetailItem *item1 = obj1;
            SSJFundingTransferDetailItem *item2 = obj2;
            
            NSDate *date1 = [NSDate dateWithString:item1.transferDate formatString:@"yyyy-MM-dd"];
            NSDate *date2 = [NSDate dateWithString:item2.transferDate formatString:@"yyyy-MM-dd"];
            
            if ([date1 compare:date2] == NSOrderedAscending) {
                return NSOrderedDescending;
            } else if ([date1 compare:date2] == NSOrderedDescending) {
                return NSOrderedAscending;
            } else {
                if ([item1.transferMoney doubleValue] > [item2.transferMoney doubleValue]) {
                    return NSOrderedAscending;
                } else if ([item1.transferMoney doubleValue] < [item2.transferMoney doubleValue]) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        
        NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:oldTransferCharges.count + newTransferCharges.count];
        NSDate *lastDate = nil;
        
        // 相同年份月份的数据整合到一起
        for (SSJFundingTransferDetailItem *item in tempList) {
            NSDate *currentDate = [NSDate dateWithString:item.transferDate formatString:@"yyyy-MM-dd"];
            if (!lastDate || lastDate.year != currentDate.year || lastDate.month != currentDate.month) {
                NSMutableDictionary *monthInfo = [NSMutableDictionary dictionary];
                [monthInfo setObject:currentDate forKey:SSJFundingTransferStoreMonthKey];
                
                NSMutableArray *list = [NSMutableArray array];
                [list addObject:item];
                [monthInfo setObject:list forKey:SSJFundingTransferStoreListKey];
                
                [resultList addObject:monthInfo];
            } else {
                NSMutableDictionary *monthInfo = [resultList lastObject];
                NSMutableArray *list = monthInfo[SSJFundingTransferStoreListKey];
                [list addObject:item];
            }
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(resultList);
            });
        }
    }];
}

+ (void)deleteFundingTransferWithItem:(SSJFundingTransferDetailItem *)item
                              Success:(void(^)())success
                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *userid = SSJUSERID();
        NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 2 , cwritedate = ? , iversion = ? where ichargeid in (?,?) and cuserid = ?",writeDate,@(SSJSyncVersion()),item.transferInChargeId,item.transferOutChargeId,userid]) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            *rollback = YES;
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)saveCycleTransferRecordWithID:(NSString *)ID
                  transferInAccountId:(NSString *)transferInAccountId
                 transferOutAccountId:(NSString *)transferOutAccountId
                                money:(float)money
                                 memo:(nullable NSString *)memo
                      cyclePeriodType:(SSJCyclePeriodType)cyclePeriodType
                            beginDate:(NSString *)beginDate
                              endDate:(nullable NSString *)endDate
                              success:(nullable void (^)(BOOL isExisted))success
                              failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userId = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL existed = [db boolForQuery:@"select count(1) from bk_tansfer_cycle where cuserid = ? and icycleid = ?", userId, ID];
        
        BOOL successful = YES;
        NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        if (existed) {
            successful = [db executeUpdate:@"update bk_tansfer_cycle set ctransferinaccountid = ?, ctransferoutaccountid = ?, imoney = ?, cmemo = ?, icycletype = ?, cbegindate = ?, cenddate = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cuserid = ? and icycleid = ? and operatortype <> 2", transferInAccountId, transferOutAccountId, @(money), memo, @(cyclePeriodType), beginDate, endDate, writeDateStr, @(SSJSyncVersion()), userId, ID];
        } else {
            successful = [db executeUpdate:@"insert into bk_tansfer_cycle (icycleid, cuserid, ctransferinaccountid, ctransferoutaccountid, imoney, cmemo, icycletype, cbegindate, cenddate, clientadddate, cwritedate, iversion, operatortype) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", ID, userId, transferInAccountId, transferOutAccountId, @(money), memo, @(cyclePeriodType), beginDate, endDate, writeDateStr, writeDateStr, @(SSJSyncVersion()), @0];
        }
        
        if (!successful || [SSJRegularManager supplementCyclicTransferForUserId:userId inDatabase:db]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return ;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(existed);
            });
        }
    }];
}

+ (void)deleteCycleTransferRecordWithID:(NSString *)ID
                                success:(nullable void (^)())success
                                failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update bk_transfer_cycle set operatortype = 2, cwritedate = ?, iversion = ? where cuserid = ? and icycleid = ?", writeDate, @(SSJSyncVersion()), userid, ID]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

+ (void)updateCycleTransferRecordStateWithID:(NSString *)ID
                                      opened:(BOOL)opened
                                     success:(nullable void (^)())success
                                     failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    NSString *writeDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db executeUpdate:@"update bk_transfer_cycle set istate = ?, operatortype = 1, cwritedate = ?, iversion = ? where cuserid = ? and icycleid = ?", @(opened), writeDate, @(SSJSyncVersion()), userid, ID]) {
            if (success) {
                SSJDispatchMainAsync(^{
                    success();
                });
            }
        } else {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
        }
    }];
}

+ (void)queryCycleTransferRecordsListWithSuccess:(nullable void (^)(NSArray <NSDictionary *>*))success
                                         failure:(nullable void (^)(NSError *error))failure {
    
    NSString *userid = SSJUSERID();
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select tc.*, fund_in.cacctname as transferInAcctName, fund_in.cicoin as transferInAcctIcon, fund_out.cacctname as transferOutAcctName, fund_out.cicoin as transferOutAcctIcon from bk_transfer_cycle as tc, bk_fund_info as fund_in, bk_fund_info as fund_out where tc.ctransferinaccountid = fund_in.cfundid and tc.ctransferoutaccountid = fund_out.cfundid and tc.cuserid = ? and tc.cuserid = fund_in.cuserid and tc.cuserid = fund_out.cuserid and tc.icycletype <> -1 and tc.operatortype <> 2 order by tc.cbegindate desc, tc.imoney desc", userid];
        
        if (!resultSet) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        NSMutableArray *result = [[NSMutableArray alloc] init];
        NSDate *lastDate = nil;
        
        while ([resultSet next]) {
            SSJFundingTransferDetailItem *item = [[SSJFundingTransferDetailItem alloc] init];
            item.ID = [resultSet stringForColumn:@"icycleid"];
            item.transferMoney = [NSString stringWithFormat:@"%.2f", [resultSet doubleForColumn:@"imoney"]];
            item.beginDate = [resultSet stringForColumn:@"cbegindate"];
            item.endDate = [resultSet stringForColumn:@"cenddate"];
            item.transferInName = [resultSet stringForColumn:@"transferInAcctName"];
            item.transferOutName = [resultSet stringForColumn:@"transferOutAcctName"];
            item.transferInImage = [resultSet stringForColumn:@"transferInAcctIcon"];
            item.transferOutImage = [resultSet stringForColumn:@"transferOutAcctIcon"];
            item.transferMemo = [resultSet stringForColumn:@"cmemo"];
            item.cycleType = [resultSet intForColumn:@"icycletype"];
            item.opened = [resultSet boolForColumn:@"istate"];
            
            NSDate *currentDate = [NSDate dateWithString:item.beginDate formatString:@"yyyy-MM"];
            
            if (!lastDate || [lastDate compare:currentDate] != NSOrderedSame) {
                NSMutableDictionary *monthInfo = [[NSMutableDictionary alloc] init];
                [monthInfo setObject:currentDate forKey:SSJFundingTransferStoreMonthKey];
                
                NSMutableArray *list = [[NSMutableArray alloc] init];
                [list addObject:item];
                [monthInfo setObject:list forKey:SSJFundingTransferStoreListKey];
                
                [result addObject:monthInfo];
            } else {
                NSMutableDictionary *monthInfo = [result lastObject];
                NSMutableArray *list = monthInfo[SSJFundingTransferStoreListKey];
                [list addObject:item];
            }
            
            lastDate = currentDate;
        }
        [resultSet close];
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(result);
            });
        }
    }];
}

+ (NSArray <SSJFundingTransferDetailItem *>*)queryOldTransferChargesInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet * transferResult = [db executeQuery:@"select substr(a.cbilldate,0,7) as cmonth , a.* , b.cacctname , b.cfundid , b.cicoin , b.operatortype as fundoperatortype , b.cparent from bk_user_charge as a, bk_fund_info as b where a.ibillid in (3,4) and a.operatortype != 2 and a.cuserid = ? and a.ifunsid = b.cfundid and (a.ichargetype = ? or a.ichargetype = ?) order by cmonth desc , cwritedate desc , ibillid asc",SSJUSERID(),@(SSJChargeIdTypeNormal),@(SSJChargeIdTypeTransfer)];
    
    if (!transferResult) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:0];
    
    while ([transferResult next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.money = [transferResult stringForColumn:@"IMONEY"];
        item.ID = [transferResult stringForColumn:@"ICHARGEID"];
        item.fundId = [transferResult stringForColumn:@"IFUNSID"];
        item.fundImage = [transferResult stringForColumn:@"CICOIN"];
        item.editeDate = [transferResult stringForColumn:@"CWRITEDATE"];
        item.billId = [transferResult stringForColumn:@"IBILLID"];
        item.chargeImage = [transferResult stringForColumn:@"CIMGURL"];
        item.chargeThumbImage = [transferResult stringForColumn:@"THUMBURL"];
        item.chargeMemo = [transferResult stringForColumn:@"CMEMO"];
        item.billDate = [transferResult stringForColumn:@"CBILLDATE"];
        item.fundName = [transferResult stringForColumn:@"CACCTNAME"];
        item.fundOperatorType = [transferResult intForColumn:@"fundoperatortype"];
        item.fundParent = [transferResult stringForColumn:@"cparent"];
        
        SSJFundingTransferDetailItem *detailItem = nil;
        if (tempArr.count == 1) {
            [tempArr addObject:item];
            detailItem = [self transferItemWithArray:tempArr];
            [tempArr removeAllObjects];
        }else{
            [tempArr addObject:item];
        }
        
        if (detailItem) {
            [resultList addObject:detailItem];
        }
    }
    
    return resultList;
}

+ (NSArray <SSJFundingTransferDetailItem *>*)queryNewTransferChargesInDatabase:(FMDatabase *)db error:(NSError **)error {
    FMResultSet *resultSet = [db executeQuery:@"select uc.*, fi.cacctname, fi.cfundid, fi.cicoin, fi.operatortype as fundoperatortype, fi.cparent from bk_user_charge as uc, bk_fund_info as fi where uc.ibillid in (3,4) and uc.operatortype != 2 and uc.cuserid = ? and uc.cuserid = fi.cuserid and uc.ifunsid = fi.cfundid and uc.ichargetype = 5 order by uc.cid", SSJUSERID()];
    
    if (!resultSet) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:0];
    
    while ([resultSet next]) {
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        item.money = [resultSet stringForColumn:@"IMONEY"];
        item.ID = [resultSet stringForColumn:@"ICHARGEID"];
        item.fundId = [resultSet stringForColumn:@"IFUNSID"];
        item.fundImage = [resultSet stringForColumn:@"CICOIN"];
        item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
        item.billId = [resultSet stringForColumn:@"IBILLID"];
        item.chargeImage = [resultSet stringForColumn:@"CIMGURL"];
        item.chargeThumbImage = [resultSet stringForColumn:@"THUMBURL"];
        item.chargeMemo = [resultSet stringForColumn:@"CMEMO"];
        item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
        item.fundName = [resultSet stringForColumn:@"CACCTNAME"];
        item.fundOperatorType = [resultSet intForColumn:@"fundoperatortype"];
        item.fundParent = [resultSet stringForColumn:@"cparent"];
        
        SSJFundingTransferDetailItem *detailItem = nil;
        if (tempArr.count == 1) {
            [tempArr addObject:item];
            detailItem = [self transferItemWithArray:tempArr];
            [tempArr removeAllObjects];
        }else{
            [tempArr addObject:item];
        }
        
        if (detailItem) {
            [resultList addObject:detailItem];
        }
    }
    
    return resultList;
}

+ (SSJFundingTransferDetailItem *)transferItemWithArray:(NSArray <SSJBillingChargeCellItem *>*)array{
    if (array.count != 2) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    
    SSJBillingChargeCellItem *transferInItem;
    SSJBillingChargeCellItem *transferOutItem;
    for (int i = 0; i < array.count; i ++) {
        SSJBillingChargeCellItem *item = [array ssj_safeObjectAtIndex:i];
        if ([item.billId isEqualToString:@"3"]) {
            transferInItem = [array ssj_safeObjectAtIndex:i];
        }else{
            transferOutItem = [array ssj_safeObjectAtIndex:i];
        }
    }
    if (![transferInItem.billId isEqualToString:@"3"]) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    if (![transferInItem.money isEqualToString:transferOutItem.money]) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    if (![transferOutItem.billId isEqualToString:@"4"]) {
        NSLog(@"匹配失败,请检查数据");
        return nil;
    }
    
    SSJFundingTransferDetailItem *item = [[SSJFundingTransferDetailItem alloc]init];
    item.transferMoney = transferInItem.money;
    item.transferDate = transferInItem.billDate;
    item.transferInId = transferInItem.fundId;
    item.transferOutId = transferOutItem.fundId;
    item.transferInName = transferInItem.fundName;
    item.transferOutName = transferOutItem.fundName;
    item.transferInImage = transferInItem.fundImage;
    item.transferOutImage = transferOutItem.fundImage;
    item.transferMemo = transferInItem.chargeMemo;
    item.transferInChargeId = transferInItem.ID;
    item.transferOutChargeId = transferOutItem.ID;
    item.transferInFundOperatorType = transferInItem.fundOperatorType;
    item.transferOutFundOperatorType = transferOutItem.fundOperatorType;
    item.editable = YES;
    if ([transferInItem.fundParent isEqualToString:@"11"] || [transferOutItem.fundParent isEqualToString:@"11"]) {
        item.editable = NO;
    }
    if ([transferInItem.fundParent isEqualToString:@"10"] || [transferOutItem.fundParent isEqualToString:@"10"]) {
        item.editable = NO;
    }
    return item;
}

@end
