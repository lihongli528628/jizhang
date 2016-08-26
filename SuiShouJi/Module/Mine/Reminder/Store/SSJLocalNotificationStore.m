//
//  SSJLocalNotificationStore.m
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLocalNotificationStore.h"

@implementation SSJLocalNotificationStore

+ (void)queryForreminderListWithSuccess:(void(^)(NSArray<SSJReminderItem *> *result))success
                               failure:(void (^)(NSError *error))failure {
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FMResultSet * resultSet = [db executeQuery:@"select * from bk_user_remind where cuserid = ? and operatortype <> 2",userId];
        if (!resultSet) {
            if (failure) {
                SSJDispatch_main_async_safe(^{
                    failure([db lastError]);
                });
            }
            return;
        }
        while ([resultSet next]) {
            SSJReminderItem *item = [[SSJReminderItem alloc]init];
            item.remindId = [resultSet stringForColumn:@"cremindid"];
            item.remindName = [resultSet stringForColumn:@"cremindname"];
            item.remindMemo = [resultSet stringForColumn:@"cmemo"];
            item.remindCycle = [resultSet intForColumn:@"icycle"];
            item.remindType = [resultSet intForColumn:@"itype"];
            NSString *dateStr = [resultSet stringForColumn:@"cstartdate"];
            item.remindDate = [NSDate dateWithString:dateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
            item.remindState = [resultSet stringForColumn:@"istate"];
            item.remindAtTheEndOfMonth = [resultSet stringForColumn:@"iisend"];
            if (item.remindType == SSJReminderTypeCreditCard) {
                item.remindFundid = [db stringForQuery:@"select cfundid from bk_user_credit where cremindid = ? and cuserid = ?",item.remindId,userId];
            }else if (item.remindType == SSJReminderTypeBorrowing){
                item.remindFundid = [db stringForQuery:@"select cfundid from bk_loan where cremindid = ? and cuserid = ?",item.remindId,userId];
            }else{
                item.remindFundid = @"";
            }
            [tempArr addObject:item];
        }
        if (success) {
            SSJDispatch_main_async_safe(^{
                success(tempArr);
            });
        }
    }];
}

+ (NSError *)saveReminderWithReminderItem:(SSJReminderItem *)item
                               inDatabase:(FMDatabase *)db {
    if (!item.remindId.length) {
        item.remindId = SSJUUID();
    }
    
    NSString *userId = SSJUSERID();
    
    NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    // 判断是编辑还是新增
    if ([db intForQuery:@"select count(1) from bk_user_remind where cuserid = ? and cremindid = ?",userId,item.remindId]) {
        if (![db executeUpdate:@"update bk_user_remind set cremindname = ?, cmemo = ?, cstartdate  = ?, istate = 1, itype = ?, icycle = ?, iisend = ? , cwritedate = ?, operatortype = 1, iversion = ? where cuserid = ? and cremindid = ?",item.remindName,item.remindMemo,[item.remindDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"],@(item.remindType),@(item.remindCycle),@(item.remindAtTheEndOfMonth),cwriteDate,@(SSJSyncVersion()),userId,item.remindId]) {
            return [db lastError];
        }
    }else{
        if (![db executeUpdate:@"insert into bk_user_remind (cremindid,cremindname,cmemo,cstartdate,istate,itype,icycle,iisend,cwritedate,operatortype,iversion,cuserid) values (?,?,?,?,1,?,?,?,?,0,?,?)",item.remindId,item.remindName,item.remindMemo,[item.remindDate formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"],@(item.remindType),@(item.remindCycle),@(item.remindAtTheEndOfMonth),cwriteDate,@(SSJSyncVersion()),userId]) {
            return [db lastError];
        }
    }
    
    return nil;
}

+ (void)syncSaveReminderWithReminderItem:(SSJReminderItem *)item
                               Error:(NSError **)error {
    //  保存提醒
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveReminderWithReminderItem:item inDatabase:db];
        SSJDispatch_main_async_safe(^{
            if (error) {
                *error = tError;
            }
        });
    }];
}

+ (void)asyncsaveReminderWithReminderItem:(SSJReminderItem *)item
                                  Success:(void (^)(void))success
                                  failure:(void (^)(NSError *error))failure {
    //  保存提醒
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSError *tError = [self saveReminderWithReminderItem:item inDatabase:db];
        if (tError) {
            SSJDispatch_main_async_safe(^{
                if (failure) {
                    failure(tError);
                }
            });
        } else {
            SSJDispatch_main_async_safe(^{
                if (success) {
                    success();
                }
            });
        }
    }];
}

+ (SSJReminderItem *)queryReminderItemForID:(NSString *)remindId {
    SSJReminderItem *item = [[SSJReminderItem alloc] init];
    NSString *userId = SSJUSERID();
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select * from bk_user_remind where cremindid = ?",remindId];
        item.remindId = [resultSet stringForColumn:@"cremindid"];
        item.remindName = [resultSet stringForColumn:@"cremindname"];
        item.remindMemo = [resultSet stringForColumn:@"cmemo"];
        item.remindCycle = [resultSet intForColumn:@"icycle"];
        item.remindType = [resultSet intForColumn:@"itype"];
        NSString *dateStr = [resultSet stringForColumn:@"cstartdate"];
        item.remindDate = [NSDate dateWithString:dateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
        item.remindState = [resultSet stringForColumn:@"istate"];
        item.remindAtTheEndOfMonth = [resultSet stringForColumn:@"iisend"];
        if (item.remindType == SSJReminderTypeCreditCard) {
            item.remindFundid = [db stringForQuery:@"select cfundid from bk_user_credit where cremindid = ? and cuserid = ?",remindId,userId];
        }else if (item.remindType == SSJReminderTypeBorrowing){
            item.remindFundid = [db stringForQuery:@"select cfundid from bk_loan where cremindid = ? and cuserid = ?",remindId,userId];
        }else{
            item.remindFundid = @"";
        }
    }];
    return item;
}

@end