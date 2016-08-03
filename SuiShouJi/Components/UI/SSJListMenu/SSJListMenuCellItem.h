//
//  SSJListMenuCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJListMenuCellItem : NSObject

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *imageColor;

@end