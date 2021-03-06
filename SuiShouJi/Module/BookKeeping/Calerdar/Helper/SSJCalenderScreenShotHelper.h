//
//  SSJCalenderScreenShotHelper.h
//  SuiShouJi
//
//  Created by ricky on 2017/1/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJCalenderScreenShotHelper : NSObject

+ (NSArray *)screenShotForTableView:(UITableView *)tableview;

+ (void)screenShotForCalenderWithCellImages:(NSArray *)images Date:(NSDate *)date income:(double)income expence:(double)expence imageBlock:(void (^)(UIImage *image))imageBlock;

@end
