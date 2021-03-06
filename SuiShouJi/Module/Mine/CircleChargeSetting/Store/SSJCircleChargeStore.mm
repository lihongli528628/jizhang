//
//  SSJCircleChargeStore.m
//  SuiShouJi
//
//  Created by ricky on 16/5/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCircleChargeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJChargeMemberItem.h"
#import "SSJBooksTypeItem.h"
#import "SSJBooksTypeTable.h"
#import "SSJUserBillTypeTable.h"
#import "SSJOrmDatabaseQueue.h"
#import "SSJFundInfoTable.h"

@implementation SSJCircleChargeStore

+ (void)queryForChargeListWithSuccess:(void(^)(NSArray<SSJBillingChargeCellItem *> *result))success
                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userid];
        if (!booksId.length) {
            booksId = userid;
        }
        NSMutableArray *chargeList = [NSMutableArray array];
        FMResultSet *chargeResult = [db executeQuery:@"select a.* , b.cicoin as bill_img , b.cname , b.ccolor , b.itype as INCOMEOREXPENSE , b.cbillid , c.cbooksname , d.cacctname , d.cicoin as fund_img from bk_charge_period_config as a, bk_user_bill_type as b , bk_books_type as c , bk_fund_info as d where a.cuserid = ? and a.operatortype != 2 and a.ibillid = b.cbillid and a.cuserid = b.cuserid and a.cbooksid = b.cbooksid and a.cbooksid = c.cbooksid and c.cuserid = a.cuserid and a.ifunsid = d.cfundid order by A.itype ASC , A.imoney DESC",userid];
        if (!chargeResult) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([chargeResult next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [chargeResult stringForColumn:@"bill_img"];
            item.typeName = [chargeResult stringForColumn:@"CNAME"];
            item.money = [chargeResult stringForColumn:@"IMONEY"];
            item.colorValue = [chargeResult stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = (SSJBillType)[chargeResult intForColumn:@"INCOMEOREXPENSE"];
            item.fundId = [chargeResult stringForColumn:@"IFUNSID"];
            item.editeDate = [chargeResult stringForColumn:@"CWRITEDATE"];
            item.billId = [chargeResult stringForColumn:@"IBILLID"];
            item.chargeImage = [chargeResult stringForColumn:@"CIMGURL"];
            item.chargeMemo = [chargeResult stringForColumn:@"CMEMO"];
            item.sundryId = [chargeResult stringForColumn:@"ICONFIGID"];
            item.billDate = [chargeResult stringForColumn:@"CBILLDATE"];
            item.billDetailDate = @"00:00";
            item.booksName = [chargeResult stringForColumn:@"CBOOKSNAME"];
            item.isOnOrNot = [chargeResult boolForColumn:@"ISTATE"];
            item.chargeCircleType = (SSJCyclePeriodType)[chargeResult intForColumn:@"ITYPE"];
            item.fundName = [chargeResult stringForColumn:@"CACCTNAME"];
            item.fundImage = [chargeResult stringForColumn:@"fund_img"];
            item.chargeCircleEndDate = [chargeResult stringForColumn:@"cbilldateend"];
            item.booksId = [chargeResult stringForColumn:@"CBOOKSID"];
            NSString *memberStr = [chargeResult stringForColumn:@"CMEMBERIDS"];
            item.membersItem = [NSMutableArray arrayWithCapacity:0];
            if (!memberStr.length) {
                memberStr = [NSString stringWithFormat:@"%@-0",userid];
            }
            NSArray *idArr = [memberStr componentsSeparatedByString:@","];
            for (NSString *memberId in idArr) {
                SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
                memberItem.memberId = memberId;
                memberItem.memberName = [db stringForQuery:@"select cname from bk_member where cmemberid = ? and cuserid = ?",memberId,userid];
                memberItem.memberColor = [db stringForQuery:@"select ccolor from bk_member where cmemberid = ? and cuserid = ?",memberId,userid];
                [item.membersItem addObject:memberItem];
            }
            [chargeList addObject:item];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(chargeList);
            });
        }
    }];
}

