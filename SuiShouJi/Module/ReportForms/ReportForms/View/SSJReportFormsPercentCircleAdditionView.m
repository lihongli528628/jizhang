//
//  SSJReportFormsPercentCircleAdditionView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPercentCircleAdditionView.h"

static NSString *const kAnimationKey = @"kAnimationKey";

@interface SSJReportFormsPercentCircleAdditionView ()

@property (nonatomic, readwrite, strong) SSJReportFormsPercentCircleAdditionViewItem *item;

@property (nonatomic, strong) CAShapeLayer *brokenLineLayer;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic) CGPoint startPoint;

@property (nonatomic) CGPoint turnPoint;

@property (nonatomic) CGPoint endPoint;

@end

@implementation SSJReportFormsPercentCircleAdditionView

- (instancetype)initWithItem:(SSJReportFormsPercentCircleAdditionViewItem *)item {
    if (!item) {
        return nil;
    }
    
    if (self = [super initWithFrame:CGRectMake(item.startPoint.x, item.startPoint.y, 0, 0)]) {
        self.item = item;
        
        
        [self.layer addSublayer:self.brokenLineLayer];
        [self addSubview:self.imageView];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (void)didMoveToSuperview {
    if (self.superview) {
        self.startPoint = [self convertPoint:self.item.startPoint fromView:self.superview];
        self.turnPoint = [self convertPoint:self.item.turnPoint fromView:self.superview];
        self.endPoint = [self convertPoint:self.item.endPoint fromView:self.superview];
    }
}

- (void)layoutSubviews {
    switch (self.item.orientation) {
        case SSJReportFormsPercentCircleAdditionViewOrientationTopRight:
        case SSJReportFormsPercentCircleAdditionViewOrientationBottomRight:
            self.imageView.center = CGPointMake(self.endPoint.x + self.item.imageRadius, self.endPoint.y);
            break;
            
        case SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft:
        case SSJReportFormsPercentCircleAdditionViewOrientationTopLeft:
            self.imageView.center = CGPointMake(self.endPoint.x - self.item.imageRadius, self.endPoint.y);
            break;
    }
    self.textLabel.top = self.imageView.centerY + self.item.imageRadius + self.item.gapBetweenImageAndText;
    self.textLabel.centerX = self.imageView.centerX;
}

//- (CGSize)sizeThatFits:(CGSize)size {
//    CGSize textSize = [self.item.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.item.textSize]}];
//    CGFloat width = 0;
//    CGFloat height = 0;
//    switch (self.item.orientation) {
//        case SSJReportFormsPercentCircleAdditionViewOrientationTopRight:
//            width = self.item.endPoint.x - self.item.startPoint.x + MAX(self.item.imageRadius * 2, textSize.width);
//            height = self.item.imageRadius + MAX(self.item.imageRadius + self.item.gapBetweenImageAndText + textSize.height, self.item.startPoint.y - self.item.endPoint.y);
//            break;
//        case SSJReportFormsPercentCircleAdditionViewOrientationBottomRight:
//            width = self.item.endPoint.x - self.item.startPoint.x + MAX(self.item.imageRadius * 2, textSize.width);
//            height = self.item.imageRadius + self.item.gapBetweenImageAndText + textSize.height + MAX(self.item.imageRadius, self.item.endPoint.y - self.item.startPoint.y);
//            break;
//            
//        case SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft:
//            width = self.item.startPoint.x - self.item.endPoint.x + MAX(self.item.imageRadius * 2, textSize.width);
//            height = self.item.imageRadius + self.item.gapBetweenImageAndText + textSize.height + MAX(self.item.imageRadius, self.item.endPoint.y - self.item.startPoint.y);
//            break;
//        case SSJReportFormsPercentCircleAdditionViewOrientationTopLeft:
//            width = self.item.startPoint.x - self.item.endPoint.x + MAX(self.item.imageRadius * 2, textSize.width);
//            height = self.item.imageRadius + MAX(self.item.imageRadius + self.item.gapBetweenImageAndText + textSize.height, self.item.startPoint.y - self.item.endPoint.y);
//            break;
//    }
//    return CGSizeMake(width, height);
//}

- (BOOL)testOverlap:(SSJReportFormsPercentCircleAdditionView *)view {
    if (![view isKindOfClass:[SSJReportFormsPercentCircleAdditionView class]]) {
        return NO;
    }
    
    SSJReportFormsPercentCircleAdditionViewItem *anotherItem = view.item;
    if (![anotherItem isKindOfClass:[SSJReportFormsPercentCircleAdditionViewItem class]]) {
        return NO;
    }
    
    if (self.item.startPoint.x == anotherItem.startPoint.x) {
        return NO;
    }
    
    if (self.item.orientation == anotherItem.orientation) {
        switch (anotherItem.orientation) {
            case SSJReportFormsPercentCircleAdditionViewOrientationTopRight: {
                SSJReportFormsPercentCircleAdditionViewItem *item1 = nil;
                SSJReportFormsPercentCircleAdditionViewItem *item2 = nil;
                
                if (self.item.startPoint.x < anotherItem.startPoint.x) {
                    item1 = self.item;
                    item2 = anotherItem;
                } else if (self.item.startPoint.x > anotherItem.startPoint.x) {
                    item1 = anotherItem;
                    item2 = self.item;
                }
                
                CGSize textSize = [item1.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:anotherItem.textSize]}];
                CGFloat item1TextBottom = item1.endPoint.y + item1.imageRadius + item1.gapBetweenImageAndText + textSize.height;
                CGFloat item1TextRight = item1.endPoint.x + item1.imageRadius + textSize.width * 0.5;
                
                if (item2.endPoint.y <= item1TextBottom) {
                    return NO;
                }
                
                if (item2.endPoint.x < item1TextRight) {
                    return NO;
                }
                
                double bevelingSquare = pow(item2.startPoint.x - item1.startPoint.x, 2) + pow(item2.startPoint.y - item1.startPoint.y, 2);
                if (bevelingSquare < pow(item1.imageRadius + item2.imageRadius, 2)) {
                    return NO;
                }
            }
                break;
                
            case SSJReportFormsPercentCircleAdditionViewOrientationBottomRight: {
                SSJReportFormsPercentCircleAdditionViewItem *item1 = nil;
                SSJReportFormsPercentCircleAdditionViewItem *item2 = nil;
                
                if (self.item.startPoint.x < anotherItem.startPoint.x) {
                    item1 = anotherItem;
                    item2 = self.item;
                } else if (self.item.startPoint.x > anotherItem.startPoint.x) {
                    item1 = self.item;
                    item2 = anotherItem;
                }
                
                //  图片和折线是否重叠
                if (item2.endPoint.y - item2.imageRadius <= item1.endPoint.y) {
                    return NO;
                }
                
                //  图片和文本是否重叠
                CGSize item1TextSize = [item1.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:item1.textSize]}];
                CGFloat item1TextLeft = item1.endPoint.x + item1.imageRadius - item1TextSize.width * 0.5;
                CGFloat item1TextTop = item1.endPoint.y + item1.imageRadius + item1.gapBetweenImageAndText;
                CGRect item1TextFrame = CGRectMake(item1TextLeft, item1TextTop, item1TextSize.width, item1TextSize.height);
                
                CGRect item2ImageFrame = CGRectMake(item2.endPoint.x, item2.endPoint.y - item2.imageRadius, item2.imageRadius * 2, item2.imageRadius * 2);
                if (CGRectIntersectsRect(item1TextFrame, item2ImageFrame)) {
                    return NO;
                }
                
                //  图片和图片是否重叠
                double bevelingSquare = pow(item2.startPoint.x - item1.startPoint.x, 2) + pow(item2.startPoint.y - item1.startPoint.y, 2);
                if (bevelingSquare < pow(item1.imageRadius + item2.imageRadius, 2)) {
                    return NO;
                }
            }
                break;
                
            case SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft: {
                SSJReportFormsPercentCircleAdditionViewItem *item1 = nil;
                SSJReportFormsPercentCircleAdditionViewItem *item2 = nil;
                
                if (self.item.startPoint.x < anotherItem.startPoint.x) {
                    item1 = anotherItem;
                    item2 = self.item;
                } else if (self.item.startPoint.x > anotherItem.startPoint.x) {
                    item1 = self.item;
                    item2 = anotherItem;
                }
                
                //  图片和折线是否重叠
                if (item1.endPoint.y - item1.imageRadius <= item2.endPoint.y) {
                    return NO;
                }
                
                //  图片和文本是否重叠
                CGSize item2TextSize = [item2.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:item2.textSize]}];
                CGFloat item2TextLeft = item2.endPoint.x - item2.imageRadius - item2TextSize.width * 0.5;
                CGFloat item2TextTop = item2.endPoint.y + item2.imageRadius + item2.gapBetweenImageAndText;
                CGRect item2TextFrame = CGRectMake(item2TextLeft, item2TextTop, item2TextSize.width, item2TextSize.height);
                CGRect item1ImageFrame = CGRectMake(item1.endPoint.x - item1.imageRadius * 2, item1.endPoint.y - item1.imageRadius, item1.imageRadius * 2, item1.imageRadius * 2);
                if (CGRectIntersectsRect(item1ImageFrame, item2TextFrame)) {
                    return NO;
                }
                
                //  图片和图片是否重叠
                double bevelingSquare = pow(item2.startPoint.x - item1.startPoint.x, 2) + pow(item2.startPoint.y - item1.startPoint.y, 2);
                if (bevelingSquare < pow(item1.imageRadius + item2.imageRadius, 2)) {
                    return NO;
                }
            }
                break;
                
            case SSJReportFormsPercentCircleAdditionViewOrientationTopLeft: {
                SSJReportFormsPercentCircleAdditionViewItem *item1 = nil;
                SSJReportFormsPercentCircleAdditionViewItem *item2 = nil;
                
                if (self.item.startPoint.x < anotherItem.startPoint.x) {
                    item1 = self.item;
                    item2 = anotherItem;
                } else if (self.item.startPoint.x > anotherItem.startPoint.x) {
                    item1 = anotherItem;
                    item2 = self.item;
                }
                
                //  图片和折线是否重叠
                if (item1.endPoint.y - item1.imageRadius <= item2.endPoint.y) {
                    return NO;
                }
                
                //  图片和文本是否重叠
                CGSize item2TextSize = [item2.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:item2.textSize]}];
                CGFloat item2TextLeft = item2.endPoint.x - item2.imageRadius - item2TextSize.width * 0.5;
                CGFloat item2TextTop = item2.endPoint.y + item2.imageRadius + item2.gapBetweenImageAndText;
                CGRect item2TextFrame = CGRectMake(item2TextLeft, item2TextTop, item2TextSize.width, item2TextSize.height);
                CGRect item1ImageFrame = CGRectMake(item1.endPoint.x - item1.imageRadius * 2, item1.endPoint.y - item1.imageRadius, item1.imageRadius * 2, item1.imageRadius * 2);
                if (CGRectIntersectsRect(item1ImageFrame, item2TextFrame)) {
                    return NO;
                }
                
                //  图片和图片是否重叠
                double bevelingSquare = pow(item2.startPoint.x - item1.startPoint.x, 2) + pow(item2.startPoint.y - item1.startPoint.y, 2);
                if (bevelingSquare < pow(item1.imageRadius + item2.imageRadius, 2)) {
                    return NO;
                }
            }
                break;
        }
    } else {
        SSJReportFormsPercentCircleAdditionViewItem *item1 = nil;
        SSJReportFormsPercentCircleAdditionViewItem *item2 = nil;
        if (self.item.orientation == SSJReportFormsPercentCircleAdditionViewOrientationTopRight
            && anotherItem.orientation == SSJReportFormsPercentCircleAdditionViewOrientationBottomRight) {
            item1 = self.item;
            item2 = anotherItem;
        } else if (self.item.orientation == SSJReportFormsPercentCircleAdditionViewOrientationBottomRight
                   && anotherItem.orientation == SSJReportFormsPercentCircleAdditionViewOrientationTopRight) {
            item1 = anotherItem;
            item2 = self.item;
        } else if (self.item.orientation == SSJReportFormsPercentCircleAdditionViewOrientationTopLeft
                   && anotherItem.orientation == SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft) {
            item1 = self.item;
            item2 = anotherItem;
        } else if (self.item.orientation == SSJReportFormsPercentCircleAdditionViewOrientationBottomLeft
                   && anotherItem.orientation == SSJReportFormsPercentCircleAdditionViewOrientationTopLeft) {
            item1 = anotherItem;
            item2 = self.item;
        }
    }
    
    return YES;
}

