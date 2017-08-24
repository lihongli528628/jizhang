//
//  SSJRecycleHelper.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJRecycleModel.h"
#import "SSJRecycleListModel.h"
#import "SSJRecycleListCell.h"

@interface _SSJRecycleTransferModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *targetFundID;

@end

@implementation _SSJRecycleTransferModel
@end



@interface _SSJRecycleChargeModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *fundID;

@property (nonatomic, copy) NSString *sundryID;

@end

@implementation _SSJRecycleChargeModel
@end



@implementation SSJRecycleHelper

+ (void)queryRecycleListModelsWithSuccess:(void(^)(NSArray<SSJRecycleListModel *> *models))success
                                  failure:(nullable void(^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        NSMutableArray *models = [NSMutableArray array];
        FMResultSet *rs = [db executeQuery:@"select * from bk_recycle where cuserid = ? and operatortype = ? order by clientadddate desc", SSJUSERID(), @(SSJRecycleStateNormal)];
        while ([rs next]) {
            [models addObject:[SSJRecycleModel modelWithResultSet:rs]];
        }
        [rs close];
        
        NSMutableArray *resultModels = [NSMutableArray array];
        NSMutableArray *cellItems = [NSMutableArray array];
        NSDate *lastDate = nil;
        
        NSError *error = nil;
        for (SSJRecycleModel *model in models) {
            SSJRecycleListCellItem *cellItem = nil;
            switch (model.type) {
                case SSJRecycleTypeCharge:
                    cellItem = [self chargeItemWithRecycleModel:model inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeFund:
                    cellItem = [self fundItemWithRecycleModel:model inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeBooks:
                    cellItem = [self booksItemWithRecycleModel:model inDatabase:db error:&error];
                    break;
            }
            
            if (error) {
                SSJDispatchMainAsync(^{
                    if (failure) {
                        failure(error);
                    }
                });
                return;
            }
            
            if (lastDate && ![model.clientAddDate isSameDay:lastDate]) {
                SSJRecycleListModel *listModel = [[SSJRecycleListModel alloc] init];
                NSDate *now = [NSDate date];
                if ([lastDate isSameDay:now]) {
                    listModel.dateStr = @"今天";
                } else if ([lastDate isSameDay:[now dateBySubtractingDays:1]]) {
                    listModel.dateStr = @"昨天";
                } else {
                    listModel.dateStr = [lastDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm"];
                }
                listModel.cellItems = cellItems;
                [resultModels addObject:listModel];
                
                cellItems = [NSMutableArray array];
            }
            
            [cellItems addObject:cellItem];
            lastDate = model.clientAddDate;
        }
        
        SSJRecycleListModel *listModel = [[SSJRecycleListModel alloc] init];
        NSDate *now = [NSDate date];
        if ([lastDate isSameDay:now]) {
            listModel.dateStr = @"今天";
        } else if ([lastDate isSameDay:[now dateBySubtractingDays:1]]) {
            listModel.dateStr = @"昨天";
        } else {
            listModel.dateStr = [lastDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm"];
        }
        listModel.cellItems = cellItems;
        [resultModels addObject:listModel];
        
        SSJDispatchMainAsync(^{
            if (success) {
                success(resultModels);
            }
        });
    }];
}

+ (SSJRecycleListCellItem *)chargeItemWithRecycleModel:(SSJRecycleModel *)model inDatabase:(SSJDatabase *)db error:(NSError **)error {
    FMResultSet *rs = [db executeQuery:@"select uc.imoney, uc.cbooksid, ub.cicoin, ub.ccolor, ub.cname, fi.cacctname from bk_user_charge as uc, bk_user_bill_type as ub, bk_fund_info as fi where uc.ibillid = ub.cbillid and uc.cbooksid = ub.cbooksid and uc.cuserid = ub.cuserid and uc.ifunsid = fi.cfundid and uc.ichargeid = ? and uc.cuserid = ?", model.sundryID, model.userID];
    
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *billName = nil;
    NSString *money = nil;
    NSString *fundName = nil;
    NSString *booksID = nil;
    
    while ([rs next]) {
        iconName = [rs stringForColumn:@"cicoin"];
        colorValue = [rs stringForColumn:@"ccolor"];
        billName = [rs stringForColumn:@"cname"];
        money = [rs stringForColumn:@"imoney"];
        fundName = [rs stringForColumn:@"cacctname"];
        booksID = [rs stringForColumn:@"cbooksid"];
    }
    [rs close];
    
    NSString *booksName = nil;
    NSString *memberName = nil;
    
    BOOL isShareBooks = [db executeQuery:@"select count(1) from bk_share_books where cbooksid = ?", booksID];
    if (isShareBooks) {
        booksName = [db stringForQuery:@"select cbooksname from bk_share_books where cbooksid = ?", booksID];
        booksName = [NSString stringWithFormat:@"%@(共享)", booksName];
        memberName = @"我";
    } else {
        booksName = [db stringForQuery:@"select cbooksname from bk_books_type where cbooksid = ? and cuserid = ?", booksID, model.userID];
        booksName = [NSString stringWithFormat:@"%@(个人)", booksName];
        
        rs = [db executeQuery:@"select m.cname from bk_user_charge as uc, bk_member_charge as mc, bk_member as m where uc.ichargeid = mc.ichargeid and mc.cmemberid = m.cmemberid and uc.ichargeid = ?", model.sundryID];
        NSMutableArray *memberNames = [NSMutableArray array];
        while ([rs next]) {
            [memberNames addObject:[rs stringForColumn:@"cname"]];
        }
        [rs close];
        memberName = [memberNames componentsJoinedByString:@","];
    }
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:[NSString stringWithFormat:@"%@ %.2f", billName, [money doubleValue]]
                                                                   subtitles:@[booksName, fundName, memberName]
                                                                       state:SSJRecycleListCellStateNormal];
    
    return item;
}

+ (SSJRecycleListCellItem *)fundItemWithRecycleModel:(SSJRecycleModel *)model inDatabase:(SSJDatabase *)db error:(NSError **)error {
    
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *fundName = nil;
    int parent = 0;
    
    NSMutableArray *subtitles = [NSMutableArray array];
    
    FMResultSet *rs = [db executeQuery:@"select fi.cicoin, fi.cacctname, fi.ccolor, fi.cparent, count(uc.*) as chargecount from bk_fund_info as fi, bk_user_charge as uc where fi.cfundid = uc.ifunsid and uc.operatortype <> 2 and fi.cfundid = ?", model.sundryID];
    while ([rs next]) {
        iconName = [rs stringForColumn:@"cicoin"];
        colorValue = [rs stringForColumn:@"ccolor"];
        fundName = [rs stringForColumn:@"cacctname"];
        parent = [rs intForColumn:@"cparent"];
        [subtitles addObject:[NSString stringWithFormat:@"%d条流水", [rs intForColumn:@"chargecount"]]];
    }
    [rs close];
    
    if ([db boolForQuery:@"select count(*) from bk_charge_period_config where ifunsid = ?", model.sundryID]) {
        [subtitles addObject:@"周期记账"];
    }
    
    if (parent == SSJFinancingParentPaidLeave
        || parent == SSJFinancingParentDebt) {
        if ([db boolForQuery:@"select count(*) from bk_loan where cthefundid = ? and length(cremindid) > 0", model.sundryID]) {
            [subtitles addObject:@"提醒"];
        }
    } else if (parent == SSJFinancingParentCreditCard) {
        if ([db boolForQuery:@"select count(*) from bk_user_credit where cfundid = ? and length(cremindid) > 0", model.sundryID]) {
            [subtitles addObject:@"提醒"];
        }
    } else if (parent == SSJFinancingParentFixedEarnings) {
        if ([db boolForQuery:@"select count(*) from bk_fixed_finance_product where cthisfundid = ? and length(cremindid) > 0", model.sundryID]) {
            [subtitles addObject:@"提醒"];
        }
    }
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:fundName
                                                                   subtitles:subtitles
                                                                       state:SSJRecycleListCellStateNormal];
    return item;
}

+ (SSJRecycleListCellItem *)booksItemWithRecycleModel:(SSJRecycleModel *)model inDatabase:(SSJDatabase *)db error:(NSError **)error {
    
    NSString *iconName = nil;
    NSString *colorValue = nil;
    NSString *bookName = nil;
    NSMutableArray *subtitles = [NSMutableArray array];
    
    if ([db boolForQuery:@"select count(*) from bk_share_books where cbooksid = ?", model.sundryID]) {
        FMResultSet *rs = [db executeQuery:@"select sb.cbooksname, sb.cbookscolor, sb.iparenttype, count(uc.*) as chargecount from bk_share_books as sb, bk_user_charge as uc where sb.cbooksid = uc.cbooksid and uc.operatortype <> 2 and sb.cbooksid = ?", model.sundryID];
        while ([rs next]) {
            iconName = SSJImageNameForBooksType([rs intForColumn:@"iparenttype"]);
            colorValue = [rs stringForColumn:@"cbookscolor"];
            bookName = [rs stringForColumn:@"cbooksname"];
            [subtitles addObject:[NSString stringWithFormat:@"%d条流水", [rs intForColumn:@"chargecount"]]];
        }
        [subtitles addObject:@"共享账本"];
        [rs close];
    } else {
        FMResultSet *rs = [db executeQuery:@"select bt.cbooksname, bt.cbookscolor, bt.iparenttype, count(uc.*) as chargecount from bk_books_type as bt, bk_user_charge as uc where bt.cbooksid = uc.cbooksid and uc.operatortype <> 2 and bt.cbooksid = ?", model.sundryID];
        while ([rs next]) {
            iconName = SSJImageNameForBooksType([rs intForColumn:@"iparenttype"]);
            colorValue = [rs stringForColumn:@"cbookscolor"];
            bookName = [rs stringForColumn:@"cbooksname"];
            [subtitles addObject:[NSString stringWithFormat:@"%d条流水", [rs intForColumn:@"chargecount"]]];
        }
        [subtitles addObject:@"个人账本"];
        [rs close];
    }
    
    SSJRecycleListCellItem *item = [SSJRecycleListCellItem itemWithRecycleID:model.ID
                                                                        icon:[UIImage imageNamed:iconName]
                                                               iconTintColor:[UIColor ssj_colorWithHex:colorValue]
                                                                       title:bookName
                                                                   subtitles:subtitles
                                                                       state:SSJRecycleListCellStateNormal];
    return item;
}

+ (void)recoverWithRecycleIDs:(NSArray<NSString *> *)recycleIDs
                      success:(nullable void(^)())success
                      failure:(nullable void(^)(NSError *error))failure {
    
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
        for (NSString *recycleID in recycleIDs) {
            
            SSJRecycleModel *recycleModel = nil;
            
            FMResultSet *rs = [db executeQuery:@"select * from bk_recycle where rid = ?", recycleIDs];
            while ([rs next]) {
                recycleModel = [SSJRecycleModel modelWithResultSet:rs];
            }
            [rs close];
            
            NSError *error = nil;
            switch (recycleModel.type) {
                case SSJRecycleTypeCharge:
                    [self recoverChargeWithRecycleModel:recycleModel inDatabase:db error:&error];
                    break;
                    
                case SSJRecycleTypeFund:
                    
                    break;
                    
                case SSJRecycleTypeBooks:
                    
                    break;
            }
        }
    }];
}

