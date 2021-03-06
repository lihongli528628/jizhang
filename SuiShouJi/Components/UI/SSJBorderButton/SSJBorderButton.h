//
//  SSJBorderButton.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SSJBorderButtonState) {
    SSJBorderButtonStateNormal,
    SSJBorderButtonStateHighlighted,
    SSJBorderButtonStateDisable
};

@interface SSJBorderButton : UIView

//  title字体大小
@property (nonatomic) CGFloat fontSize;

//  default 1
@property (nonatomic) CGFloat borderWidth;

//  圆角弧度半径
@property (nonatomic) CGFloat cornerRadius;

//  default SSJBorderButtonStateNormal
@property (readonly, nonatomic) SSJBorderButtonState state;

//  default YES
@property (nonatomic) BOOL enabled;

- (void)setTitle:(NSString *)title forState:(SSJBorderButtonState)state;

- (void)setTitleColor:(UIColor *)color forState:(SSJBorderButtonState)state;

- (void)setBorderColor:(UIColor *)color forState:(SSJBorderButtonState)state;

- (void)setBackgroundColor:(UIColor *)color forState:(SSJBorderButtonState)state;

/**
 *  添加点击执行的方法
 *
 *  @param target 执行方法的目标
 *  @param action 执行的方法
 */
- (void)addTarget:(id)target action:(SEL)action;

@end

NS_ASSUME_NONNULL_END