- (void)beginDraw {
    [self drawBrokenLine];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([self.brokenLineLayer animationForKey:kAnimationKey] == anim) {
        CABasicAnimation *circleAnimation = (CABasicAnimation *)anim;
        [self.brokenLineLayer removeAnimationForKey:kAnimationKey];
        
//        [CATransaction begin];
//        [CATransaction setDisableActions:YES];
        self.brokenLineLayer.strokeEnd = [circleAnimation.toValue floatValue];
//        [CATransaction commit];
        
        [self showImageView];
    }
}

#pragma mark - Private
- (void)drawBrokenLine {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:self.startPoint];
    [path addLineToPoint:self.turnPoint];
    [path addLineToPoint:self.endPoint];
    
    self.brokenLineLayer.path = path.CGPath;
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    lineAnimation.duration = 0.35;
    lineAnimation.toValue = @(1);
    lineAnimation.delegate = self;
    lineAnimation.removedOnCompletion = NO;
    lineAnimation.fillMode = kCAFillModeForwards;
    lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.brokenLineLayer addAnimation:lineAnimation forKey:kAnimationKey];
}

- (void)showImageView {
    [UIView animateKeyframesWithDuration:0.36 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            self.imageView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    } completion:^(BOOL finished) {
        [self showTextLabel];
    }];
}

