//
//  AccountViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/26.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "AccountViewController.h"
#import "ChangeNameOrPasswordViewController.h"
#import "UserModel.h"
#import "LoginViewController.h"
#import "DataManager.h"

@interface AccountViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"账户管理";
    self.view.backgroundColor = MAIN_BACKGROUND_COLOR;
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdges];
}

#pragma mark - UITableViewDataSorce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell) {
        if (0 == indexPath.section) {
            [cell.imageView setImage:[UIImage imageNamed:@"default_avatar"]];
            cell.imageView.layer.cornerRadius = 22;
            cell.imageView.clipsToBounds = YES;
            if ([DataServiceManager sharedManager].isUsingService) {
                cell.textLabel.text = [DataServiceManager sharedManager].currentUser.name;
            }
            else
            {
                cell.textLabel.text = [[DataManager sharedManager] currentUser].name;
            }
        }
        else if (1 == indexPath.section)
        {
            cell.textLabel.text = @"更改用户名或密码";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = MAIN_BLUE_COLOR;
        }
        else if (2 == indexPath.section)
        {
            cell.textLabel.text = @"退出当前账号";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor redColor];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section || 1 == section) {
        return 20;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return 20;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (1 == indexPath.section) {
        ChangeNameOrPasswordViewController *changeNameOrPasswordViewController = [ChangeNameOrPasswordViewController new];
        [changeNameOrPasswordViewController setDidChangeName:^(NSString *name) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:index];
            cell.textLabel.text = name;
        }];
        [self.navigationController pushViewController:changeNameOrPasswordViewController animated:YES];
    }
    else if (2 == indexPath.section)
    {
        if ([DataServiceManager sharedManager].isUsingService) {
            [[DataServiceManager sharedManager] logout:^(ServiceResponseModel *responseModel) {
                
            }];
        }
        else
        {
            [[DataManager sharedManager] logout];
        }
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [UIApplication sharedApplication].windows[0].rootViewController = navi;
    }
}

#pragma mark - get
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [UITableView newAutoLayoutView];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
