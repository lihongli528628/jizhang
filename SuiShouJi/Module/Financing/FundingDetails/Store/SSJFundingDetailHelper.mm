//
//  SSJFundingDetailHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//


#import "SSJFundingDetailHelper.h"
#import "SSJBillingChargeCellItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJFundingListDayItem.h"
#import "SSJCreditCardListDetailItem.h"
#import "SSJOrmDatabaseQueue.h"
#import "SSJFundInfoTable.h"
#import "SSJUserCreditTable.h"
#import "SSJUserChargeTable.h"
#import "SSJUserBillTypeTable.h"
#import "SSJShareBooksMemberTable.h"
#import "SSJUserRemindTable.h"
#import "SSJLoanTable.h"
#import "SSJCreditRepaymentTable.h"
#import "SSJReminderItem.h"
#import "SSJCreditCardListFirstLineItem.h"
#import "SSJCreditRepaymentTable.h"
#import "SSJFundingTypeManager.h"
#import "SSJFixedFinanceProductTable.h"


NSString *const SSJFundingDetailDateKey = @"SSJFundingDetailDateKey";
NSString *const SSJFundingDetailRecordKey = @"SSJFundingDetailRecordKey";
NSString *const SSJFundingDetailSumKey = @"SSJFundingDetailSumKey";


@implementation SSJFundingDetailHelper

+ (void)queryDataWithFundTypeID:(NSString *)ID success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data , SSJFinancingHomeitem *fundingItem))success failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        SSJFinancingHomeitem *newItem = [self getFundingItemWithFundId:ID inDataBase:db];

        NSString *userId = SSJUSERID();

        WCTResultList resultList = {
            SSJUserChargeTable.AllProperties.inTable(@"BK_USER_CHARGE"),
            SSJUserBillTypeTable.AllProperties.inTable(@"BK_USER_BILL_TYPE"),
            SSJShareBooksMemberTable.AllProperties.inTable(@"BK_SHARE_BOOKS_MEMBER"),
            SSJLoanTable.AllProperties.inTable(@"BK_LOAN"),
            SSJFixedFinanceProductTable.AllProperties.inTable(@"BK_FIXED_FINANCE_PRODUCT")
        };

        WCDB::JoinClause joinClause = WCDB::JoinClause("BK_USER_CHARGE").join("BK_USER_BILL_TYPE" , WCDB::JoinClause::Type::Inner).on(SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.billId.inTable(@"BK_USER_BILL_TYPE") && ((SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.booksId.inTable(@"BK_USER_BILL_TYPE") && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE")) || SSJUserBillTypeTable.billId.length() < 4) && SSJUserBillTypeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUSERID() && SSJUserChargeTable.operatorType.inTable(@"BK_USER_CHARGE") != 2 && SSJUserChargeTable.fundId == ID);

        joinClause.join("BK_SHARE_BOOKS_MEMBER" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.booksId.inTable(@"BK_SHARE_BOOKS_MEMBER") && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.memberId.inTable(@"BK_SHARE_BOOKS_MEMBER"));

        joinClause.join("BK_LOAN" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.cid.inTable(@"BK_USER_CHARGE") == SSJLoanTable.loanId.inTable(@"BK_LOAN"));
        
        joinClause.join("BK_FIXED_FINANCE_PRODUCT" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.cid.inTable(@"BK_USER_CHARGE").like(SSJFixedFinanceProductTable.productId.concat(@"%%")));

        WCDB::OrderList orderList = {SSJUserChargeTable.billDate.inTable(@"BK_USER_CHARGE").order(WCTOrderedDescending),SSJUserChargeTable.writeDate.inTable(@"BK_USER_CHARGE").order(WCTOrderedDescending)};

        WCDB::StatementSelect statementSelect = WCDB::StatementSelect().select(resultList).from(joinClause).where((SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER") == SSJShareBooksMemberStateNormal || SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER").isNull() || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"13" || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"14") && (SSJUserChargeTable.billDate.inTable(@"BK_USER_CHARGE") <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"])).orderBy(orderList);

        WCTStatement *statement = [db prepare:statementSelect];

        NSMutableArray *result = [NSMutableArray array];
        NSString *lastDate = @"";
        NSString *lastDetailDate = @"";
        SSJFundingListDayItem *lastDayItem;
        NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];

        if ([statement getError]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([statement getError]);
                }
            });
        }

        NSMutableArray *chargeArr = [NSMutableArray arrayWithCapacity:0];

        while ([statement step]) {
            SSJBillingChargeCellItem *chargeItem = [self getChargeItemWithStatement:statement];
            [chargeArr addObject:chargeItem];
            NSLog(@"%@" , [chargeItem ssj_debugDescription]);
        }

        for (SSJBillingChargeCellItem *item in chargeArr) {
            if (item.chargeImage.length || item.chargeMemo.length || item.idType == SSJChargeIdTypeFixedFinance || item.idType == SSJChargeIdTypeLoan || item.memberNickname.length) {
                item.rowHeight = 65;
            } else {
                item.rowHeight = 50;
            }
            if (item.idType == SSJChargeIdTypeLoan && item.sundryId.length) {
                // 先判断他是借入还是借出
                if (item.loanType == SSJLoanTypeBorrow) {
                    //借入
                    if ([item.typeName isEqualToString:@"转入"]) {
                        // 对于借入来说转入是创建
                        item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                    } else if ([item.typeName isEqualToString:@"转出"]) {
                        // 转出是结清
                        item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                    } else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]) {
                        item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                    } else if ([item.typeName isEqualToString:@"借贷变更收入"]) {
                        // 变更收入是追加
                        item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                    } else if ([item.typeName isEqualToString:@"借贷变更支出"]) {
                        // 变更支出是收款
                        item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                    } else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]) {
                        // 余额转入转出是余额变更
                        item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                    }
                } else {
                    //借出
                    if ([item.typeName isEqualToString:@"转入"]) {
                        // 对于借入来说转入是结清
                        item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                    } else if ([item.typeName isEqualToString:@"转出"]) {
                        // 转出是创建
                        item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                    } else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]) {
                        item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                    } else if ([item.typeName isEqualToString:@"借贷变更收入"]) {
                        // 变更收入是收款
                        item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                    } else if ([item.typeName isEqualToString:@"借贷变更支出"]) {
                        // 变更支出是追加
                        item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                    } else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]) {
                        // 余额转入转出是余额变更
                        item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                    }
                }
            } else if (item.idType == SSJChargeIdTypeFixedFinance) {
                if ([item.billId isEqualToString:@"3"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeCloseOut;
                } else if ([item.billId isEqualToString:@"4"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeCreate;
                } else if ([item.billId isEqualToString:@"15"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeRedemption;
                } else if ([item.billId isEqualToString:@"16"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeAdd;
                } else if ([item.billId isEqualToString:@"17"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeBalanceInterestIncrease;
                } else if ([item.billId isEqualToString:@"20"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeCloseOutInterest;
                }
            } else {
                if ([item.billId isEqualToString:@"3"]) {
                    NSString *sourceId = [db getOneValueOnResult:SSJUserChargeTable.fundId
                                                       fromTable:@"bk_user_charge"
                                                           where:SSJUserChargeTable.cid == item.sundryId
                                          && SSJUserChargeTable.userId == userId
                                          && SSJUserChargeTable.billId == @"4"];
                    item.transferSource = [db getOneValueOnResult:SSJFundInfoTable.fundName
                                                        fromTable:@"bk_fund_info"
                                                            where:SSJFundInfoTable.fundId == sourceId];
                } else if ([item.billId isEqualToString:@"4"]) {
                    NSString *sourceId = [db getOneValueOnResult:SSJUserChargeTable.fundId
                                                       fromTable:@"bk_user_charge"
                                                           where:SSJUserChargeTable.cid == item.sundryId
                                          && SSJUserChargeTable.userId == userId
                                          && SSJUserChargeTable.billId == @"3"];
                    item.transferSource = [db getOneValueOnResult:SSJFundInfoTable.fundName
                                                        fromTable:@"bk_fund_info"
                                                            where:SSJFundInfoTable.fundId == sourceId];
                }
                
            }

            NSString *month = [item.billDate substringWithRange:NSMakeRange(0 , 7)];
            double money = ABS([item.money doubleValue]);
            if ([month isEqualToString:lastDate]) {
                SSJFundingDetailListItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture + money;
                } else {
                    listItem.income = listItem.income + money;
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    SSJFundingListDayItem *dayItem = [tempDateArr firstObject];
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    } else {
                        dayItem.income = dayItem.income + money;
                    }
                    [tempDateArr addObject:item];
                } else {
                    [listItem.chargeArray addObjectsFromArray:tempDateArr];
                    [tempDateArr removeAllObjects];
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc] init];
                    dayItem.rowHeight = 35;
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = money;
                    } else {
                        dayItem.income = money;
                    }
                    lastDetailDate = item.billDate;
                    [tempDateArr addObject:dayItem];
                    [tempDateArr addObject:item];
                }
            } else {
                SSJFundingDetailListItem *lastlistItem = [result lastObject];
                [lastlistItem.chargeArray addObjectsFromArray:tempDateArr];
                [tempDateArr removeAllObjects];
                SSJFundingDetailListItem *listItem = [[SSJFundingDetailListItem alloc] init];
                if ([lastDate isEqualToString:@""]) {
                    listItem.isExpand = YES;
                } else {
                    listItem.isExpand = NO;
                }
                if (item.incomeOrExpence) {
                    listItem.expenture = money;
                } else {
                    listItem.income = money;
                }
                listItem.date = month;
                SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc] init];
                dayItem.rowHeight = 35;
                dayItem.date = item.billDate;
                if (item.incomeOrExpence) {
                    dayItem.expenture = money;
                } else {
                    dayItem.income = money;
                }
                listItem.chargeArray = [NSMutableArray arrayWithCapacity:0];
                lastDetailDate = item.billDate;
                [tempDateArr addObject:dayItem];
                [tempDateArr addObject:item];
                lastDate = month;
                [result addObject:listItem];
            }
        }
        SSJFundingDetailListItem *listItem = [result lastObject];
        [listItem.chargeArray addObjectsFromArray:tempDateArr];
        dispatch_main_async_safe (^{
            if (success) {
                success(result , newItem);
            }
        });
    }];
}

