//
//  SSJSyncTable.h
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

//  无效的版本号，int类型
#define SSJ_INVALID_SYNC_VERSION INT_MIN

extern int lastSyncVersion;

@interface SSJSyncTable : NSObject

/**
 *  返回对应的表名，子类必需覆写
 *
 *  @return 表名
 */
+ (NSString *)tableName;

/**
 *  返回对应的表的列名，子类必需覆写
 *
 *  @return 返回对应的表的列名
 */
+ (NSArray *)columns;

/**
 *  返回对应的表的主键，子类必需覆写
 *
 *  @return 对应的表的主键
 */
+ (NSArray *)primaryKeys;

/**
 *  获取上次同步成功的版本号
 *
 *  @param db FMDatabase实例
 *  @return 上次同步成功的版本号
 */
+ (int)lastSuccessSyncVersionInDatabase:(FMDatabase *)db;

/**
 *  查询需要同步的记录，即属于当前用户并且版本号大于上次同步成功版本号的记录
 *
 *  @param db FMDatabase实例
 *  @return 需要同步的记录
 */
+ (NSArray *)queryRecordsForSyncInDatabase:(FMDatabase *)db;

/**
 *  返回查询需要同步的记录的其它条件，根据需要子类可以覆写
 *
 *  @return (BOOL) 查询需要同步的记录的其它条件
 */
+ (NSString *)queryRecordsForSyncAdditionalCondition;

/**
 *  更新表中版本号大于当前同步版本号的记录的版本号
 *
 *  @param version 新版本号
 *  @param db FMDatabase实例
 *  @return 是否更新成功
 */
+ (BOOL)updateSyncVersionToServerSyncVersion:(int)version inDatabase:(FMDatabase *)db;

/**
 *  返回更新版本号需要的额外条件，根据需要子类可以覆写
 *
 *  @return 更新版本号需要的额外条件
 */
+ (NSString *)updateSyncVersionAdditionalCondition;

/**
 *  合并记录到相应的表中
 *
 *  @param db FMDatabase实例
 *  @return 是否合并成功
 */
+ (BOOL)mergeRecords:(NSArray *)records inDatabase:(FMDatabase *)db;

/**
 *  返回合并记录的其它条件，根据需要子类可以覆写
 *
 *  @param record 要合并的记录数据
 *  @return (NSString *) 合并记录的其它条件
 */
+ (NSString *)additionalConditionForMergeRecord:(NSDictionary *)record;


//----------------------------------------------------------------------
//  用于单元测试暴露的方法
//----------------------------------------------------------------------

//  根据合并记录返回相应的sql语句
+ (NSString *)sqlStatementForMergeRecord:(NSDictionary *)recordInfo inDatabase:(FMDatabase *)db;

//  返回插入的sql语句
+ (NSString *)insertStatementForMergeRecord:(NSDictionary *)recordInfo;

//  返回更新的sql语句
+ (NSString *)updateStatementForMergeRecord:(NSDictionary *)recordInfo compareWriteDate:(BOOL)compareWriteDate condition:(NSString *)condition;

//
+ (NSString *)spliceKeyAndValueForKeys:(NSArray *)keys record:(NSDictionary *)recordInfo joinString:(NSString *)joinString;

@end
