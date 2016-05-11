//
//  UserModel.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/25.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface UserModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *password;

@end
