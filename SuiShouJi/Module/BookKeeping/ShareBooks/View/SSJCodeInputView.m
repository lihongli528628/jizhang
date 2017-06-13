//
//  SSJCodeInputView.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCodeInputView.h"


@interface SSJCodeInputView()

@property(nonatomic) UIEdgeInsets insects;

@end

@implementation SSJCodeInputView

- (instancetype)initWithFrame:(CGRect)frame clearButtonInsects:(UIEdgeInsets)insects
{
    self = [super initWithFrame:frame];
    if (self) {
        self.insects = insects;
    }
    return self;
}


- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
    
    CGRect rect = [super clearButtonRectForBounds:bounds];
    
    
    return UIEdgeInsetsInsetRect(rect, self.insects);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
