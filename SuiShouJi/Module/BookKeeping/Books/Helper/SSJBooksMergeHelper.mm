//
//  SSJBooksMergeHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksMergeHelper.h"
#import <WCDB/WCDB.h>
#import "SSJUserChargeTable.h"
#import "SSJUserBillTypeTable.h"
#import "SSJChargePeriodConfigTable.h"
#import "SSJBooksTypeTable.h"
#import "SSJShareBooksTable.h"
#import "SSJShareBooksMemberTable.h"
#import "SSJBooksTypeItem.h"
#import "SSJShareBookItem.h"



@interface SSJBooksMergeHelper()

@property (nonatomic, strong) WCTDatabase *db;

@end

@implementation SSJBooksMergeHelper

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startMergeWithSourceBooksId:(NSString *)sourceBooksId
                      targetBooksId:(NSString *)targetBooksId
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure {
    @weakify(self);
    [self.db runTransaction:^BOOL{
        @strongify(self);
        
        NSString *userId = SSJUSERID();
        
        
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSMutableIndexSet *sameNameIndexs = [NSMutableIndexSet indexSet];
        
        NSMutableDictionary *sameNameDic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        // 取出所有用到的记账类型
        NSMutableArray *userBillTypeArr = [[self.db getObjectsOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE" where:SSJUserBillTypeTable.billId.in([self.db getOneDistinctColumnOnResult:SSJUserChargeTable.billId
                                                                                                                                                                                         fromTable:@"BK_USER_CHARGE"
                                                                                                                                                                                             where:SSJUserChargeTable.userId.inTable(@"bk_user_charge") == userId
                                                                                                                                                              && SSJUserChargeTable.operatorType.inTable(@"bk_user_charge") != 2
                                                                                                                                                              && SSJUserChargeTable.booksId == sourceBooksId])
                                    && SSJUserBillTypeTable.billId.notIn([self.db getOneDistinctColumnOnResult:SSJUserBillTypeTable.billId fromTable:@"BK_USER_BILL_TYPE"
                                                                                                         where:SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE") == userId
                                                                                                                                                                                                                                                     && SSJUserBillTypeTable.operatorType.inTable(@"BK_USER_BILL_TYPE") != 2
                                                                                                                                                                                                                                                     && SSJUserBillTypeTable.booksId == targetBooksId])] mutableCopy];
        
        for (SSJUserBillTypeTable *userBill in userBillTypeArr) {
            NSInteger currentIndex = [userBillTypeArr indexOfObject:userBill];
            userBill.booksId = targetBooksId;
            userBill.writeDate = writeDate;
            userBill.version = SSJSyncVersion();
            SSJUserBillTypeTable *sameNameBill = [self.db getOneObjectOfClass:SSJUserBillTypeTable.class fromTable:@"BK_USER_BILL_TYPE"
                                                                        where:SSJUserBillTypeTable.billName == userBill.billName
                                                  && SSJUserBillTypeTable.booksId == sourceBooksId];
            if (sameNameBill) {
                [sameNameDic setObject:userBill.billId forKey:sameNameBill.billId];
                [sameNameIndexs addIndex:currentIndex];
            }
            
        }
        
        [userBillTypeArr removeObjectsAtIndexes:sameNameIndexs];
        
        [self.db insertOrReplaceObjects:userBillTypeArr into:@"BK_USER_BILL_TYPE"];

        
        // 取出账本中所有的流水
        NSArray *chargeArr = [self.db getObjectsOfClass:SSJUserChargeTable.class fromTable:@"BK_USER_CHARGE"
                                                  where:SSJUserChargeTable.userId == userId
                                                  && SSJUserChargeTable.booksId == sourceBooksId
                                                  && SSJUserChargeTable.operatorType != 2];
        
        for (SSJUserChargeTable *userCharge in chargeArr) {
            userCharge.booksId = targetBooksId;
            userCharge.writeDate = writeDate;
            userCharge.version = SSJSyncVersion();
            if ([sameNameDic objectForKey:userCharge.billId]) {
                userCharge.billId = [sameNameDic objectForKey:userCharge.billId];
            }
            
            [self.db updateAllRowsInTable:@"BK_USER_CHARGE" onProperties:SSJUserChargeTable.AllProperties withObject:userCharge];
        }
        
        // 取出账本中所有的流水
        NSArray *periodChargeArr = [self.db getObjectsOfClass:SSJChargePeriodConfigTable.class fromTable:@"BK_CHARGE_PERIOD_CONFIG"
                                                  where:SSJChargePeriodConfigTable.userId == userId
                              && SSJChargePeriodConfigTable.booksId == sourceBooksId
                              && SSJChargePeriodConfigTable.operatorType != 2];
        
        for (SSJChargePeriodConfigTable *chargePeriod in chargeArr) {
            chargePeriod.booksId = targetBooksId;
            chargePeriod.writeDate = writeDate;
            chargePeriod.version = SSJSyncVersion();
            if ([sameNameDic objectForKey:chargePeriod.billId]) {
                chargePeriod.billId = [sameNameDic objectForKey:chargePeriod.billId];
            }
            
            [self.db updateAllRowsInTable:@"BK_CHARGE_PERIOD_CONFIG" onProperties:SSJChargePeriodConfigTable.AllProperties withObject:chargePeriod];
        }

    }];
}


