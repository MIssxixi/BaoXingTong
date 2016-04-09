//
//  HomeViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeViewTableViewCell.h"
#import "DataManager.h"
#import "GuaranteeSlipModel.h"
#import "EditGuaranteeSlipViewController.h"

#define HOMEVIEWTABLEVIEWCELL_IDENTIFER @"HOMEVIEWTABLEVIEWCELL"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *idsArray;
@property (nonatomic, strong) NSMutableArray <GuaranteeSlipModel *> *modelArray;    //暂时不支持加载，直接一次性将数据获取完
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"保单";
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新建" style:UIBarButtonItemStylePlain target:self action:@selector(addGuaranteeSlip)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdges];
}

- (void)addGuaranteeSlip
{
    EditGuaranteeSlipViewController *editGuaranteeSlipViewController = [[EditGuaranteeSlipViewController alloc] init];
    [editGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
        if (model) {
            [self.modelArray addObject:model];
            [self.tableView reloadData];
        }
    }];
    [self.navigationController pushViewController:editGuaranteeSlipViewController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HOMEVIEWTABLEVIEWCELL_IDENTIFER forIndexPath:indexPath];
    if (indexPath.row < self.modelArray.count) {
        [cell setData:self.modelArray[indexPath.row]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.modelArray.count) {
        EditGuaranteeSlipViewController *editGuaranteeSlipViewController = [[EditGuaranteeSlipViewController alloc] initWithModel:self.modelArray[indexPath.row]];
        [editGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
            [self.tableView reloadData];
        }];
        [editGuaranteeSlipViewController setDidDelete:^(GuaranteeSlipModel *model) {
            [self.modelArray removeObject:model];
            [self.tableView reloadData];
        }];
        [self.navigationController pushViewController:editGuaranteeSlipViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEWCELL_HEIGHT_DEFAULT;
}

#pragma mark - get set
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        [_tableView registerClass:[HomeViewTableViewCell class] forCellReuseIdentifier:HOMEVIEWTABLEVIEWCELL_IDENTIFER];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray *)idsArray
{
    if (!_idsArray) {
        _idsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllIds]];
    }
    return _idsArray;
}

- (NSMutableArray <GuaranteeSlipModel *> *)modelArray
{
    if (!_modelArray) {
        _modelArray = [[NSMutableArray alloc] init];
        for (NSNumber *number in self.idsArray) {
            GuaranteeSlipModel *model = [[DataManager sharedManager] getModelWithId:number.integerValue];
            if (model) {                                    //！！！为nil会崩溃
                [_modelArray addObject:[[DataManager sharedManager] getModelWithId:number.integerValue]];
            }
        }
    }
    return _modelArray;
}

@end
