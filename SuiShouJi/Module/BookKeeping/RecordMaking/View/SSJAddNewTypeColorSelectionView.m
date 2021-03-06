//
//  SSJAddNewTypeColorSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddNewTypeColorSelectionView.h"
#import "SSJColorSelectCollectionViewCell.h"

//#define ITEM_SIZE_WIDTH (self.width - 80) / 5
#define ITEM_SIZE_WIDTH 40
#define ITEM_SPACE (self.width - 40 * 5) / 6

static NSString *const kCellId = @"SSJColorSelectCollectionViewCell";

@interface SSJAddNewTypeColorSelectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation SSJAddNewTypeColorSelectionView

- (instancetype)initWithWidth:(CGFloat)width {
    if (self = [super initWithFrame:CGRectMake(0, 0, width, 0)]) {
        _displayRowCount = 2;
        [self addSubview:self.collectionView];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithWidth:CGRectGetWidth(frame)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, 30 + ITEM_SIZE_WIDTH * _displayRowCount + ITEM_SPACE * (_displayRowCount + 1));
}

- (void)layoutSubviews {
    _collectionView.frame = self.bounds;
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = ITEM_SPACE;
    layout.minimumLineSpacing = ITEM_SPACE;
    layout.sectionInset = UIEdgeInsetsMake(ITEM_SPACE, ITEM_SPACE, ITEM_SPACE, ITEM_SPACE);
}

- (void)setColors:(NSArray *)colors {
    if (![_colors isEqualToArray:colors]) {
        _colors = colors;
        _selectedIndex = _colors.count > 0 ? 0 : -1;
        [_collectionView reloadData];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [_collectionView reloadData];
    }
}

- (void)setDisplayRowCount:(CGFloat)displayRowCount {
    if (_displayRowCount != displayRowCount) {
        _displayRowCount = displayRowCount;
        [self sizeToFit];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _collectionView.contentInset = contentInset;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _colors.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJColorSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.itemColor = _colors[indexPath.item];
    cell.isSelected = _selectedIndex == indexPath.item;
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_selectedIndex != indexPath.item) {
        _selectedIndex = indexPath.item;
        [collectionView reloadData];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJColorSelectCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = ITEM_SPACE;
    flowLayout.minimumLineSpacing = ITEM_SPACE;
    flowLayout.itemSize = CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_WIDTH);
    flowLayout.sectionInset = UIEdgeInsetsMake(ITEM_SPACE, ITEM_SPACE, ITEM_SPACE, ITEM_SPACE);
    return flowLayout;
}

@end
