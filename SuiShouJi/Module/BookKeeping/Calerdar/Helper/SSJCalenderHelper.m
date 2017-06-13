//
//  SSJCalenderHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJChargeMemberItem.h"

@implementation SSJCalenderHelper
+ (void)queryDataInYear:(NSInteger)year
                          month:(NSInteger)month
                        success:(void (^)(NSMutableDictionary *data))success
                        failure:(void (^)(NSError *error))failure {
    
    if (year == 0 || month > 12) {
        SSJPRINT(@"class:%@\n method:%@\n message:(year == 0 || month > 12)",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        failure(nil);
        return;
    }
    NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-__",(long)year,(long)month];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userid];
        if (!booksid.length) {
            booksid = userid;
        }
        FMResultSet *resultSet = [db executeQuery:@"select a.*, b.CNAME, b.CCOIN, b.CCOLOR, b.ITYPE from BK_USER_CHARGE as a, BK_BILL_TYPE as b where a.IBILLID = b.ID and a.CBILLDATE like ? and a.CUSERID = ? and a.OPERATORTYPE <> 2 and b.istate <> 2 and a.cbooksid = ? order by a.CBILLDATE desc, a.cdetaildate desc, a.cwritedate desc", dateStr,userid,booksid];
        if (!resultSet) {
            SSJPRINT(@"class:%@\n method:%@\n message:%@\n error:%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [db lastErrorMessage], [db lastError]);
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        NSMutableDictionary *result = [[NSMutableDictionary alloc]init];
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CCOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"CWRITEDATE"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.idType = [resultSet intForColumn:@"ichargetype"];
            item.billDetailDate = [resultSet stringForColumn:@"cdetaildate"];
            if (item.idType == SSJChargeIdTypeCircleConfig) {
                item.sundryId = [resultSet stringForColumn:@"cid"];
            }
            NSString *billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            if ([result objectForKey:billDate] == nil) {
                NSMutableArray *items = [[NSMutableArray alloc]init];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }else{
                NSMutableArray *items = [result objectForKey:billDate];
                [items addObject:item];
                [result setObject:items forKey:billDate];
            }
        }
        SSJDispatch_main_async_safe(^{
            success(result);
        });
    }];
}

+ (void)queryBalanceForDate:(NSString*)date
             success:(void (^)(double income , double expence))success
             failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db) {
        double income = 0;
        double expence = 0;
        NSString *userId = SSJUSERID();
        NSString *booksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksid.length) {
            booksid = userId;
        }
        FMResultSet *result = [db executeQuery:@"SELECT * FROM BK_DAILYSUM_CHARGE WHERE CBILLDATE = ? AND CUSERID = ? and cbooksid = ?",date,userId,booksid];
        if (!result) {
            SSJDispatch_main_async_safe(^{
                failure([db lastError]);
            });
            return;
        }
        while ([result next]) {
            income = [result doubleForColumn:@"INCOMEAMOUNT"];
            expence = [result doubleForColumn:@"EXPENCEAMOUNT"];
        }
        SSJDispatch_main_async_safe(^{
            success(income,expence);
        });
    }];
}

