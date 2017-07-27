//
//  SSJCreateOrEditBillTypeViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrEditBillTypeViewController.h"
#import "SSJCreateOrEditBillTypeTopView.h"
#import "SSJCreateOrEditBillTypeColorSelectionView.h"
#import "SSJCaterotyMenuSelectionView.h"

#import "SSJBillTypeCategoryModel.h"
#import "SSJBillTypeLibraryModel.h"
#import "SSJBillModel.h"

#import "SSJBillTypeManager.h"
#import "SSJCategoryListHelper.h"
#import "YYKeyboardManager.h"
#import "SSJBooksTypeStore.h"
#import "SSJDataSynchronizer.h"

static NSString *const kCatgegoriesInfoIncomeKey = @"kCatgegoriesInfoIncomeKey";

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeViewController
#pragma mark -
@interface SSJCreateOrEditBillTypeViewController () <SSJCaterotyMenuSelectionViewDataSource, SSJCaterotyMenuSelectionViewDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJCreateOrEditBillTypeTopView *topView;

@property (nonatomic, strong) SSJCaterotyMenuSelectionView *bodyView;

@property (nonatomic, strong) SSJCreateOrEditBillTypeColorSelectionView *colorSelectionView;

@property (nonatomic) SSJBooksType booksType;

@property (nonatomic, strong) NSArray<NSNumber *> *booksTypes;

@property (nonatomic, strong) SSJBillTypeLibraryModel *libraryModel;

@property (nonatomic, strong) NSArray<NSString *> *colors;

@end

@implementation SSJCreateOrEditBillTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[YYKeyboardManager defaultManager] addObserver:self];
        self.booksType = -1;
        self.libraryModel = [[SSJBillTypeLibraryModel alloc] init];
        self.colors = [SSJCategoryListHelper billTypeLibraryColors];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bodyView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.colorSelectionView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    
    [self loadColors];
    
    [[[self loadBooksTypeIfNeeded] then:^RACSignal *{
        return [self loadSelectedIndexPath];
    }] subscribeNext:^(SSJCaterotyMenuSelectionViewIndexPath *indexPath) {
        [self.bodyView reloadAllData];
        self.bodyView.selectedIndexPath = indexPath;

        SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
        SSJBillTypeModel *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
        self.topView.billTypeIcon = [UIImage imageNamed:item.icon];
        self.topView.billTypeName = item.name;
        
    } error:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)updateViewConstraints {
    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.left.and.right.mas_equalTo(self.view);
        make.height.mas_equalTo(65);
    }];
    [self.bodyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.and.right.and.bottom.mas_equalTo(self.view);
    }];
    [self.colorSelectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bodyView);
    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.topView updateAppearanceAccordingToTheme];
    [self.bodyView updateAppearanceAccordingToTheme];
}

#pragma mark - SSJCaterotyMenuSelectionViewDataSource
- (NSUInteger)numberOfMenuTitlesInSelectionView:(SSJCaterotyMenuSelectionView *)selectionView {
    return self.expended ? self.booksTypes.count : 1;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForLeftMenuAtIndex:(NSInteger)index {
    SSJBooksType booksType = [[self.booksTypes ssj_safeObjectAtIndex:index] integerValue];
    switch (booksType) {
        case SSJBooksTypeDaily:
            return @"日常";
            break;
            
        case SSJBooksTypeBusiness:
            return @"生意";
            break;
            
        case SSJBooksTypeMarriage:
            return @"结婚";
            break;
            
        case SSJBooksTypeDecoration:
            return @"装修";
            break;
            
        case SSJBooksTypeTravel:
            return @"旅行";
            break;
            
        case SSJBooksTypeBaby:
            return @"宝宝";
            break;
    }
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfCategoriesAtMenuIndex:(NSInteger)index {
    return self.currentCategories.count;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForCategoryAtIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:categoryIndex];
    return category.title;
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfItemsAtCategoryIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:categoryIndex];
    return category.items.count;
}

