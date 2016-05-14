//
//  NSString+Utils.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/5.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

- (NSString *)url;  //字符串可能包含中文

- (NSString *)trim;

- (BOOL)isPhoneNumber;
- (BOOL)isUserIdCard;
- (BOOL)isCarId;
- (BOOL)isDate;     //yyyy-MM-dd

@end
