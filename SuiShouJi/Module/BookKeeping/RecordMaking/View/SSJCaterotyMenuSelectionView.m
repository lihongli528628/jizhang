//
//  SSJCreateOrEditBillTypeIconSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCaterotyMenuSelectionView.h"
#import "SSJBaseTableViewCell.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSArray (SSJCaterotyMenuSelectionView)
#pragma mark -

@interface NSArray (SSJCaterotyMenuSelectionView)

@end

@implementation NSArray (SSJCaterotyMenuSelectionView)

- (id)ssj_objectAtIndex:(NSUInteger)index {
    if (self.count > index) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionCellItem
#pragma mark -

@interface SSJCaterotyMenuSelectionCellItem ()

@property (nonatomic) BOOL selected;

@end


@implementation SSJCaterotyMenuSelectionCellItem

+ (instancetype)itemWithTitle:(NSString *)title icon:(UIImage *)icon color:(UIColor *)color {
    SSJCaterotyMenuSelectionCellItem *item = [[SSJCaterotyMenuSelectionCellItem alloc] init];
    item.title = title;
    item.icon = icon;
    item.color = color;
    return item;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionViewIndexPath
#pragma mark -
@implementation SSJCaterotyMenuSelectionViewIndexPath

+ (instancetype)indexPathWithMenuIndex:(NSInteger)menuIndex categoryIndex:(NSInteger)categoryIndex itemIndex:(NSInteger)itemIndex {
    SSJCaterotyMenuSelectionViewIndexPath *indexPath = [[SSJCaterotyMenuSelectionViewIndexPath alloc] init];
    indexPath.menuIndex = menuIndex;
    indexPath.categoryIndex = categoryIndex;
    indexPath.itemIndex = itemIndex;
    return indexPath;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJCaterotyMenuSelectionViewTableViewCell
#pragma mark -
@interface _SSJCaterotyMenuSelectionViewTableViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation _SSJCaterotyMenuSelectionViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self updateAppearanceAccordingToTheme];
        [self setNeedsUpdateConstraints];
        self.selectedBackgroundView = [[UIView alloc] init];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor = selected ? [UIColor clearColor] : SSJ_MAIN_BACKGROUND_COLOR;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearanceAccordingToTheme];
}

- (void)updateAppearanceAccordingToTheme {
    self.titleLab.textColor = self.selected ? SSJ_MAIN_COLOR : SSJ_SECONDARY_COLOR;
    self.backgroundColor = self.selected ? [UIColor clearColor] : SSJ_MAIN_BACKGROUND_COLOR;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJCaterotyMenuSelectionViewCollectionHeaderView
#pragma mark -
@interface _SSJCaterotyMenuSelectionViewCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation _SSJCaterotyMenuSelectionViewCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLab];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJCaterotyMenuSelectionViewCollectionCell
#pragma mark -

static const CGFloat kBorderRadius = 20;

@interface _SSJCaterotyMenuSelectionViewCollectionCell : UICollectionViewCell

@property (nonatomic, strong) SSJCaterotyMenuSelectionCellItem *item;

@end

@interface _SSJCaterotyMenuSelectionViewCollectionCell ()

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIView *container;

@end

@implementation _SSJCaterotyMenuSelectionViewCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.borderView];
        [self.contentView addSubview:self.container];
        [self.container addSubview:self.icon];
        [self.container addSubview:self.titleLab];
    }
    return self;
}

- (void)updateConstraints {
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.and.centerX.mas_equalTo(self.container).offset(0);
        make.size.mas_equalTo(self.icon.image.size);
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(5);
        make.bottom.and.centerX.mas_equalTo(self.container).offset(0);
    }];
    
    [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentView);
        make.center.mas_equalTo(self.contentView);
    }];
    [self.borderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kBorderRadius * 2, kBorderRadius * 2));
        make.center.mas_equalTo(self.icon);
    }];
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [UIView animateWithDuration:0.25 animations:^{
        self.borderView.alpha = selected ? 1 : 0;
    }];
}

- (void)setItem:(SSJCaterotyMenuSelectionCellItem *)item {
    _item = item;
    self.icon.image = item.icon;
    self.titleLab.text = item.title;
    [self setNeedsUpdateConstraints];
}

- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
        _borderView.backgroundColor = [UIColor clearColor];
        _borderView.layer.borderWidth = 1;
        _borderView.layer.cornerRadius = kBorderRadius;
        _borderView.alpha = 0;
    }
    return _borderView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
    }
    return _container;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJCategoryItemSet
#pragma mark -

@interface _SSJCategoryItemSet : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSMutableArray<SSJCaterotyMenuSelectionCellItem *> *items;

@end

@implementation _SSJCategoryItemSet

- (instancetype)init {
    if (self = [super init]) {
        self.items = [@[] mutableCopy];
    }
    return self;
}

- (SSJCaterotyMenuSelectionCellItem *)itemAtIndex:(NSInteger)index {
    return [self.items ssj_objectAtIndex:index];
}

- (void)addItem:(SSJCaterotyMenuSelectionCellItem *)item {
    [self.items addObject:item];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJMenuItemSet
#pragma mark -

@interface _SSJMenuItemSet : NSObject

@property (nonatomic, strong) NSMutableArray<NSMutableArray<_SSJCategoryItemSet *> *> *items;

@end

@implementation _SSJMenuItemSet

- (instancetype)init {
    if (self = [super init]) {
        self.items = [@[] mutableCopy];
    }
    return self;
}

- (void)addItem:(SSJCaterotyMenuSelectionCellItem *)item atMenuIndex:(NSInteger)menuIndex categoryIndex:(NSInteger)categoryIndex {
    NSMutableArray *categories = [self.items ssj_objectAtIndex:menuIndex];
    if (!categories) {
        for (int i = self.items.count; i <= menuIndex; i ++) {
            [self.items addObject:[NSMutableArray array]];
        }
        categories = [self.items lastObject];
    }
    
    if (categories) {
        _SSJCategoryItemSet *category = [categories ssj_objectAtIndex:categoryIndex];
        if (!category) {
            for (int i = categories.count; i <= categoryIndex; i ++) {
                [categories addObject:[[_SSJCategoryItemSet alloc] init]];
            }
            category = [categories lastObject];
        }
        
        if (category.items) {
            [category.items addObject:item];
        }
    }
}

- (NSArray<NSArray<SSJCaterotyMenuSelectionCellItem *> *> *)categoriesAtMenuIndex:(NSInteger)index {
    return [self.items ssj_objectAtIndex:index];
}

- (_SSJCategoryItemSet *)itemsAtMenuIndex:(NSInteger)index categoryIndex:(NSInteger)categoryIndex {
    NSArray *categories = [self.items ssj_objectAtIndex:index];
    if (categories) {
        return [categories ssj_objectAtIndex:categoryIndex];
    }
    
    return nil;
}

- (SSJCaterotyMenuSelectionCellItem *)itemAtMenuIndex:(NSInteger)index categoryIndex:(NSInteger)categoryIndex itemIndex:(NSInteger)itemIndex {
    NSArray *categories = [self.items ssj_objectAtIndex:index];
    if (categories) {
        _SSJCategoryItemSet *category = [categories ssj_objectAtIndex:categoryIndex];
        if (category.items) {
            return [category.items ssj_objectAtIndex:itemIndex];
        }
    }
    
    return nil;
}

- (void)clear {
    [self.items removeAllObjects];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionView
#pragma mark -

static NSString *const kTableViewCellID = @"kTableViewCellID";
static NSString *const kCollectionViewCellID = @"kCollectionViewCellID";
static NSString *const kCollectionHeaderViewID = @"kCollectionHeaderViewID";

@interface SSJCaterotyMenuSelectionView () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) _SSJMenuItemSet *itemsSet;

@end

@implementation SSJCaterotyMenuSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.itemsSet = [[_SSJMenuItemSet alloc] init];
        [self addSubview:self.tableView];
        [self addSubview:self.collectionView];
        [self updateAppearanceAccordingToTheme];
    }
    return self;
}

- (void)updateConstraints {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.top.and.left.and.height.mas_equalTo(self);
    }];
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView.mas_right);
        make.top.and.bottom.and.right.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layout.itemSize = CGSizeMake((self.collectionView.width - self.layout.sectionInset.left - self.layout.sectionInset.right) / 4, 66);
}

