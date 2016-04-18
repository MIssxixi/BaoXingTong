//
//  DataServiceManager.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/15.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

//访问服务器

#import <Foundation/Foundation.h>
#import "ServiceResponseModel.h"

@class GuaranteeSlipModel;

static NSString *ipAddress = @"http://172.26.251.63";         //因为是局域网，所以可以改变

typedef void (^serviceResponseBlock)(ServiceResponseModel *responseModel);

@interface DataServiceManager : NSObject

+ (instancetype)sharedManager;

- (void)listOfGuarateeSlips:(serviceResponseBlock)response;
- (NSArray *)getAllIds:(serviceResponseBlock)response;
- (GuaranteeSlipModel *)getModelWithId:(NSInteger)Id response:(serviceResponseBlock)response;
- (void)saveDataWithModel:(GuaranteeSlipModel *)model response:(serviceResponseBlock)response;
- (void)deleteDataWithId:(NSInteger)Id response:(serviceResponseBlock)response;

@end