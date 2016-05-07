//
//  HomeViewTableViewCell.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/8.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HomeViewTableViewCell.h"
#import "GuaranteeSlipModel.h"
#import <JSBadgeView/JSBadgeView.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeViewTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation HomeViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.bounds = CGRectMake(0, 0, 44, 44);   //单独设置，没用！！！！！
}

- (void)needRead:(BOOL)need
{
    //坑！！！！！必须当作属性，否则每次都创建新的badgeview，不能更改红点值！！
//    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.imageView alignment:JSBadgeViewAlignmentTopRight];
//    badgeView.badgePositionAdjustment = CGPointMake(-5, 8);
    if (need) {
        self.badgeView.badgeText = @"1";
    }
    else
    {
        self.badgeView.badgeText = @"";
    }
}

- (void)setData:(GuaranteeSlipModel *)data
{
    [self.imageView setImage:data.avatarImage ? data.avatarImage :[UIImage imageNamed:@"default_avatar"]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.cornerRadius = AVATAR_SIZE.width / 2.0;
//    self.imageView.layer.masksToBounds = YES;       //必须要
    self.imageView.clipsToBounds = YES;
    self.textLabel.text = data.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", data.carId.length ? data.carId : @"", data.insuranceAgent.length ? data.insuranceAgent : @""];
}

- (JSBadgeView *)badgeView
{
    if (!_badgeView) {
//        _badgeView = [[JSBadgeView alloc] initWithParentView:self.imageView alignment:JSBadgeViewAlignmentTopRight];  //由于头像为圆角，clipsToBounds设置为yes，不能采用这个
        _badgeView = [[JSBadgeView alloc] initWithParentView:self.textLabel alignment:JSBadgeViewAlignmentTopLeft];
        _badgeView.badgePositionAdjustment = CGPointMake(-20, 0);
    }
    return _badgeView;
}

@end
