//
//  HtmlManager.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/27.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GuaranteeSlipModel;

@interface HtmlManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)creatHtmlWithGuaranteeSlipModel:(GuaranteeSlipModel *)model;
- (NSString *)creatHtmlWithGuaranteeSlipModels:(NSArray <GuaranteeSlipModel *> *)array;

- (NSString *)creatPdfUsingHtmlWithGuaranteeSlipModel:(GuaranteeSlipModel *)model;

@end
