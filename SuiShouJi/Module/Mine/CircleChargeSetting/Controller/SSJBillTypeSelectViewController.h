//
//  SSJBillTypeSelectViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewBaseTableViewController.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"

@interface SSJBillTypeSelectViewController : SSJNewBaseTableViewController
@property (nonatomic) BOOL incomeOrExpenture;
@property(nonatomic, strong) NSString *selectedId;


typedef void (^typeSelectBlock)(NSString *typeId , NSString *typeName);


@property(nonatomic, copy) typeSelectBlock typeSelectBlock;

@property(nonatomic, strong) NSString *selectTypeName;

@end
