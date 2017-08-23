//
//  SSJLoanListCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListCellItem.h"
#import "SSJLoanModel.h"
#import "SSJFixedFinanceProductItem.h"

@implementation SSJLoanListCellItem

+ (instancetype)itemWithLoanModel:(SSJLoanModel *)model {
    SSJLoanListCellItem *item = [[SSJLoanListCellItem alloc] init];
    item.icon = model.image;
    item.memo = model.memo;
    item.showStamp = model.closeOut;
    
    NSString *borrowDate = [model.borrowDate formattedDateWithFormat:@"yyyy.MM.dd"];
    switch (model.type) {
        case SSJLoanTypeLend:
            item.money = [NSString stringWithFormat:@"+%.2f", model.jMoney];
            item.loanTitle = [NSString stringWithFormat:@"被%@借", model.lender];
            item.date = [NSString stringWithFormat:@"借出日期：%@", borrowDate];
            
            break;
            
        case SSJLoanTypeBorrow:
            item.money = [NSString stringWithFormat:@"-%.2f", model.jMoney];
            item.loanTitle = [NSString stringWithFormat:@"欠%@钱款", model.lender];
            item.date = [NSString stringWithFormat:@"欠款日期：%@", borrowDate];
            break;
    }
    
    return item;
}

+ (instancetype)itemForFixedFinanceProductModel:(SSJFixedFinanceProductItem *)model {
    SSJLoanListCellItem *item = [[SSJLoanListCellItem alloc] init];
    item.icon = model.productIcon;
    item.memo = model.memo;
    item.loanTitle = model.productName;
    item.money = [NSString stringWithFormat:@"+%.2f",[model.money doubleValue]];
    item.date = [NSString stringWithFormat:@"起息日期：%@",model.startdate];
    return item;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"icon":(_icon ?: [NSNull null]),
                                                        @"loanTitle":(_loanTitle ?: [NSNull null]),
                                                        @"memo":(_memo ?: [NSNull null]),
                                                        @"money":(_money ?: [NSNull null]),
                                                        @"date":(_date ?: [NSNull null])}];
}

@end
