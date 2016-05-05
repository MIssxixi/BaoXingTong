//
//  EditGuaranteeSlipViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/20.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "EditGuaranteeSlipViewController.h"
#import "SelectViewController.h"
#import "PopoverController.h"
#import "GuaranteeSlipModel.h"
#import <DoImagePickerController/DoImagePickerController.h>
#import <DoImagePickerController/AssetHelper.h>
#import "TextFieldTableViewCell.h"
#import "ChoseOrEditTableViewCell.h"
#import "ImageFooterView.h"
#import "DataManager.h"
#import "DataServiceManager.h"
#import "TipView.h"
#import "PdfManager.h"

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

@interface EditGuaranteeSlipViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, DoImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate, UIDocumentInteractionControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) GuaranteeSlipModel *model;
@property (nonatomic, strong) NSArray *propertyList;
@property (nonatomic, retain) ImageFooterView *imageFooterView;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation EditGuaranteeSlipViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (instancetype)initWithModel:(GuaranteeSlipModel *)model
{
    self = [super init];
    if (self) {
        self.model = [[DataManager sharedManager] getModelWithId:model.guaranteeSlipModelId needImages:NO];
        
        UIImage *defaultImage = [UIImage imageNamed:@"default_avatar"];
        for (NSString *imageName in self.model.imageNames) {
            [self.model.imageArray addObject:defaultImage];
        }
        [self updateFooterView];
        
        NSInteger item = 0;
        for (;item < self.model.imageNames.count; item++) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                //进入后，快速退出该界面，如何停止这些线程？？
                if ([self isMovingToParentViewController]) {
                    return ;
                }
                UIImage *image = [[DataManager sharedManager] getImage:self.model.imageNames[item]];
                UIImage *resizeImage = [image newImageWithResize:CGSizeMake(100, 100)];
                
                if (resizeImage && item < self.model.imageArray.count) {
                    [self.model.imageArray replaceObjectAtIndex:item withObject:resizeImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.imageFooterView updateImage:resizeImage AtItem:item];
                    });
                }
            });
        }
    }
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
    
    UIBarButtonItem *moreBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStylePlain target:self action:@selector(more)];
    UIBarButtonItem *saveBarButonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(restoreData)];
    NSArray *array;
    if (self.model.guaranteeSlipModelId > 0) {
//        array = @[saveBarButonItem, deleteBarButonItem];
        array = @[moreBarButtonItem, saveBarButonItem];
    }
    else
    {
        array = @[saveBarButonItem];
    }
    self.navigationItem.rightBarButtonItems = array;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:UITABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[ChoseOrEditTableViewCell class] forCellReuseIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER];
//    [self.tableView registerClass:[ImageFooterView class] forHeaderFooterViewReuseIdentifier:IMAGEFOOTERVIEWIDENTIFIER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)share
{
    NSString *filePath = [[PdfManager sharedManager] creatPdf:self.model];
    
    [self.documentInteractionController dismissMenuAnimated:YES];
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    self.documentInteractionController.delegate = self;
    self.documentInteractionController.UTI = @"com.adobe.pdf";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.documentInteractionController presentOpenInMenuFromRect:CGRectMake(0, 20, 100, 300) inView:self.view animated:YES];
    });
}

- (void)more
{
    PopoverController *popoverController = [[PopoverController alloc] initWithBarButtonItem:self.navigationItem.rightBarButtonItem Options:@[@"分享", @"删除"] selectedCallBack:^(NSInteger index) {
        if (0 == index) {
            [self share];
        }
        else if (1 == index)
        {
            [self tapDelete];
        }
        
        [self dismissViewControllerAnimated:NO completion:nil];
    } delegate:self];
    
    [self presentViewController:popoverController animated:YES completion:nil];
}

- (BOOL)checkModelIsTrue
{
    NSPredicate *predicate;
    BOOL result = YES;
    
    {
//        predicate = [NSPredicate predicateWithFormat:@"^[1][3-8]\\d{9}$"];
//        result = [predicate evaluateWithObject:self.model.phone];
//        if (!result) {
//            [TipView show:@"手机号格式不正确"];
//            return result;
//        }
    }
    
    return result;
}

