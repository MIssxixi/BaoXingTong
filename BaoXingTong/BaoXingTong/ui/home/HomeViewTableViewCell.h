//
//  HomeViewTableViewCell.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/8.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuaranteeSlipModel;

@interface HomeViewTableViewCell : UITableViewCell

- (void)needRead:(BOOL)need;
- (void)setData:(GuaranteeSlipModel *)data;

@end
