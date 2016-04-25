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
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.text = data.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", data.carId.length ? data.carId : @"", data.insuranceAgent.length ? data.insuranceAgent : @""];
}

- (JSBadgeView *)badgeView
{
    if (!_badgeView) {
        _badgeView = [[JSBadgeView alloc] initWithParentView:self.imageView alignment:JSBadgeViewAlignmentTopRight];
        _badgeView.badgePositionAdjustment = CGPointMake(-5, 8);
    }
    return _badgeView;
}

@end