- (void)showTextLabel {
    [UIView transitionWithView:self.textLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.textLabel.hidden = NO;
    } completion:NULL];
}

#pragma mark - Getter
- (CAShapeLayer *)brokenLineLayer {
    if (!_brokenLineLayer) {
        _brokenLineLayer = [CAShapeLayer layer];
        _brokenLineLayer.contentsScale = [[UIScreen mainScreen] scale];
        _brokenLineLayer.lineWidth = 1;
        _brokenLineLayer.strokeColor = [UIColor ssj_colorWithHex:@"#e8e8e8"].CGColor;
        _brokenLineLayer.fillColor = [UIColor whiteColor].CGColor;
        _brokenLineLayer.strokeEnd = 0;
    }
    return _brokenLineLayer;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.item.imageName]];
        _imageView.size = CGSizeMake(self.item.imageRadius * 2, self.item.imageRadius * 2);
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.layer.borderColor = [UIColor ssj_colorWithHex:self.item.borderColorValue].CGColor;
        _imageView.layer.borderWidth = 0.5;
        _imageView.layer.cornerRadius = _imageView.width * 0.5;
        _imageView.transform = CGAffineTransformMakeScale(0, 0);
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.hidden = YES;
        _textLabel.backgroundColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:self.item.textSize];
        _textLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        _textLabel.text = self.item.text;
        [_textLabel sizeToFit];
    }
    return _textLabel;
}

@end
