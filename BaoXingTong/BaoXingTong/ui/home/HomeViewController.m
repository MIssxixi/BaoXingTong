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
#import "PopoverController.h"
#import "HomeBottomButton.h"

#define HOMEVIEWTABLEVIEWCELL_IDENTIFER @"HOMEVIEWTABLEVIEWCELL"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) HomeBottomButton *bottomButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomButtonHeight;

@property (nonatomic, strong) NSMutableArray *idsArray;
@property (nonatomic, strong) NSMutableArray <GuaranteeSlipModel *> *modelArray;    //暂时不支持加载，直接一次性将数据获取完
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"保单";
    
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomButton];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.tableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomButton];
    
    [self.bottomButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    self.bottomButtonHeight = [self.bottomButton autoSetDimension:ALDimensionHeight toSize:0];
}

- (void)edit
{
    [self.tableView setEditing:YES animated:YES];
    self.bottomButtonHeight.constant = BUTTON_HEIGHT;
    [self updateButtonsToMatchTableState];
}

- (void)cancel
{
    [self.tableView setEditing:NO animated:YES];
    self.bottomButtonHeight.constant = 0;
    [self updateButtonsToMatchTableState];
}

- (void)addGuaranteeSlip
{
    UIViewController *popoverViewContoller = [[UIViewController alloc] init];
    popoverViewContoller.modalPresentationStyle = UIModalPresentationPopover;
    popoverViewContoller.preferredContentSize = CGSizeMake(100, 200);
    popoverViewContoller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    popoverViewContoller.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    popoverViewContoller.popoverPresentationController.delegate = self;
    
    PopoverController *popover = [[PopoverController alloc] initWithBarButtonItem:self.navigationItem.rightBarButtonItem Options:@[@"新增", @"删除"] selectedCallBack:^(NSInteger index) {
        if (0 == index) {
            EditGuaranteeSlipViewController *editGuaranteeSlipViewController = [[EditGuaranteeSlipViewController alloc] init];
            [editGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
                if (model) {
                    [self.modelArray addObject:model];
                    [self.tableView reloadData];
                }
            }];
            [self.navigationController pushViewController:editGuaranteeSlipViewController animated:YES];
        }
        else if (1 == index)
        {
            [self.tableView setEditing:YES animated:YES];
        }
        
        [self dismissViewControllerAnimated:NO completion:nil];
    } delegate:self];
    
    [self presentViewController:popover animated:YES completion:nil];
}

- (void)share
{
    
}

- (void)deleteAll
{
    for (GuaranteeSlipModel *model in self.modelArray) {
        [[DataManager sharedManager] deleteDataWithId:model.guaranteeSlipModelId];
    }
    
    [self.modelArray removeAllObjects];
    [self.tableView reloadData];
    [self updateButtonsToMatchTableState];
}

- (void)delete
{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *selectedIndexSet = [NSMutableIndexSet new];
    
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [[DataManager sharedManager] deleteDataWithId:self.modelArray[indexPath.row].guaranteeSlipModelId];
        [selectedIndexSet addIndex:indexPath.row];
    }
    
    [self.modelArray removeObjectsAtIndexes:selectedIndexSet];
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self updateButtonsToMatchTableState];
}

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.isEditing) {
        [self.leftBarButtonItem setTitle:@"取消"];
        [self.leftBarButtonItem setAction:@selector(cancel)];
        self.rightBarButtonItem.title = @"分享";
        [self.rightBarButtonItem setAction:@selector(share)];
        
        NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        [self.bottomButton.rightButton setTitle:[NSString stringWithFormat:@"删除(%ld)", selectedIndexPaths.count] forState:UIControlStateNormal];
        if (selectedIndexPaths.count) {
            self.bottomButton.rightButton.enabled = YES;
            self.bottomButton.rightButton.alpha = 1;
        }
        else
        {
            self.bottomButton.rightButton.enabled = NO;
            self.bottomButton.rightButton.alpha = 0.5;
        }
        
        if ([self.tableView numberOfRowsInSection:0]) {
            self.bottomButton.leftButton.enabled = YES;
            self.bottomButton.leftButton.alpha = 1;
            
            self.rightBarButtonItem.enabled = YES;
        }
        else
        {
            self.bottomButton.leftButton.enabled = NO;
            self.bottomButton.leftButton.alpha = 0.5;
            
            self.rightBarButtonItem.enabled = NO;
        }
    }
    else
    {
        self.leftBarButtonItem.title = @"编辑";
        [self.leftBarButtonItem setAction:@selector(edit)];
        self.rightBarButtonItem.title = @"新增";
        [self.rightBarButtonItem setAction:@selector(addGuaranteeSlip)];
        self.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;     //!!!在iphone下必须实现改代理，否则会pop出一个全屏
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
    if (tableView.isEditing)
    {
        [self updateButtonsToMatchTableState];
    }
    else
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
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonsToMatchTableState];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEWCELL_HEIGHT_DEFAULT;
}

#pragma mark - get set
- (UIBarButtonItem *)leftBarButtonItem
{
    if (!_leftBarButtonItem) {
        _leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit)];
    }
    return _leftBarButtonItem;
}

- (UIBarButtonItem *)rightBarButtonItem
{
    if (!_rightBarButtonItem) {
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addGuaranteeSlip)];
    }
    return _rightBarButtonItem;
}

- (HomeBottomButton *)bottomButton
{
    if (!_bottomButton) {
        _bottomButton = [HomeBottomButton newAutoLayoutView];
        [_bottomButton.leftButton addTarget:self action:@selector(deleteAll) forControlEvents:UIControlEventTouchUpInside];
        [_bottomButton.rightButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomButton;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
//        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {  //这样设置让分割线从头像开始，否则从title开始
//            [_tableView setSeparatorInset:UIEdgeInsetsZero];
//        }
        [_tableView registerClass:[HomeViewTableViewCell class] forCellReuseIdentifier:HOMEVIEWTABLEVIEWCELL_IDENTIFER];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.allowsMultipleSelectionDuringEditing = YES;
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
