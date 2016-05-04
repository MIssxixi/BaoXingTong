//
//  DataManager.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserModel;
@class GuaranteeSlipModel;

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)hasLogin;
- (BOOL)loginWithUserName:(NSString *)name password:(NSString *)password;
- (void)logout;
- (NSArray *)getAllUsers;
- (UserModel *)currentUser;
- (UserModel *)getUserWithPhoneNumber:(NSString *)phoneNumber;
- (void)registerNewUser:(UserModel *)model;
- (void)deleteUser:(UserModel *)model;
- (void)saveUser:(UserModel *)model;

//本地通知，最多不超过64条  Id为保单Id
- (void)addLocalNotifaction:(NSInteger)Id fireDate:(NSDate *)date;
- (void)removeLocalNotifaction:(NSInteger)Id;

- (NSArray *)getAllRemindGuaranteeSlipIds;
- (NSInteger)sumOfAllUnReadRmindGuranteeSlips;
- (void)setNeedRead:(NSInteger)modelId;        //需要读
- (void)resetNotNeedRead:(NSInteger)modelId;        //已经读过

- (NSArray *)getAllIds;
- (GuaranteeSlipModel *)getModelWithId:(NSInteger)Id needImages:(BOOL)needImages;
- (void)saveDataWithModel:(GuaranteeSlipModel *)model;
- (void)deleteDataWithId:(NSInteger)Id;

- (UIImage *)getImage:(NSString *)imageName;
- (BOOL)deleteImage:(NSString *)imageName;

@end