+ (void)queryDataWithCreditCardId:(NSString *)cardId success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data , SSJFinancingHomeitem *cardItem))success failure:(void (^)(NSError *error))failure {
    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        SSJFinancingHomeitem *newItem = [self getFundingItemWithFundId:cardId inDataBase:db];

        NSString *userId = SSJUSERID();

        WCTResultList resultList = {
            SSJUserChargeTable.AllProperties.inTable(@"BK_USER_CHARGE"),
            SSJUserBillTypeTable.AllProperties.inTable(@"BK_USER_BILL_TYPE"),
            SSJShareBooksMemberTable.AllProperties.inTable(@"BK_SHARE_BOOKS_MEMBER"),
            SSJLoanTable.AllProperties.inTable(@"BK_LOAN"),
            SSJFixedFinanceProductTable.AllProperties.inTable(@"BK_FIXED_FINANCE_PRODUCT")
        };

        WCDB::JoinClause joinClause = WCDB::JoinClause("BK_USER_CHARGE").join("BK_USER_BILL_TYPE" , WCDB::JoinClause::Type::Inner).on(SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.billId.inTable(@"BK_USER_BILL_TYPE") && ((SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.booksId.inTable(@"BK_USER_BILL_TYPE") && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE")) || SSJUserBillTypeTable.billId.length() < 4) && SSJUserBillTypeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUSERID() && SSJUserChargeTable.operatorType.inTable(@"BK_USER_CHARGE") != 2 && SSJUserChargeTable.fundId == cardId);

        joinClause.join("BK_SHARE_BOOKS_MEMBER" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.booksId.inTable(@"BK_SHARE_BOOKS_MEMBER") && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.memberId.inTable(@"BK_SHARE_BOOKS_MEMBER"));

        joinClause.join("BK_LOAN" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.cid.inTable(@"BK_USER_CHARGE") == SSJLoanTable.loanId.inTable(@"BK_LOAN"));
        
        joinClause.join("BK_FIXED_FINANCE_PRODUCT" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.cid.inTable(@"BK_USER_CHARGE").like(SSJFixedFinanceProductTable.productId.concat(@"%%")));

        WCDB::OrderList orderList = {SSJUserChargeTable.billDate.inTable(@"BK_USER_CHARGE").order(WCTOrderedDescending),SSJUserChargeTable.writeDate.inTable(@"BK_USER_CHARGE").order(WCTOrderedDescending)};
        
        WCDB::StatementSelect statementSelect = WCDB::StatementSelect().select(resultList).from(joinClause).where((SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER") == SSJShareBooksMemberStateNormal || SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER").isNull() || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"13" || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"14") && (SSJUserChargeTable.billDate.inTable(@"BK_USER_CHARGE") <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"])).orderBy(orderList);

        WCTStatement *statement = [db prepare:statementSelect];

        NSMutableArray *result = [NSMutableArray array];
        NSString *lastPeriod = @"";
        NSString *lastDetailDate = @"";
        SSJFundingListDayItem *lastDayItem;

        if ([statement getError]) {
            dispatch_main_async_safe(^{
                if (failure) {
                    failure([statement getError]);
                }
            });
        }

        NSMutableArray *chargeArr = [NSMutableArray arrayWithCapacity:0];

        while ([statement step]) {
            SSJBillingChargeCellItem *chargeItem = [self getChargeItemWithStatement:statement];
            [chargeArr addObject:chargeItem];
        }
        


        for (SSJBillingChargeCellItem *item in chargeArr) {
            double money = ABS([item.money doubleValue]);
            if (item.chargeImage.length || item.chargeMemo.length || item.idType == SSJChargeIdTypeFixedFinance || item.idType == SSJChargeIdTypeLoan || item.memberNickname.length) {
                item.rowHeight = 65;
            } else {
                item.rowHeight = 50;
            }
            if (item.idType == SSJChargeIdTypeLoan && item.sundryId.length) {
                // 先判断他是借入还是借出
                switch ( item.loanType ) {
                    case SSJLoanTypeLend:
                        //借出
                        if ([item.typeName isEqualToString:@"转入"]) {
                            // 对于借入来说转入是结清
                            item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                        } else if ([item.typeName isEqualToString:@"转出"]) {
                            // 转出是创建
                            item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                        } else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]) {
                            item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                        } else if ([item.typeName isEqualToString:@"借贷变更收入"]) {
                            // 变更收入是收款
                            item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                        } else if ([item.typeName isEqualToString:@"借贷变更支出"]) {
                            // 变更支出是追加
                            item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                        } else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]) {
                            // 余额转入转出是余额变更
                            item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                        }
                        break;

                    case SSJLoanTypeBorrow:
                        //借入
                        if ([item.typeName isEqualToString:@"转入"]) {
                            // 对于借入来说转入是创建
                            item.loanChargeType = SSJLoanCompoundChargeTypeCreate;
                        } else if ([item.typeName isEqualToString:@"转出"]) {
                            // 转出是结清
                            item.loanChargeType = SSJLoanCompoundChargeTypeCloseOut;
                        } else if ([item.typeName isEqualToString:@"借贷利息收入"] || [item.typeName isEqualToString:@"借贷利息支出"]) {
                            item.loanChargeType = SSJLoanCompoundChargeTypeInterest;
                        } else if ([item.typeName isEqualToString:@"借贷变更收入"]) {
                            // 变更收入是追加
                            item.loanChargeType = SSJLoanCompoundChargeTypeAdd;
                        } else if ([item.typeName isEqualToString:@"借贷变更支出"]) {
                            // 变更支出是收款
                            item.loanChargeType = SSJLoanCompoundChargeTypeRepayment;
                        } else if ([item.typeName isEqualToString:@"借贷余额转入"] || [item.typeName isEqualToString:@"借贷余额转出"]) {
                            // 余额转入转出是余额变更
                            item.loanChargeType = SSJLoanCompoundChargeTypeBalanceIncrease;
                        }
                        break;
                }
            } else if (item.idType == SSJChargeIdTypeFixedFinance) {
                if ([item.billId isEqualToString:@"3"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeCloseOut;
                } else if ([item.billId isEqualToString:@"4"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeCreate;
                } else if ([item.billId isEqualToString:@"15"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeRedemption;
                } else if ([item.billId isEqualToString:@"16"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeAdd;
                } else if ([item.billId isEqualToString:@"17"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeBalanceInterestIncrease;
                } else if ([item.billId isEqualToString:@"20"]) {
                    item.fixedFinanceChargeType = SSJFixedFinCompoundChargeTypeCloseOutInterest;
                }
            } else {
                if ([item.billId isEqualToString:@"3"]) {
                    NSString *sourceId = [db getOneValueOnResult:SSJUserChargeTable.fundId
                                                       fromTable:@"bk_user_charge"
                                                           where:SSJUserChargeTable.cid == item.sundryId
                                                                 && SSJUserChargeTable.userId == userId
                                                                 && SSJUserChargeTable.billId == @"4"];
                    item.transferSource = [db getOneValueOnResult:SSJFundInfoTable.fundName
                                                        fromTable:@"bk_fund_info"
                                                            where:SSJFundInfoTable.fundId == sourceId];
                } else if ([item.billId isEqualToString:@"4"]) {
                    NSString *sourceId = [db getOneValueOnResult:SSJUserChargeTable.fundId
                                                       fromTable:@"bk_user_charge"
                                                           where:SSJUserChargeTable.cid == item.sundryId
                                                                 && SSJUserChargeTable.userId == userId
                                                                 && SSJUserChargeTable.billId == @"3"];
                    item.transferSource = [db getOneValueOnResult:SSJFundInfoTable.fundName
                                                        fromTable:@"bk_fund_info"
                                                            where:SSJFundInfoTable.fundId == sourceId];
                }

            }
            NSDate *billDate = [NSDate dateWithString:item.billDate formatString:@"yyyy-MM-dd"];
            NSString *currentPeriod;
            NSString *currentMonthStr;
            NSDate *firstDate = [NSDate date];
            NSDate *secondDate = [NSDate date];
            if (billDate.day >= newItem.cardItem.cardBillingDay) {
                if (newItem.cardItem.cardType == SSJCrediteCardTypeAlipay) {
                    firstDate = [NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay];
                    secondDate = [[[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingMonths:1] dateBySubtractingDays:1];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld" , (long) firstDate.month , (long) firstDate.day , (long) secondDate.month , (long) secondDate.day];
                    currentMonthStr = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];

                } else {
                    firstDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingDays:1];
                    secondDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingMonths:1];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld" , (long) firstDate.month , (long) firstDate.day , (long) secondDate.month , (long) secondDate.day];
                    currentMonthStr = [[[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] dateByAddingMonths:1] formattedDateWithFormat:@"yyyy-MM"];

                }
            } else {
                if (newItem.cardItem.cardType == SSJCrediteCardTypeAlipay) {
                    firstDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateBySubtractingMonths:1];
                    secondDate = [[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateBySubtractingDays:1];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld" , (long) firstDate.month , (long) firstDate.day , (long) secondDate.month , (long) secondDate.day];
                    currentMonthStr = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
                } else {
                    firstDate = [[[NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay] dateByAddingDays:1] dateBySubtractingMonths:1];
                    secondDate = [NSDate dateWithYear:0 month:billDate.month day:newItem.cardItem.cardBillingDay];
                    currentPeriod = [NSString stringWithFormat:@"%ld.%ld-%ld.%ld" , (long) firstDate.month , (long) firstDate.day , (long) secondDate.month , (long) secondDate.day];
                    currentMonthStr = [[NSDate dateWithYear:billDate.year month:billDate.month day:billDate.day] formattedDateWithFormat:@"yyyy-MM"];
                }
            }
            NSDate *minDate = [firstDate isEarlierThan:secondDate] ? firstDate : secondDate;
            if ([currentPeriod isEqualToString:lastPeriod]) {
                SSJCreditCardListDetailItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture + money;
                } else {
                    listItem.income = listItem.income + money;
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    [listItem.chargeArray addObject:item];
                    if (item.incomeOrExpence) {
                        lastDayItem.expenture = lastDayItem.expenture + money;
                    } else {
                        lastDayItem.income = lastDayItem.income + money;
                    }
                } else {
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc] init];
                    dayItem.rowHeight = 35;
                    lastDayItem = dayItem;
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    } else {
                        dayItem.income = dayItem.income + money;
                    }
                    lastDetailDate = item.billDate;
                    [listItem.chargeArray addObject:dayItem];
                    [listItem.chargeArray addObject:item];
                }
            } else {
                SSJCreditCardListDetailItem *listItem = [[SSJCreditCardListDetailItem alloc] init];
                listItem.month = currentMonthStr;
                listItem.billingDay = newItem.cardItem.cardBillingDay;
                listItem.repaymentDay = newItem.cardItem.cardRepaymentDay;
                listItem.instalmentMoney = [[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentMoney
                                                          fromTable:@"bk_credit_repayment"
                                                              where:SSJCreditRepaymentTable.userId == userId
                                                                    && SSJCreditRepaymentTable.repaymentMonth == listItem.month
                                                                    && SSJCreditRepaymentTable.operatorType != 2
                                                                    && SSJCreditRepaymentTable.cardId == cardId
                                                                    && SSJCreditRepaymentTable.instalmentCount > 0] doubleValue];
                listItem.repaymentMoney = [[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentMoney.sum()
                                                         fromTable:@"bk_credit_repayment"
                                                             where:SSJCreditRepaymentTable.userId == userId
                                                                   && SSJCreditRepaymentTable.repaymentMonth == listItem.month
                                                                   && SSJCreditRepaymentTable.cardId == cardId
                                                                   && SSJCreditRepaymentTable.operatorType != 2
                                                                   && SSJCreditRepaymentTable.instalmentCount == 0] doubleValue];
                NSDate *currentMonth = [NSDate dateWithString:currentMonthStr formatString:@"yyyy-MM"];
                NSDate *firstDate = [[NSDate dateWithYear:currentMonth.year month:currentMonth.month day:newItem.cardItem.cardBillingDay] dateBySubtractingMonths:1];
                NSDate *seconDate = [[NSDate dateWithYear:currentMonth.year month:currentMonth.month day:newItem.cardItem.cardBillingDay] dateByAddingDays:1];
                listItem.repaymentForOtherMonthMoney = [[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentMoney.sum()
                                                                      fromTable:@"bk_credit_repayment"
                                                                          where:SSJCreditRepaymentTable.userId == userId
                                                                                && SSJCreditRepaymentTable.repaymentMonth != listItem.month
                                                                                && SSJCreditRepaymentTable.cardId == cardId
                                                                                && SSJCreditRepaymentTable.operatorType != 2
                                                                                && SSJCreditRepaymentTable.instalmentCount == 0
                                                                                && SSJCreditRepaymentTable.applyDate.between([firstDate formattedDateWithFormat:@"yyyy-MM-dd"] , [seconDate formattedDateWithFormat:@"yyyy-MM-dd"])]
                                                            doubleValue];
                if (result.count < 2) {
                    listItem.isExpand = YES;
                } else {
                    listItem.isExpand = NO;
                }
                if (item.incomeOrExpence) {
                    listItem.expenture = money;
                } else {
                    listItem.income = money;
                }
                listItem.datePeriod = currentPeriod;
                NSMutableArray *tempArray = [NSMutableArray array];
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    if (item.incomeOrExpence) {
                        lastDayItem.expenture = lastDayItem.expenture + money;
                    } else {
                        lastDayItem.income = lastDayItem.income + money;
                    }
                    [tempArray addObject:item];
                } else {
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc] init];
                    dayItem.rowHeight = 35;
                    lastDayItem = dayItem;
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    } else {
                        dayItem.income = dayItem.income + money;
                    }
                    lastDetailDate = item.billDate;
                    SSJCreditCardListFirstLineItem *firstLineItem = [[SSJCreditCardListFirstLineItem alloc] init];
                    firstLineItem.repaymentStr = [self getRepaymentStrWithListItem:listItem];
                    if (firstLineItem.repaymentStr.length) {
                        firstLineItem.rowHeight = 65;
                    } else {
                        firstLineItem.rowHeight = 35;
                    }
                    firstLineItem.period = currentPeriod;
                    firstLineItem.remainingDaysStr = [self caculateRemainingDaysStrWithBillingDay:newItem.cardItem.cardBillingDay
                                                                                     repaymentDay:newItem.cardItem.cardRepaymentDay
                                                                                     currentMonth:currentMonthStr];
                    [tempArray addObject:firstLineItem];
                    [tempArray addObject:dayItem];
                    [tempArray addObject:item];
                }
                listItem.chargeArray = [NSMutableArray arrayWithArray:tempArray];
                lastPeriod = currentPeriod;
                [result addObject:listItem];
            }

        }

        dispatch_main_async_safe(^{
            if (success) {
                success(result , newItem);
            }
        });
    }];
}

