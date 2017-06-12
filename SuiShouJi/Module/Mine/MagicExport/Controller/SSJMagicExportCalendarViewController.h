//
//  SSJMagicExportCalendarViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJMagicExportCalendarViewController : SSJBaseViewController

//---------------------------------------------------------------------------------------------------------
// 注意：
// 如果传了billTypeId，就不需要传billName和billType；
// 反之传了billName就必须传billType（因为有可能收入和支出都有同名的类别），billName不需要再传
//---------------------------------------------------------------------------------------------------------
/**
 收支类别id,不传则查询所有类别，如果有值则忽略billType
 */
@property (nonatomic, copy, nullable) NSString *billTypeId;

/**
 收支类别名称
 */
@property (nonatomic, copy, nullable) NSString *billName;

/**
 日历显示哪种收支类型的流水日期，默认SSJBillTypeSurplus；如果
 */
@property (nonatomic) SSJBillType billType;
// --------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------

/**
 账本类型id,不传则查询当前账本数据，传SSJAllBooksIds则查询所有账本数据
 */
@property (nonatomic, copy) NSString *booksId;

/**
 是否包含其他成员流水；当booksId为SSJAllBooksIds时有效
 */
@property (nonatomic) BOOL containsOtherMember;

/**
 默认选中的起始导出日期
 */
@property (nullable, nonatomic, strong) NSDate *selectedBeginDate;

/**
 默认选中的结束导出日期
 */
@property (nullable, nonatomic, strong) NSDate *selectedEndDate;

/**
 选择日期完成的回调
 */
@property (nonatomic, copy) void (^completion)(NSDate *selectedBeginDate, NSDate *selectedEndDate);

@end

NS_ASSUME_NONNULL_END