- (SSJCaterotyMenuSelectionCellItem *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView itemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
    SSJBillTypeModel *model = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
    return [SSJCaterotyMenuSelectionCellItem itemWithTitle:model.name icon:[UIImage imageNamed:model.icon] color:[UIColor ssj_colorWithHex:model.color]];
}

#pragma mark - SSJCaterotyMenuSelectionViewDelegate
- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectMenuAtIndex:(NSInteger)menuIndex {
    self.booksType = [[self.booksTypes objectAtIndex:menuIndex] integerValue];
}

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
    SSJBillTypeModel *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
    [self.topView setBillTypeIcon:[UIImage imageNamed:item.icon] animated:YES];
    [self.topView setBillTypeName:item.name animated:YES];
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGFloat bottom = transition.toVisible ? [YYKeyboardManager defaultManager].keyboardFrame.size.height : 0;
    self.bodyView.contentInsets = UIEdgeInsetsMake(0, 0, bottom, 0);
}

#pragma mark - Private
- (void)loadColors {
    NSMutableArray *colors = [NSMutableArray array];
    for (NSString *colorValue in self.colors) {
        [colors addObject:[UIColor ssj_colorWithHex:colorValue]];
    }
    self.colorSelectionView.colors = colors;
    self.colorSelectionView.selectedIndex = self.color ? [self.colors indexOfObject:self.color] : 0;
    self.topView.billTypeColor = [colors firstObject];
}

- (NSArray<SSJBillTypeCategoryModel *> *)currentCategories {
    if (self.expended) {
        return [self.libraryModel expenseCategoriesWithBooksType:self.booksType];
    } else {
        return [self.libraryModel incomeCategories];
    }
}

