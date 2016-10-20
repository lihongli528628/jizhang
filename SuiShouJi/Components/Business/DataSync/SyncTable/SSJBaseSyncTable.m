//
//  SSJBaseSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseSyncTable.h"
#import "SSJSyncTable.h"

@implementation SSJBaseSyncTable

+ (NSString *)tableName {
    return nil;
}

+ (NSArray *)columns {
    return nil;
}

+ (NSArray *)primaryKeys {
    return nil;
}

+ (NSString *)queryRecordsForSyncAdditionalCondition {
    return nil;
}

+ (NSString *)updateSyncVersionAdditionalCondition {
    return nil;
}

+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    return YES;
}

+ (NSArray *)queryRecordsNeedToSyncWithUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        *error = [db lastError];
        return nil;
    }
    
    NSMutableString *query = [NSMutableString stringWithFormat:@"select * from %@ where IVERSION > %lld and CUSERID = '%@'", [self tableName], version, userId];
    
    NSString *additionalCondition = [self queryRecordsForSyncAdditionalCondition];
    if (additionalCondition.length) {
        [query appendFormat:@" and %@", additionalCondition];
    }
    
    FMResultSet *result = [db executeQuery:query];
    if (!result) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([result next]) {
        NSMutableDictionary *recordInfo = [NSMutableDictionary dictionaryWithCapacity:[self columns].count];
        for (NSString *column in [self columns]) {
            NSString *value = [result stringForColumn:column];
            NSString *mappedKey = [[self fieldMapping] objectForKey:column];
            [recordInfo setObject:(value ?: @"") forKey:(mappedKey ?: column)];
        }
        [syncRecords addObject:recordInfo];
    }
    
    [result close];
    
    return syncRecords;
}

+ (BOOL)updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:(int64_t)newVersion forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    int64_t version = [SSJSyncTable lastSuccessSyncVersionForUserId:userId inDatabase:db];
    if (version == SSJ_INVALID_SYNC_VERSION) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    if (newVersion == SSJ_INVALID_SYNC_VERSION) {
        SSJPRINT(@">>>SSJ warning: invalid sync version");
        return NO;
    }
    
    NSMutableString *update = [NSMutableString stringWithFormat:@"update %@ set IVERSION = %lld where IVERSION = %lld and CUSERID = '%@'", [self tableName], newVersion, version + 2, userId];
    NSString *additionalCondition = [self updateSyncVersionAdditionalCondition];
    if (additionalCondition.length) {
        [update appendFormat:@" and %@", additionalCondition];
    }
    
    BOOL success = [db executeUpdate:update];
    if (!success) {
        *error = [db lastError];
        SSJPRINT(@">>>SSJ warning:an error occured when update sync version of record that is modified during synchronization to the newest version\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
    }
    
    return success;
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *record in records) {
        if (![record isKindOfClass:[NSDictionary class]]) {
            if (error) {
                *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"record that is being merged is not kind of NSDictionary class"}];
            }
            SSJPRINT(@">>>SSJ warning: record needed to merge is not subclass of NSDictionary\n record:%@", record);
            return NO;
        }
        
        NSMutableDictionary *recordInfo = [record mutableCopy];
        NSDictionary *mapping = [self fieldMapping];
        if (mapping) {
            [mapping enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                id value = recordInfo[obj];
                if (value) {
                    [recordInfo removeObjectForKey:obj];
                    [recordInfo setObject:value forKey:key];
                }
            }];
        }
        
        if (![self shouldMergeRecord:recordInfo forUserId:userId inDatabase:db error:error]) {
            if (error && *error) {
                return NO;
            }
            continue;
        }
        
        //  根据合并记录返回相应的sql语句
        NSMutableString *statement = [[self sqlStatementForMergeRecord:recordInfo inDatabase:db error:error] mutableCopy];
        if (error && *error) {
            return NO;
        }
        
        //  如果返回nil，就不需要对这条数据进行处理
        if (!statement) {
            continue;
        }
        
        BOOL success = [db executeUpdate:statement];
        if (!success) {
            if (error) {
                *error = [db lastError];
            }
            return NO;
        }
    }
    
    return YES;
}

