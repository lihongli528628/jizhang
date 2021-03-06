//
//  SSJAnnouncementsListViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnnouncementsListViewController.h"
#import "SSJAnnouncementDetailCell.h"
#import "SSJAnnoucementService.h"
#import "SSJAnnouncementWebViewController.h"

static NSString *const kAnnouncementCellIdentifier = @"kAnnouncementCellIdentifier";


@interface SSJAnnouncementsListViewController ()

@property(nonatomic, strong) SSJAnnoucementService *service;

@property(nonatomic) NSInteger currentPage;

@end

@implementation SSJAnnouncementsListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"有鱼头条";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1;
    [self.tableView registerClass:[SSJAnnouncementDetailCell class] forCellReuseIdentifier:kAnnouncementCellIdentifier];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self startPullRefresh];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(startLoadMore)];
     [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
     [super viewWillAppear:animated];
     [self.service requestAnnoucementsWithPage:1];
     if (self.items.count > 0) {
          SSJAnnoucementItem *item = [self.items firstObject];
          [[NSUserDefaults standardUserDefaults] setObject:item.announcementId forKey:kLastAnnoucementIdKey];
          [[NSUserDefaults standardUserDefaults] synchronize];
     }
}

- (void)viewDidDisappear:(BOOL)animated
{
     [super viewDidDisappear:animated];
     [self.service cancel];
}

- (void)updateAppearanceAfterThemeChanged {
     [super updateAppearanceAfterThemeChanged];
     [self updateAppearance];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return 114;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
     SSJAnnoucementItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
     SSJAnnouncementWebViewController *webVc = [SSJAnnouncementWebViewController webViewVCWithURL:[NSURL URLWithString:item.announcementUrl]];
     item.haveReaded = YES;
     [self.tableView reloadData];
     webVc.item = item;
     [self.navigationController pushViewController:webVc animated:YES];
     
     NSMutableArray *announcements = [[[NSUserDefaults standardUserDefaults] objectForKey:SSJAnnouncementHaveReadKey] mutableCopy];
     if (!announcements) {
          announcements = [NSMutableArray arrayWithObjects:item.announcementId, nil];
     } else {
          if (![announcements containsObject:item.announcementId]) {
               [announcements addObject:item.announcementId];
          }
     }
     [[NSUserDefaults standardUserDefaults] setObject:announcements forKey:SSJAnnouncementHaveReadKey];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJAnnouncementDetailCell *announcementCell  = [tableView dequeueReusableCellWithIdentifier:kAnnouncementCellIdentifier];
     
    [announcementCell setCellItem:[self.items objectAtIndex:indexPath.row]];
     
    return announcementCell;
}


#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service {
     [self.tableView.mj_header endRefreshing];
     if (self.currentPage == self.totalPage) {
          [self.tableView.mj_footer endRefreshingWithNoMoreData];
     } else {
          [self.tableView.mj_footer endRefreshing];
          
     }
     if ([service.returnCode isEqualToString:@"1"]) {
          if (self.currentPage == 1) {
               [self.items removeAllObjects];
               self.items = [self.service.annoucements mutableCopy];
          } else {
               [self.items addObjectsFromArray:self.service.annoucements];
          }
          self.totalPage = self.service.totalPage;
          [self.tableView reloadData];
     }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - Getter
- (SSJAnnoucementService *)service {
    if (!_service) {
        _service = [[SSJAnnoucementService alloc] initWithDelegate:self];
    }
    return _service;
}

#pragma mark - Private
- (void)startPullRefresh {
    self.currentPage = 1;
    [self.service requestAnnoucementsWithPage:1];
}

- (void)startLoadMore {
    self.currentPage ++;
    if (self.currentPage > self.totalPage) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.service requestAnnoucementsWithPage:self.currentPage];
    }
}

- (void)updateAppearance {
     ((MJRefreshStateHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.textColor = SSJ_SECONDARY_COLOR;
     ((MJRefreshStateHeader *)self.tableView.mj_header).stateLabel.textColor = SSJ_SECONDARY_COLOR;
     ((MJRefreshAutoStateFooter *)self.tableView.mj_footer).stateLabel.textColor = SSJ_SECONDARY_COLOR;
}

@end
