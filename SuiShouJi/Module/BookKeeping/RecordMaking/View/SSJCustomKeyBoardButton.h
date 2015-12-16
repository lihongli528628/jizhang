//
//  SSJCustomKeyBoardButton.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCustomKeyBoardButton : UIButton

//键盘上按键类型
typedef NS_ENUM(NSUInteger, KeyType) {
    KeyTypeNumKey = 1,
    KeyTypeDecimalPointKey,
    KeyTypeReturnKey,
    KeyTypeClearKey,
    KeyTypePlusKey,
    KeyTypeMinusKey
};

@property (nonatomic, assign)   KeyType   keyboardButtonType;

@end