- (void)restoreData
{
    [self.tableView endEditing:YES];
    
    if (0 == self.model.name.length) {
        [TipView show:@"姓名不能为空"];
        return;
    }
    
    if (![self checkModelIsTrue]) {
        return;
    }
    
    if (self.model.isNeedRemind) {
        if (0 == self.model.remindDate.length) {
            [TipView show:@"到期提醒日期为空"];
            return;
        }
        
        if (self.model.remindDate.length < 19) {
            self.model.remindDate = [self.model.remindDate stringByAppendingString:@" 10:00:00"];   //这个地方需要改进
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSTimeInterval currentSec = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval remindSec = [[formatter dateFromString:self.model.remindDate] timeIntervalSince1970];
        if (remindSec <= currentSec && remindSec > 0) {
            [TipView show:@"到期提醒日期已过期"];
            return;
        }
        
//        [[DataManager sharedManager] addLocalNotifaction:self.model.guaranteeSlipModelId fireDate:[formatter dateFromString:self.model.remindDate]];
        [[DataManager sharedManager] addLocalNotifaction:self.model.guaranteeSlipModelId fireDate:[formatter dateFromString:self.model.remindDate]];
    }
    else
    {
        [[DataManager sharedManager] removeLocalNotifaction:self.model.guaranteeSlipModelId];
        self.model.remindDate = nil;
    }

    if (isUsingService) {
        [[DataServiceManager sharedManager] saveDataWithModel:self.model response:^(ServiceResponseModel *responseModel) {
            NSLog(@"%@", responseModel);
        }];
        
        for (UIImage *image in self.model.imageArray) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DataServiceManager sharedManager] uploadImageWithImage:image progress:^(NSProgress *uploadProgress) {
                    
                } response:^(ServiceResponseModel *responseModel) {
                    
                }];
            });
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [[DataManager sharedManager] saveDataWithModel:self.model];
    if (self.didSave) {
        self.didSave(self.model);
    }
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.alertBody = @"你有保单快到期了！";
    localNotification.applicationIconBadgeNumber = 2;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{kLocalNotificationKey: @(self.model.guaranteeSlipModelId)};
    localNotification.category = kNotificationCategoryIdentifile;
    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    
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

- (void)tapDelete
{
    AlterView *alterView = [[AlterView alloc] initWithTitle:@"确认删除该保单" message:nil sureAction:^{
        [self deleteData];
    } cancelAction:^{
        
    } owner:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alterView show];
    });
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
    [self.imageFooterView setImageNames:self.model.imageNames];
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

- (void)updateIsNeedRemind:(UITapGestureRecognizer *)sender
{
    self.model.isNeedRemind = !self.model.isNeedRemind;
    if (self.model.isNeedRemind) {
        [(UIImageView *)sender.view setImage:[UIImage imageNamed:@"check_gray"]];
    }
    else
    {
        [(UIImageView *)sender.view setImage:[UIImage imageNamed:@"uncheck_gray"]];
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
    //cell的block，引用self会循环引用！！！！
//    return [UITableViewCell new];                 //这样退出该页时，回调用dealloc
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
        cell.accessoryView = nil;                       //出现数据混乱，提醒框会出现在其他cell中
        cell.rightTextField.text = nil;                 //出现数据混乱
       
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
            NSInteger i = 0;
            for (NSString *string in self.model.commercialInsurance) {
                NSString *str;
                if (i++ > 0) {
                    str = [NSString stringWithFormat:@"  %@", string];
                }
                else
                {
                    str = string;
                }
                text = [text stringByAppendingString:str];
            }
        }
        else if ([cellId isEqualToString:@"remindDate"]){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TABLEVIEWCELL_HEIGHT_DEFAULT, TABLEVIEWCELL_HEIGHT_DEFAULT)];
            if (self.model.isNeedRemind) {
                [imageView setImage:[UIImage imageNamed:@"check_gray"]];
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:@"uncheck_gray"]];
            }
