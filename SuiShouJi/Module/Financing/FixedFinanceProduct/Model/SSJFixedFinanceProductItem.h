//
//  SSJFixedFinanceProductItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

NS_ASSUME_NONNULL_BEGIN
@class FMResultSet;
@class FMDatabase;


@interface SSJFixedFinanceProductItem : SSJBaseCellItem<NSCopying>

/**理财产品id*/
@property (nonatomic, copy) NSString *productid;

/**理财产品名称*/
@property (nonatomic, copy) NSString *productName;

/**理财产品图片*/
@property (nonatomic, copy) NSString *productIcon;

/**用户id*/
@property (nonatomic, copy) NSString *userid;

/**提醒id*/
@property (nonatomic, copy, nullable) NSString *remindid;

/**资金账户id*/
@property (nonatomic, copy) NSString *thisfundid;

/**转出账户id*/
@property (nonatomic, copy,nullable) NSString *targetfundid;

/**结算账户id*/
@property (nonatomic, copy, nullable) NSString *etargetfundid;

/**投资金额*/
@property (nonatomic, copy) NSString *money;

/**余额变更前的金额*/
@property (nonatomic, copy) NSString *oldMoney;

/**余额变更的差额*/
//@property (nonatomic, assign) double difMoney;

/**备注*/
@property (nonatomic, copy, nullable) NSString *memo;

/**利率*/
@property (nonatomic, assign) double rate;

/**利率类型（年:2、月:1、日:0)*/
@property (nonatomic, assign) SSJMethodOfRateOrTime ratetype;

/**期限*/
@property (nonatomic, assign) float time;

/**期限类型（年:2、月:1、日:0）*/
@property (nonatomic, assign) SSJMethodOfRateOrTime timetype;

/**计息方式（一次性付清:0，每日付息到期还本:1，每月付息到期还本:2）*/
@property (nonatomic, assign) SSJMethodOfInterest interesttype;

/**起息日期*/
@property (nonatomic, copy) NSString *startdate;

@property (nonatomic, strong) NSDate *startDate;

/**结算日期*/
@property (nonatomic, copy, nullable) NSString *enddate;

/**是否结算0 未结算，1，结算*/
@property (nonatomic, assign) NSInteger isend;

/**颜色*/
@property (nonatomic, copy) NSString *startcolor;

@property (nonatomic, copy) NSString *endcolor;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet inDatabase:(FMDatabase *)db isProductList:(BOOL)list;

/**
 2:余额转入，由少变多，1:余额转出，由多变少，0：金额没有变动
 */
//@property (nonatomic, assign) NSInteger balanceOutOrIn;

//+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet inDatabase:(SSJDatabase *)db;

+ (NSArray *)keyArr;

@end

NS_ASSUME_NONNULL_END


// /**
// * 固收理财变更转入（对固收理财账户而言，是追加投资）
// **/
//public static final String FIXED_FIN_PRODUCT_CHANGE_IN_ID = "15";
///**
// * 固收理财变更转出（对固收理财账户而言，是部分赎回）
// **/
//public static final String FIXED_FIN_PRODUCT_CHANGE_OUT_ID = "16";
///**
// * 固收理财结算利息转入
// **/
//public static final String FIXED_FIN_PRODUCT_INTEREST_IN_ID = "17";
///**
// * 固收理财结算利息转出
// **/
//public static final String FIXED_FIN_PRODUCT_INTEREST_OUT_ID = "18";
///**
// * 固收理财派发利息流水
// **/
//public static final String FIXED_FIN_PRODUCT_INTEREST_ID = "19";
///**
// * 固收理财手续费率（部分赎回，结算）
// **/
//public static final String FIXED_FIN_PRODUCT_POUNDAGE_ID = "20";
///**
// * 固收理财平账收入
// **/
//public static final String FIXED_FIN_PRODUCT_MATCH_ACCOUNT_IN_ID = "21";
///**
// * 固收理财平账支出
// **/
//public static final String FIXED_FIN_PRODUCT_MATCH_ACCOUNT_OUT_ID = "22";
//