+ (void)queryDefualtItemWithIncomeOrExpence:(BOOL)incomeOrExpence
                                    Success:(void(^)(SSJBillingChargeCellItem *item))success
                              failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userid];
        if (!booksId.length) {
            booksId = userid;
        }
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc]init];
        item.billDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"];
        item.billDetailDate = @"00:00";
        item.billId = [db stringForQuery:@"select cbillid from bk_user_bill_type where cuserid = ? and itype = ? and cbooksid = ? and operatortype <> 2 order by iorder, cwritedate, cbillid limit 1", userid, @(incomeOrExpence), booksId];
        item.typeName = [db stringForQuery:@"select cname from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", item.billId, userid, booksId];
        item.colorValue = [db stringForQuery:@"select ccolor from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", item.billId, userid, booksId];
        item.booksId = booksId;
        item.booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ?",booksId];
        item.fundId = [db stringForQuery:@"select cfundid from bk_fund_info where cuserid = ? and operatortype <> 2 order by iorder limit 1",userid];
        item.fundName = [db stringForQuery:@"select cacctname from bk_fund_info where cfundid = ?",item.fundId];
        item.fundImage = [db stringForQuery:@"select cicoin from bk_fund_info where cfundid = ?",item.fundId ];
        item.imageName = [db stringForQuery:@"select cicoin from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", item.billId, userid, booksId];
        SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
        memberItem.memberId = [NSString stringWithFormat:@"%@-0",userid];
        memberItem.memberName = @"我";
        item.membersItem = [@[memberItem] mutableCopy];
        item.chargeCircleType = SSJCyclePeriodTypeDaily;
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(item);
            });
        }

    }];
}

+ (SSJBillingChargeCellItem *)chargeItemWithResultSet:(FMResultSet *)set inDatabase:(FMDatabase *)db {
    SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
    item.imageName = [set stringForColumn:@"CCOIN"];
    item.typeName = [set stringForColumn:@"CNAME"];
    item.money = [set stringForColumn:@"IMONEY"];
    item.colorValue = [set stringForColumn:@"CCOLOR"];
    item.incomeOrExpence = (SSJBillType)[set intForColumn:@"INCOMEOREXPENSE"];
    item.fundId = [set stringForColumn:@"IFUNSID"];
    item.editeDate = [set stringForColumn:@"CWRITEDATE"];
    item.billId = [set stringForColumn:@"IBILLID"];
    item.chargeImage = [set stringForColumn:@"CIMGURL"];
    item.chargeMemo = [set stringForColumn:@"CMEMO"];
    item.sundryId = [set stringForColumn:@"ICONFIGID"];
    item.billDate = [set stringForColumn:@"CBILLDATE"];
    item.booksName = [set stringForColumn:@"CBOOKSNAME"];
    item.isOnOrNot = [set boolForColumn:@"ISTATE"];
    item.chargeCircleType = (SSJCyclePeriodType)[set intForColumn:@"ITYPE"];
    item.chargeCircleEndDate = [set stringForColumn:@"CBILLDATEEND"];
    item.fundName = [set stringForColumn:@"CACCTNAME"];
    return item;
}

