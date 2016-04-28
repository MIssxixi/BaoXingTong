//
//  PdfManager.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/28.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GuaranteeSlipModel;

@interface PdfManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)creatPdf:(GuaranteeSlipModel *)model;
- (NSString *)creatPdfWithModels:(NSArray <GuaranteeSlipModel *> *)array;

@end
