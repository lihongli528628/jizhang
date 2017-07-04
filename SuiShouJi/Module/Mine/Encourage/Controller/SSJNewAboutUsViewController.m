//
//  SSJNewAboutUsViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNewAboutUsViewController.h"

#import "SSJEncourageHeaderView.h"
#import "SSJEncourageCell.h"

#import "SSJEncourageService.h"
#import "SSJShareManager.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "SSJUserTableManager.h"

static NSString *const ktitle1 = @"微信公众号";
static NSString *const ktitle2 = @"新浪微博";
static NSString *const ktitle3 = @"QQ群";
static NSString *const ktitle4 = @"微信群";
static NSString *const ktitle5 = @"在线客服";
static NSString *const ktitle6 = @"电话客服";

static NSString *SSJEncourageCellIndetifer = @"SSJEncourageCellIndetifer";

@interface SSJNewAboutUsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) SSJEncourageHeaderView *header;

@property (nonatomic,strong) NSArray *titles;


@property(nonatomic, strong) NSMutableArray <SSJEncourageCellModel *> *items;

@end

@implementation SSJNewAboutUsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"关于我们";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self organizeCellItems];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJEncourageCellModel *item = [self.items ssj_objectAtIndexPath:indexPath];

    
    return item.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    
    if ([title isEqualToString:ktitle1]) {
        NSString *weixin = self.service.wechatId;
        
        [[UIPasteboard generalPasteboard] setString:weixin];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"打开微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [WXApi openWXApp];
        }];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:cancel];
        
        [alert addAction:comfirm];
        
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
        
        
    }
    
    if ([title isEqualToString:ktitle2]) {
        NSString *urlStr = [NSString stringWithFormat:@"sinaweibo://userinfo?uid=%@",@"5603151337"];
        NSURL *url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
    if ([title isEqualToString:ktitle3]) {
        NSString *qqGroup = self.service.qqgroup ? : @"552563622";
        NSString *qqGroupId = self.service.qqgroupId ? : @"160aa4d10987c3a6ff17b2fb89e3e1f0e4e996e320207f1e23e1299518f58169";
        SSJJoinQQGroup(qqGroup, qqGroupId);
    }
    
    if ([title isEqualToString:ktitle4]) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"打开微信" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [WXApi openWXApp];
        }];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:cancel];
        
        [alert addAction:comfirm];
        
        [self.navigationController presentViewController:alert animated:YES completion:NULL];
    }
    
    if ([title isEqualToString:ktitle5]) {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            NSDictionary* clientCustomizedAttrs = @{@"userid": userItem.userId ?: @"",
                                                    @"openid": userItem.openId ?: @"",
                                                    @"nickname": userItem.nickName ?: @"",
                                                    @"tel": userItem.mobileNo ?: @"",
                                                    @"登录方式": userItem.loginType ?: @"",
                                                    @"注册状态": userItem.registerState ?: @"",
                                                    @"应用名称": SSJAppName(),
                                                    @"应用版本号": SSJAppVersion(),
                                                    @"手机型号" : SSJPhoneModel()
                                                    };
            [MQManager setClientInfo:clientCustomizedAttrs completion:NULL];
            MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
            [chatViewManager pushMQChatViewControllerInViewController:self];
        } failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
    }
    
    if ([title isEqualToString:ktitle6]) {
        NSString *telNum = self.service.telNum ? : @"400-7676-298";
        NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",telNum];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJEncourageCellModel *item = [self.items ssj_objectAtIndexPath:indexPath];
    
    SSJEncourageCell * cell = [tableView dequeueReusableCellWithIdentifier:SSJEncourageCellIndetifer];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.item = item;
    
    return cell;
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height- SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.tableHeaderView = self.header;
        [_tableView registerClass:[SSJEncourageCell class] forCellReuseIdentifier:SSJEncourageCellIndetifer];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (SSJEncourageHeaderView *)header {
    if (!_header) {
        _header = [[SSJEncourageHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 180)];
    }
    return _header;
}

#pragma mark - Private
- (void)organizeCellItems {
    NSMutableArray *tempTitleArr = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *firstArr = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableArray *secondArr = [NSMutableArray arrayWithCapacity:0];

    NSMutableArray *thirdArr = [NSMutableArray arrayWithArray:@[ktitle5,ktitle6]];
    
    if ([WXApi isWXAppInstalled]) {
        [firstArr insertObject:ktitle1 atIndex:0];
        [secondArr insertObject:ktitle4 atIndex:0];
    }
    
    if ([WeiboSDK isWeiboAppInstalled]) {
        [secondArr insertObject:ktitle2 atIndex:0];
    }
    
    if ([TencentOAuth iphoneQQInstalled]) {
        [firstArr insertObject:ktitle3 atIndex:firstArr.count];
    }
    
    [tempTitleArr insertObject:thirdArr atIndex:0];

    if (secondArr.count) {
        [tempTitleArr insertObject:secondArr atIndex:0];
    }
    
    if (firstArr.count) {
        [tempTitleArr insertObject:firstArr atIndex:0];
    }
    
    self.titles = tempTitleArr;
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (NSArray *titles in self.titles) {
        NSMutableArray *sectionArr = [NSMutableArray arrayWithCapacity:0];
        for (NSString *title in titles) {
            SSJEncourageCellModel *item = [[SSJEncourageCellModel alloc] init];
            item.cellTitle = title;
            if ([title isEqualToString:ktitle1]) {
                item.cellDetail = self.service.wechatId ? : @"youyujz";
            } else if ([title isEqualToString:ktitle2]) {
                item.cellDetail = self.service.sinaBlog ? : @"有鱼记账";
            } else if ([title isEqualToString:ktitle3]) {
                item.cellDetail = self.service.qqgroup ? : @"552563622";
            } else if ([title isEqualToString:ktitle4]) {
                item.cellDetail = self.service.wechatgroup ? : @"youyujz01";
            } else if ([title isEqualToString:ktitle5]) {

            } else if ([title isEqualToString:ktitle6]) {
                item.cellDetail = self.service.telNum ? : @"400-7676-298";
                item.cellSubTitle = @"工作日：9:00——18:00";
                item.rowHeight = 70;
            }
            [sectionArr addObject:item];
        }
        
        [tempArr addObject:sectionArr];
    }
    
    self.items = [NSMutableArray arrayWithArray:tempArr];
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end