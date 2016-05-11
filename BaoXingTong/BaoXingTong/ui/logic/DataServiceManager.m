//
//  DataServiceManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/15.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "DataServiceManager.h"
#import "GuaranteeSlipModel.h"
#import "UserModel.h"

@interface DataServiceManager ()

@end

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

#pragma mark - Account
- (void)registerWithModel:(UserModel *)model response:(serviceResponseBlock)response
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/registerAccount.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/registerAccount.php"];
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

- (void)loginWithName:(NSString *)name password:(NSString *)password response:(serviceResponseBlock)response
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/login.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/login.php"];
    NSDictionary *paramas = @{
                              @"name":name,
                              @"password":password
                              };
    self.currentUser.name = name;
    self.currentUser.password = password;
    
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    [[AFHTTPSessionManager manager] POST:url parameters:paramas progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        responseModel.errorMessage = [responseObject objectForKey:@"error"];
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

- (void)logout:(serviceResponseBlock)response
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/logout.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/logout.php"];
    
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    [[AFHTTPSessionManager manager] POST:url parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        responseModel.errorMessage = [responseObject objectForKey:@"error"];
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

- (void)changeName:(NSString *)name password:(NSString *)password response:(serviceResponseBlock)response
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/changeNameOrPassword.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/changeNameOrPassword.php"];
    
    NSDictionary *paramas = @{
                              @"name":name,
                              @"password":password
                              };
    
    __block ServiceResponseModel *responseModel = [ServiceResponseModel new];
    [[AFHTTPSessionManager manager] POST:url parameters:paramas progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@", responseObject);
        responseModel.errorMessage = [responseObject objectForKey:@"error"];
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

#pragma mark - GuarateeSlips
- (void)listOfGuarateeSlips:(serviceResponseBlock)response
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/listOfGuarateeSlips.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/listOfGuarateeSlips.php"];
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
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/editGuaranteeSlip.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/editGuaranteeSlip.php"];
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

- (void)uploadImageWithImage:(UIImage *)image name:(NSString *)name progress:(void (^)(NSProgress *))uploadProgressBlock response:(serviceResponseBlock)responseBlock
{
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/upload.php"];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImagePNGRepresentation(image) name:@"file" fileName:name mimeType:@"image/png"];          //name必须为@"file"，否则不会成功！！！！！
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
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/upload.php"];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
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

- (UIImage *)getImageWithName:(NSString *)imageName
{
    NSString *url = [self.domainName stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", imageName]];
    NSURL *URL = [NSURL URLWithString:url];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    return [UIImage imageWithData:data];
}

- (void)downloadImageWithName:(NSString *)imageName response:(serviceResponseBlock)response
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *url = [self.domainName stringByAppendingPathComponent:[NSString stringWithFormat:@"image/%@", imageName]];
    NSURL *URL =[NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

- (void)deleteDataWithIds:(NSArray *)ids response:(serviceResponseBlock)response
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/deleteGuaranteeSlips.php"];
    NSString *url = [self.domainName stringByAppendingPathComponent:@"BaoXingTongPHP/deleteGuaranteeSlips.php"];
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

#pragma mark - get
- (UserModel *)currentUser
{
    if (!_currentUser) {
        _currentUser = [[UserModel alloc] init];
    }
    return _currentUser;
}

@end
