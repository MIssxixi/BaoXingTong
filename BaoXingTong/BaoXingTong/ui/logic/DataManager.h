//
//  DataManager.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GuaranteeSlipModel;

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (NSArray *)getAllIds;
- (GuaranteeSlipModel *)getModelWithId:(NSInteger)Id;
- (void)saveDataWithModel:(GuaranteeSlipModel *)model;
- (void)deleteDataWithId:(NSInteger)Id;

@end