+ (void)queryDataWithBooksId:(NSString *)booksId
                  FundTypeID:(NSString *)ID
                     success:(void (^)(NSMutableArray <SSJFundingDetailListItem *> *data))success
                     failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
        NSString *sql = [NSString stringWithFormat:@"select substr(a.cbilldate,1,7) as cmonth , a.* , a.cwritedate as chargedate , a.cid as sundryid, b.cicoin, b.cname, b.ccolor, b.itype from BK_USER_CHARGE a, BK_USER_BILL_TYPE b where a.ibillid = b.cbillid and ((a.cuserid = b.cuserid and a.cbooksid = b.cbooksid) or length(b.cbillid) < 4) and a.IFUNSID = '%@' and a.operatortype <> 2 and a.cbooksid  = '%@' and a.cbilldate <= '%@' and a.ibillid <> '13' and a.ibillid <> '14' order by cmonth desc ,a.cbilldate desc ,a.cwritedate desc" , ID , booksId , [[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        FMResultSet *resultSet = [db executeQuery:sql];
        dispatch_main_async_safe(^{
            if (!resultSet) {
                if (failure) {
                    failure([db lastError]);
                }
            }
        });

        NSMutableArray *result = [NSMutableArray array];
        NSString *lastDate = @"";
        NSString *lastDetailDate = @"";
        while ([resultSet next]) {
            SSJBillingChargeCellItem *item = [[SSJBillingChargeCellItem alloc] init];
            item.imageName = [resultSet stringForColumn:@"CICOIN"];
            item.typeName = [resultSet stringForColumn:@"CNAME"];
            item.colorValue = [resultSet stringForColumn:@"CCOLOR"];
            item.incomeOrExpence = (SSJBillType)[resultSet boolForColumn:@"ITYPE"];
            item.ID = [resultSet stringForColumn:@"ICHARGEID"];
            item.fundId = [resultSet stringForColumn:@"IFUNSID"];
            item.billDate = [resultSet stringForColumn:@"CBILLDATE"];
            item.editeDate = [resultSet stringForColumn:@"chargedate"];
            item.billId = [resultSet stringForColumn:@"IBILLID"];
            item.chargeMemo = [resultSet stringForColumn:@"cmemo"];
            item.chargeImage = [resultSet stringForColumn:@"cimgurl"];
            item.chargeThumbImage = [resultSet stringForColumn:@"thumburl"];
            item.booksId = [resultSet stringForColumn:@"cbooksid"];
            item.money = [resultSet stringForColumn:@"IMONEY"];
            item.idType = (SSJChargeIdType) [resultSet intForColumn:@"ichargetype"];
            double money = [item.money doubleValue];
            item.sundryId = [resultSet stringForColumn:@"sundryid"];
            if (item.incomeOrExpence) {
                item.money = [NSString stringWithFormat:@"-%.2f" , money];
            } else if (!item.incomeOrExpence) {
                item.money = [NSString stringWithFormat:@"+%.2f" , money];
            }
            if (item.chargeImage.length || item.chargeMemo.length || item.idType == SSJChargeIdTypeFixedFinance || item.idType == SSJChargeIdTypeLoan || item.memberNickname.length) {
                item.rowHeight = 65;
            } else {
                item.rowHeight = 50;
            }
            
            NSString *month = [resultSet stringForColumn:@"cmonth"];
            if ([month isEqualToString:lastDate]) {
                SSJFundingDetailListItem *listItem = [result lastObject];
                if (item.incomeOrExpence) {
                    listItem.expenture = listItem.expenture + money;
                } else {
                    listItem.income = listItem.income + money;
                }
                if ([item.billDate isEqualToString:lastDetailDate]) {
                    SSJFundingListDayItem *dayItem = [tempDateArr firstObject];
                    
                    if (item.incomeOrExpence) {
                        dayItem.expenture = dayItem.expenture + money;
                    } else {
                        dayItem.income = dayItem.income + money;
                    }
                    [tempDateArr addObject:item];
                } else {
                    [listItem.chargeArray addObjectsFromArray:tempDateArr];
                    [tempDateArr removeAllObjects];
                    SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc] init];
                    dayItem.rowHeight = 35;
                    dayItem.date = item.billDate;
                    if (item.incomeOrExpence) {
                        dayItem.expenture = money;
                    } else {
                        dayItem.income = money;
                    }
                    lastDetailDate = item.billDate;
                    [tempDateArr addObject:dayItem];
                    [tempDateArr addObject:item];
                }
            } else {
                SSJFundingDetailListItem *lastlistItem = [result lastObject];
                [lastlistItem.chargeArray addObjectsFromArray:tempDateArr];
                [tempDateArr removeAllObjects];
                SSJFundingDetailListItem *listItem = [[SSJFundingDetailListItem alloc] init];
                if ([lastDate isEqualToString:@""]) {
                    listItem.isExpand = YES;
                } else {
                    listItem.isExpand = NO;
                }
                if (item.incomeOrExpence) {
                    listItem.expenture = money;
                } else {
                    listItem.income = money;
                }
                listItem.date = month;
                SSJFundingListDayItem *dayItem = [[SSJFundingListDayItem alloc] init];
                dayItem.rowHeight = 35;
                dayItem.date = item.billDate;
                if (item.incomeOrExpence) {
                    dayItem.expenture = money;
                } else {
                    dayItem.income = money;
                }
                listItem.chargeArray = [NSMutableArray arrayWithCapacity:0];
                lastDetailDate = item.billDate;
                [tempDateArr addObject:dayItem];
                [tempDateArr addObject:item];
                lastDate = month;
                [result addObject:listItem];
            }
        }
        SSJFundingDetailListItem *listItem = [result lastObject];
        [listItem.chargeArray addObjectsFromArray:tempDateArr];
        [resultSet close];

        dispatch_main_async_safe(^{
            if (success) {
                success(result);
            }
        });
    }];
}

