//
//  HomeViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/6.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeViewTableViewCell.h"
#import "BlankHomeView.h"
#import "DataManager.h"
#import "HtmlManager.h"
#import "DataServiceManager.h"
#import "GuaranteeSlipModel.h"
#import "EditGuaranteeSlipViewController.h"
#import "ServiceEditGuaranteeSlipViewController.h"
#import "AccountViewController.h"
#import "PopoverController.h"
#import "HomeBottomButton.h"
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "PdfManager.h"

#define HOMEVIEWTABLEVIEWCELL_IDENTIFER @"HOMEVIEWTABLEVIEWCELL"
static HomeViewController *sharedInstance = nil;

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UIDocumentInteractionControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) HomeBottomButton *bottomButton;
@property (nonatomic, strong) NSLayoutConstraint *bottomButtonHeight;

@property (nonatomic, strong) BlankHomeView *blankHomeView;

@property (nonatomic, strong) NSMutableArray *idsArray;
@property (nonatomic, strong) NSMutableArray <GuaranteeSlipModel *> *modelArray;    //暂时不支持加载，直接一次性将数据获取完
@property (nonatomic, strong) NSMutableArray *needReadIdsArray;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *filteredArray;

@end

@implementation HomeViewController

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([DataServiceManager sharedManager].isUsingService) {         //采用服务器
            self.blankHomeView.hidden = YES;
            WS(weakSelf);
            self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf onRefresh];
            }];
            [self.modelArray removeAllObjects];
            [self.tableView reloadData];
            [self.tableView.mj_header beginRefreshing];
            return self;
        }
        
        [self.tableView.mj_header setHidden:YES];
        //每次退出账号然后登录，由于采用单例，所以需要改变之前数据
        [_modelArray removeAllObjects];
        _idsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllIds]];
        NSInteger item = 0;
        for (NSNumber *number in self.idsArray) {
            GuaranteeSlipModel *model = [[DataManager sharedManager] getModelWithId:number.integerValue needImages:NO];
            if (model) {                                    //！！！为nil会崩溃
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    model.avatarImage = [[DataManager sharedManager] getImage:model.avatar];
                    if (model.avatarImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self updateAvatar:model.avatarImage index:item];
                        });
                    }
                });
                [_modelArray addObject:model];
                item++;
            }
        }
        [self.tableView reloadData];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateBadgeView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"保单";
    
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomButton];
    [self.view addSubview:self.blankHomeView];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [self.tableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.bottomButton];
    
    [self.bottomButton autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    self.bottomButtonHeight = [self.bottomButton autoSetDimension:ALDimensionHeight toSize:0];
    [self.bottomButton setHidden:YES];
    
    [self.blankHomeView autoPinEdgesToSuperviewEdges];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
//    NSInteger item = 0;
//    for (; item < self.modelArray.count; item++) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            self.modelArray[item].avatarImage = [[DataManager sharedManager] getImage:self.modelArray[item].avatar];
//            if (self.modelArray[item].avatarImage) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self updateAvatar:self.modelArray[item].avatarImage index:item];
//                });
//            }
//        });
//    }
    
    if ([DataServiceManager sharedManager].isUsingService) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)updateBadgeView
{
    if (!self.tableView.isEditing) {
        [self updateNeedReadNumber];
        [self.tableView reloadData];
    }
}

