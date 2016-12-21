//
//  SSJCreditRepaymentSyncTable.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCreditRepaymentSyncTable.h"

@implementation SSJCreditRepaymentSyncTable

+ (NSString *)tableName {
    return @"bk_credit_repayment";
}

+ (NSArray *)columns {
    return @[@"crepaymentid",
             @"iinstalmentcount",
             @"capplydate",
             @"ccardid",
             @"repaymentmoney",
             @"ipoundagerate",
             @"cmemo",
             @"cuserid",
             @"operatortype",
             @"cwritedate",
             @"iversion",
             @"crepaymentmonth"];
}

+ (NSArray *)primaryKeys {
    return @[@"crepaymentid"];
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    
    for (NSDictionary *recordInfo in records) {
        NSString *repaymentid = recordInfo[@"crepaymentid"];
        NSString *instalmentcount = recordInfo[@"iinstalmentcount"];
        NSString *applydate = recordInfo[@"capplydate"];
        NSString *cardid = recordInfo[@"ccardid"];
        NSString *money = recordInfo[@"repaymentmoney"];
        NSString *poundagerate = recordInfo[@"ipoundagerate"];
        NSString *memo = recordInfo[@"cmemo"];
        NSString *userid = recordInfo[@"cuserid"];
        NSString *operatortype = recordInfo[@"operatortype"];
        NSString *writedate = recordInfo[@"cwritedate"];
        NSString *version = recordInfo[@"iversion"];
        NSString *month = recordInfo[@"crepaymentmonth"];
        BOOL isExsit = NO;
        NSInteger localOperatortype;
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_credit_repayment where cuerid = ? and repaymentid = ?",userid,repaymentid];
        while ([resultSet next]) {
            isExsit = YES;
            localOperatortype = [resultSet intForColumn:@"operatortype"];
        }
        if ([db intForQuery:@"select count(1) from bk_credit_repayment where cuserid = ? and crepaymentmonth = ? and iinstalmentcount > 0 and operatortype <> 2",userId,month] && [instalmentcount integerValue]) {
            // 首先判断当月有没有分期,如果有,则直接抛弃这条数据
            if (localOperatortype == 1 || localOperatortype == 0) {
                // 如果本地有一条已经删除的数据
            }
            
        }
    }
    return YES;
}


@end