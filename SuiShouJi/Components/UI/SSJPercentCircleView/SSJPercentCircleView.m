//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJPercentCircleView.h"
#import "SSJPercentCircleNode.h"
#import "SSJPercentCircleAdditionNode.h"
#import "SSJPercentCircleAdditionGroupNode.h"

@interface SSJPercentCircleView ()

@property (nonatomic, readwrite) UIEdgeInsets circleInsets;

@property (nonatomic, readwrite) CGFloat circleThickness;

@property (nonatomic) CGRect circleFrame;

@property (nonatomic, strong) SSJPercentCircleNode *circleNode;

@property (nonatomic, strong) SSJPercentCircleAdditionGroupNode *additionGroupNode;

@property (nonatomic, strong) UIImageView *skinView;

@property (nonatomic) NSUInteger animateCounter;

@end

@implementation SSJPercentCircleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame insets:UIEdgeInsetsZero thickness:0];
}

- (instancetype)initWithFrame:(CGRect)frame insets:(UIEdgeInsets)insets thickness:(CGFloat)thickness {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.circleInsets = insets;
        self.circleThickness = thickness;
        
        self.additionGroupNode = [SSJPercentCircleAdditionGroupNode node];
        [self addSubview:self.additionGroupNode];
        
        self.skinView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.skinView.hidden = YES;
        [self addSubview:self.skinView];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateCircleFrame];
}

- (void)reloadData {

    if (!self.dataSource
        || ![self.dataSource respondsToSelector:@selector(numberOfComponentsInPercentCircle:)]
        || ![self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]
        || self.circleThickness <= 0
        || CGRectIsEmpty(self.bounds)
        || CGRectIsEmpty(self.circleFrame)) {
        return;
    }
    
    self.skinView.hidden = YES;
    
    NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
    CGFloat overlapScale = 0;
    
    if (!self.circleNode) {
        CGPoint center = CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame));
        CGFloat radius = CGRectGetWidth(self.circleFrame) * 0.5 - self.circleThickness;
        CGFloat lineWith = self.circleThickness * 2;
        self.circleNode = [SSJPercentCircleNode nodeWithCenter:center radius:radius lineWith:lineWith];
        [self addSubview:self.circleNode];
    }
    
    NSMutableArray *circleNodeItems = [NSMutableArray arrayWithCapacity:numberOfComponents];
    NSMutableArray *additionNodeItems = [NSMutableArray array];
    
    for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
        
        if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
            SSJReportFormsPercentCircleItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
            if (!item) {
                return;
            }
            
            item.previousScale = overlapScale;
            
            SSJPercentCircleNodeItem *circleNodeItem = [[SSJPercentCircleNodeItem alloc] init];
            circleNodeItem.startAngle = overlapScale * M_PI * 2;
            circleNodeItem.endAngle = (overlapScale + item.scale) * M_PI * 2;
            circleNodeItem.colorValue = item.colorValue;
            [circleNodeItems addObject:circleNodeItem];
            
            overlapScale += item.scale;
            
            //  添加附加视图(折线、图片、比例)
            SSJPercentCircleAdditionNodeItem *additionViewItem = [[SSJPercentCircleAdditionNodeItem alloc] init];
            
            CGPoint startPoint = CGPointZero;
            CGPoint turnPoint = CGPointZero;
            CGPoint endPoint = CGPointZero;
            
            SSJPercentCircleAdditionNodeOrientation orientation = SSJPercentCircleAdditionNodeOrientationTopRight;
            
            //  根据比例计算出角度，再根据角度计算出折现的起点
            CGFloat angle = (0.5 * item.scale + item.previousScale) * M_PI * 2;
            CGFloat axisY = -cos(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidY(self.circleFrame);
            CGFloat axisX = sin(angle) * CGRectGetWidth(self.circleFrame) * 0.5 + CGRectGetMidX(self.circleFrame);
            startPoint = CGPointMake(axisX, axisY);
            
            if (angle >= 0 && angle < M_PI_2) {
                turnPoint = CGPointMake(axisX + 5, axisY - 10);
                endPoint = CGPointMake(axisX + 5 + 35, axisY - 10);
                orientation = SSJPercentCircleAdditionNodeOrientationTopRight;
            } else if (angle >= M_PI_2 && angle < M_PI) {
                turnPoint = CGPointMake(axisX + 5, axisY + 10);
                endPoint = CGPointMake(axisX + 5 + 35, axisY + 10);
                orientation = SSJPercentCircleAdditionNodeOrientationBottomRight;
            } else if (angle >= M_PI && angle < M_PI + M_PI_2) {
                turnPoint = CGPointMake(axisX - 5, axisY + 10);
                endPoint = CGPointMake(axisX - 5 - 35, axisY + 10);
                orientation = SSJPercentCircleAdditionNodeOrientationBottomLeft;
            } else if (angle >= M_PI + M_PI_2) {
                turnPoint = CGPointMake(axisX - 5, axisY - 10);
                endPoint = CGPointMake(axisX - 5 - 35, axisY - 10);
                orientation = SSJPercentCircleAdditionNodeOrientationTopLeft;
            }
            
            additionViewItem.startPoint = startPoint;
            additionViewItem.turnPoint = turnPoint;
            additionViewItem.endPoint = endPoint;
            additionViewItem.orientation = orientation;
            additionViewItem.imageName = item.imageName;
            additionViewItem.imageRadius = 13;
            additionViewItem.borderColorValue = item.colorValue;
            additionViewItem.gapBetweenImageAndText = 0;
            additionViewItem.text = item.additionalText;
            additionViewItem.textSize = 15;
            additionViewItem.textColorValue = @"#a7a7a7";
            [additionNodeItems addObject:additionViewItem];
        }
    }
    
    self.circleNode.hidden = NO;
    [self.additionGroupNode cleanUpAdditionNodes];
    
    self.animateCounter ++;
    
    __weak typeof(self) weakSelf = self;
    [self.circleNode setItems:circleNodeItems completion:^{
        [weakSelf.additionGroupNode setItems:additionNodeItems completion:^{
            weakSelf.animateCounter --;
            if (weakSelf.animateCounter > 0 || numberOfComponents == 0) {
                return;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *screentShot = [weakSelf ssj_takeScreenShot];
                [UIImagePNGRepresentation(screentShot) writeToFile:@"/Users/oldlang/Desktop/screenshot/test.png" atomically:YES];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.skinView.hidden = NO;
                    weakSelf.skinView.image = screentShot;
                    weakSelf.skinView.size = screentShot.size;
                    
                    weakSelf.circleNode.hidden = YES;
                });
            });
        }];
    }];
}

- (void)updateCircleFrame {
    CGRect circleFrame = UIEdgeInsetsInsetRect(self.bounds, self.circleInsets);
    CGFloat circleDiam = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake((self.width - circleDiam) * 0.5, circleFrame.origin.y, circleDiam, circleDiam);
}

@end
