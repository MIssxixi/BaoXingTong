//
//  AppDelegate.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/18.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "DataManager.h"
#import "GuaranteeSlipModel.h"
#import "LoginViewController.h"
#import <SMS_SDK/SMSSDK.h>

@interface AppDelegate ()

@property (nonatomic, strong) HomeViewController *homeVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.homeVC = [[HomeViewController alloc] init];
    LoginViewController *loginVC = [LoginViewController new];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    if ([DataManager sharedManager].hasLogin) {
        navi = [[UINavigationController alloc] initWithRootViewController:self.homeVC];
    }
    else
    {
        navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
    }
    self.window.rootViewController = navi;
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self registerLocalNotification];
    
    //短信认证
    [SMSSDK registerApp:@"121a438480c48" withSecret:@"6b8023ec70606a3a888b55a8b899c06d"];
    
    return YES;
}

- (void)registerLocalNotification
{
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = kNotificationCategoryIdentifile;
    UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:[NSSet setWithObject:category]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[DataManager sharedManager] setNeedRead:((NSNumber *)[notification.userInfo objectForKey:kLocalNotificationKey]).integerValue];
    [self.homeVC updateBadgeView];
}
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler
{
    [[DataManager sharedManager] setNeedRead:((NSNumber *)[notification.userInfo objectForKey:kLocalNotificationKey]).integerValue];
    [self.homeVC updateBadgeView];
    completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //主要用于点击app图标时，更新红点状态。因为通知到时，如果不点击通知栏，app无法知道通知到了
    NSDate *currentDate = [NSDate date];
    NSArray *allIds = [[DataManager sharedManager] getAllIds];
    for (NSNumber *number in allIds) {
        GuaranteeSlipModel *model = [[DataManager sharedManager] getModelWithId:number.integerValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *remindDate = [formatter dateFromString:model.remindDate];
        if ([currentDate compare:remindDate] == NSOrderedDescending && model.isNeedRemind) {
            [[DataManager sharedManager] setNeedRead:model.guaranteeSlipModelId];
        }
    }
    
    [self.homeVC updateBadgeView];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
