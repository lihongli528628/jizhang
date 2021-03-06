//
//  SSJMoreHomeAnnouncementButton.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMoreHomeAnnouncementButton : UIView

@property (nonatomic, copy) void (^buttonClickBlock)();

@property (nonatomic) BOOL hasNewAnnoucements;

- (void)updateAfterThemeChange;

@end
