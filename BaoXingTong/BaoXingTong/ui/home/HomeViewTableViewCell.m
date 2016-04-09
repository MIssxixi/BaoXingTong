//
//  HomeViewTableViewCell.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/8.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HomeViewTableViewCell.h"
#import "GuaranteeSlipModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface HomeViewTableViewCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;

@end

@implementation HomeViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (void)setData:(GuaranteeSlipModel *)data
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:data.avatar] placeholderImage:[UIImage imageNamed:@"avatar_mask"]];
    self.textLabel.text = data.name;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", data.carId.length ? data.carId : @"", data.insuranceAgent.length ? data.insuranceAgent : @""];
}

@end
