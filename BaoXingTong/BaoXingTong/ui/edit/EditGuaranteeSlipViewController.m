//
//  EditGuaranteeSlipViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/20.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "EditGuaranteeSlipViewController.h"
#import <DoImagePickerController/DoImagePickerController.h>
#import <DoImagePickerController/AssetHelper.h>
#import "TextFieldTableViewCell.h"
#import "ChoseOrEditTableViewCell.h"

typedef NS_ENUM(NSInteger, SelectCellAction) {
    SelectCellActionNone = 0,
    SelectCellActionForceInsurance = 1,
    SelectCellActionCommercialInsurance = 2,
    SelectCellActionExpirationReminder = 3,
    SelectCellActionAddPicture = 4
};

#define EDITGUARANTEESLIPLIST_TITLE @"title"
#define EDITGUARANTEESLIPLISTT_CELL_CLASS @"cellClass"
#define EDITGUARANTEESLIPLIST_CELL_TYPE @"cellType"
#define EDITGUARANTEESLIPLIST_KEYBOARD_TYPE @"keyboardType"
#define EDITGUARANTEESLIPLIST_SELECT_CELL_ACTION @"selectCellAction"

#define TEXTFIELDTABLEVIEWCELLIDENTIFIER @"TEXTFIELDTABLEVIEWCELL"
#define CHOSEOREDITTABLEVIEWCELLIDENTIFIER @"CHOSEOREDITTABLEVIEWCELL"

@interface EditGuaranteeSlipViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, DoImagePickerControllerDelegate>

@property (nonatomic, strong) NSArray *propertyList;
@property (nonatomic, strong) DoImagePickerController *doImagePickerController;

@end

@implementation EditGuaranteeSlipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"编辑保单"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyeboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[ChoseOrEditTableViewCell class] forCellReuseIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyeboardHide:(UIGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.tableView endEditing:YES];
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
    NSString *title = [dic valueForKey:EDITGUARANTEESLIPLIST_TITLE];
    NSString *cellClass = [dic valueForKey:EDITGUARANTEESLIPLISTT_CELL_CLASS];
    NSInteger cellType = [[dic valueForKey:EDITGUARANTEESLIPLIST_CELL_TYPE] integerValue];
    NSInteger keyboardType = [[dic valueForKey:EDITGUARANTEESLIPLIST_KEYBOARD_TYPE] integerValue];
    
    
    if ([cellClass isEqualToString:NSStringFromClass([TextFieldTableViewCell class])]) {
        TextFieldTableViewCell *cell = (TextFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER forIndexPath:indexPath];
        cell.leftLabel.text = title;
        cell.rightTextField.placeholder = title;
        cell.rightTextField.keyboardType = keyboardType;
        cell.cellStyle = cellType;
        
        return cell;
    }
    else if([cellClass isEqualToString:NSStringFromClass([ChoseOrEditTableViewCell class])])
    {
        ChoseOrEditTableViewCell *cell = (ChoseOrEditTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER forIndexPath:indexPath];
        cell.leftLabel.text = title;
        cell.rightTextField.placeholder = title;
        cell.rightTextField.keyboardType = keyboardType;
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

        [self.navigationController pushViewController:self.doImagePickerController animated:YES];
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
    [picker.navigationController popViewControllerAnimated:YES];
}

#pragma mark - get
- (NSArray *)propertyList
{
    if (!_propertyList) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EditGuaranteeSlipList" ofType:@"plist"];
        _propertyList = [NSArray arrayWithContentsOfFile:path];
    }
    return _propertyList;
}

- (DoImagePickerController *)doImagePickerController
{
    if (!_doImagePickerController) {
        _doImagePickerController = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        _doImagePickerController.delegate = self;
        _doImagePickerController.nMaxCount = 4;
        _doImagePickerController.nColumnCount =3 ;
//        _doImagePickerController.nResultType = 1;
    }
    return _doImagePickerController;
}

@end
