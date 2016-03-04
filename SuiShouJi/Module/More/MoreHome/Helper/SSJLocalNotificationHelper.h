//
//  SSJLocalNotificationHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJLocalNotificationHelper : NSObject
/**
 *  注册一个本地通知
 *
 *  @param fireDate        触发时间
 *  @param repeatIterval   触发频率
 *  @param notificationKey 触发通知的key
 */
+(void)registerLocalNotificationWithFireDate:(NSDate*)fireDate
                               repeatIterval:(NSCalendarUnit)repeatIterval
                             notificationKey:(NSString *)notificationKey;

+(void)cancelLocalNotificationWithKey:(NSString *)key;
@end
