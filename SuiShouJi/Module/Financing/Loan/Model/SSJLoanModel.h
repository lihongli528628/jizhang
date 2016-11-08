//
//  SSJLoanModel.h
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJLoanChargeModel.h"

@class FMResultSet;

@interface SSJLoanModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *ID;

// 用户ID
@property (nonatomic, copy) NSString *userID;

// 借款人／欠款人
@property (nonatomic, copy) NSString *lender;

// 借贷图标
@property (nonatomic, copy) NSString *image;

// 剩余借入／借出金额（包含扣除余额变更、追加变更、结清）
@property (nonatomic) double jMoney;

// 借入／借出所属账户
@property (nonatomic, copy) NSString *fundID;

// 借入／借出目标账户(结清前)
@property (nonatomic, copy) NSString *targetFundID;

// 借入／借出目标账户(结清后)
@property (nonatomic, copy) NSString *endTargetFundID;

// 创建借贷时产生的本账户转账流水
@property (nonatomic, copy) NSString *chargeID;

// 创建借贷时产生的目标账户转账流水
@property (nonatomic, copy) NSString *targetChargeID;

// 结清时产生的本账户转账流水
@property (nonatomic, copy) NSString *endChargeID;

// 结清时产生的目标账户转账流水
@property (nonatomic, copy) NSString *endTargetChargeID;

// 结清产生的利息流水
@property (nonatomic, copy) NSString *interestChargeID;

@property (nonatomic, copy) NSArray <SSJLoanChargeModel *>*chargeModels;

// 借入／借出日期
@property (nonatomic, copy) NSDate *borrowDate;

// 期限日期
@property (nonatomic, copy) NSDate *repaymentDate;

// 结清日期
@property (nonatomic, copy) NSDate *endDate;

// 利率
@property (nonatomic) double rate;

// 备注
@property (nonatomic, copy) NSString *memo;

// 提醒ID
@property (nonatomic, copy) NSString *remindID;

// 是否计息
@property (nonatomic) BOOL interest;

// 是否已结清
@property (nonatomic) BOOL closeOut;

// 0:借出 1:借入
@property (nonatomic) SSJLoanType type;

@property (nonatomic) int operatorType;

@property (nonatomic) long long version;

@property (nonatomic, copy) NSDate *writeDate;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;

@end
