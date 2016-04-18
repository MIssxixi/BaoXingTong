//
//  EditGuaranteeSlipViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/20.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "EditGuaranteeSlipViewController.h"
#import "SelectViewController.h"
#import "GuaranteeSlipModel.h"
#import <DoImagePickerController/DoImagePickerController.h>
#import <DoImagePickerController/AssetHelper.h>
#import "TextFieldTableViewCell.h"
#import "ChoseOrEditTableViewCell.h"
#import "ImageFooterView.h"
#import "DataManager.h"
#import "DataServiceManager.h"
#import "TipView.h"

typedef NS_ENUM(NSInteger, SelectCellAction) {
    SelectCellActionNone = 0,
    SelectCellActionForceInsurance = 1,
    SelectCellActionCommercialInsurance = 2,
    SelectCellActionExpirationReminder = 3,
    SelectCellActionAddPicture = 4,
};

#define EDITGUARANTEESLIPLIST_ID @"id"
#define EDITGUARANTEESLIPLIST_TITLE @"title"
#define EDITGUARANTEESLIPLISTT_CELL_CLASS @"cellClass"
#define EDITGUARANTEESLIPLIST_CELL_TYPE @"cellType"
#define EDITGUARANTEESLIPLIST_KEYBOARD_TYPE @"keyboardType"
#define EDITGUARANTEESLIPLIST_SELECT_CELL_ACTION @"selectCellAction"

#define UITABLEVIEWCELLIDENTIFIER @"UITABLEVIEWCELL"
#define TEXTFIELDTABLEVIEWCELLIDENTIFIER @"TEXTFIELDTABLEVIEWCELL"
#define CHOSEOREDITTABLEVIEWCELLIDENTIFIER @"CHOSEOREDITTABLEVIEWCELL"
#define IMAGEFOOTERVIEWIDENTIFIER @"IMAGEFOOTERVIEW"

@interface EditGuaranteeSlipViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, DoImagePickerControllerDelegate>

@property (nonatomic, strong) GuaranteeSlipModel *model;
@property (nonatomic, strong) NSArray *propertyList;
@property (nonatomic, strong) ImageFooterView *imageFooterView;

@end

@implementation EditGuaranteeSlipViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateFooterView];
}