+ (void)saveCircleChargeItem:(SSJBillingChargeCellItem *)item
                     success:(void(^)())success
                     failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback){
        NSString *userid = SSJUSERID();
        if (!item.booksId.length) {
            item.booksId = [db stringForQuery:@"select ccurrentBooksId from bk_user where cuserid = ?", userid];
            item.booksId = item.booksId.length > 0 ? item.booksId : userid;
        }
        if (!item.sundryId.length) {
            item.sundryId = SSJUUID();
        }
        NSString *cwriteDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        NSMutableArray *membersIdArr = [NSMutableArray arrayWithCapacity:0];
        for (SSJChargeMemberItem *memberItem in item.membersItem) {
            [membersIdArr addObject:memberItem.memberId];
        }
        if (item.chargeImage.length && ![item.chargeImage hasSuffix:@".jpg"] && ![item.chargeImage hasSuffix:@".webp"]) {
            item.chargeImage = [NSString stringWithFormat:@"%@.jpg",item.chargeImage];
        }
        if (item.chargeThumbImage.length && ![item.chargeThumbImage hasSuffix:@".jpg"] && ![item.chargeImage hasSuffix:@".webp"]) {
            item.chargeThumbImage = [NSString stringWithFormat:@"%@.jpg",item.chargeThumbImage];
        }
        NSString *membersStr = [membersIdArr componentsJoinedByString:@","];
        NSString *originImageName = [db stringForQuery:@"select cimgurl from bk_charge_period_config where iconfigid = ?",item.sundryId];
        //如果有图片,插入图片表
        if (![item.chargeImage isEqualToString:originImageName]) {
            if (item.chargeImage.length) {
                if (![db executeUpdate:@"insert into bk_img_sync (rid,cimgname,cwritedate,operatortype,isynctype,isyncstate) values (?,?,?,0,0,0)",item.sundryId,item.chargeImage,cwriteDate]) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    *rollback = YES;
                }
            }
        }
        //插入周期记账表
        if (![db intForQuery:@"select count(1) from bk_charge_period_config where iconfigid = ?",item.sundryId]) {
            if (![db executeUpdate:@"insert into bk_charge_period_config (iconfigid, cuserid, ibillid, ifunsid, itype, imoney, cimgurl, cmemo, cbilldate, istate, iversion, cwritedate, operatortype, cbooksid, cmemberids, cbilldateend) values (?,?,?,?,?,?,?,?,?,1,?,?,0,?,?,?)",item.sundryId,userid,item.billId,item.fundId,@(item.chargeCircleType),@([item.money doubleValue]),item.chargeImage,item.chargeMemo,item.billDate,@(SSJSyncVersion()),cwriteDate,item.booksId,membersStr,item.chargeCircleEndDate]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                *rollback = YES;
            }
            //如果是今天的周期记账,插入一条流水
            if ([item.billDate isEqualToString:[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [formatter dateFromString:item.billDate];
                if (item.chargeCircleType == SSJCyclePeriodTypeDaily && (date.weekday == 1 || date.weekday == 7)) {
                    
                }else if (item.chargeCircleType == SSJCyclePeriodTypePerWeekend && (date.weekday != 1 && date.weekday != 7)) {
                    
                }else if (item.chargeCircleType == SSJCyclePeriodTypeLastDayPerMonth && date.day != date.daysInMonth) {
                    
                }else{
                    NSString *chargeId = SSJUUID();
                    //修改流水表
                    if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cid, ichargetype, imoney, cimgurl, thumburl, cmemo, cbilldate, cdetaildate, iversion, cwritedate, operatortype, cbooksid) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,?)",chargeId,userid,item.billId,item.fundId,item.sundryId,@(SSJChargeIdTypeCircleConfig),@([item.money doubleValue]),item.chargeImage,item.chargeThumbImage,item.chargeMemo,item.billDate,item.billDetailDate,@(SSJSyncVersion()),cwriteDate,item.booksId]) {
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        *rollback = YES;
                    }
                    //修改成员流水
                    for (NSString *memberId in membersIdArr) {
                        if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, imoney, iversion, cwritedate, operatortype, cmemberid) values (?,?,?,?,0,?)",chargeId,@([item.money doubleValue] / item.membersItem.count),@(SSJSyncVersion()),cwriteDate,memberId]) {
                            if (failure) {
                                SSJDispatch_main_async_safe(^{
                                    failure([db lastError]);
                                });
                            }
                            *rollback = YES;
                        }
                    }
                }
            }else{
                NSString *chargeId = SSJUUID();
                //修改流水表
                if (![db executeUpdate:@"insert into bk_user_charge (ichargeid, cuserid, ibillid, ifunsid, cid, ichargetype, imoney, cimgurl, thumburl, cmemo, cbilldate, cdetaildate, iversion, cwritedate, operatortype, cbooksid) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,?)",chargeId,userid,item.billId,item.fundId,item.sundryId,@(SSJChargeIdTypeCircleConfig),@([item.money doubleValue]),item.chargeImage,item.chargeThumbImage,item.chargeMemo,item.billDate,item.billDetailDate,@(SSJSyncVersion()),cwriteDate,item.booksId]) {
                    if (failure) {
                        SSJDispatch_main_async_safe(^{
                            failure([db lastError]);
                        });
                    }
                    *rollback = YES;
                }
                //修改成员流水
                for (NSString *memberId in membersIdArr) {
                    if (![db executeUpdate:@"insert into bk_member_charge (ichargeid, imoney, iversion, cwritedate, operatortype, cmemberid) values (?,?,?,?,0,?)",chargeId,@([item.money doubleValue] / item.membersItem.count),@(SSJSyncVersion()),cwriteDate,memberId]) {
                        if (failure) {
                            SSJDispatch_main_async_safe(^{
                                failure([db lastError]);
                            });
                        }
                        *rollback = YES;
                    }
                }
            }
        }else{
            //修改周期记账
            if (![db executeUpdate:@"update bk_charge_period_config set ibillid = ? ,ifunsid = ? ,itype = ? ,imoney = ?,cimgurl = ?,cmemo = ?,cbilldate = ?,iversion = ?,cwritedate = ?,operatortype = 1 , cmemberids = ?, cbilldateend = ?, cbooksid = ? where cuserid = ? and iconfigid = ?",item.billId,item.fundId,@(item.chargeCircleType),item.money,item.chargeImage,item.chargeMemo,item.billDate,@(SSJSyncVersion()),cwriteDate,membersStr,item.chargeCircleEndDate,item.booksId,userid,item.sundryId]) {
                if (failure) {
                    SSJDispatch_main_async_safe(^{
                        failure([db lastError]);
                    });
                }
                *rollback = YES;
            }
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success();
            });
        }
    }];
}