- (void)updateNeedReadNumber
{
    self.needReadIdsArray = [NSMutableArray arrayWithArray:[[DataManager sharedManager] getAllRemindGuaranteeSlipIds]];
    NSInteger number = 0;
    NSInteger count = 0;
    for (; number < self.modelArray.count; number++) {
        if ([self.needReadIdsArray containsObject:@(self.modelArray[number].guaranteeSlipModelId)]) {
            count++;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = count;
}

- (void)edit
{
    if (!self.modelArray.count) {
        return;
    }
    if ([DataServiceManager sharedManager].isUsingService) {
        [self.tableView.mj_header setHidden:YES];
    }
    [self.tableView setEditing:YES animated:YES];
    self.bottomButtonHeight.constant = BUTTON_HEIGHT;
    [self.bottomButton setHidden:NO];
    self.tableView.tableHeaderView = nil;
    [self updateButtonsToMatchTableState];
}

- (void)cancel
{
    if ([DataServiceManager sharedManager].isUsingService) {
        [self.tableView.mj_header setHidden:NO];
    }
    [self.tableView setEditing:NO animated:YES];
    self.bottomButtonHeight.constant = 0;
    [self.bottomButton setHidden:YES];
    self.tableView.tableHeaderView = self.searchController.searchBar;
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
    
    PopoverController *popover = [[PopoverController alloc] initWithBarButtonItem:self.navigationItem.rightBarButtonItem Options:@[@"新增", @"账户管理"] selectedCallBack:^(NSInteger index) {
        if (0 == index) {
            if ([DataServiceManager sharedManager].isUsingService) {
                ServiceEditGuaranteeSlipViewController * serviceEditGuaranteeSlipViewController = [[ServiceEditGuaranteeSlipViewController alloc] init];
                [serviceEditGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
                    [self.tableView.mj_header beginRefreshing];
                }];
                [self.navigationController pushViewController:serviceEditGuaranteeSlipViewController animated:YES];
            }
            else
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
        }
        else if (1 == index)
        {
            AccountViewController *accountViewController = [[AccountViewController alloc] init];
            [self.navigationController pushViewController:accountViewController animated:YES];
//            [self.tableView setEditing:YES animated:YES];
            
//            [[DataServiceManager sharedManager] uploadImage:[UIImage imageNamed:@"/Users/bjhl/Documents/ios/MyRepository/BaoXingTong/BaoXingTong/BaoXingTong/Resources/default_avatar.png"] progress:^(NSProgress *uploadProgress) {
//            
//            } response:^(ServiceResponseModel *responseModel) {
//                
//            }];
            
            
//            NSString *url = [NSString stringWithFormat:@"%@%@", ipAddress, @"/~yongjie_zou/BaoXingTongPHP/deleteGuaranteeSlips.php"];
//            NSDictionary *params = @{
//                                     @"ids" : @[@(101), @(100), @(102)]
//                                     };
//            
//            [[AFHTTPSessionManager manager] POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
//                
//            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                NSLog(@"%@", responseObject);
//            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSLog(@"%@", error);
//            }];
        }
        
        [self dismissViewControllerAnimated:NO completion:nil];
    } delegate:self];
    
    [self presentViewController:popover animated:YES completion:nil];
}

- (void)share
{
    
//    NSString *folderPath = [[HtmlManager sharedManager] creatHtmlWithGuaranteeSlipModel:self.modelArray[0]];
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *selectedArray = [NSMutableArray new];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [selectedArray addObject:self.modelArray[indexPath.row]];
    }
    
    if (0 == selectedArray.count) {
        [TipView show:@"未选择保单"];
        return;
    }
    
    NSString *filePath = [[PdfManager sharedManager] creatPdfWithModels:selectedArray];
    
    [self.documentInteractionController dismissMenuAnimated:YES];
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.UTI = @"com.adobe.pdf";
    [self.documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 20, 100, 300) inView:self.view animated:YES];
//    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[] applicationActivities:nil];
//    [self presentViewController:vc animated:YES completion:nil];
}

- (void)deleteAll
{
    if ([DataServiceManager sharedManager].isUsingService) {
        NSMutableArray *ids = [NSMutableArray new];
        for (GuaranteeSlipModel *model in self.modelArray) {
            [ids addObject:@(model.guaranteeSlipModelId)];
        }
        
        [[DataServiceManager sharedManager] deleteDataWithIds:ids response:^(ServiceResponseModel *responseModel) {
            
        }];
    }
    else
    {
        for (GuaranteeSlipModel *model in self.modelArray) {
            [[DataManager sharedManager] deleteDataWithModel:model];
        }
    }
    
    [self.modelArray removeAllObjects];
    [self.tableView reloadData];
    [self updateButtonsToMatchTableState];
    [self updateNeedReadNumber];
}

