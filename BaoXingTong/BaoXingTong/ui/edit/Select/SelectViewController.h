//
//  SelectViewController.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/3/21.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectViewController : UIViewController

@property (nonatomic, assign) BOOL canMutilSelect;
@property (nonatomic, copy) void (^didSelectedString)(NSString *selectedString);
@property (nonatomic, copy) void (^didSelectedArray)(NSArray <NSString *> *selectedArray);

- (instancetype)initWithResourcePath:(NSString *)resourcePath selectedString:(NSString *)selectedString title:(NSString *)title;
- (instancetype)initWithResourcePath:(NSString *)resourcePath selectedArray:(NSArray <NSString *> *)selectedArray title:(NSString *)title;

@end
