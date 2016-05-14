//
//  ServiceImageFooterView.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/12.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "ServiceImageFooterView.h"
#import "ImageCollectionViewCell.h"
#import "MWPhotoBrowser.h"
#import "DataManager.h"

#define IMAGECOLLECTIONVIEWCELL_IDENTIFIER @"IMAGECOLLECTIONVIEWCELL"

const CGFloat collectionViewCellHeight = 80;
const CGFloat collectionViewCellminimumLineSpacing = 10;

@interface ServiceImageFooterView () <UICollectionViewDataSource, UICollectionViewDelegate, MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray <NSString *> *imageNames;
@property (nonatomic, strong) NSMutableArray <UIImage *> *imageArray;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ServiceImageFooterView

- (void)dealloc
{
    
}
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
    return self.imageNames.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:IMAGECOLLECTIONVIEWCELL_IDENTIFIER forIndexPath:indexPath];
    if (self.imageNames.count > indexPath.row) {
        NSString *url = [[DataServiceManager sharedManager].domainName stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", self.imageNames[indexPath.row]]];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //url中可能含中文字符
//        BOOL b = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"default_avatar"] options:SDWebImageRefreshCached];
        
        WS(weakSelf)
        [cell setDidDeleteAction:^(UICollectionViewCell *cell) {
            if (weakSelf.didDeleteAction) {
                weakSelf.didDeleteAction(indexPath.row);
            }
        }];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.imageNames.count) {
        MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        [photoBrowser setCurrentPhotoIndex:indexPath.row];
        [[UIViewController currentViewController].navigationController pushViewController:photoBrowser animated:YES];
    }
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return self.imageNames.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < self.imageNames.count) {
//        image = [[DataServiceManager sharedManager] getImageWithName:[self.imageNames[index] url]];
        NSString *url = [[DataServiceManager sharedManager].domainName stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", self.imageNames[index]]];
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:[url url]]];
        return photo;
    }
    return nil;
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

- (void)setImageNames:(NSMutableArray<NSString *> *)imageNames
{
    _imageNames = imageNames;
    [self.collectionView reloadData];
}

- (void)setImageArray:(NSMutableArray <UIImage *> *)imageArray
{
    _imageArray = imageArray;
    [self.collectionView reloadData];
}

- (void)updateImage:(UIImage *)image AtItem:(NSInteger)item
{
    if (item < self.imageArray.count) {
        [self.imageArray replaceObjectAtIndex:item withObject:image];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:0]]];
    }
}

#pragma mark - static methods
+ (CGFloat)heightWithImageNames:(NSArray<NSString *> *)imageName
{
    if (!imageName.count) {
        return 0;
    }
    NSInteger line = (imageName.count - 1) / 3 + 1;
    return line * collectionViewCellHeight + (line - 1) * collectionViewCellminimumLineSpacing + 15;
}

@end
