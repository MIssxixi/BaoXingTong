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
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.imageView alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgePositionAdjustment = CGPointMake(-5, 8);
    if (need) {
        badgeView.badgeText = @"1";
    }
    else
    {
        badgeView.badgeText = @"";
    }
}

- (void)setData:(GuaranteeSlipModel *)data
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.textLabel.text = data.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", data.carId.length ? data.carId : @"", data.insuranceAgent.length ? data.insuranceAgent : @""];
}

@end
