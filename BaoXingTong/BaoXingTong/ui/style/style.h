//
//  style.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/2/23.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#ifndef style_h
#define style_h

#define SCREEN_WIDTH     ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT    ([UIScreen mainScreen].bounds.size.height)

#pragma mark - font
#define FONT(size)      [UIFont systemFontOfSize:size]

#pragma mark - 高度
#define TABLEVIEWCELL_HEIGHT_DEFAULT 54  //列表条目的默认高度
#define BUTTON_HEIGHT 54

#pragma mark - 通用边距
#define PADDING_LR      20      //// 通用的左右边距

#define AVATAR_SIZE   CGSizeMake(44, 44)

#define MAIN_BACKGROUND_COLOR [UIColor colorWithHexString:@"f0f0f0"]
#define MAIN_BLUE_COLOR [UIColor colorWithHexString:@"00ccff"]
#define LINE_GRAY_COLOR [UIColor colorWithHexString:@"dddddd"].CGColor

#endif /* style_h */
