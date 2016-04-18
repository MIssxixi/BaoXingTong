//
//  DataManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "DataManager.h"
#import "GuaranteeSlipModel.h"

static NSString *const allRemindGuaranteeSlipsIdentifer = @"allRemindGuaranteeSlipsIdentifer";
static NSString *const allIdsIdentifer = @"allIdsIdentifer";

@interface DataManager ()

@property (nonatomic, strong) NSMutableArray *needReadArray;
@property (nonatomic, strong) NSMutableArray *IdsArray;

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
        self.needReadArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:allRemindGuaranteeSlipsIdentifer]];
        self.IdsArray = [NSMutableArray arrayWithArray:[self getDataWithIdentifer:allIdsIdentifer]];
    }
    return self;
}

- (id)getDataWithIdentifer:(NSString *)identifer
{
    if (identifer.length) {
        return [[NSUserDefaults standardUserDefaults] valueForKey:identifer];
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

- (GuaranteeSlipModel *)getModelWithId:(NSInteger)Id
{
    if ([self.IdsArray containsObject:@(Id)]) {
        NSData *data = [self getDataWithIdentifer:@(Id).stringValue];
        return (GuaranteeSlipModel *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
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
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [self saveData:data WithIdentifer:@(model.guaranteeSlipModelId).stringValue];
}

- (void)deleteDataWithId:(NSInteger)Id
{
    if ([self.IdsArray containsObject:@(Id)]) {
        [self.IdsArray removeObject:@(Id)];
        [self deleteDataWithIdentifer:@(Id).stringValue];
        [self saveData:self.IdsArray WithIdentifer:allIdsIdentifer];
    }
}

@end
