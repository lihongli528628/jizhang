//
//  SSJWishChargeSyncTable.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishChargeSyncTable.h"

@implementation SSJWishChargeSyncTable
+ (NSString *)tableName {
    return @"bk_wish_charge";
}

+ (NSArray *)columns {
    return @[@"chargeid",
             @"money",
             @"wishid",
             @"cuserid",
             @"iversion",
             @"cwritedate",
             @"operatortype",
             @"memo",
             @"itype",
             @"cbilldate"];
}

+ (NSArray *)primaryKeys {
    return @[@"chargeid"];
}
@end
