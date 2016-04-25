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
        NSLog(@"%@", responseObject);
        responseModel.data = responseObject;
        if (response) {
            response(responseModel);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        responseModel.errorMessage = error.domain;
        if (response) {
            response(responseModel);
        }
    }];

}

- (void)uploadImageWithImage:(UIImage *)image progress:(void (^)(NSProgress *))uploadProgressBlock response:(serviceResponseBlock)responseBlock
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://172.26.251.63/~yongjie_zou/BaoXingTongPHP/upload.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:@"filename.png" mimeType:@"image/png"];          //name必须为@"file"，否则不会成功！！！！！
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          uploadProgressBlock(uploadProgress);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          responseModel.errorMessage = error.domain;
                          if (responseBlock) {
                              responseBlock(responseModel);
                          }
                      } else {
                          responseModel.data = responseObject;
                          if (responseBlock) {
                              responseBlock(responseModel);
                          }
                      }
                  }];
    
    [uploadTask resume];
}

- (void)uploadImageWithPath:(NSString *)path progress:(void (^)(NSProgress *))uploadProgressBlock response:(serviceResponseBlock)responseBlock
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://172.26.251.63/~yongjie_zou/BaoXingTongPHP/upload.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:path] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
        UIImage *image = [UIImage imageNamed:@"/Users/bjhl/Documents/ios/MyRepository/BaoXingTong/BaoXingTong/BaoXingTong/Resources/default_avatar.png"];
        [formData appendPartWithFormData:UIImagePNGRepresentation(image) name:@"default.png"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          uploadProgressBlock(uploadProgress);
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          responseModel.errorMessage = error.domain;
                          if (responseBlock) {
                              responseBlock(responseModel);
                          }
                      } else {
                          responseModel.data = responseObject;
                          if (responseBlock) {
                              responseBlock(responseModel);
                          }
                      }
                  }];
    
    [uploadTask resume];
}

- (void)deleteDataWithIds:(NSArray *)ids response:(serviceResponseBlock)response
{
    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/deleteGuaranteeSlips.php"];
    NSDictionary *params = @{
                             @"ids" : ids
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

@end
