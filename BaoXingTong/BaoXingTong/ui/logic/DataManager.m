//
//  DataManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "DataManager.h"
#import "GuaranteeSlipModel.h"
#import "UserModel.h"

static NSString *const loginIdentifer = @"loginIdentifer";
static NSString *const userIdsIdentifer = @"userIdsIdentifer";
static NSString *const allLocalNotificationsIdentifer = @"allLocalNotificationsIdentifer";
static NSString *const allRemindGuaranteeSlipsIdentifer = @"allRemindGuaranteeSlipsIdentifer";
static NSString *const allIdsIdentifer = @"allIdsIdentifer";

@interface DataManager ()

@property (nonatomic, assign) NSInteger loginUserId;

@property (nonatomic, strong) NSMutableArray *userIdsArray;
@property (nonatomic, strong) NSMutableArray *notificationArray;
@property (nonatomic, strong) NSMutableArray *needReadArray;
@property (nonatomic, strong) NSMutableArray *IdsArray;         //当前用户保单id

@end

@implementation DataManager

static DataManager *sharedDataManager = nil;

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
        self.loginUserId = ((NSNumber *)[self getDataWithIdentifer:loginIdentifer]).integerValue;
        self.userIdsArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:userIdsIdentifer]];
        self.needReadArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:allRemindGuaranteeSlipsIdentifer]];
        self.IdsArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:allIdsIdentifer]];
    }
    return self;
}

- (BOOL)saveImage:(UIImage *)image filePath:(NSString *)imagePath
{
    if (image) {
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSLog((@"pre writing to file"));
        if (![imageData writeToFile:imagePath atomically:NO])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)deleteImage:(NSString *)imageName
{
    NSLog(@"pre delete image");
    return [[NSFileManager defaultManager] removeItemAtPath:[[self imageFolder] stringByAppendingPathComponent:imageName] error:nil];
}

- (UIImage *)getImage:(NSString *)imageName
{
    //保存时，图片已被删除
    NSString *imagePath = [[self imageFolder] stringByAppendingPathComponent:imageName];
    UIImage *tempImage = [UIImage imageWithContentsOfFile:imagePath];
//    NSData *tempData = UIImagePNGRepresentation(tempImage);
//    UIImage *newImage = [UIImage imageWithData:tempData];
//    return newImage;
    return tempImage;
}

- (NSString *)imageFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *folderString = [documentsDirectory stringByAppendingPathComponent:@"images"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderString]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderString withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    return folderString;
}

- (id)getDataWithIdentifer:(NSString *)identifer
{
    if (identifer.length) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:identifer];      //之前写错了，写成valueForKey了,导致有时得不到对象
    }
    return nil;
}

- (void)saveData:(id )data WithIdentifer:(NSString *)identifer
{
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:identifer];    //如果保存失败会怎样？
}

- (void)deleteDataWithIdentifer:(NSString *)identifer
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:identifer];    //如果删除失败会怎样？
}

#pragma mark - user
- (NSString *)userIdentifer:(NSInteger)userId
{
    return [NSString stringWithFormat:@"user-%ld", userId];
}

- (BOOL)hasLogin
{
    if (self.loginUserId > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)loginWithUserName:(NSString *)name password:(NSString *)password
{
    NSArray *usersArray = [self getAllUsers];
    for (UserModel *model in usersArray) {
        if ([model.name isEqualToString:name] && [model.password isEqualToString:password]) {
            self.loginUserId = model.userId;
            [self saveData:@(self.loginUserId) WithIdentifer:loginIdentifer];
            return YES;
        }
    }
    return NO;
}

- (void)logout
{
    self.loginUserId = 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self saveData:@(0) WithIdentifer:loginIdentifer];
}

