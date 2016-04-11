//
//  PopoverController.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/9.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "PopoverController.h"

@interface PopoverController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *items;

@end

@implementation PopoverController

- (instancetype)initWithBarButtonItem:(UIBarButtonItem *)barButtonItem Options:(NSArray *)items selectedCallBack:(selectOptionCallBack)callBack delegate:(id <UIPopoverPresentationControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.barButtonItem = barButtonItem;
        self.items = items;
        self.callBack = callBack;
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.preferredContentSize = CGSizeMake(100, 44 * self.items.count);
        self.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        self.popoverPresentationController.barButtonItem = self.barButtonItem;
        self.popoverPresentationController.delegate = delegate; //popoverPresentationController什么时候初始化，如果最先设置delegate，这时popoverPresentationController为nil，会设置不成功
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView autoPinEdgesToSuperviewEdges];
}

#pragma mark - UITalbeViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.items[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.callBack) {
        self.callBack(indexPath.row);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - get
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
