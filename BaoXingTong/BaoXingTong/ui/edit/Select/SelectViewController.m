//
//  SelectViewController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/21.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "SelectViewController.h"
#import "SelectStateView.h"

@interface SelectViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, copy) NSString *resourcePath;
@property (nonatomic, copy) NSString *selectedString;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSString *> *dataArray;
@property (nonatomic, strong) NSMutableArray <NSString *> *selectedArray;

@property (nonatomic, strong) UIView *popBackgroudView;
@property (nonatomic, strong) UITextField *popTextField;

@property (nonatomic, strong) SelectStateView *stateView;

@end

@implementation SelectViewController

- (instancetype)initWithResourcePath:(NSString *)resourcePath selectedString:(NSString *)selectedString title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.resourcePath = resourcePath;
        self.selectedString = selectedString;
        self.title = title;
    }
    return self;
}

- (instancetype)initWithResourcePath:(NSString *)resourcePath selectedArray:(NSArray<NSString *> *)selectedArray title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.resourcePath = resourcePath;
        self.selectedArray = [NSMutableArray arrayWithArray:selectedArray];
        self.title = title;
        [self updateState];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addCarType)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    if (self.canMutilSelect)
    {
        [self.view addSubview:self.tableView];
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        
        [self.view addSubview:self.stateView];
        [self.stateView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [self.stateView autoSetDimension:ALDimensionHeight toSize:44];
        [self.tableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.stateView];
    
        [self.stateView.allButton addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.stateView.configButton addTarget:self action:@selector(confim:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        [self.view addSubview:self.tableView];
        [self.tableView autoPinEdgesToSuperviewEdges];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self restoreData];
}

- (void)selectAll:(id)sender
{
    if (self.stateView.allButton.selected) {
        [self.selectedArray removeAllObjects];
    }
    else
    {
        self.selectedArray = [NSMutableArray arrayWithArray:self.dataArray];
    }
    self.stateView.allButton.selected = !self.stateView.allButton.selected;
    self.stateView.selectedLabel.text = [NSString stringWithFormat:@"已选%ld个", self.selectedArray.count];
    [self.tableView reloadData];
}

- (void)confim:(id)sender
{
    if (self.didSelectedArray) {
        self.didSelectedArray(self.selectedArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateState
{
    if (self.selectedArray.count == self.dataArray.count && self.dataArray.count > 0) {
        self.stateView.allButton.selected = YES;
    }
    else
    {
        self.stateView.allButton.selected = NO;
    }
    self.stateView.selectedLabel.text = [NSString stringWithFormat:@"已选%ld个", self.selectedArray.count];
}

- (void)addCarType
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.popBackgroudView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePopView)];
//    tapGesture.cancelsTouchesInView = NO;       //如果设置为no，点击popTextField的清除按钮，popTextField会消失，即会调用removePopView，如果要设置为no，实现tapGesture.delegate
//    tapGesture.delegate = self;
    [self.popBackgroudView addGestureRecognizer: tapGesture];
    
    [self.popTextField becomeFirstResponder];
    self.popTextField.text = nil;
    [self.popBackgroudView addSubview:self.popTextField];
    [self.popTextField autoCenterInSuperview];
    [self.popTextField autoSetDimensionsToSize:CGSizeMake(SCREEN_WIDTH - PADDING_LR * 2, TABLEVIEWCELL_HEIGHT_DEFAULT)];
}

- (void)removePopView
{
    [self.popBackgroudView removeFromSuperview];
}

- (void)restoreData
{
    [self.dataArray writeToFile:self.filePath atomically:YES];
}

#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isDescendantOfView:self.popTextField]) {
//        return NO;
//    }
//    return YES;   //为啥点击popTextField可以出发，却不调用removePopView
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![self.dataArray containsObject:text] && text.length > 0) {
        [self.dataArray addObject:text];
        [self.popBackgroudView removeFromSuperview];
        [self.tableView reloadData];
        [self restoreData];
        return YES;
    }
    else
    {
        UILabel *errorLabel = [UILabel newAutoLayoutView];
        
        if (text.length) {
            errorLabel.text = @"已存在！";
        }
        else
        {
            errorLabel.text = @"不能为空!";
        }
        errorLabel.textColor = [UIColor redColor];
        [errorLabel sizeToFit];
        errorLabel.backgroundColor = [UIColor whiteColor];
        [[UIApplication sharedApplication].keyWindow addSubview:errorLabel];
        [errorLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self.popTextField];
        [errorLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.popTextField];
        [UIView animateWithDuration:1.5 animations:^{
//            [errorLabel removeFromSuperview];         //这样不会出现@"已存在！"的字样
            errorLabel.alpha = 0;
        }];
        return NO;
    }
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;    //最后一行为@“添加”
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArray.count > indexPath.row) {
        
        cell.textLabel.text = self.dataArray[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        if (self.canMutilSelect) {
            if ([self.selectedArray containsObject:self.dataArray[indexPath.row]]) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_gray"]];
                cell.accessoryView = imageView;
            }
            else
            {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uncheck_gray"]];
                cell.accessoryView = imageView;
            }
        }
        else
        {
             if ([self.selectedString isEqualToString:self.dataArray[indexPath.row]]) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check_gray"]];
                cell.accessoryView = imageView;
            }
            else
            {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"uncheck_gray"]];
                cell.accessoryView = imageView;
            }           
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count > indexPath.row) {
        if (self.canMutilSelect) {
            if ([self.selectedArray containsObject:self.dataArray[indexPath.row]]) {
                [self.selectedArray removeObject:self.dataArray[indexPath.row]];
            }
            else
            {
                [self.selectedArray addObject:self.dataArray[indexPath.row]];
            }
            self.stateView.selectedLabel.text = [NSString stringWithFormat:@"已选%ld个",self.selectedArray.count];
            if (self.selectedArray.count == self.dataArray.count) {
                self.stateView.allButton.selected = YES;
            }
            else
            {
                self.stateView.allButton.selected = NO;
            }
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            if (![self.selectedString isEqualToString:self.dataArray[indexPath.row]]) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                self.selectedString = self.dataArray[indexPath.row];
                if (self.didSelectedString) {
                    self.didSelectedString(self.selectedString);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && self.dataArray.count > indexPath.row) {
        if ([self.selectedString isEqualToString:self.dataArray[indexPath.row]]) {
            self.selectedString = nil;
        }
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - get set
- (NSString *)filePath
{
    if (!_filePath) {
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [pathArray objectAtIndex:0];
        //获取文件的完整路径
        _filePath = [path stringByAppendingPathComponent:[self.resourcePath stringByAppendingString:@".plist"]];
    }
    return _filePath;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [UITableView newAutoLayoutView];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableArray <NSString *> *)dataArray
{
    if (!_dataArray) {
//        _dataArray =[[NSMutableArray alloc] initWithContentsOfFile:self.filePath];   //文件可能为nil 则_dataArray也为nil，无法新增
        _dataArray = [NSMutableArray arrayWithArray:[[NSArray alloc] initWithContentsOfFile:self.filePath]];
        if (self.canMutilSelect) {
            for (NSString *selectedString in self.selectedArray) {
                if (![_dataArray containsObject:selectedString] && selectedString.length > 0) {
                    [_dataArray addObject:selectedString];
                }
            }
        }
        else
        {
            if (![_dataArray containsObject:self.selectedString] && self.selectedString.length > 0) {
                [_dataArray addObject:self.selectedString];
            }
        }
    }
    return _dataArray;
}

- (NSMutableArray <NSString *> *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray new];
    }
    return _selectedArray;
}

- (NSString *)selectedString
{
    if (!_selectedString) {
        _selectedString = [NSString new];
    }
    return _selectedString;
}

- (UIView *)popBackgroudView
{
    if (!_popBackgroudView) {
        _popBackgroudView = [[UIView alloc] initWithFrame:self.view.bounds];
        _popBackgroudView.backgroundColor = COLOR_FROM_RGB(0, 0, 0, 0.6);
//    self.popBackgroudView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.6];    //等效
//    self.popBackgroudView.alpha = 0.6;                                                            //popTextField也会透明
    }
    return _popBackgroudView;
}

- (UITextField *)popTextField
{
    if (!_popTextField) {
        _popTextField = [UITextField newAutoLayoutView];
        _popTextField.placeholder = self.title;
        _popTextField.backgroundColor = [UIColor whiteColor];
        _popTextField.delegate = self;
        _popTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _popTextField.userInteractionEnabled = YES;
    }
    return _popTextField;
}

- (SelectStateView *)stateView
{
    if (!_stateView) {
        _stateView = [[SelectStateView alloc] init];
    }
    return _stateView;
}

@end
