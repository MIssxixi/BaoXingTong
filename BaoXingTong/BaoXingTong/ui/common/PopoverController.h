//
//  PopoverController.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/9.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^selectOptionCallBack)(NSInteger index) ;

@interface PopoverController : UIViewController

@property (nonatomic, copy) selectOptionCallBack callBack;
- (instancetype)initWithBarButtonItem:(UIBarButtonItem *)barButtonItem Options:(NSArray *)items selectedCallBack:(selectOptionCallBack)callBack delegate:(id <UIPopoverPresentationControllerDelegate>)delegate;

@end
