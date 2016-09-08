//
//  SSJUserCreditSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserCreditSyncTable.h"

@implementation SSJUserCreditSyncTable

+ (NSString *)tableName {
    return @"bk_user_credit";
}

+ (NSArray *)columns {
    return @[@"cfundid",
             @"iquota",
             @"cbilldate",
             @"crepaymentdate",
             @"cremindid",
             @"cuserid",
             @"cwritedate",
             @"iversion",
             @"operatortype",
             @"ibilldatesettlement"];
}

+ (NSArray *)primaryKeys {
    return @[@"cfundid"];
}

@end
