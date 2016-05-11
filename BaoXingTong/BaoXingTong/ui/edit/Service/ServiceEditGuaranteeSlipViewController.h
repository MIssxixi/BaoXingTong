//
//  ServiceEditGuaranteeSlipViewController.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/10.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuaranteeSlipModel;

@interface ServiceEditGuaranteeSlipViewController : UITableViewController

@property (nonatomic, copy) void (^didSave)(GuaranteeSlipModel *model);
@property (nonatomic, copy) void (^didDelete)(GuaranteeSlipModel *model);

- (instancetype)initWithModel:(GuaranteeSlipModel *)model;

@end