+ (BOOL)queryCloseOutStateWithLoanId:(NSString *)loanId {
    __block BOOL closeOut = NO;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        closeOut = [db boolForQuery:@"select iend from BK_LOAN where loanid = ?" , loanId];
    }];
    return closeOut;
}

+ (NSString *)stringFromWeekday:(NSInteger)weekday {
    switch ( weekday ) {
        case 1:
            return @"星期日";
        case 2:
            return @"星期一";
        case 3:
            return @"星期二";
        case 4:
            return @"星期三";
        case 5:
            return @"星期四";
        case 6:
            return @"星期五";
        case 7:
            return @"星期六";

        default:
            return nil;
    }
}


+ (SSJFinancingHomeitem *)getFundingItemWithFundId:(NSString *)fundid inDataBase:(WCTDatabase *)db {
    SSJFundInfoTable *fund = [db getOneObjectOfClass:SSJFundInfoTable.class fromTable:@"bk_fund_info" where:SSJFundInfoTable.fundId == fundid && SSJFundInfoTable.userId == SSJUSERID()];
    SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc] init];

    item.fundingID = fund.fundId;
    item.fundingName = fund.fundName;
    item.fundingMemo = fund.memo;
    item.fundingColor = fund.fundColor;
    item.fundingIcon = fund.fundIcon;
    item.startColor = fund.startColor;
    item.endColor = fund.endColor;
    item.fundingParent = fund.fundParent;
    item.fundingParentName = [[SSJFundingTypeManager sharedManager] modelForFundId:fund.fundParent].name;
    item.fundingOrder = fund.fundOrder;

    item.chargeCount = [[db getOneValueOnResult:SSJUserChargeTable.AnyProperty.count()
                                      fromTable:@"BK_USER_CHARGE"
                                          where:SSJUserChargeTable.userId == SSJUSERID()
                                                && SSJUserChargeTable.operatorType != 2
                                                && SSJUserChargeTable.fundId == item.fundingID] doubleValue];

    item.fundingIncome = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypeIncome inDataBase:db] doubleValue];

    item.fundingExpence = [[self getFundBalanceWithFundId:item.fundingID type:SSJBillTypePay inDataBase:db] doubleValue];

    item.fundingAmount = item.fundingIncome - item.fundingExpence;

    SSJUserCreditTable *credit = [db getOneObjectOfClass:SSJUserCreditTable.class
                                               fromTable:@"bk_user_credit"
                                                   where:SSJUserCreditTable.cardId == item.fundingID
                                                         && SSJUserCreditTable.userId == SSJUSERID()];


    if ([item.fundingParent isEqualToString:@"3"] || [item.fundingParent isEqualToString:@"16"]) {
        SSJCreditCardItem *cardItem = [[SSJCreditCardItem alloc] init];
        cardItem.cardLimit = credit.cardQuota;
        if (![item.fundingParent isEqualToString:@"3"]) {
            cardItem.settleAtRepaymentDay = YES;
        } else {
            cardItem.settleAtRepaymentDay = credit.billDateSettlement;
        }
        cardItem.cardBillingDay = credit.billingDate;
        cardItem.cardRepaymentDay = credit.repaymentDate;
        cardItem.remindItem = [self getRemindItemWithRemindId:credit.remindId indataBase:db];
        cardItem.hasMadeInstalment = [(NSNumber *)[db getOneValueOnResult:SSJCreditRepaymentTable.repaymentId.count()
                                                   fromTable:@"bk_credit_repayment"
                                                       where:SSJCreditRepaymentTable.cardId == cardItem.fundingID] boolValue];
        item.cardItem = cardItem;

    }

    return item;

}


