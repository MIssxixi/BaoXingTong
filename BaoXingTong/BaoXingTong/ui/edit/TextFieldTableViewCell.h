//
//  TextFieldTableViewCell.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/20.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextField.h"

typedef NS_ENUM(NSInteger, TextFieldTableViewCellStyle)
{
    TextFieldTableViewCellKeyBoard = 0,
    TextFieldTableViewCellDatePicker = 1,
    TextFieldTableViewCellSelector = 2,
};

@interface TextFieldTableViewCell : UITableViewCell

@property (nonatomic, assign) TextFieldTableViewCellStyle cellStyle;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UITextField *rightTextField;

@property (nonatomic, copy) void (^keyBoardDidBeginEditing)();
@property (nonatomic, copy) void (^keyBoardDidEndEditing)(NSString *text);

@end
