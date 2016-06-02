//
//  SSJFundingTransferEditeViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/6/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferEditeViewController.h"
#import "SSJFundingTransferEdite.h"
#import "SSJFundingTransferStore.h"
#import "SSJFundingTransferViewController.h"

static NSString *const kTitle1 = @"转账金额";
static NSString *const kTitle2 = @"转出账户";
static NSString *const kTitle3 = @"转入账户";
static NSString *const kTitle4 = @"备注";
static NSString *const kTitle5 = @"时间";

static NSString * SSJTransferEditeCellIdentifier = @"transferEditeCell";


@interface SSJFundingTransferEditeViewController ()
@property(nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) UIView *modifyButtonView;
@end

@implementation SSJFundingTransferEditeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账详情";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@[kTitle1,kTitle2,kTitle3,kTitle4,kTitle5]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:@"929292"];
    [self.tableView registerClass:[SSJFundingTransferEdite class] forCellReuseIdentifier:SSJTransferEditeCellIdentifier];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return self.modifyButtonView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 80;
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJFundingTransferEdite *cell = [tableView dequeueReusableCellWithIdentifier:SSJTransferEditeCellIdentifier];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    cell.cellTitle = title;
    if ([title isEqualToString:kTitle1]) {
        cell.cellDetail = self.item.transferMoney;
    }else if ([title isEqualToString:kTitle1]) {
        cell.cellDetail = self.item.transferOutName;
    }else if ([title isEqualToString:kTitle2]) {
        cell.cellDetail = self.item.transferInName;
    }else if ([title isEqualToString:kTitle3]) {
        cell.cellDetail = self.item.transferOutName;
    }else if ([title isEqualToString:kTitle4]) {
        cell.cellDetail = self.item.transferMemo;
    }else if ([title isEqualToString:kTitle5]) {
        cell.cellDetail = self.item.transferDate;
    }
    return cell;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    __weak typeof(self) weakSelf = self;
    if (buttonIndex == 0) {
        [SSJFundingTransferStore deleteFundingTransferWithItem:self.item Success:^{
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:@"删除失败"];
        }];
    }
}

#pragma mark - Getter
-(UIView *)modifyButtonView{
    if (_modifyButtonView == nil) {
        _modifyButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *modifyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _modifyButtonView.width - 20, 40)];
        [modifyButton setTitle:@"编辑" forState:UIControlStateNormal];
        modifyButton.layer.cornerRadius = 3.f;
        modifyButton.layer.masksToBounds = YES;
        [modifyButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        [modifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [modifyButton addTarget:self action:@selector(modifyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        modifyButton.center = CGPointMake(_modifyButtonView.width / 2, _modifyButtonView.height / 2);
        [_modifyButtonView addSubview:modifyButton];
    }
    return _modifyButtonView;
}

#pragma mark - Private
-(void)rightBarButtonClicked:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"确定删除该项记录?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
    [sheet showInView:self.view];
}

-(void)modifyButtonClicked:(id)sender{
    if (self.item.transferInFundOperatorType == 2) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"%@账户已删除，不能编辑了哦。",self.item.transferInName]];
        return;
    }
    if (self.item.transferOutFundOperatorType == 2) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"%@账户已删除，不能编辑了哦。",self.item.transferOutName]];
        return;
    }
    SSJFundingTransferViewController *transferModifyVC = [[SSJFundingTransferViewController alloc]init];
    transferModifyVC.item = self.item;
    [self.navigationController pushViewController:transferModifyVC animated:YES];
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
