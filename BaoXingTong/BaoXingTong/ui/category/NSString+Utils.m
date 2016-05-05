//
//  NSString+Utils.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/5/5.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (BOOL)isPhoneNumber
{
    NSString *regex = @"^1[3578]\\d{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}

- (BOOL)isUserIdCard
{
    NSString *regex = @"(^\\d{15}$)|(^\\d{17}(\\d|x|X)$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:self];
}

- (BOOL)isCarId
{
    NSString *regex = @"^[\u4e00-\u9fa5]{1}[A-Z]{1}[A-Z_0-9]{5}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", regex];
    return [pred evaluateWithObject:self];
}

- (BOOL)isDate
{
    NSString *regex = @"^\\d{4}-\\d{2}-\\d{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", regex];
    return [pred evaluateWithObject:self];
}

@end
