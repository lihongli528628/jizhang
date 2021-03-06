//
//  SSJFinancingHomeitem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseCellItem.h"
#import "SSJFinancingItem.h"
#import "SSJCreditCardItem.h"

@interface SSJFinancingHomeitem : SSJBaseCellItem<SSJFinancingItemProtocol>

//账户父类名称
@property (nonatomic,strong) NSString *fundingParentName;

//账户收入
@property (nonatomic) double fundingIncome;

//账户支出
@property (nonatomic) double fundingExpence;

@property(nonatomic) NSInteger fundingOrder;

//账户下流水数量
@property(nonatomic) NSInteger chargeCount;

@property(nonatomic) NSInteger fundOperatortype;

@property (nonatomic, strong) SSJCreditCardItem *cardItem;

@end
