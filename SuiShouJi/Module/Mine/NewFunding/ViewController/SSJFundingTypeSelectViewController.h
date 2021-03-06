//
//  SSJFundingTypeSelectViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"

@interface SSJFundingTypeSelectViewController : SSJNewBaseTableViewController

typedef void (^typeSelectedBlock)(NSString *selectParent , NSString *selectIcoin);

@property(nonatomic,copy) typeSelectedBlock typeSelectedBlock;

@property (nonatomic,strong) NSString *selectFundID;

@end
