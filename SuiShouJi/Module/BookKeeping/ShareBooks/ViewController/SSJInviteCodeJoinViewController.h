//
//  SSJInviteCodeJoinViewController.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/23.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJInviteCodeJoinViewController : SSJBaseViewController
/**<#注释#>*/
@property (nonatomic, copy) void (^inviteCodeJoinBooksBlock)(NSString *bookName);

@end