- (UserModel *)currentUser
{
    if (self.loginUserId <= 0) {
        return nil;
    }
    
    NSData *data = [self getDataWithIdentifer:[self userIdentifer:self.loginUserId]];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (UserModel *)getUserWithPhoneNumber:(NSString *)phoneNumber
{
    NSArray *users = [self getAllUsers];
    for (UserModel *model in users) {
        if ([phoneNumber isEqualToString:model.phone]) {
            return model;
        }
    }
    return nil;
}

- (NSArray *)getAllUsers
{
    NSMutableArray *users = [NSMutableArray new];
    for (NSNumber *userId in self.userIdsArray) {
        NSData *data = [self getDataWithIdentifer:[self userIdentifer:userId.integerValue]];
        UserModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [users addObject:model];
    }
    return [NSArray arrayWithArray:users];
}

- (void)registerNewUser:(UserModel *)model
{
    if (0 == model.name.length || 0 == model.password.length) {
        return;
    }
    
    if (model.userId <= 0) {      //新建的用户
        model.userId = self.userIdsArray.count + 1;
        NSInteger i = 1;
        for (; i <= self.userIdsArray.count; i++) {
            if (![self.userIdsArray containsObject:@(i)]) {
                model.userId = i;
                break;
            }
        }
    }
    
    if (![self.userIdsArray containsObject:@(model.userId)]) {
        [self.userIdsArray addObject:@(model.userId)];
        [self saveData:self.userIdsArray WithIdentifer:userIdsIdentifer];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    
    [self saveData:data WithIdentifer:[self userIdentifer:model.userId]];
}

- (void)saveUser:(UserModel *)model
{
    if (0 == model.name.length || 0 == model.password.length) {
        return;
    }
    
    if (![self.userIdsArray containsObject:@(model.userId)]) {
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [self saveData:data WithIdentifer:[self userIdentifer:model.userId]];
}

- (void)deleteUser:(UserModel *)model
{
    if (![model isKindOfClass:[UserModel class]]) {
        return;
    }
    
    NSInteger Id = model.userId;
    if ([self.userIdsArray containsObject:@(Id)]) {
        [self.userIdsArray removeObject:@(Id)];
        [self deleteDataWithIdentifer:[self userIdentifer:Id]];
        [self saveData:self.IdsArray WithIdentifer:userIdsIdentifer];
    }
}


#pragma mark - notification
- (void)updataLocalNotification         //更新所有本地通知，主要是applicationIconBadgeNumber
{
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if (array.count <= 0) {
        return;
    }
    
    NSMutableArray *modelArray = [NSMutableArray new];
    for (UILocalNotification *notification in array) {
        NSInteger localNotificationId = ((NSNumber *)[notification.userInfo objectForKey:kLocalNotificationKey]).integerValue;
        GuaranteeSlipModel *model = [self getModelWithId:localNotificationId needImages:NO];
        if (model) {
            [modelArray addObject:model];
        }
    }
    
    [modelArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *date1 = [formatter dateFromString:((GuaranteeSlipModel *)obj1).remindDate];
        NSDate *date2 = [formatter dateFromString:((GuaranteeSlipModel *)obj2).remindDate];
        
        NSTimeInterval a = [date1 timeIntervalSince1970];
        NSTimeInterval b = [date2 timeIntervalSince1970];
        if (a > b) {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedAscending;
        }
    }];
    
    for (UILocalNotification *notification in array) {
        NSInteger localNotificationId = ((NSNumber *)[notification.userInfo objectForKey:kLocalNotificationKey]).integerValue;
        for (GuaranteeSlipModel *model in modelArray) {
            if (model.guaranteeSlipModelId == localNotificationId) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                notification.fireDate = [formatter dateFromString:model.remindDate];
                notification.applicationIconBadgeNumber = [modelArray indexOfObject:model] + 1;
                continue;
            }
        }
    }
    
    [[UIApplication sharedApplication] scheduledLocalNotifications];
}

- (void)addLocalNotifaction:(NSInteger)Id fireDate:(NSDate *)date
{
    if (![self.IdsArray containsObject:@(Id)] || !date) {
        return;         //为该Id的保单不存在
    }
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in array) {
        NSInteger localNotificationId = ((NSNumber *)[notification.userInfo objectForKey:kLocalNotificationKey]).integerValue;
        if (localNotificationId == Id) {
            [self updataLocalNotification];
            return;     //已经添加
        }
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"你有保单快到期了";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = self.needReadArray.count + 1;
    localNotification.userInfo = @{
                                   kLocalNotificationKey:@(Id)
                                   };
    localNotification.category = kNotificationCategoryIdentifile;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [self updataLocalNotification];
}

- (void)removeLocalNotifaction:(NSInteger)Id
{
    NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in array) {
        NSInteger localNotificationId = ((NSNumber *)[notification.userInfo objectForKey:kLocalNotificationKey]).integerValue;
        if (localNotificationId == Id) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    [self updataLocalNotification];
}

#pragma mark - guarantee
- (NSString *)guaranteeSlipIdentifer:(NSInteger)Id
{
    return [NSString stringWithFormat:@"user-%ld-guarantee-%ld", self.loginUserId, Id];
}

- (NSArray *)getAllRemindGuaranteeSlipIds
{
    return self.needReadArray;
//    return [NSArray arrayWithArray:[self getDataWithIdentifer:allRemindGuaranteeSlipsIdentifer]];
}

- (NSInteger)sumOfAllUnReadRmindGuranteeSlips
{
    return self.needReadArray.count;
//    return [NSArray arrayWithArray:[self getDataWithIdentifer:allRemindGuaranteeSlipsIdentifer]].count;
}

- (void)setNeedRead:(NSInteger)modelId
{
    if (modelId > 0 && ![self.needReadArray containsObject:@(modelId)]) {
        [self.needReadArray addObject:@(modelId)];
        [self saveData:self.needReadArray WithIdentifer:allRemindGuaranteeSlipsIdentifer];
        
        GuaranteeSlipModel *model = [self getModelWithId:modelId needImages:NO];
        model.isNeedRemind = NO;
        [self saveDataWithModel:model];
    }
}

- (void)resetNotNeedRead:(NSInteger)modelId
{
    if ([self.needReadArray containsObject:@(modelId)]) {
        [self.needReadArray removeObject:@(modelId)];
        [self saveData:self.needReadArray WithIdentifer:allRemindGuaranteeSlipsIdentifer];
    }
}

- (NSArray *)getAllIds
{
    return self.IdsArray;
}

- (GuaranteeSlipModel *)getModelWithId:(NSInteger)Id needImages:(BOOL)needImages
{
    if ([self.IdsArray containsObject:@(Id)]) {
//        NSData *data = [self getDataWithIdentifer:@(Id).stringValue];
        NSData *data = [self getDataWithIdentifer:[self guaranteeSlipIdentifer:Id]];
        GuaranteeSlipModel *model = (GuaranteeSlipModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (needImages) {
            for (NSString *imagePath in model.imageNames) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    UIImage *image = [self getImage:imagePath];
                    if (image) {
                        [model.imageArray addObject:image];
                    }
                });
            }
        }
        
        return model;
    }
    return nil;
}