#pragma mark - Public
- (void)setSelectedIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)selectedIndexPath {
    [self setSelectedIndexPath:selectedIndexPath animated:NO];
}

- (void)setSelectedIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)selectedIndexPath animated:(BOOL)animated {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndexPath.menuIndex inSection:0] animated:animated scrollPosition:UITableViewScrollPositionMiddle];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndexPath.itemIndex inSection:selectedIndexPath.categoryIndex] animated:animated scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}

- (void)reloadAllData {
    [self.itemsSet clear];
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)updateAppearanceAccordingToTheme {
    self.tableView.separatorColor = SSJ_CELL_SEPARATOR_COLOR;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfMenuTitlesInSelectionView:)]) {
        return [self.dataSource numberOfMenuTitlesInSelectionView:self];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _SSJCaterotyMenuSelectionViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellID];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:titleForLeftMenuAtIndex:)]) {
        cell.titleLab.text = [self.dataSource selectionView:self titleForLeftMenuAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionView:didSelectMenuAtIndex:)]) {
        [self.delegate selectionView:self didSelectMenuAtIndex:indexPath.row];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
    
    NSArray *categories = [self.itemsSet categoriesAtMenuIndex:selectedMenuIndex];
    if (categories.count) {
        return categories.count;
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:numberOfCategoriesAtMenuIndex:)]) {
        return [self.dataSource selectionView:self numberOfCategoriesAtMenuIndex:selectedMenuIndex];
    }
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
    
    _SSJCategoryItemSet *category = [self.itemsSet itemsAtMenuIndex:selectedMenuIndex categoryIndex:section];
    if (category.items.count) {
        return category.items.count;
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:numberOfItemsAtCategoryIndex:menuIndex:)]) {
        return [self.dataSource selectionView:self numberOfItemsAtCategoryIndex:section menuIndex:selectedMenuIndex];
    }
    
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    _SSJCaterotyMenuSelectionViewCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellID forIndexPath:indexPath];
    
    NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
    SSJCaterotyMenuSelectionCellItem *item = [self.itemsSet itemAtMenuIndex:selectedMenuIndex categoryIndex:indexPath.section itemIndex:indexPath.item];
    if (item) {
        cell.item = item;
    } else if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:itemAtIndexPath:)]) {
        SSJCaterotyMenuSelectionViewIndexPath *tIndexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:selectedMenuIndex categoryIndex:indexPath.section itemIndex:indexPath.item];
        SSJCaterotyMenuSelectionCellItem *item = [self.dataSource selectionView:self itemAtIndexPath:tIndexPath];
        cell.item = item;
        if (self.needToCacheData) {
            [self.itemsSet addItem:item atMenuIndex:selectedMenuIndex categoryIndex:indexPath.section];
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    _SSJCaterotyMenuSelectionViewCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionHeaderViewID forIndexPath:indexPath];
    
    NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
    _SSJCategoryItemSet *category = [self.itemsSet itemsAtMenuIndex:selectedMenuIndex categoryIndex:indexPath.section];
    if (category.title) {
        header.titleLab.text = category.title;
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:titleForCategoryAtIndex:menuIndex:)]) {
        header.titleLab.text = [self.dataSource selectionView:self titleForCategoryAtIndex:indexPath.section menuIndex:selectedMenuIndex];
        category.title = header.titleLab.text;
    }
    
    return header;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionView:didSelectItemAtIndexPath:)]) {
        NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
        SSJCaterotyMenuSelectionViewIndexPath *tIndexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:selectedMenuIndex categoryIndex:indexPath.section itemIndex:indexPath.item];
        [self.delegate selectionView:self didSelectItemAtIndexPath:tIndexPath];
    }
}

#pragma mark - Lazyloading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 90;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[_SSJCaterotyMenuSelectionViewTableViewCell class] forCellReuseIdentifier:kTableViewCellID];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[_SSJCaterotyMenuSelectionViewCollectionCell class] forCellWithReuseIdentifier:kCollectionViewCellID];
        [_collectionView registerClass:[_SSJCaterotyMenuSelectionViewCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionHeaderViewID];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        [_layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        _layout.headerReferenceSize = CGSizeMake(0, 44);
        _layout.sectionInset = UIEdgeInsetsMake(18, 12, 20, 12);
    }
    return _layout;
}

@end