- (instancetype)initWithModel:(GuaranteeSlipModel *)model
{
    self = [super init];
    self.model = model;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"编辑保单"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyeboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UIBarButtonItem *saveBarButonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(restoreData)];
    UIBarButtonItem *deleteBarButonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteData)];
    NSArray *array;
    if (self.model.guaranteeSlipModelId > 0) {
        array = @[saveBarButonItem, deleteBarButonItem];
    }
    else
    {
        array = @[saveBarButonItem];
    }
    self.navigationItem.rightBarButtonItems = array;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:UITABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[ChoseOrEditTableViewCell class] forCellReuseIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[ImageFooterView class] forHeaderFooterViewReuseIdentifier:IMAGEFOOTERVIEWIDENTIFIER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restoreData
{
    [self.tableView endEditing:YES];
    
    if (0 == self.model.name.length) {
        [TipView show:@"姓名不能为空"];
        return;
    }
    
    [[DataServiceManager sharedManager] saveDataWithModel:self.model response:^(ServiceResponseModel *responseModel) {
        
    }];
    
    [[DataManager sharedManager] saveDataWithModel:self.model];
    if (self.didSave) {
        self.didSave(self.model);
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"你有保单快到期了！";
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{kLocalNotificationKey: @(self.model.guaranteeSlipModelId)};
    localNotification.category = kNotificationCategoryIdentifile;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteData
{
    [self.tableView endEditing:YES];
    
    [[DataManager sharedManager] deleteDataWithId:self.model.guaranteeSlipModelId];
    if (self.didDelete) {
        self.didDelete(self.model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)keyeboardHide:(UIGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.tableView endEditing:YES];
    }
}

- (void)updateFooterView
{
    [self.imageFooterView setImageArray:self.model.imageArray];
    CGRect rect = self.imageFooterView.frame;
    rect.size.height = [ImageFooterView heightWithImageArray:self.model.imageArray];
    self.imageFooterView.frame = rect;
    self.tableView.tableFooterView = self.imageFooterView;
}

- (void)updateForceInsurance:(BOOL)hasBought
{
    self.model.hasBoughtForceInsurance = hasBought;
    [self.tableView reloadData];
}

- (void)updateExpirationReminder:(BOOL)needReminder
{
    self.model.isNeedRemind = needReminder;
    [self.tableView reloadData];
    
    if (needReminder) {
//        if (!self.model.boughtDate.length) {
//            [TipView show:@"请先填写购买日期"];
//            return;
//        }
//        else if (!self.model.yearInterval.length)
//        {
//            [TipView show:@"请先填写购买年限"];
//            return;
//        }
        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        dateFormatter.dateFormat = @"yyyy-MM-dd";
//        NSDate *date = [dateFormatter dateFromString:self.model.boughtDate];
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:date];
//        components.hour = 10;
//        date = [calendar dateFromComponents:components];
//        NSTimeInterval sec = [date timeIntervalSince1970] - 1;
        
        
    }
    else
    {
        
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.propertyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic;
    if (self.propertyList.count > indexPath.row) {
        dic = self.propertyList[indexPath.row];
    }
    NSString *cellId = [dic valueForKey:EDITGUARANTEESLIPLIST_ID];
    NSString *title = [dic valueForKey:EDITGUARANTEESLIPLIST_TITLE];
    NSString *cellClass = [dic valueForKey:EDITGUARANTEESLIPLISTT_CELL_CLASS];
    NSInteger cellType = [[dic valueForKey:EDITGUARANTEESLIPLIST_CELL_TYPE] integerValue];
    NSInteger keyboardType = [[dic valueForKey:EDITGUARANTEESLIPLIST_KEYBOARD_TYPE] integerValue];
    
    
    if ([cellClass isEqualToString:NSStringFromClass([TextFieldTableViewCell class])]) {
        TextFieldTableViewCell *cell = (TextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER forIndexPath:indexPath];
       
        NSString *text = [NSString string];             //= [self.model valueForKey:cellId];
        if ([cellId isEqualToString:@"hasBoughtForceInsurance"]) {
            if (self.model.hasBoughtForceInsurance) {
                text = @"已购买";
            }
            else
            {
                text = @"未购买";
            }
        }
        else if ([cellId isEqualToString:@"commercialInsurance"]) {
            for (NSString *string in self.model.commercialInsurance) {
                text = [text stringByAppendingString:string];
            }
        }
        else
        {
            text = [self.model valueForKey:cellId];
        }
        
        if (text.length > 0) {
            cell.rightTextField.text = text;
        }
        
        cell.leftLabel.text = title;
        cell.rightTextField.placeholder = title;
        cell.rightTextField.keyboardType = keyboardType;
        cell.cellStyle = cellType;
        
        [cell setKeyBoardDidEndEditing:^(NSString *text) {
            if ([self.model respondsToSelector:NSSelectorFromString(cellId)]) {
                [self.model setValue:text forKey:cellId];
            }
        }];
        
        return cell;
    }
    else if([cellClass isEqualToString:NSStringFromClass([ChoseOrEditTableViewCell class])])
    {
        ChoseOrEditTableViewCell *cell = (ChoseOrEditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER forIndexPath:indexPath];
        cell.leftLabel.text = title;
        
        if ([[self.model valueForKey:cellId] isKindOfClass:[NSString class]]) {
            cell.rightTextField.text = [self.model valueForKey:cellId];
        }
        cell.rightTextField.placeholder = title;
        cell.rightTextField.keyboardType = keyboardType;
        
        [cell setDidTapIndicator:^{
            if ([cellId isEqualToString:@"carType"]) {
                SelectViewController *carTypeVC = [[SelectViewController alloc] initWithResourcePath:@"CarTypeList" selectedString:self.model.carType title:@"车型"];
                [carTypeVC setDidSelectedString:^(NSString *selectedString) {
                    if (selectedString.length) {
                        self.model.carType = selectedString;
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }];
                [self.navigationController pushViewController:carTypeVC animated:YES];
            }
            else if ([cellId isEqualToString:@"insuranceAgent"])
            {
                SelectViewController *insuranceAgentVC = [[SelectViewController alloc] initWithResourcePath:@"InsuranceAgentList" selectedString:self.model.insuranceAgent title:@"保险公司"];
                [insuranceAgentVC setDidSelectedString:^(NSString *selectedString) {
                    if (selectedString.length) {
                        self.model.insuranceAgent = selectedString;
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }];
                [self.navigationController pushViewController:insuranceAgentVC animated:YES];
            }
        }];
        
        [cell setKeyBoardDidEndEditing:^(NSString *text) {
            if ([self.model respondsToSelector:NSSelectorFromString(cellId)]) {
                [self.model setValue:text forKey:cellId];
            }
        }];
        
        return cell;
    }
    else if ([cellClass isEqualToString:NSStringFromClass([UITableViewCell class])])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITABLEVIEWCELLIDENTIFIER forIndexPath:indexPath];
        cell.textLabel.font = FONT(15);
        cell.textLabel.textColor = COLOR_FROM_RGB(99, 99, 99, 1);
        cell.textLabel.text = title;
        cell.indentationLevel = 1;
        cell.indentationWidth = 0;
        
        if ([cellId isEqualToString:@"isNeedRemind"]) {
            UIImageView *imageView = [[UIImageView alloc] init];
            if (self.model.isNeedRemind) {
                [imageView setImage:[UIImage imageNamed:@"check_gray"]];
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:@"uncheck_gray"]];
            }
            [imageView sizeToFit];
            cell.accessoryView = imageView;
        }
//        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEWCELL_HEIGHT_DEFAULT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.propertyList[indexPath.row];
    NSInteger selectCellAction = [[dic valueForKey:EDITGUARANTEESLIPLIST_SELECT_CELL_ACTION] integerValue];
    
    if (selectCellAction == SelectCellActionAddPicture) {
        DoImagePickerController *doImagePickerController = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        doImagePickerController.nColumnCount = 3;
        doImagePickerController.nMaxCount = -1;
        doImagePickerController.delegate = self;
        [self.navigationController pushViewController:doImagePickerController animated:YES];
    }
    else if (selectCellAction == SelectCellActionForceInsurance)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"交强险" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertActionYes = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateForceInsurance:YES];
        }];
        UIAlertAction *alertActionNo = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateForceInsurance:NO];
        }];
        [alertController addAction:alertActionYes];
        [alertController addAction:alertActionNo];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (selectCellAction == SelectCellActionCommercialInsurance)
    {
        SelectViewController *selectVC = [[SelectViewController alloc] initWithResourcePath:@"CommercialInsurance" selectedArray:self.model.commercialInsurance title:@"商业险"];
        selectVC.canMutilSelect = YES;
        [selectVC setDidSelectedArray:^(NSArray <NSString *> *selectedArray) {
            if (selectedArray.count) {
                self.model.commercialInsurance = selectedArray;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        [self.navigationController pushViewController:selectVC animated:YES];
    }
    else if (selectCellAction == SelectCellActionExpirationReminder)
    {
        [self updateExpirationReminder:!self.model.isNeedRemind];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tableView endEditing:YES];
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self.model.imageArray addObjectsFromArray:aSelected];
    [picker.navigationController popViewControllerAnimated:YES];
    [self.tableView reloadData];
}

#pragma mark - get
- (GuaranteeSlipModel *)model
{
    if (!_model) {
        _model = [[GuaranteeSlipModel alloc] init];
    }
    return _model;
}

- (NSArray *)propertyList
{
    if (!_propertyList) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EditGuaranteeSlipList" ofType:@"plist"];
        _propertyList = [NSArray arrayWithContentsOfFile:path];
    }
    return _propertyList;
}

- (ImageFooterView *)imageFooterView
{
    if (!_imageFooterView) {
        _imageFooterView = [[ImageFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [ImageFooterView heightWithImageArray:self.model.imageArray])];
        __weak typeof (self) weakSelf = self;
        [_imageFooterView setDidDeleteAction:^(NSInteger index) {
            if (index < self.model.imageArray.count) {
                [weakSelf.model.imageArray removeObjectAtIndex:index];
                [weakSelf updateFooterView];
            }
        }];
    }
    return _imageFooterView;
}

@end