- (void)saveDataWithModel:(GuaranteeSlipModel *)model
{
    if (model.guaranteeSlipModelId <= 0) {      //新建的保单
        model.guaranteeSlipModelId = self.IdsArray.count + 1;
        NSInteger i = 1;
        for (; i <= self.IdsArray.count; i++) {
            if (![self.IdsArray containsObject:@(i)]) {
                model.guaranteeSlipModelId = i;
                break;
            }
        }
    }
    
    if (![self.IdsArray containsObject:@(model.guaranteeSlipModelId)]) {
        [self.IdsArray addObject:@(model.guaranteeSlipModelId)];
        [self saveData:self.IdsArray WithIdentifer:allIdsIdentifer];
    }
    
//    //删除之前照片              //这样做非常消耗io，不好。同时会出现问题：每次删除的话，获取图片就不能用imageWithContentsOfFile，因为，接下来保存的时候之前的图片已经删了，只能通过NSData来转换，但这样又有其他问题，因为图片是异步获取的，点击保单详情后，快速返回，这时图片还没加载完，会继续加载，从而内存不断增加且不会释放
//    for (NSString *imageName in model.imageNames) {
//        [[NSFileManager defaultManager] removeItemAtPath:[[self imageFolder] stringByAppendingPathComponent:imageName] error:nil];
//    }
    
    model.avatar = [NSString stringWithFormat:@"%@-%ld-avatar.png", model.name, model.guaranteeSlipModelId];
    NSString *avatarPath = [[self imageFolder] stringByAppendingPathComponent:model.avatar];
    UIImage *avatarImage = model.avatarImage;
    if (avatarImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self saveImage:avatarImage filePath:avatarPath];
        });
    }
//    model.avatarImage = nil;              //不改变传进来的model
    
    NSInteger temp = model.imageNames.count;
    for (;temp < model.imageArray.count; temp++) {
        NSString *imageName = [NSString stringWithFormat:@"%@-%ld-%@.png", model.name, model.guaranteeSlipModelId, [[NSProcessInfo processInfo] globallyUniqueString]];
        NSString *imagePath = [[self imageFolder] stringByAppendingPathComponent:imageName];
        [model.imageNames addObject:imageName];
        UIImage *image = model.imageArray[temp];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self saveImage:image filePath:imagePath];
        });
    }
//    [model.imageArray removeAllObjects];      ////不改变传进来的model
    GuaranteeSlipModel *copyModel = [model copy];
    copyModel.avatarImage = nil;
    [copyModel.imageArray removeAllObjects];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:copyModel];
    [self saveData:data WithIdentifer:[self guaranteeSlipIdentifer:model.guaranteeSlipModelId]];
}

- (void)deleteDataWithId:(NSInteger)Id
{
    if ([self.IdsArray containsObject:@(Id)]) {
        [self.IdsArray removeObject:@(Id)];
//        [self deleteDataWithIdentifer:@(Id).stringValue];
        [self deleteDataWithIdentifer:[self guaranteeSlipIdentifer:Id]];
        [self saveData:self.IdsArray WithIdentifer:allIdsIdentifer];
        
        [self removeLocalNotifaction:Id];
        [self resetNotNeedRead:Id];
    }
}

@end
