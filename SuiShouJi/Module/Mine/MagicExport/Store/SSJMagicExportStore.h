//
//  SSJMagicExportStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SSJMagicExportStoreBeginDateKey;
extern NSString *const SSJMagicExportStoreEndDateKey;

@interface SSJMagicExportStore : NSObject

/**
 *  查询第一次记账时间和最近一次记账时间(截止到当前系统时间)
 *
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryBillPeriodWithBookId:(NSString *)bookId
                          success:(void (^)(NSDictionary<NSString *, NSDate *> *result))success
                          failure:(void (^)(NSError *error))failure;

/**
 *  查询所有有效的记账时间(截止到当前系统时间)
 *
 *  @param success   查询成功的回调
 *  @param failure   查询失败的回调
 */
+ (void)queryAllBillDateWithBillType:(SSJBillType)billType
                             success:(void (^)(NSArray<NSDate *> *result))success
                             failure:(void (^)(NSError *error))failure;

@end