//            [imageView sizeToFit];
//            imageView.backgroundColor = [UIColor redColor];
            imageView.contentMode = UIViewContentModeRight;
            cell.accessoryView = imageView;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateIsNeedRemind:)];
            cell.accessoryView.userInteractionEnabled = YES;
            [cell.accessoryView addGestureRecognizer:gesture];
            text = [self.model valueForKey:cellId];
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
        
        WS(weakSelf)
        [cell setKeyBoardDidEndEditing:^(NSString *text) {
            if ([weakSelf.model respondsToSelector:NSSelectorFromString(cellId)]) {
                [weakSelf.model setValue:text forKey:cellId];
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
       
        __weak UITableView *weakTable = self.tableView;
        weakifyself;
        [cell setDidTapIndicator:^{
            strongifyself;
            if ([cellId isEqualToString:@"carType"]) {
                SelectViewController *carTypeVC = [[SelectViewController alloc] initWithResourcePath:@"CarTypeList" selectedString:self.model.carType title:@"车型"];
                [carTypeVC setDidSelectedString:^(NSString *selectedString) {
                    if (selectedString.length) {
                        self.model.carType = selectedString;
                        [weakTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic]; //cell和tableview循环引用！！！
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
                        [weakTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }];
                [self.navigationController pushViewController:insuranceAgentVC animated:YES];
            }
        }];
        
        WS(weakSelf)
        [cell setKeyBoardDidEndEditing:^(NSString *text) {
            if ([weakSelf.model respondsToSelector:NSSelectorFromString(cellId)]) {
                [weakSelf.model setValue:text forKey:cellId];
            }
        }];
        
        return cell;
    }
    else
        if ([cellClass isEqualToString:NSStringFromClass([UITableViewCell class])])
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.propertyList[indexPath.row];
    NSInteger selectCellAction = [[dic valueForKey:EDITGUARANTEESLIPLIST_SELECT_CELL_ACTION] integerValue];
    
    if (selectCellAction == SelectCellActionAddPicture) {
        if (self.model.imageArray.count >= 100) {
            [TipView show:@"最多添加100张照片"];
            return;
        }
        
        if (self.model.imageArray.count - self.model.imageNames.count >= 20) {
            [TipView show:@"一次最多添加20张照片"];
            return;
        }
        
        WS(weakSelf);
        UIAlertController *alterController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             DoImagePickerController *doImagePickerController = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
            doImagePickerController.nColumnCount = 3;
            NSInteger canAddCount = 100 - weakSelf.model.imageArray.count;
            doImagePickerController.nMaxCount = canAddCount > 20 ? 20 : canAddCount;
            doImagePickerController.delegate = weakSelf;
            [weakSelf.navigationController pushViewController:doImagePickerController animated:YES];
        }];
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.modalPresentationStyle = UIModalPresentationOverFullScreen;
            imagePickerController.delegate = weakSelf;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [weakSelf presentViewController:imagePickerController animated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alterController dismissViewControllerAnimated:YES completion:nil];
        }];
        [alterController addAction:photoLibraryAction];
        [alterController addAction:cameraAction];
        [alterController addAction:cancelAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alterController animated:YES completion:nil];
        });
    }
    else if (selectCellAction == SelectCellActionForceInsurance)
    {
        WS(weakSelf);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"交强险" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertActionYes = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf updateForceInsurance:YES];
        }];
        UIAlertAction *alertActionNo = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf updateForceInsurance:NO];
        }];
        [alertController addAction:alertActionYes];
        [alertController addAction:alertActionNo];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alertController animated:YES completion:nil];
        });
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

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.model.imageArray addObject:orgImage];
    [self updateFooterView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPopoverPresentationControllerDelegate
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;     //!!!在iphone下必须实现改代理，否则会pop出一个全屏
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tableView endEditing:YES];
}

#pragma mark - DoImagePickerControllerDelegate
- (void)didCancelDoImagePickerController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectPhotosFromDoImagePickerController:(DoImagePickerController *)picker result:(NSArray *)aSelected
{
    [self.model.imageArray addObjectsFromArray:aSelected];
    [picker.navigationController popViewControllerAnimated:YES];
    [self updateFooterView];
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
            //会内存泄漏
            if (index < weakSelf.model.imageArray.count) {
                AlterView *alterView = [[AlterView alloc] initWithTitle:@"确定删除照片吗" message:@"删除后不可复原" sureAction:^{
                    [[DataManager sharedManager] deleteImage:weakSelf.model.imageNames[index]];
                    [weakSelf.model.imageArray removeObjectAtIndex:index];
                    [weakSelf.model.imageNames removeObjectAtIndex:index];
                    [weakSelf updateFooterView];
                } cancelAction:^{
                    
                } owner:weakSelf];
                [alterView show];
            }
        }];
    }
    return _imageFooterView;
}

- (void)dealloc
{
}

@end