- (NSNumber *)getChargeCountForBooksId:(NSString *)booksId {
    NSString *userId = SSJUSERID();
    NSNumber *chargeCount = [self.db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count() fromTable:@"BK_USER_CHARGE"
                                                   where:SSJUserChargeTable.userId == userId
                             && SSJUserChargeTable.booksId == booksId
                             && SSJUserChargeTable.operatorType == 2];
    return chargeCount;
}

- (NSArray *)getAllBooksItem {
    NSString *userId = SSJUSERID();
    
    NSMutableArray *booksItems = [NSMutableArray arrayWithCapacity:0];
    
    NSArray *normalBooksArr = [self.db getObjectsOfClass:SSJBooksTypeTable.class fromTable:@"BK_BOOKS_TYPE" where:SSJBooksTypeTable.userId == userId && SSJBooksTypeTable.operatorType != 2];
    
    for (SSJBooksTypeTable *booksType in normalBooksArr) {
        SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc] init];
        item.booksId = booksType.booksId;
        item.booksName = booksType.booksName;
        item.booksParent = booksType.parentType;
        NSString *startColor = [[booksType.booksColor componentsSeparatedByString:@","] firstObject];
        NSString *endColor = [[booksType.booksColor componentsSeparatedByString:@","] lastObject];
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = startColor;
        colorItem.endColor = endColor;
        item.booksColor = colorItem;
        [booksItems addObject:item];
    }
    
    NSArray *shareBooksArr = [self.db getObjectsOfClass:SSJShareBooksTable.class fromTable:@"BK_SHARE_BOOKS" where:SSJBooksTypeTable.booksId.in([self.db getOneDistinctColumnOnResult:SSJShareBooksMemberTable.booksId fromTable:@""
                                                                                                                                                                                where:SSJShareBooksMemberTable.memberId == userId
                                                                                                                                                 && SSJShareBooksMemberTable.memberState == SSJShareBooksMemberStateNormal])];
    
    for (SSJShareBooksTable *shareBooksType in shareBooksArr) {
        SSJShareBookItem *item = [[SSJShareBookItem alloc] init];
        item.booksId = shareBooksType.booksId;
        item.booksName = shareBooksType.booksName;
        item.booksParent = shareBooksType.booksParent;
        NSString *startColor = [[shareBooksType.booksColor componentsSeparatedByString:@","] firstObject];
        NSString *endColor = [[shareBooksType.booksColor componentsSeparatedByString:@","] lastObject];
        SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
        colorItem.startColor = startColor;
        colorItem.endColor = endColor;
        item.booksColor = colorItem;
        [booksItems addObject:item];
    }

    return booksItems;
}

- (WCTDatabase *)db {
    if (!_db) {
        _db = [[WCTDatabase alloc] initWithPath:SSJSQLitePath()];
    }
    return _db;
}

@end