+ (void)queryChargeDetailWithId:(NSString *)chargeId
                        success:(void (^)(SSJBillingChargeCellItem *chargeItem))success
                        failure:(void(^)(NSError *error))failure {
    if (!chargeId.length) {
        if (failure) {
            SSJDispatchMainAsync(^{
                failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"参数chargeId无效"}]);
            });
        }
        return;
    }
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        FMResultSet *rs = [db executeQuery:@"select a.* , b.* from bk_user_charge a , bk_bill_type b where a.ichargeid = ? and a.ibillid = b.id", chargeId];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
        while ([rs next]) {
            item.ID = chargeId;
            item.userId = [rs stringForColumn:@"cuserid"];
            item.billId = [rs stringForColumn:@"IBILLID"];
            item.imageName = [rs stringForColumn:@"CCOIN"];
            item.typeName = [rs stringForColumn:@"CNAME"];
            item.money = [rs stringForColumn:@"IMONEY"];
            item.chargeImage = [rs stringForColumn:@"CIMGURL"];
            item.chargeMemo = [rs stringForColumn:@"CMEMO"];
            item.billDate = [rs stringForColumn:@"CBILLDATE"];
            item.fundId = [rs stringForColumn:@"IFUNSID"];
            item.colorValue = [rs stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = [rs boolForColumn:@"ITYPE"];
            item.billDetailDate = [rs stringForColumn:@"cdetaildate"];
            item.booksId = [rs stringForColumn:@"cbooksid"];
            item.booksId = item.booksId.length ? item.booksId : SSJUSERID();
            item.idType = [rs intForColumn:@"ichargetype"];
        }
        [rs close];
        
        if (item.idType == SSJChargeIdTypeShareBooks) { // 共享账本
            if ([item.userId isEqualToString:SSJUSERID()]) {// 如果是自己的流水就还需要查询资金账户
                rs = [db executeQuery:@"select fi.cacctname, sb.cbooksname, sm.cmark from bk_user_charge as uc, bk_fund_info as fi, bk_share_books as sb, bk_share_books_friends_mark as sm where uc.ifunsid = fi.cfundid and uc.cbooksid = sb.cbooksid and sb.cbooksid = sm.cbooksid and uc.cuserid = sm.cfriendid and sm.cuserid = ? and uc.ichargeid = ?", SSJUSERID(), item.ID];
                while ([rs next]) {
                    item.fundName = [rs stringForColumn:@"cacctname"];
                    item.booksName = [rs stringForColumn:@"cbooksname"];
                    item.memberNickname = [rs stringForColumn:@"cmark"];
                }
                [rs close];
            } else {
                rs = [db executeQuery:@"select sb.cbooksname, sm.cmark from bk_user_charge as uc, bk_share_books as sb, bk_share_books_friends_mark as sm where uc.cbooksid = sb.cbooksid and sb.cbooksid = sm.cbooksid and uc.cuserid = sm.cfriendid and sm.cuserid = ? and uc.ichargeid = ?", SSJUSERID(), item.ID];
                while ([rs next]) {
                    item.booksName = [rs stringForColumn:@"cbooksname"];
                    item.memberNickname = [rs stringForColumn:@"cmark"];
                }
                [rs close];
            }
            
            // 如果账本名称为nil，就是退出了共享账本，需要从相同账本、资金账户下的平账流水中查询账本名称
            if (!item.booksName) {
                item.booksName = [db stringForQuery:@"select t1.cmemo from bk_user_charge as t1, bk_user_charge as t2 where t1.cbooksid = t2.cbooksid and t1.ifunsid = t2.ifunsid and t1.ichargeid != t2.ichargeid and t1.ibillid in ('13', '14') and t2.ichargeid = ?", chargeId];
            }
        } else { // 个人账本
            rs = [db executeQuery:@"select fi.cacctname, bt.cbooksname from bk_user_charge as uc, bk_fund_info as fi, bk_books_type as bt where uc.ifunsid = fi.cfundid and uc.cbooksid = bt.cbooksid and uc.ichargeid = ?", item.ID];
            while ([rs next]) {
                item.fundName = [rs stringForColumn:@"cacctname"];
                item.booksName = [rs stringForColumn:@"cbooksname"];
            }
            [rs close];
            
            rs = [db executeQuery:@"select a.* , b.* from bk_member_charge as a , bk_member as b where a.ichargeid = ? and a.cmemberid = b.cmemberid and b.cuserid = ?", chargeId, SSJUSERID()];
            if (!rs) {
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            }
            
            NSMutableArray *memberItems = [NSMutableArray arrayWithCapacity:0];
            while ([rs next]) {
                SSJChargeMemberItem *memberItem = [[SSJChargeMemberItem alloc]init];
                memberItem.memberId = [rs stringForColumn:@"cmemberId"];
                memberItem.memberName = [rs stringForColumn:@"cname"];
                memberItem.memberColor = [rs stringForColumn:@"ccolor"];
                [memberItems addObject:memberItem];
            }
            [rs close];
            
            if (!memberItems.count) {
                SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
                item.memberId = [NSString stringWithFormat:@"%@-0",SSJUSERID()];
                item.memberName = @"我";
                item.memberColor = @"#fc7a60";
                [memberItems addObject:item];
            }
            item.membersItem = memberItems;
        }
        
        if (success) {
            SSJDispatch_main_async_safe(^(){
                success(item);
            })
        }
    }];
}

+ (void)deleteChargeWithItem:(SSJBillingChargeCellItem *)item
                     success:(nullable void(^)())success
                     failure:(nullable void(^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db , BOOL *rollback) {
        NSString *userId = SSJUSERID();
        NSString *booksId = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",userId];
        if (!booksId.length) {
            booksId = userId;
        }
        
        if (![db executeUpdate:@"UPDATE BK_USER_CHARGE SET OPERATORTYPE = 2 , CWRITEDATE = ? , IVERSION = ? WHERE ICHARGEID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],@(SSJSyncVersion()),item.ID]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if ([db intForQuery:@"SELECT ITYPE FROM BK_BILL_TYPE WHERE ID = ?",item.billId]) {
            if (![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET EXPENCEAMOUNT = EXPENCEAMOUNT - ? , SUMAMOUNT = SUMAMOUNT + ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ?",[NSNumber numberWithDouble:[item.money doubleValue]],[NSNumber numberWithDouble:[item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],item.billDate,booksId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            };
        } else {
            if (![db executeUpdate:@"UPDATE BK_DAILYSUM_CHARGE SET INCOMEAMOUNT = INCOMEAMOUNT - ? , SUMAMOUnT = SUMAMOUNT - ? , CWRITEDATE = ? WHERE CBILLDATE = ? and cbooksid = ?",[NSNumber numberWithDouble:[item.money doubleValue]],[NSNumber numberWithDouble:[item.money doubleValue]],[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],item.billDate,booksId]) {
                *rollback = YES;
                if (failure) {
                    SSJDispatchMainAsync(^{
                        failure([db lastError]);
                    });
                }
                return;
            };
        }
        
        if (![db executeUpdate:@"DELETE FROM BK_DAILYSUM_CHARGE WHERE SUMAMOUNT = 0 AND INCOMEAMOUNT = 0 AND EXPENCEAMOUNT = 0"]) {
            *rollback = YES;
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success();
            });
        }
    }];
}

+ (void)queryShareBookStateWithBooksId:(NSString *)booksId
                              memberId:(NSString *)memberId
                               success:(void(^)(SSJShareBooksMemberState state))success
                               failure:(nullable void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select istate from bk_share_books_member where cmemberid = ? and cbooksid = ?", memberId, booksId];
        if (!rs) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        
        SSJShareBooksMemberState state = SSJShareBooksMemberStateNormal;
        BOOL existed = NO;
        while ([rs next]) {
            existed = YES;
            state = [rs intForColumn:@"istate"];
        }
        [rs close];
        
        if (!existed) {
            if (failure) {
                SSJDispatchMainAsync(^{
                    failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"不存在查询的记录"}]);
                });
            }
            return;
        }
        
        if (success) {
            SSJDispatchMainAsync(^{
                success(state);
            });
        }
    }];
}

@end
