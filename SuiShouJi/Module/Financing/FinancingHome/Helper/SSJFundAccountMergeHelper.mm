//
//  SSJFundAccountMergeHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundAccountMergeHelper.h"
#import <WCDB/WCDB.h>
#import "SSJFundInfoTable.h"
#import "SSJUserChargeTable.h"
#import "SSJTransferCycleTable.h"
#import "SSJChargePeriodConfigTable.h"
#import "SSJLoanTable.h"

@interface SSJFundAccountMergeHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJFundAccountMergeHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startMergeWithSourceBooksId:(NSString *)sourceFundId
                      targetBooksId:(NSString *)targetFundId
                            Success:(void(^)())success
                            failure:(void (^)(NSError *error))failure {
    @weakify(self);
    [self.db runTransaction:^BOOL{
        @strongify(self);
        
        NSString *userId = SSJUSERID();
        
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        // 取出账本中所有的流水
        NSArray *chargeArr = [self.db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == userId
                              && SSJUserChargeTable.fundId == sourceFundId
                              && SSJUserChargeTable.operatorType != 2];
        
        for (SSJUserChargeTable *userCharge in chargeArr) {
            userCharge.fundId = targetFundId;
            userCharge.writeDate = writeDate;
            userCharge.version = SSJSyncVersion();
            
            if (![self.db updateAllRowsInTable:@"BK_USER_CHARGE" onProperties:SSJUserChargeTable.AllProperties withObject:userCharge]) {
                dispatch_main_async_safe(^{
                    if (failure) {
                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并流水失败"}]);
                    }
                });
                return NO;
            };
        }
        
        
        // 取出所有的转账
        NSArray *transferArr = [self.db getObjectsOfClass:SSJTransferCycleTable.class fromTable:@"BK_TRANSFER_CYCLE"
                                                  where:SSJTransferCycleTable.userId == userId
                                && (SSJTransferCycleTable.transferInId == sourceFundId
                                    || SSJTransferCycleTable.transferOutId == sourceFundId
                                    )
                              && SSJTransferCycleTable.operatorType != 2];

        for (SSJTransferCycleTable *transfer in transferArr) {
            transfer.writeDate = writeDate;
            transfer.version = SSJSyncVersion();
            if ([transfer.transferInId isEqualToString:sourceFundId]) {
                transfer.transferInId = targetFundId;
            } else if ([transfer.transferOutId isEqualToString:sourceFundId]) {
                transfer.transferOutId = targetFundId;
            }
            
            if (![transfer.transferInId isEqualToString:transfer.transferOutId]) {
                if (![self.db updateRowsInTable:@"BK_TRANSFER_CYCLE" onProperties:{
                    SSJTransferCycleTable.writeDate,
                    SSJTransferCycleTable.version,
                    SSJTransferCycleTable.transferInId,
                    SSJTransferCycleTable.transferOutId
                } withObject:transfer where:SSJTransferCycleTable.cycleId == transfer.cycleId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并转账失败"}]);
                        }
                    });
                    return NO;
                };

            } else {
                transfer.operatorType = 2;
                if (![self.db updateRowsInTable:@"BK_TRANSFER_CYCLE" onProperties:{
                    SSJTransferCycleTable.writeDate,
                    SSJTransferCycleTable.version,
                    SSJTransferCycleTable.transferInId,
                    SSJTransferCycleTable.transferOutId,
                    SSJTransferCycleTable.operatorType
                } withObject:transfer where:SSJTransferCycleTable.cycleId == transfer.cycleId]) {
                    dispatch_main_async_safe(^{
                        if (failure) {
                            failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并转账失败"}]);
                        }
                    });
                    return NO;
                };
            }
        }
        
        // 取出所有的周期记账
        NSArray *periodChargeArr = [self.db getObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                    where:SSJChargePeriodConfigTable.userId == userId
                                && SSJChargePeriodConfigTable.fundId == sourceFundId
                                && SSJChargePeriodConfigTable.operatorType != 2];
        
        for (SSJChargePeriodConfigTable *periodCharge in periodChargeArr) {
            periodCharge.writeDate = writeDate;
            periodCharge.version = SSJSyncVersion();
            periodCharge.billId = targetFundId;
            
            if (![self.db updateAllRowsInTable:@"BK_CHARGE_PERIOD_CONFIG" onProperties:SSJChargePeriodConfigTable.AllProperties withObject:periodCharge]) {
                dispatch_main_async_safe(^{
                    if (failure) {
                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并周期记账失败"}]);
                    }
                });
                return NO;
            };
            
        }
        
        // 取出所有的借贷
        NSArray *loanArr = [self.db getObjectsOfClass:SSJLoanTable.class fromTable:@"BK_LOAN"
                                                    where:SSJLoanTable.userId == userId
                                && (SSJLoanTable.targetFundid == sourceFundId
                                    || SSJLoanTable.endTargetFundid == sourceFundId
                                    )
                                && SSJLoanTable.operatorType != 2];
        
        for (SSJLoanTable *loan in transferArr) {
            loan.writeDate = writeDate;
            loan.version = SSJSyncVersion();
            if ([loan.targetFundid isEqualToString:sourceFundId]) {
                loan.targetFundid = targetFundId;
            } else if ([loan.endTargetFundid isEqualToString:sourceFundId]) {
                loan.endTargetFundid = targetFundId;
            }
            
            if (![self.db updateRowsInTable:@"BK_LOAN" onProperties:{
                SSJLoanTable.writeDate,
                SSJLoanTable.version,
                SSJLoanTable.targetFundid,
                SSJLoanTable.endTargetFundid
            } withObject:loan where:SSJLoanTable.loanId == loan.loanId]) {
                dispatch_main_async_safe(^{
                    if (failure) {
                        failure([NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"合并失败"}]);
                    }
                });
                return NO;
            };
            }


        if (success) {
            success();
        }
        
        return YES;
        
    }];
}

- (NSArray *)getFundingsWithType:(BOOL)fundType exceptFundId:(NSString *)exceptFundId{
    NSString *userId = SSJUSERID();
    
    NSArray *funsArr = [NSArray array];
    
    if (fundType) {
        funsArr = [self.db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                                where:SSJFundInfoTable.userId == userId
                   && SSJFundInfoTable.fundParent.notIn(@[@"3",@"10",@"11",@"9",@"16"])
                   && SSJFundInfoTable.operatorType != 2
                   && SSJFundInfoTable.fundParent != @"root"
                   && SSJFundInfoTable.fundId != exceptFundId];
    } else {
        funsArr = [self.db getObjectsOfClass:SSJFundInfoTable.class fromTable:@"BK_FUND_INFO"
                                       where:SSJFundInfoTable.userId == userId
                   && SSJFundInfoTable.fundParent.in(@[@"3",@"16"])
                   && SSJFundInfoTable.operatorType != 2
                   && SSJFundInfoTable.fundParent != @"root"
                   && SSJFundInfoTable.fundId != exceptFundId];
    }
    
    return funsArr;
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}



@end
