//
//  ChoseOrEditTableViewCell.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/14.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChoseOrEditTableViewCell : UITableViewCell

@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UITextField *rightTextField;

@property (nonatomic, copy) void (^didTapIndicator)();
@property (nonatomic, copy) void (^keyBoardDidEndEditing)(NSString *text);

@end
