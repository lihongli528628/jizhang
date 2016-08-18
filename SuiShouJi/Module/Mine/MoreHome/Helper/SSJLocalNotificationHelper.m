//
//  SSJLocalNotificationHelper.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLocalNotificationHelper.h"
#import "SSJStartChecker.h"

@interface SSJLocalNotificationHelper()

@end
@implementation SSJLocalNotificationHelper

//+ (void)load {
//    if (SSJIsFirstLaunchForCurrentVersion()) {
//        NSString *baseDateStr = [NSString stringWithFormat:@"%@ 20:00:00",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
//        NSDate *baseDate = [NSDate dateWithString:baseDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
//        if ([baseDate isEarlierThan:[NSDate date]]) {
//            baseDate = [baseDate dateByAddingDays:1];
//        }
//        [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJChargeReminderNotification];
//        [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSCalendarUnitDay notificationKey:SSJChargeReminderNotification];
//    }
//}

+ (void)registerLocalNotificationWithremindItem:(SSJReminderItem *)item
{
    NSMutableArray *notificationsArr = [NSMutableArray array];
//    // 设置触发通知的时间
//    notification.fireDate = fireDate;
//    // 时区
//    notification.timeZone = [NSTimeZone defaultTimeZone];
//    // 设置重复的间隔
//    notification.repeatInterval = repeatIterval;
//    // 通知内容
//    notification.alertBody =  str;
//
//    notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    
    NSDate * fireDate = [NSDate dateWithString:item.remindDate formatString:@"yyyy-MM-dd HH:mm:ss"];
    
    switch (item.remindCycle) {
        // 如果是每天
        case 0:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = [NSDictionary dictionaryWithObject:item forKey:@"key"];
            notification.userInfo = userDict;
            notification.repeatInterval = NSCalendarUnitDay;
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
        
        // 如果是每周
        case 3:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = [NSDictionary dictionaryWithObject:item forKey:@"key"];
            notification.userInfo = userDict;
            notification.repeatInterval = NSWeekdayCalendarUnit;
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
        
        case 7:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = [NSDictionary dictionaryWithObject:item forKey:@"key"];
            notification.userInfo = userDict;
            if ([fireDate isEarlierThan:[NSDate date]]) {
                fireDate = [fireDate dateByAddingDays:1];
            }
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
        
        case 1:{
            NSDate *firstDayOfTheWeek = [[fireDate dateBySubtractingDays:fireDate.weekday] dateByAddingDays:2];
            for (int i = 0; i < 5; i ++) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                // 时区
                notification.timeZone = [NSTimeZone defaultTimeZone];
                // 通知内容
                notification.alertBody = item.remindContent;
                // 通知被触发时播放的声音
                notification.soundName = @"pushsound.wav";
                // 通知参数
                NSDictionary *userDict = [NSDictionary dictionaryWithObject:item forKey:@"key"];
                notification.userInfo = userDict;
                notification.fireDate = [firstDayOfTheWeek dateByAddingDays:i];
                [notificationsArr addObject:notification];
            }
        }
        break;
        
        default:{
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            // 时区
            notification.timeZone = [NSTimeZone defaultTimeZone];
            // 通知内容
            notification.alertBody = item.remindContent;
            // 通知被触发时播放的声音
            notification.soundName = @"pushsound.wav";
            // 通知参数
            NSDictionary *userDict = [NSDictionary dictionaryWithObject:item forKey:@"key"];
            notification.userInfo = userDict;
            if ([fireDate isEarlierThan:[NSDate date]]) {
                fireDate = [fireDate dateByAddingDays:1];
            }
            notification.fireDate = fireDate;
            [notificationsArr addObject:notification];
        }
        break;
    }
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    // 执行通知注册
    for (UILocalNotification *notification in notificationsArr) {
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
//    NSArray *localNotifications = [[NSArray alloc]init];
//    localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
}

+ (void)cancelLocalNotificationWithKey:(nullable NSString *)key{
    if (!key.length) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        return;
    }
    // 获取所有本地通知数组
    NSArray *localNotifications = [[NSArray alloc]init];
    localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[@"key"];
            
            // 如果找到需要取消的通知，则取消
            if (([info isEqualToString: key])) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }  
        }  
    }
}


@end
