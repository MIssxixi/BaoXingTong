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

@class UserModel;
@class GuaranteeSlipModel;


typedef void (^serviceResponseBlock)(ServiceResponseModel *responseModel);

@interface DataServiceManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, assign) BOOL isUsingService;
@property (nonatomic, copy) NSString *domainName;

@property (nonatomic, strong) UserModel *currentUser;

- (void)registerWithModel:(UserModel *)model response:(serviceResponseBlock)response;
- (void)loginWithName:(NSString *)name password:(NSString *)password response:(serviceResponseBlock)response;
- (void)logout:(serviceResponseBlock)response;
- (void)changeName:(NSString *)name password:(NSString *)password response:(serviceResponseBlock)response;

- (void)listOfGuarateeSlips:(serviceResponseBlock)response;
- (NSArray *)getAllIds:(serviceResponseBlock)response;
- (GuaranteeSlipModel *)getModelWithId:(NSInteger)Id response:(serviceResponseBlock)response;
- (void)saveDataWithModel:(GuaranteeSlipModel *)model response:(serviceResponseBlock)response;
- (void)deleteDataWithIds:(NSArray *)ids response:(serviceResponseBlock)response;

- (void)uploadImageWithImage:(UIImage *)image name:(NSString *)name progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock response:(serviceResponseBlock)responseBlock;
- (void)uploadImageWithPath:(NSString *)path progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock response:(serviceResponseBlock)responseBlock;
- (UIImage *)getImageWithName:(NSString *)imageName;
- (void)downloadImageWithName:(NSString *)imageName response:(serviceResponseBlock)response;

@end