+ (void)recoverChargeWithRecycleModel:(SSJRecycleModel *)recycleModel
                           inDatabase:(SSJDatabase *)db
                                error:(NSError **)error {
    
    if ([db intForQuery:@"select operatortype from bk_user_charge where ichargeid = ?", recycleModel.sundryID] != 2) {
        return;
    }
    
    NSString *writeDateStr = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 如果流水依赖的资金账户也被删除了，先恢复资金账户
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge wehre ichargeid = ?) and operatortype = 2", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 如果流水依赖的共享账本也被删除了，先恢复账本
    if (![db executeUpdate:@"update bk_books_type set operatortype = 1, cwritedate = ?, iversion = ? where cbooksid = (select cbooksid from bk_user_charge where ichargeid = ?) and cuserid = ? and operatortype = 2", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID, recycleModel.userID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 如果流水依赖的个人账本也被删除了，先恢复账本
    if (![db executeUpdate:@"update bk_share_books set operatortype = 1, cwritedate = ?, iversion = ? where cbooksid = (select cbooksid from bk_user_charge where ichargeid = ?) and operatortype = 2", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 将流水恢复
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ichargeid = ?", writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复回收站记录
    if (![db executeUpdate:@"update bk_recycle set operatortype = ?, cwritedate = ?, iversion = ? where ichargeid = ?", @(SSJRecycleStateRecovered), writeDateStr, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
}

+ (void)recoverFundWithRecycleModel:(SSJRecycleModel *)recycleModel
                         inDatabase:(SSJDatabase *)db
                              error:(NSError **)error {
    NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString *clientDate = [db stringForQuery:@"select clientadddate from bk_recycle where rid = ?", recycleModel.ID];
    
    // 恢复资金账户
    if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 如果此账户是信用卡账户，还要恢复信用卡表中的记录
    if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复回收站记录
    if (![db executeUpdate:@"update bk_recycle set operatortype = ?, cwritedate = ?, iversion = ? where rid = ?", @(SSJRecycleStateRecovered), writeDate, @(SSJSyncVersion()), recycleModel.ID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // 恢复普通流水／周期记账流水
    if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where ifunsid = ? and cwritedate = ? and (ichargetype = ? or ichargetype = ?) and operatortype = 2", writeDate, @(SSJSyncVersion()), recycleModel.sundryID, clientDate, @(SSJChargeIdTypeNormal), @(SSJChargeIdTypeCircleConfig)]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
    // ------------------------------------- 周期转账 begin ------------------------------------- //
    // 查询已删除的周期转账配置
    NSMutableArray *transferModels = [NSMutableArray array];
    FMResultSet *rs = [db executeQuery:@"select icycleid, ctransferinaccountid, ctransferoutaccountid from bk_transfer_cycle where cwritedate = ? and (ctransferinaccountid = ? or ctransferoutaccountid = ?) and operatortype = 2", clientDate, recycleModel.sundryID, recycleModel.sundryID];
    while ([rs next]) {
        _SSJRecycleTransferModel *model = [[_SSJRecycleTransferModel alloc] init];
        model.ID = [rs stringForColumn:@"icycleid"];
        NSString *transferInID = [rs stringForColumn:@"ctransferinaccountid"];
        NSString *transferOutID = [rs stringForColumn:@"ctransferoutaccountid"];
        model.targetFundID = [recycleModel.sundryID isEqualToString:transferInID] ? transferOutID : transferInID;
        [transferModels addObject:model];
    }
    [rs close];
    
    for (_SSJRecycleTransferModel *model in transferModels) {
        // 恢复周期转账配置对应的目标资金账户
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.targetFundID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.targetFundID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复周期转账配置
        if (![db executeUpdate:@"update bk_transfer_cycle set operatortype = 1, cwritedate = ?, iversion = ? where icycleid = ?", writeDate, @(SSJSyncVersion()), model.ID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
    }
    
    // 查询此账户下已删除的周期转账流水
    NSMutableArray *chargeModels = [NSMutableArray array];
    rs = [db executeQuery:@"select ichargeid, cid from bk_user_charge where cwritedate = ? and ichargetype = ? and ifunsid = ? and operatortype = 2", clientDate, @(SSJChargeIdTypeCyclicTransfer), recycleModel.sundryID];
    while ([rs next]) {
        _SSJRecycleChargeModel *model = [[_SSJRecycleChargeModel alloc] init];
        model.ID = [rs stringForColumn:@"ichargeid"];
        model.sundryID = [rs stringForColumn:@"cid"];
        [chargeModels addObject:model];
    }
    [rs close];
    
    for (_SSJRecycleChargeModel *model in chargeModels) {
        // 恢复周期转账流水对应的目标资金账户
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeCyclicTransfer)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeCyclicTransfer)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复所有和此账户关联的周期转账流水
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, @(SSJChargeIdTypeCyclicTransfer), clientDate]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
    }
    // ------------------------------------- 周期转账 end ------------------------------------- //
    
    
    // ------------------------------------- 借贷 begin ------------------------------------- //
    // 查询此账户下已删除的借贷流水
    NSMutableArray *loanChargeModels = [NSMutableArray array];
    rs = [db executeQuery:@"select ichargeid, cid from bk_user_charge where cwritedate = ? and ichargetype = ? and ifunsid = ? and operatortype = 2", clientDate, @(SSJChargeIdTypeLoan), recycleModel.sundryID];
    while ([rs next]) {
        _SSJRecycleChargeModel *model = [[_SSJRecycleChargeModel alloc] init];
        model.ID = [rs stringForColumn:@"ichargeid"];
        model.sundryID = [rs stringForColumn:@"cid"];
        [loanChargeModels addObject:model];
    }
    [rs close];
    
    for (_SSJRecycleChargeModel *model in loanChargeModels) {
        // 恢复借贷流水目标资金账户
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeLoan)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeLoan)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复借贷项目
        NSString *loanID = [[model.sundryID componentsSeparatedByString:@"_"] firstObject];
        if (![db executeUpdate:@"update bk_loan set operatortype = 1, cwritedate = ?, iversion = ? where loanid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), loanID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复借贷流水
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, @(SSJChargeIdTypeLoan), clientDate]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
    }
    // ------------------------------------- 借贷 end ------------------------------------- //
    
    
    // ------------------------------------- 信用卡 begin ------------------------------------- //
    // 查询此账户下已删除的还款流水
    NSMutableArray *creditChargeModels = [NSMutableArray array];
    rs = [db executeQuery:@"select ichargeid, cid from bk_user_charge where cwritedate = ? and ichargetype = ? and ifunsid = ? and operatortype = 2", clientDate, @(SSJChargeIdTypeRepayment), recycleModel.sundryID];
    while ([rs next]) {
        _SSJRecycleChargeModel *model = [[_SSJRecycleChargeModel alloc] init];
        model.ID = [rs stringForColumn:@"ichargeid"];
        model.sundryID = [rs stringForColumn:@"cid"];
        [creditChargeModels addObject:model];
    }
    [rs close];
    
    for (_SSJRecycleChargeModel *model in creditChargeModels) {
        // 恢复还款流水目标资金账户
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeRepayment)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeRepayment)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复还款项目
        if (![db executeUpdate:@"update bk_credit_repayment set operatortype = 1, cwritedate = ?, iversion = ? where crepaymentid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复还款流水
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, @(SSJChargeIdTypeRepayment), clientDate]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
    }
    // ------------------------------------- 信用卡 end ------------------------------------- //
    
    
    // ------------------------------------- 固收理财 begin ------------------------------------- //
    // 查询此账户下已删除的固收理财流水
    NSMutableArray *fixedChargeModels = [NSMutableArray array];
    rs = [db executeQuery:@"select ichargeid, cid from bk_user_charge where cwritedate = ? and ichargetype = ? and ifunsid = ? and operatortype = 2", clientDate, @(SSJChargeIdTypeRepayment), recycleModel.sundryID];
    while ([rs next]) {
        _SSJRecycleChargeModel *model = [[_SSJRecycleChargeModel alloc] init];
        model.ID = [rs stringForColumn:@"ichargeid"];
        model.sundryID = [rs stringForColumn:@"cid"];
        [loanChargeModels addObject:model];
    }
    [rs close];
    
    for (_SSJRecycleChargeModel *model in fixedChargeModels) {
        // 恢复固收理财流水目标资金账户
        if (![db executeUpdate:@"update bk_fund_info set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeFixedFinance)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 如果目标账户是信用卡账户，还要恢复信用卡表中的记录
        if (![db executeUpdate:@"update bk_user_credit set operatortype = 1, cwritedate = ?, iversion = ? where cfundid = (select ifunsid from bk_user_charge where cid = ? and ichargeid <> ? and ichargetype = ? and operatortype = 2) and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, model.ID, @(SSJChargeIdTypeFixedFinance)]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复固收理财项目
        NSString *productID = [[model.sundryID componentsSeparatedByString:@"_"] firstObject];
        if (![db executeUpdate:@"update bk_fixed_finance_product set operatortype = 1, cwritedate = ?, iversion = ? where crepaymentid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), productID]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
        
        // 恢复固收理财流水
        if (![db executeUpdate:@"update bk_user_charge set operatortype = 1, cwritedate = ?, iversion = ? where cid = ? and ichargetype = ? and cwritedate = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), model.sundryID, @(SSJChargeIdTypeFixedFinance), clientDate]) {
            if (error) {
                *error = [db lastError];
            }
            return;
        }
    }
    // ------------------------------------- 固收理财 end ------------------------------------- //
    
    // 恢复提醒
    if (![db executeUpdate:@"update bk_user_remind set operatortype = 1, cwritedate = ?, iversion = ? where cwritedate = ? and cuserid = ? and operatortype = 2", writeDate, @(SSJSyncVersion()), clientDate, recycleModel.userID]) {
        if (error) {
            *error = [db lastError];
        }
        return;
    }
    
#warning TODO
    // 周期记账
}

+ (void)recoverBookWithRecycleModel:(SSJRecycleModel *)recycleModel
                         inDatabase:(SSJDatabase *)db
                              error:(NSError **)error {
    
}

@end
