//
//  SSJBooksView.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBooksItem.h"

@interface SSJBooksView : UIView

@property(nonatomic, strong) __kindof SSJBaseCellItem <SSJBooksItemProtocol> *booksTypeItem;

@end
