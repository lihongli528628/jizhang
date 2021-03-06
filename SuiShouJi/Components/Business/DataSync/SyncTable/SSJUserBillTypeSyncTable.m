//
//  SSJUserBillTypeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBillTypeSyncTable.h"

@implementation SSJUserBillTypeSyncTable

+ (NSString *)tableName {
    return @"bk_user_bill_type";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"cbillid",
            @"cuserid",
            @"cbooksid",
            @"itype",
            @"cname",
            @"ccolor",
            @"cicoin",
            @"iorder",
            @"cwritedate",
            @"operatortype",
            @"iversion",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObjects:
            @"cbillid",
            @"cuserid",
            @"cbooksid",
            nil];
}

- (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    for (NSDictionary *recordInfo in records) {
        // 老版本有数据可能cbooksid为null
        BOOL exist = [db boolForQuery:@"select count(*) from bk_user_bill_type where cbillid = ? and cuserid = ? and cbooksid = ?", recordInfo[@"cbillid"], recordInfo[@"cuserid"], recordInfo[@"cbooksid"] ? : recordInfo[@"cuserid"]];
        
        NSDictionary *param = @{@"cbillid":recordInfo[@"cbillid"],
                                @"cuserid":recordInfo[@"cuserid"],
                                @"cbooksid":recordInfo[@"cbooksid"],
                                @"itype":recordInfo[@"itype"],
                                @"cname":recordInfo[@"cname"],
                                @"ccolor":recordInfo[@"ccolor"],
                                @"cicoin":recordInfo[@"cicoin"],
                                @"iorder":recordInfo[@"iorder"],
                                @"cwritedate":recordInfo[@"cwritedate"],
                                @"operatortype":recordInfo[@"operatortype"],
                                @"iversion":recordInfo[@"iversion"]};
        if (exist) {
            if (![db executeUpdate:@"update bk_user_bill_type set itype = :itype, cname = :cname, ccolor = :ccolor, cicoin = :cicoin, iorder = :iorder, cwritedate = :cwritedate, operatortype = :operatortype, iversion = :iversion where cbillid = :cbillid and cuserid = :cuserid and cbooksid = :cbooksid and cwritedate < :cwritedate" withParameterDictionary:param]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        } else {
            if (![db executeUpdate:@"insert into bk_user_bill_type (cbillid, cuserid, cbooksid, itype, cname, ccolor, cicoin, iorder, cwritedate, operatortype, iversion) values (:cbillid, :cuserid, :cbooksid, :itype, :cname, :ccolor, :cicoin, :iorder, :cwritedate, :operatortype, :iversion)" withParameterDictionary:param]) {
                if (error) {
                    *error = [db lastError];
                }
                return NO;
            }
        }
    }
    
    return YES;
}

@end