- (RACSignal *)loadBooksTypeIfNeeded {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.expended) {
            [SSJBooksTypeStore queryBooksItemWithID:self.booksId success:^(id<SSJBooksItemProtocol> booksItem) {
                self.booksType = booksItem.booksParent;
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
        } else {
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (RACSignal *)loadSelectedIndexPath {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSInteger menuIndex = [self.booksTypes indexOfObject:@(self.booksType)];
        if (self.icon.length) {
            __block SSJCaterotyMenuSelectionViewIndexPath *indexPath = nil;
            [[self currentCategories] enumerateObjectsUsingBlock:^(SSJBillTypeCategoryModel * _Nonnull categoryModel, NSUInteger categoryIdx, BOOL * _Nonnull stop) {
                [categoryModel.items enumerateObjectsUsingBlock:^(SSJBillTypeModel * _Nonnull billModel, NSUInteger itemIdx, BOOL * _Nonnull stop) {
                    if ([billModel.icon isEqualToString:self.icon]) {
                        indexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:categoryIdx itemIndex:itemIdx];
                        *stop = YES;
                    }
                }];
                
                if (indexPath) {
                    *stop = YES;
                }
            }];
            
            if (!indexPath) {
                indexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:-1 itemIndex:-1];
            }
            
            [subscriber sendNext:indexPath];
            [subscriber sendCompleted];
        } else {
            [subscriber sendNext:[SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:0 itemIndex:0]];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (void)doneAction {
    if (self.topView.billTypeName.length == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
        return;
    }
    
    if (self.topView.billTypeName.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"类别名称不能超过5个字符"];
        return;
    }
    
    SSJBillTypeCategoryModel *category = [[self currentCategories] ssj_safeObjectAtIndex:self.bodyView.selectedIndexPath.categoryIndex];
    SSJBillTypeModel *billModel = [category.items ssj_safeObjectAtIndex:self.bodyView.selectedIndexPath.itemIndex];
    NSString *image = billModel.icon;
    NSString *name = self.topView.billTypeName;
    NSString *color = [self.colors ssj_safeObjectAtIndex:self.colorSelectionView.selectedIndex];
    
    [SSJCategoryListHelper querySameNameCategoryWithName:name exceptForBillID:self.billId booksId:self.booksId expended:self.expended success:^(SSJBillModel *model) {
        if (model && model.operatorType != 2) {
            // 有同名称类别，不支持新建／修改
            [CDAutoHideMessageHUD showMessage:@"已有同名称类别，换个名称吧"];
        } else if (model && model.operatorType == 2 && self.created) {
            // 恢复已删除的类别
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"该类别名称曾经使用过，是否将之前的流水合并过来？" action:[SSJAlertViewAction actionWithTitle:@"不合并" handler:^(SSJAlertViewAction *action) {
                [self addNewCategoryWithName:name image:image color:color];
            }], [SSJAlertViewAction actionWithTitle:@"合并" handler:^(SSJAlertViewAction *action) {
                int order = [SSJCategoryListHelper queryForBillTypeMaxOrderWithType:model.type booksId:self.booksId] + 1;
                [self updateBillTypeWithID:model.ID
                                      name:model.name
                                     color:color
                                     image:image
                                     order:order];
            }], nil];
        } else if (self.created) {
            [self addNewCategoryWithName:name image:image color:color];
        } else {
            [self updateBillTypeWithID:self.billId
                                  name:name
                                 color:color
                                 image:image
                                 order:SSJImmovableOrder];
        }
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)addNewCategoryWithName:(NSString *)name image:(NSString *)image color:(NSString *)color {
    [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:self.expended name:name icon:image color:color booksId:self.booksId success:^(NSString *categoryId){
        [self.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        if (self.addNewCategoryAction) {
            self.addNewCategoryAction(categoryId);
        }
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)updateBillTypeWithID:(NSString *)ID name:(NSString *)name color:(NSString *)color image:(NSString *)image order:(int)order {
    [SSJCategoryListHelper updateCategoryWithID:ID name:name color:color image:image order:order booksId:self.booksId success:^(NSString *categoryId) {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.addNewCategoryAction) {
            self.addNewCategoryAction(categoryId);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

#pragma mark - Lazyloading
- (SSJCreateOrEditBillTypeTopView *)topView {
    if (!_topView) {
        _topView = [[SSJCreateOrEditBillTypeTopView alloc] init];
        _topView.billTypeColor = [UIColor ssj_colorWithHex:self.color];
        _topView.billTypeIcon = [UIImage imageNamed:self.icon];
        _topView.billTypeName = self.name;
        __weak typeof(self) wself = self;
        _topView.tapColorAction = ^(SSJCreateOrEditBillTypeTopView *view){
            if (view.arrowDown) {
                [wself.colorSelectionView dismiss];
            } else {
                [wself.colorSelectionView show];
            }
        };
    }
    return _topView;
}

- (SSJCaterotyMenuSelectionView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[SSJCaterotyMenuSelectionView alloc] initWithFrame:CGRectZero style:(self.expended ? SSJCaterotyMenuSelectionViewMenuLeft : SSJCaterotyMenuSelectionViewNoMenu)];
        _bodyView.dataSource = self;
        _bodyView.delegate = self;
        _bodyView.numberOfItemPerRow = self.expended ? 4 : 5;
    }
    return _bodyView;
}

- (SSJCreateOrEditBillTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJCreateOrEditBillTypeColorSelectionView alloc] init];
        __weak typeof(self) wself = self;
        _colorSelectionView.selectColorAction = ^(SSJCreateOrEditBillTypeColorSelectionView *view) {
            [wself.topView setArrowDown:YES animated:YES];
            [wself.topView setBillTypeColor:view.colors[view.selectedIndex] animated:YES];
        };
    }
    return _colorSelectionView;
}

- (NSArray<NSNumber *> *)booksTypes {
    if (!_booksTypes) {
        _booksTypes = @[@(SSJBooksTypeDaily),
                        @(SSJBooksTypeBaby),
                        @(SSJBooksTypeBusiness),
                        @(SSJBooksTypeTravel),
                        @(SSJBooksTypeDecoration),
                        @(SSJBooksTypeMarriage)];
    }
    return _booksTypes;
}

@end