+ (NSNumber *)getFundBalanceWithFundId:(NSString *)fundId type:(SSJBillType)type inDataBase:(WCTDatabase *)db {
    NSNumber *currentBalance = 0;

    WCTResultList resultList = {SSJUserChargeTable.money.inTable(@"BK_USER_CHARGE").sum()};

    WCDB::JoinClause joinClause = WCDB::JoinClause("BK_USER_CHARGE").join("BK_USER_BILL_TYPE" , WCDB::JoinClause::Type::Inner).on(SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.billId.inTable(@"BK_USER_BILL_TYPE") && ((SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.booksId.inTable(@"BK_USER_BILL_TYPE") && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUserBillTypeTable.userId.inTable(@"BK_USER_BILL_TYPE")) || SSJUserBillTypeTable.billId.length() < 4) && SSJUserBillTypeTable.userId.inTable(@"BK_USER_CHARGE") == SSJUSERID() && SSJUserChargeTable.operatorType.inTable(@"BK_USER_CHARGE") != 2 && SSJUserBillTypeTable.billType == type && SSJUserChargeTable.fundId == fundId && (SSJUserChargeTable.chargeType == SSJChargeIdTypeLoan || SSJUserChargeTable.billDate <= [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd"])
);

    joinClause.join("BK_SHARE_BOOKS_MEMBER" , WCDB::JoinClause::Type::Left).on(SSJUserChargeTable.booksId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.booksId.inTable(@"BK_SHARE_BOOKS_MEMBER") && SSJUserChargeTable.userId.inTable(@"BK_USER_CHARGE") == SSJShareBooksMemberTable.memberId.inTable(@"BK_SHARE_BOOKS_MEMBER"));

    WCDB::StatementSelect statementSelect = WCDB::StatementSelect().select(resultList).from(joinClause).where(SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER") == SSJShareBooksMemberStateNormal || SSJShareBooksMemberTable.memberState.inTable(@"BK_SHARE_BOOKS_MEMBER").isNull() || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"13" || SSJUserChargeTable.billId.inTable(@"BK_USER_CHARGE") == @"14");

    WCTStatement *statement = [db prepare:statementSelect];

    while ([statement step]) {
        currentBalance = (NSNumber *) [statement getValueAtIndex:0];
    }

    return currentBalance;

}


+ (SSJBillingChargeCellItem *)getChargeItemWithStatement:(WCTStatement *)statement {
    SSJBillingChargeCellItem *chargeItem = [[SSJBillingChargeCellItem alloc] init];
    for (int i = 0 ; i < [statement getColumnCount] ; ++i) {
        id value = [statement getValueAtIndex:i];
        NSString *name = [statement getColumnNameAtIndex:i];
        NSString *str = SSJUserChargeTable.chargeId.getDescription();
        NSString *tableName = [statement getTableNameAtIndex:i];
        if (value) {
            if ([name isEqualToString:SSJUserChargeTable.chargeId.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.ID = value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billIcon.getDescription()] && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.imageName = value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billName.getDescription()] && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.typeName = value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billColor.getDescription()] && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.colorValue = value;
            } else if ([name isEqualToString:SSJUserChargeTable.chargeId.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.incomeOrExpence = (SSJBillType)[(NSNumber *) value boolValue];
            } else if ([name isEqualToString:SSJUserChargeTable.fundId.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.fundId = value;
            } else if ([name isEqualToString:SSJUserChargeTable.billDate.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.billDate = value;
            } else if ([name isEqualToString:SSJUserChargeTable.writeDate.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.editeDate = value;
            } else if ([name isEqualToString:SSJUserChargeTable.billDate.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.billId = value;
            } else if ([name isEqualToString:SSJUserChargeTable.memo.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.chargeMemo = value;
            } else if ([name isEqualToString:SSJUserChargeTable.imgUrl.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.chargeImage = value;
            } else if ([name isEqualToString:SSJUserChargeTable.thumbUrl.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.chargeThumbImage = value;
            } else if ([name isEqualToString:SSJUserChargeTable.booksId.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.booksId = value;
            } else if ([name isEqualToString:SSJLoanTable.lender.getDescription()] && [tableName isEqualToString:@"BK_LOAN"]) {
                chargeItem.loanOrFixedSource = value;
            } else if ([name isEqualToString:SSJLoanTable.type.getDescription()] && [tableName isEqualToString:@"BK_LOAN"]) {
                chargeItem.loanType = (SSJLoanType) [value integerValue];
            } else if ([name isEqualToString:SSJUserChargeTable.chargeType.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.idType = (SSJChargeIdType) [value integerValue];
            } else if ([name isEqualToString:SSJUserChargeTable.cid.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.sundryId = value;
            } else if ([name isEqualToString:SSJUserChargeTable.money.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.money = value;
            } else if ([name isEqualToString:SSJUserChargeTable.chargeId.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.ID = value;
            } else if ([name isEqualToString:SSJUserChargeTable.billId.getDescription()] && [tableName isEqualToString:@"BK_USER_CHARGE"]) {
                chargeItem.billId = value;
            } else if ([name isEqualToString:SSJUserBillTypeTable.billType.getDescription()] && [tableName isEqualToString:@"BK_USER_BILL_TYPE"]) {
                chargeItem.incomeOrExpence = (SSJBillType)[value integerValue];
            } else if ([name isEqualToString:SSJFixedFinanceProductTable.productName.getDescription()] && [tableName isEqualToString:@"BK_FIXED_FINANCE_PRODUCT"]) {
                chargeItem.loanOrFixedSource = value;
            }
        }

    }
    chargeItem.fundParent = @"3";
    double money = [chargeItem.money doubleValue];
    NSString *moneyStr = [[NSString stringWithFormat:@"%f" , money] ssj_moneyDecimalDisplayWithDigits:2];
    if (chargeItem.incomeOrExpence == SSJBillTypePay) {
        chargeItem.money = [NSString stringWithFormat:@"-%@" , moneyStr];
    } else if (chargeItem.incomeOrExpence == SSJBillTypeIncome) {
        chargeItem.money = [NSString stringWithFormat:@"+%@" , moneyStr];
    }
    return chargeItem;
}


+ (SSJReminderItem *)getRemindItemWithRemindId:(NSString *)remindId indataBase:(WCTDatabase *)db {
    SSJReminderItem *item = [[SSJReminderItem alloc] init];
    SSJUserRemindTable *userRemindTable = [db getOneObjectOfClass:SSJUserRemindTable.class
                                                        fromTable:@"bk_user_remind"
                                                            where:SSJUserRemindTable.remindId == remindId];
    item.remindId = userRemindTable.remindId;
    item.remindName = userRemindTable.remindName;
    item.remindMemo = userRemindTable.memo;
    item.remindCycle = userRemindTable.cycle;
    item.remindType = userRemindTable.type;
    item.remindState = userRemindTable.state;
    item.remindDate = [NSDate dateWithString:userRemindTable.startDate formatString:@"yyyy-MM-dd HH:mm:ss"];
    return item;
}

+ (NSString *)caculateRemainingDaysStrWithBillingDay:(NSInteger)billingday repaymentDay:(NSInteger)repaymentDay currentMonth:(NSString *)month {
    NSString *remainningDaysStr;
    NSDate *today = [NSDate date];
    NSString *billdateStr = [NSString stringWithFormat:@"%@-%02ld",month,billingday];
    NSString *repaymentdateStr = [NSString stringWithFormat:@"%@-%02ld",month,repaymentDay];
    NSDate *billdate = [NSDate dateWithString:billdateStr formatString:@"yyyy-MM-dd"];
    NSDate *repaymentDate = [NSDate dateWithString:repaymentdateStr formatString:@"yyyy-MM-dd"];
    if ([repaymentDate isEarlierThanOrEqualTo:billdate]) {
        repaymentDate = [repaymentDate dateBySubtractingMonths:1];
    }
    NSInteger daysFromBillDay = [billdate daysFrom:today] + 1 > 0 ? [billdate daysFrom:today] + 1 : 0;
    NSInteger daysFromRepaymentDay = [repaymentDate daysFrom:today] + 1 > 0 ? [repaymentDate daysFrom:today] + 1 : 0;
    NSInteger minumDay = MIN(daysFromBillDay , daysFromRepaymentDay);
    if (daysFromRepaymentDay == 0 && daysFromBillDay > 0) {
        remainningDaysStr = [NSString stringWithFormat:@"距账单日:%ld天",daysFromBillDay];
    } else if (daysFromBillDay == 0 && daysFromRepaymentDay > 0) {
        remainningDaysStr = [NSString stringWithFormat:@"距还款日:%ld天",daysFromRepaymentDay];
    }else if (minumDay == daysFromBillDay && daysFromBillDay > 0) {
        remainningDaysStr = [NSString stringWithFormat:@"距账单日:%ld天",daysFromBillDay];
    } else if (minumDay == daysFromRepaymentDay && daysFromRepaymentDay > 0) {
        remainningDaysStr = [NSString stringWithFormat:@"距还款日:%ld天",daysFromRepaymentDay];
    } else {
        remainningDaysStr = @"";
    }
    return remainningDaysStr;
}

+ (void)queryfixedFinanceDateWithChargeItem:(SSJBillingChargeCellItem *)item
                     success:(void (^)(SSJFixedFinanceProductItem *productItem, SSJFixedFinanceProductChargeItem *chargeItem))success
                     failure:(void (^)(NSError *error))failure {

    [[SSJOrmDatabaseQueue sharedInstance] asyncInDatabase:^(WCTDatabase *db) {
        SSJFixedFinanceProductTable *fixedFinanceProduct = [db getOneObjectOfClass:SSJFixedFinanceProductTable.class
                                                                         fromTable:@"BK_FIXED_FINANCE_PRODUCT"
                                                                             where:SSJFixedFinanceProductTable.productId == [[item.sundryId componentsSeparatedByString:@"_"] firstObject]];
        SSJUserChargeTable *userCharge = [db getOneObjectOfClass:SSJUserChargeTable.class
                                                       fromTable:@"BK_USER_CHARGE"
                                                           where:SSJUserChargeTable.chargeId == item.ID];
        SSJFundInfoTable *fundInfo = [db getOneObjectOfClass:SSJFundInfoTable.class fromTable:@"bk_fund_info" where:SSJFundInfoTable.fundId == item.fundId];
        SSJFixedFinanceProductItem *productItem = [[SSJFixedFinanceProductItem alloc] init];
        productItem.productid = fixedFinanceProduct.productId;
        productItem.productName = fixedFinanceProduct.productName;
        productItem.productIcon = fundInfo.fundIcon;
        productItem.userid = SSJUSERID();
        productItem.remindid = fixedFinanceProduct.remindId;
        productItem.thisfundid = fixedFinanceProduct.thisFundid;
        productItem.targetfundid = fixedFinanceProduct.targetFundid;
        productItem.etargetfundid = fixedFinanceProduct.etargetFundid;
        productItem.money = fixedFinanceProduct.money;
        productItem.memo = fixedFinanceProduct.memo;
        productItem.rate = fixedFinanceProduct.rate;
        productItem.ratetype = fixedFinanceProduct.rateType;
        productItem.time = fixedFinanceProduct.time;
        productItem.timetype = fixedFinanceProduct.timeType;
        productItem.interesttype = fixedFinanceProduct.interestType;
        productItem.startdate = fixedFinanceProduct.startDate;
        productItem.enddate = fixedFinanceProduct.endDate;
        productItem.isend = fixedFinanceProduct.isEnd;
        SSJFixedFinanceProductChargeItem *chargeItem = [[SSJFixedFinanceProductChargeItem alloc] init];
        chargeItem.chargeId = userCharge.chargeId;
        chargeItem.fundId = userCharge.fundId;
        chargeItem.money = [userCharge.money doubleValue];
        chargeItem.billId = userCharge.billId;
        chargeItem.userId = userCharge.userId;
        chargeItem.memo = userCharge.memo;
        chargeItem.icon = userCharge.chargeId;
        chargeItem.billDate = [NSDate dateWithString:userCharge.billDate formatString:@"yyyy-MM-dd"];
        chargeItem.cid = userCharge.cid;
        if (success) {
            dispatch_main_async_safe(^{
                success(productItem,chargeItem);
            });
        }
    }];
}

+ (NSString *)getRepaymentStrWithListItem:(SSJCreditCardListDetailItem *)creditCardItem {
    NSString *repaymentStr;
    double totalMoney = creditCardItem.income - creditCardItem.expenture + creditCardItem.instalmentMoney;
    double moneyNeedToRepay = creditCardItem.income - creditCardItem.expenture + creditCardItem.repaymentMoney - creditCardItem.repaymentForOtherMonthMoney + creditCardItem.instalmentMoney;
    if (moneyNeedToRepay < 0) {
        // 本期应还大于0
        if (creditCardItem.instalmentMoney > 0) {
            // 本期分期大于0
            if (creditCardItem.repaymentMoney > 0) {
                // 本期还过款
                repaymentStr = [NSString stringWithFormat:@"(本期已还%@元,分期%@元)",[[NSString stringWithFormat:@"%f",fabs(creditCardItem.repaymentMoney)]  ssj_moneyDecimalDisplayWithDigits:2],[[NSString stringWithFormat:@"%f",fabs(creditCardItem.instalmentMoney)]  ssj_moneyDecimalDisplayWithDigits:2]];
                
            } else {
                // 本期未还过款
                repaymentStr = [NSString stringWithFormat:@"(账单已分期,本期应还金额为%@元)",[[NSString stringWithFormat:@"%f",fabs(moneyNeedToRepay)]  ssj_moneyDecimalDisplayWithDigits:2]];
            }
        } else {
            // 本期没有分期过
            if (creditCardItem.repaymentMoney > 0) {
                // 本期还过款
                repaymentStr = [NSString stringWithFormat:@"(本期已还%@元,剩余应还%@元)",[[NSString stringWithFormat:@"%f",fabs(creditCardItem.repaymentMoney)]  ssj_moneyDecimalDisplayWithDigits:2],[[NSString stringWithFormat:@"%f",fabs(moneyNeedToRepay)]  ssj_moneyDecimalDisplayWithDigits:2]];
            } else {
                // 本期未还过款
                repaymentStr = @"";
            }
            
        }
    } else {
        if (creditCardItem.repaymentMoney > 0) {
            if (creditCardItem.instalmentMoney > 0) {
                // 本期分过期
                repaymentStr = [NSString stringWithFormat:@"(账单已分期,本期应还金额为0.00元)"];
            } else {
                // 本期未分期代表已经还清
                repaymentStr = @"账单已还清";
            }
        } else {
            if (creditCardItem.instalmentMoney > 0) {
                repaymentStr = [NSString stringWithFormat:@"(账单已分期,本期应还金额为0.00元)"];
            } else {
                repaymentStr = @"";
            }
        }
        
    }
    return repaymentStr;
}
@end
