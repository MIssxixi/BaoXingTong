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
#import "DataServiceManager.h"
#import "GuaranteeSlipModel.h"
#import "EditGuaranteeSlipViewController.h"
#import "PopoverController.h"
#import "HomeBottomButton.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>

#define HOMEVIEWTABLEVIEWCELL_IDENTIFER @"HOMEVIEWTABLEVIEWCELL"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) HomeBottomButton *bottomButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomButtonHeight;

@property (nonatomic, strong) NSMutableArray *idsArray;
@property (nonatomic, strong) NSMutableArray <GuaranteeSlipModel *> *modelArray;    //暂时不支持加载，直接一次性将数据获取完
@property (nonatomic, strong) NSMutableArray *needReadIdsArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HomeViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.needReadIdsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllRemindGuaranteeSlipIds]];
    [self.tableView reloadData];
}

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
    
    [self.tableView.mj_header beginRefreshing];
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
            
            NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:@"http://172.26.251.63/~yongjie_zou/BaoXingTongPHP/upload.php" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:@"/Users/bjhl/Documents/ios/MyRepository/BaoXingTong/BaoXingTong/BaoXingTong/Resources/default_avatar.png"] name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg" error:nil];
            } error:nil];
            
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            NSURLSessionUploadTask *uploadTask;
            uploadTask = [manager
                          uploadTaskWithStreamedRequest:request
                          progress:^(NSProgress * _Nonnull uploadProgress) {
                              // This is not called back on the main queue.
                              // You are responsible for dispatching to the main queue for UI updates
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  //Update the progress view
//                                  [progressView setProgress:uploadProgress.fractionCompleted];
                              });
                          }
                          completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                              if (error) {
                                  NSLog(@"Error: %@", error);
                              } else {
                                  NSLog(@"%@ %@", response, responseObject);
                              }
                          }];
            
            [uploadTask resume];
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

#pragma mark - 下拉刷新
- (void)onRefresh
{
    WS(weakSelf)
    [[DataServiceManager sharedManager] listOfGuarateeSlips:^(ServiceResponseModel *responseModel) {
        weakSelf.modelArray = [NSMutableArray arrayWithArray:[MTLJSONAdapter modelsOfClass:[GuaranteeSlipModel class] fromJSONArray:responseModel.data error:nil]];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
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
        
        BOOL needRead = [self.needReadIdsArray containsObject:@(self.modelArray[indexPath.row].guaranteeSlipModelId)];
        [cell needRead:needRead];
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
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self onRefresh];
        }];
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
        
        if (isUsingService) {       //采用服务器
            return _modelArray;
        }
        
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