+ (void)getBooksForCircleChargeWithsuccess:(void(^)(NSArray *books))success
                                   failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        NSArray *books = [db getObjectsOfClass:SSJBooksTypeTable.class
                                     fromTable:@"bk_books_type"
                                         where:SSJBooksTypeTable.userId == SSJUSERID()
                                               && SSJBooksTypeTable.operatorType != 2
                                       orderBy:SSJBooksTypeTable.booksOrder.order(WCTOrderedAscending)];
        NSMutableArray *booksArr = [NSMutableArray arrayWithCapacity:0];
        for (SSJBooksTypeTable *bookstype in books) {
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc] init];
            item.booksName = bookstype.booksName;
            item.booksId = bookstype.booksId;
            [booksArr addObject:item];
        }
        dispatch_main_async_safe(^{
            if (success) {
                success(booksArr);
            }
        });
    }];
}

+ (void)getFirstBillItemForBooksId:(NSString *)booksId
                        billType:(SSJBillType)billType
                       withSuccess:(void(^)(SSJRecordMakingBillTypeSelectionCellItem *billItem))success
                           failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        SSJUserBillTypeTable *userBillType = [db getOneObjectOfClass:SSJUserBillTypeTable.class
                                                             fromTable:@"bk_user_bill_type"
                                                                 where:SSJUserBillTypeTable.booksId == booksId
                                                                       && SSJUserBillTypeTable.userId == SSJUSERID()
                                                                       && SSJUserBillTypeTable.billType == billType
                                                                       && SSJUserBillTypeTable.operatorType != 2
                                                             orderBy:{SSJUserBillTypeTable.billOrder.order(WCTOrderedAscending), SSJUserBillTypeTable.writeDate.order(WCTOrderedAscending),
                                                             SSJUserBillTypeTable.billId.order(WCTOrderedAscending)}];
        SSJRecordMakingBillTypeSelectionCellItem *billItem = [[SSJRecordMakingBillTypeSelectionCellItem alloc] init];
        billItem.imageName = userBillType.billIcon;
        billItem.title = userBillType.billName;
        billItem.colorValue = userBillType.billColor;
        billItem.ID = userBillType.billId;
        if (success) {
            dispatch_main_async_safe(^{
                success(billItem);
            });
        }
    }];
}

+ (void)getFinancingItemWithFundingId:(NSString *)fundId
                              success:(void (^)(SSJFinancingHomeitem *fundingItem))success
                            failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        SSJFundInfoTable *fundInfo = [db getOneObjectOfClass:SSJFundInfoTable.class
                                                   fromTable:@"bk_fund_info"
                                                       where:SSJFundInfoTable.fundId == fundId];
        SSJFinancingHomeitem *fundItem = [[SSJFinancingHomeitem alloc] init];
        fundItem.fundingID = fundInfo.fundId;
        fundItem.fundingName = fundInfo.fundName;
        fundItem.fundingColor = fundInfo.fundColor;
        fundItem.fundingIcon = fundInfo.fundIcon;
        if (success) {
            dispatch_main_async_safe(^{
                success(fundItem);
            });
        }
    }];
    
}
@end