//  根据合并记录返回相应的sql语句
+ (NSString *)sqlStatementForMergeRecord:(NSDictionary *)recordInfo inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    //  根据记录的操作类型，对记录进行相应的操作
    NSString *opertoryType = recordInfo[@"operatortype"];
    if (opertoryType.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"record is lack of column operatortype"}];
        }
        SSJPRINT(@">>>SSJ warning: merge record lack of column 'OPERATORTYPE'\n record:%@", recordInfo);
        return nil;
    }
    
    //  0添加  1修改  2删除
    int opertoryValue = [opertoryType intValue];
    if (opertoryValue != 0 && opertoryValue != 1 && opertoryValue != 2) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"record has unknown operatortype value %@", opertoryType]}];
        }
        SSJPRINT(@">>>SSJ warning:unknown OPERATORTYPE value %d", opertoryValue);
        return nil;
    }
    
    //  根据表中的主键拼接合并条件
    NSString *necessaryCondition = [self spliceKeyAndValueForKeys:[self primaryKeys] record:recordInfo joinString:@" and "];
    if (!necessaryCondition.length) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"an error occured when splice record's keys and values"}];
        }
        SSJPRINT(@">>>SSJ warning:an error occured when splice record's keys and values");
        return nil;
    }
    
    //  检测表中是否存在将要合并的记录
    FMResultSet *resultSet = [db executeQuery:[NSString stringWithFormat:@"select operatortype from %@ where %@", [self tableName], necessaryCondition]];
    
    if (!resultSet) {
        if (error) {
            *error = [db lastError];
        }
        return nil;
    }
    
    BOOL isExisted = NO;
    NSString *statement = nil;
    
    while ([resultSet next]) {
        isExisted = YES;
        int localOperatorType = [resultSet intForColumn:@"operatortype"];
        
        if (localOperatorType == 0 || localOperatorType == 1) {
            //  如果将要合并的记录操作类型是删除，就不需要根据操作时间决定保留哪条记录，直接合并
            NSMutableString *condition = [necessaryCondition mutableCopy];
            if (opertoryValue == 0 || opertoryValue == 1) {
                [condition appendFormat:@" and cwritedate < '%@'", recordInfo[@"cwritedate"]];
            }
            
            NSString *updateStatement = [self updateStatementForMergeRecord:recordInfo];
            
            if (updateStatement) {
                statement = [NSString stringWithFormat:@"%@ where %@", updateStatement, condition];
            }
        } else if (localOperatorType == 2) {
            //  如果本地记录已经删除，就直接忽略将要合并的记录
            [resultSet close];
            return nil;
        } else {
            SSJPRINT(@">>> SSJ Warning:local record's operatortype value is error,undefined value %d", localOperatorType);
            [resultSet close];
            return nil;
        }
    }
    
    [resultSet close];
    
    if (!isExisted) {
        statement = [self insertStatementForMergeRecord:recordInfo];
    }
    
    return statement;
}

//  返回插入新纪录的sql语句
+ (NSString *)insertStatementForMergeRecord:(NSDictionary *)recordInfo {
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:[recordInfo count]];
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[recordInfo count]];
    
    [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([[self columns] containsObject:key]) {
            [columns addObject:key];
            [values addObject:[NSString stringWithFormat:@"'%@'", obj]];
        }
    }];
    
    NSString *columnsStr = [columns componentsJoinedByString:@", "];
    NSString *valuesStr = [values componentsJoinedByString:@", "];
    
    return [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [self tableName], columnsStr, valuesStr];
}

//  返回更新的sql语句
+ (NSString *)updateStatementForMergeRecord:(NSDictionary *)recordInfo {
    NSString *keyValuesStr = [self spliceKeyAndValueForKeys:[self columns] record:recordInfo joinString:@", "];
    NSMutableString *updateSql = [NSMutableString stringWithFormat:@"update %@ set %@", [self tableName], keyValuesStr];
    
    return updateSql;
}

+ (NSString *)spliceKeyAndValueForKeys:(NSArray *)keys record:(NSDictionary *)recordInfo joinString:(NSString *)joinString {
    NSMutableArray *keyValues = [NSMutableArray arrayWithCapacity:recordInfo.count];
    [recordInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([keys containsObject:key]) {
            [keyValues addObject:[NSString stringWithFormat:@"%@ = '%@'", key, obj]];
        }
    }];
    
    return [keyValues componentsJoinedByString:joinString];
}

+ (NSDictionary *)fieldMapping {
    return nil;
}

@end
