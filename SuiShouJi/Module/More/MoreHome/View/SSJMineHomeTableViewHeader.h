//
//  SSJMineHomeTableViewHeader.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJMineHeaderView.h"


@interface SSJMineHomeTableViewHeader : UIView

//+ (id)MineHomeHeader;

@property (nonatomic, strong) SSJMineHeaderView *headPotraitImage;

@property (nonatomic, strong) UILabel *nicknameLabel;

@property(nonatomic, strong) NSString *imageUrl;

//点击头像回调
typedef void (^HeaderButtonClickedBlock)();

@property (nonatomic, copy) HeaderButtonClickedBlock HeaderButtonClickedBlock;

typedef void (^HeaderClickedBlock)();

@property (nonatomic, copy) HeaderClickedBlock HeaderClickedBlock;
@end
