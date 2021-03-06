//
//  SSJCalenderScreenShotHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/1/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCalenderScreenShotHelper.h"

@implementation SSJCalenderScreenShotHelper

+ (void)screenShotForCalenderWithCellImages:(NSArray *)images Date:(NSDate *)date income:(double)income expence:(double)expence imageBlock:(void (^)(UIImage *image))imageBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *shareImage = nil;
        
        UIImage *headerImage = [UIImage imageNamed:@"calendar_shareheader"];
        
        UIImage *qrImage = [UIImage imageNamed:@"calendar_qrImage"];
        
        UIImage *backImage = [UIImage ssj_themeImageWithName:@"background"];
    
        if (!backImage) {
            backImage = [UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(SSJSCREENWITH, SSJSCREENHEIGHT)];
        }
        
        double width = SSJSCREENWITH;
        
        // 调整两张图的宽和高
        double headerImageHeight = headerImage.size.height * width / headerImage.size.width;
        double wholeHeight = MAX(headerImageHeight + 140 + 65 * images.count + 48, SSJSCREENHEIGHT);
        [headerImage ssj_scaleImageWithSize:CGSizeMake(width, headerImageHeight)];
//        [backImage ssj_scaleImageWithSize:CGSizeMake(SSJSCREENWITH, SSJSCREENHEIGHT)];

        // 开始绘制
        UIGraphicsBeginImageContext(CGSizeMake(width, wholeHeight));
        
        // 首先绘制背景图片
        [backImage drawInRect:CGRectMake(0, 0, width, backImage.size.height)];
        
        // 如果长度超过总长度,则在下面补充纯色背景
        if (wholeHeight > backImage.size.height) {
            UIImage *colorImage = [UIImage ssj_imageWithColor:[backImage ssj_getPixelColorAtLocation:CGPointMake(backImage.size.width - 1, backImage.size.height - 1)] size:CGSizeMake(backImage.size.width, wholeHeight - backImage.size.height)];
            [colorImage drawInRect:CGRectMake(0, backImage.size.height, width, wholeHeight - backImage.size.height)];
        }
        
        // 绘制第一张图
        [headerImage drawInRect:CGRectMake(0, 0, width, headerImageHeight)];
        
        float firstImageCenterX = CGRectGetMidX(CGRectMake(0, 0, width, headerImageHeight));
        float firstImageCenterY = CGRectGetMidY(CGRectMake(0, 0, width, headerImageHeight));
        
        // 写上日期
        NSString *dateStr = [date formattedDateWithFormat:@"MM/dd"];
        CGSize dateSize = [dateStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1]}];
        
        [dateStr drawInRect:CGRectMake(firstImageCenterX - 10 - dateSize.width, firstImageCenterY - dateSize.height / 2, dateSize.width, dateSize.width) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];

        
        // 写上星期
        NSString *weekDayStr = [NSString stringWithFormat:@"%@",[self stringFromWeekday:date.weekday]];
        CGSize weekDaySize = [weekDayStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1]}];
        [weekDayStr drawInRect:CGRectMake(firstImageCenterX + 10, firstImageCenterY - weekDaySize.height / 2, weekDaySize.width, weekDaySize.width) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];

        // 写上年份
        NSString *yearStr = [NSString stringWithFormat:@"%04ld",(long)date.year];
        CGSize yearSize = [yearStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}];
        [yearStr drawInRect:CGRectMake(firstImageCenterX - dateSize.width / 2 - 10 - yearSize.width / 2, firstImageCenterY + dateSize.height / 2 + 5, yearSize.width, yearSize.height) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#222222"]}];
        
        // 写上总收入
        NSString *incomeTitleStr = @"总收入:";
        CGSize incomeTitleSize = [incomeTitleStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}];
        [incomeTitleStr drawInRect:CGRectMake(10, headerImageHeight + 25 - incomeTitleSize.height / 2, incomeTitleSize.width, incomeTitleSize.height) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        // 写上收入金额
        NSString *incomeStr = [[NSString stringWithFormat:@"%f",income] ssj_moneyDecimalDisplayWithDigits:2];
        CGSize incomeSize = [incomeStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}];
        [incomeStr drawInRect:CGRectMake(10 + incomeTitleSize.width + 5, headerImageHeight + 25 - incomeSize.height / 2, incomeSize.width, incomeSize.height) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor]}];
        
        // 写上支出金额
        NSString *expenceStr = [[NSString stringWithFormat:@"%f",expence] ssj_moneyDecimalDisplayWithDigits:2];
        CGSize expenceSize = [expenceStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}];
        [expenceStr drawInRect:CGRectMake(width - expenceSize.width - 10, headerImageHeight + 25 - expenceSize.height / 2, expenceSize.width, expenceSize.height) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor]}];
        
        // 写上总支出
        NSString *expenceTitleStr = @"总支出:";
        CGSize expenceTitleSize = [expenceTitleStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}];
        [expenceTitleStr drawInRect:CGRectMake(width - expenceSize.width - 15 - expenceTitleSize.width, headerImageHeight + 25 - expenceTitleSize.height / 2, expenceTitleSize.width, expenceTitleSize.height) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        
        
        // 把cell的截图画上去
        for (UIImage *image in images) {
            NSInteger index = [images indexOfObject:image];
            [image drawInRect:CGRectMake(0, headerImageHeight + index * 65 + 48, width, 65)];
        }
    
        UIImage *lineImage = [UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] size:CGSizeMake(width, 1 / [UIScreen mainScreen].scale)];
        [lineImage drawInRect:CGRectMake(0, headerImageHeight + 48, width, 1)];
        
        // 把二维码的图画上去
        [qrImage drawInRect:CGRectMake(width / 2 - qrImage.size.width / 2, wholeHeight - 70 - qrImage.size.height / 2, qrImage.size.width, qrImage.size.height)];
        
        // 把二维码下面的字写上去
        NSString *qrStr = @"长按识别图中二维码,下载有鱼记账";
        CGSize qrStrSize = [qrStr sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}];
        [qrStr drawInRect:CGRectMake((width - qrStrSize.width) / 2, wholeHeight - 65 + qrImage.size.height / 2, qrStrSize.width, qrStrSize.height) withAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4],NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

        shareImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        SSJDispatch_main_async_safe(^{
            imageBlock(shareImage);
        });
    });
}

+ (NSString *)stringFromWeekday:(NSInteger)weekday {
    switch (weekday) {
        case 1: return @"星期日";
        case 2: return @"星期一";
        case 3: return @"星期二";
        case 4: return @"星期三";
        case 5: return @"星期四";
        case 6: return @"星期五";
        case 7: return @"星期六";
            
        default: return nil;
    }
}

+ (NSArray *)screenShotForTableView:(UITableView *)tableview {
    [tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    NSMutableArray *screenshots = [NSMutableArray array];
    for (int section=0; section < tableview.numberOfSections; section++) {

        //cell
        for (int row = 0; row< [tableview numberOfRowsInSection:section]; row++) {
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UIImage *cellScreenshot = [self screenshotForTableView:tableview AtCellAtIndexPath:cellIndexPath];
            if (cellScreenshot) [screenshots addObject:cellScreenshot];
            
            if (section == tableview.numberOfSections - 1 && row == [tableview numberOfRowsInSection:section] - 1) {
                [tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
        

    }
    
    return screenshots;
}

/**
 *  截取cell
 */
+ (UIImage *)screenshotForTableView:(UITableView *)tableView AtCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView beginUpdates];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [tableView endUpdates];
    
    return [cell ssj_takeScreenShotWithSize:cell.size opaque:NO scale:0];
}

@end
