//
//  DataServiceManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/15.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "DataServiceManager.h"
#import "GuaranteeSlipModel.h"

@implementation DataServiceManager

static  DataServiceManager *sharedDataManager = nil;

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[self alloc] init];
    });
    return sharedDataManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.needReadArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:allRemindGuaranteeSlipsIdentifer]];
//        self.IdsArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:allIdsIdentifer]];
    }
    return self;
}

- (void)listOfGuarateeSlips:(serviceResponseBlock)response
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/listOfGuarateeSlips.php"];
    NSDictionary *params = @{
        @"fuck":@"shit"
    };
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    [[AFHTTPSessionManager manager] POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseModel.data = responseObject;
        if (response) {
            response(responseModel);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        responseModel.errorMessage = error.domain;
        if (response) {
            response(responseModel);
        }
    }];
}

- (void)saveDataWithModel:(GuaranteeSlipModel *)model response:(serviceResponseBlock)response
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/editGuaranteeSlip.php"];
    NSDictionary *paramas = [MTLJSONAdapter JSONDictionaryFromModel:model error:nil];
    
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    [[AFHTTPSessionManager manager] POST:url parameters:paramas progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        responseModel.data = responseObject;
        if (response) {
            response(responseModel);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        responseModel.errorMessage = error.domain;
        if (response) {
            response(responseModel);
        }
    }];

}

@end