- (void)tapDeleteAllButton
{
    AlterView *alterView = [[AlterView alloc] initWithTitle:@"确认删除所有保单" message:nil sureAction:^{
        [self deleteAll];
        [self cancel];
    } cancelAction:^{
        
    } owner:self];
    [alterView show];
}

- (void)delete
{
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *selectedIndexSet = [NSMutableIndexSet new];
    
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        if ([DataServiceManager sharedManager].isUsingService) {
            [[DataServiceManager sharedManager] deleteDataWithIds:@[@(self.modelArray[indexPath.row].guaranteeSlipModelId)] response:^(ServiceResponseModel *responseModel) {
                
            }];
        }
        else
        {
            [[DataManager sharedManager] deleteDataWithModel:self.modelArray[indexPath.row]];
        }
        [selectedIndexSet addIndex:indexPath.row];
    }
    
    [self.modelArray removeObjectsAtIndexes:selectedIndexSet];
    [self.tableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self updateButtonsToMatchTableState];
    [self updateNeedReadNumber];
}

- (void)tapDeleteButton
{
    AlterView *alterView = [[AlterView alloc] initWithTitle:@"确认删除选择保单" message:nil sureAction:^{
        [self delete];
    } cancelAction:^{
        
    } owner:self];
    [alterView show];
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
        self.rightBarButtonItem.title = @"...";
        [self.rightBarButtonItem setAction:@selector(addGuaranteeSlip)];
        self.rightBarButtonItem.enabled = YES;
    }
}

- (void)updateAvatar:(UIImage *)avatar index:(NSInteger)row
{
    HomeViewTableViewCell *cell = (HomeViewTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:row inSection:0]];
    [cell.imageView setImage:avatar];
}

#pragma mark - 下拉刷新
- (void)onRefresh
{
    WS(weakSelf)
    [[DataServiceManager sharedManager] listOfGuarateeSlips:^(ServiceResponseModel *responseModel) {
        weakSelf.modelArray = [NSMutableArray arrayWithArray:[MTLJSONAdapter modelsOfClass:[GuaranteeSlipModel class] fromJSONArray:responseModel.data error:nil]];
        for (GuaranteeSlipModel *model in weakSelf.modelArray) {
            if (model.avatar.length) {
//                model.avatarImage = [[DataServiceManager sharedManager] getImageWithName:model.avatar];
//                [DataServiceManager sharedManager] getImageWithName:model.avatar response:^(ServiceResponseModel *responseModel) {
//                    
//                };
            }
        }
        weakSelf.blankHomeView.hidden = weakSelf.modelArray.count;
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;     //!!!在iphone下必须实现改代理，否则会pop出一个全屏
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.filteredArray removeAllObjects];
    NSString *keyString = searchController.searchBar.text;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@ or carId contains[c] %@ or insuranceAgent contains[c] %@", keyString, keyString, keyString];
    [self.filteredArray addObjectsFromArray:[self.modelArray filteredArrayUsingPredicate:searchPredicate]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return self.filteredArray.count;
    }
    if (![DataServiceManager sharedManager].isUsingService) {
        self.blankHomeView.hidden = (BOOL)self.modelArray.count;
    }
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HOMEVIEWTABLEVIEWCELL_IDENTIFER forIndexPath:indexPath];
    if (self.searchController.active) {
        if (indexPath.row < self.filteredArray.count) {
            [cell setData:self.filteredArray[indexPath.row]];
            return cell;
        }
    }
    
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
        __block GuaranteeSlipModel *selecteModel = nil;
        if (self.searchController.active && indexPath.row < self.filteredArray.count) {
            selecteModel = self.filteredArray[indexPath.row];
            self.navigationController.navigationBarHidden = NO;
        }
        else if (indexPath.row < self.modelArray.count)
        {
            selecteModel = self.modelArray[indexPath.row];
        }
        
        if (selecteModel) {
            if ([DataServiceManager sharedManager].isUsingService) {
                ServiceEditGuaranteeSlipViewController *vc = [[ServiceEditGuaranteeSlipViewController alloc] initWithModel:selecteModel];
                WS(weakSelf)
                [vc setDidSave:^(GuaranteeSlipModel *model) {
//                    selecteModel.name = model.name;
//                    selecteModel.carId = model.carId;
//                    selecteModel.insuranceAgent = model.insuranceAgent;
//                    selecteModel.avatarImage = model.avatarImage;
//                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView.mj_header beginRefreshing];
                }];
                [vc setDidDelete:^(GuaranteeSlipModel *model) {
                    [weakSelf.modelArray removeObject:model];
                    [weakSelf.tableView reloadData];
                }];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                EditGuaranteeSlipViewController *editGuaranteeSlipViewController = [[EditGuaranteeSlipViewController alloc] initWithModel:selecteModel];
                WS(weakSelf)
                [editGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
                    selecteModel.name = model.name;
                    selecteModel.carId = model.carId;
                    selecteModel.insuranceAgent = model.insuranceAgent;
                    selecteModel.avatarImage = model.avatarImage;
                    [weakSelf.tableView reloadData];
                }];
                [editGuaranteeSlipViewController setDidDelete:^(GuaranteeSlipModel *model) {
                    [weakSelf.modelArray removeObject:model];
                    [weakSelf.tableView reloadData];
                }];
                [self.navigationController pushViewController:editGuaranteeSlipViewController animated:YES];
            }
            [[DataManager sharedManager] resetNotNeedRead:selecteModel.guaranteeSlipModelId];
            [self updateNeedReadNumber];
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

#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect )documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
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
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStylePlain target:self action:@selector(addGuaranteeSlip)];
    }
    return _rightBarButtonItem;
}

