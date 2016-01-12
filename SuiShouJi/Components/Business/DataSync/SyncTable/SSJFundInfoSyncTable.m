//
//  SSJFundInfoSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundInfoSyncTable.h"

@implementation SSJFundInfoSyncTable

+ (NSString *)tableName {
//    return @"BK_FUND_INFO";
    return @"bk_fund_info";
}

+ (NSArray *)columns {
//    return @[@"CFUNDID", @"CACCTNAME", @"CICOIN", @"CPARENT", @"CCOLOR", @"CADDDATE", @"CMEMO", @"CUSERID", @"CWRITEDATE", @"IVERSION", @"OPERATORTYPE"];
    return @[@"cfundid", @"cacctname", @"cicoin", @"cparent", @"ccolor", @"cadddate", @"cmemo", @"cuserid", @"cwritedate", @"iversion", @"operatortype"];
}

+ (NSArray *)primaryKeys {
//    return @[@"CFUNDID"];
    return @[@"cfundid"];
}

+ (NSString *)queryRecordsForSyncAdditionalCondition {
//    return @"CPARENT <> 'root'";
    return @"cparent <> 'root'";
}

+ (NSString *)updateSyncVersionAdditionalCondition {
//    return @"CPARENT <> 'root'";
    return @"cparent <> 'root'";
}

//+ (BOOL)shouMergeRecord:(NSDictionary *)record inDatabase:(FMDatabase *)db {
//    FMResultSet *result = [db executeQuery:@"select count(*) from BK_FUND_INFO where CFUNDID = ?", record[@"CPARENT"]];
//    if (!result) {
//        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
//        return NO;
//    }
//    
//    [result next];
//    if ([result intForColumnIndex:0] <= 0) {
//        return NO;
//    }
//    
//    return YES;
//}

+ (NSString *)additionalConditionForMergeRecord:(NSDictionary *)record {
    return [NSString stringWithFormat:@"(select count(*) from BK_FUND_INFO where CFUNDID = '%@') > 0", record[@"CPARENT"]];
}

@end
