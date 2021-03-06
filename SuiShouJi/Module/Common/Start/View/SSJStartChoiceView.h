//
//  SSJStartChoiceView.h
//  SuiShouJi
//
//  Created by 赵天立 on 2017/9/10.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJStartChoiceView : UIView

@property (nonatomic, copy) void(^jumpOutButtonClickBlock)();

@property (nonatomic, copy) void(^choiceOutButtonClickBlock)(NSInteger buttonTag);

- (void)startAnimating;

@end