- (HomeBottomButton *)bottomButton
{
    if (!_bottomButton) {
        _bottomButton = [HomeBottomButton newAutoLayoutView];
        [_bottomButton.leftButton addTarget:self action:@selector(tapDeleteAllButton) forControlEvents:UIControlEventTouchUpInside];
        [_bottomButton.rightButton addTarget:self action:@selector(tapDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomButton;
}

- (BlankHomeView *)blankHomeView
{
    if (!_blankHomeView) {
        _blankHomeView = [[BlankHomeView alloc] init];
        _blankHomeView.hidden = YES;
        WS(weakSelf);
        [_blankHomeView setTapButton:^{
            if ([DataServiceManager sharedManager].isUsingService) {
                ServiceEditGuaranteeSlipViewController * serviceEditGuaranteeSlipViewController = [[ServiceEditGuaranteeSlipViewController alloc] init];
                [serviceEditGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
                    [weakSelf.tableView.mj_header beginRefreshing];
                }];
                [weakSelf.navigationController pushViewController:serviceEditGuaranteeSlipViewController animated:YES];
                return;
            }
            
            EditGuaranteeSlipViewController *editGuaranteeSlipViewController = [[EditGuaranteeSlipViewController alloc] init];
            [editGuaranteeSlipViewController setDidSave:^(GuaranteeSlipModel *model) {
                if (model) {
                    [weakSelf.modelArray addObject:model];
                    [weakSelf.tableView reloadData];
                }
            }];
            [weakSelf.navigationController pushViewController:editGuaranteeSlipViewController animated:YES];
        }];
    }
    return _blankHomeView;
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
        _tableView.backgroundView = [UIView new];   //Background color for UISearchController in UITableView, 刷新时，背景跳动
        _tableView.backgroundColor = MAIN_BACKGROUND_COLOR;
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
        
        if ([DataServiceManager sharedManager].isUsingService) {       //采用服务器
            return _modelArray;
        }
        
        for (NSNumber *number in self.idsArray) {
            GuaranteeSlipModel *model = [[DataManager sharedManager] getModelWithId:number.integerValue needImages:NO];
            if (model) {                                    //！！！为nil会崩溃
                [_modelArray addObject:model];
            }
        }
    }
    return _modelArray;
}

- (NSMutableArray *)filteredArray
{
    if (!_filteredArray) {
        _filteredArray = [[NSMutableArray alloc] init];
    }
    return _filteredArray;
}

- (void)dealloc
{
    
}

@end
