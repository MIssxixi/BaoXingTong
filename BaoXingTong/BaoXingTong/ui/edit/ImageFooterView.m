//
//  ImageFooterView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/17.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ImageFooterView.h"
#import "ImageCollectionViewCell.h"

#define IMAGECOLLECTIONVIEWCELL_IDENTIFIER @"IMAGECOLLECTIONVIEWCELL"

const CGFloat collectionViewCellHeight = 80;
const CGFloat collectionViewCellminimumLineSpacing = 10;

@interface ImageFooterView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray <UIImage *> * imageArray;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ImageFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.collectionView];
        [self.collectionView autoPinEdgesToSuperviewEdges];
    }
    return self;
}



#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:IMAGECOLLECTIONVIEWCELL_IDENTIFIER forIndexPath:indexPath];
    if (self.imageArray.count > indexPath.row) {
        cell.image = self.imageArray[indexPath.row];
    }
    return cell;
}
#pragma mark - get set
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH / 3.0 - 25.0, collectionViewCellHeight);
        flowLayout.minimumLineSpacing = collectionViewCellminimumLineSpacing;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:IMAGECOLLECTIONVIEWCELL_IDENTIFIER];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.contentInset=UIEdgeInsetsMake(10, 10, 5, 10);
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (void)setImageArray:(NSArray<UIImage *> *)imageArray
{
    _imageArray = imageArray;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
    [self.collectionView reloadData];
}

#pragma mark - static methods
+ (CGFloat)heightWithImageArray:(NSArray <UIImage *> *)imageArray
{
    if (!imageArray.count) {
        return 0;
    }
    NSInteger line = (imageArray.count - 1) / 3 + 1;
    return line * collectionViewCellHeight + (line - 1) * collectionViewCellminimumLineSpacing + 15;
}

@end
