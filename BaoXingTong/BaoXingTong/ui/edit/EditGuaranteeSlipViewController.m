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

@interface EditGuaranteeSlipViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *propertyList;

@end

@implementation EditGuaranteeSlipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
//    [self.view addSubview:self.tableView];
//    [self.tableView autoPinEdgesToSuperviewEdges];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyeboardHide)];
//    tapGestureRecognizer.delegate = self;
//    [self.view addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self setTitle:@"编辑保单"];
    [self.tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER];
    [self.tableView registerClass:[ChoseOrEditTableViewCell class] forCellReuseIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyeboardHide
{
//    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.tableView endEditing:YES];
    self.tableView.contentSize = self.view.frame.size;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
//    }
}

- (void)keyHide
{
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
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
        
        __weak TextFieldTableViewCell *weakCell = cell;
        [weakCell setKeyBoardDidBeginEditing:^{
//            UIEdgeInsets edgeInsets = tableView.contentInset;
//            edgeInsets.bottom = weakCell.rightTextField.inputView.bounds.size.height + weakCell.rightTextField.inputAccessoryView.bounds.size.height;
//            [tableView setContentInset:edgeInsets];
//            CGPoint contenOffset = tableView.contentOffset;
//            CGPoint pointInTable = [weakCell convertPoint:weakCell.frame.origin toView:tableView];
//            contenOffset.y = 100;
//            [tableView setContentOffset:contenOffset animated:YES];
        }];
        
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
        DoImagePickerController *doImagePickerController = [[DoImagePickerController alloc] initWithNibName:@"DoImagePickerController" bundle:nil];
        doImagePickerController.delegate = self;
        doImagePickerController.nMaxCount = 4;
        doImagePickerController.nColumnCount =3 ;
        doImagePickerController.nResultType = 1;
        [self.navigationController pushViewController:doImagePickerController animated:YES];
    }
    
//    [self keyeboardHide];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    [self.tableView endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tableView endEditing:YES];
}

#pragma mark - get
//- (UITableView *)tableView
//{
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
//        [_tableView registerClass:[TextFieldTableViewCell class] forCellReuseIdentifier:TEXTFIELDTABLEVIEWCELLIDENTIFIER];
//        [_tableView registerClass:[ChoseOrEditTableViewCell class] forCellReuseIdentifier:CHOSEOREDITTABLEVIEWCELLIDENTIFIER];
//        _tableView.backgroundColor = [UIColor whiteColor];
//        _tableView.delegate = self;
//        _tableView.dataSource = self;
//    }
//    return _tableView;
//}

- (NSArray *)propertyList
{
    if (!_propertyList) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EditGuaranteeSlipList" ofType:@"plist"];
        _propertyList = [NSArray arrayWithContentsOfFile:path];
    }
    return _propertyList;
}
@end
