//
//  ServiceResponseModel.h
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/15.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ServiceResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, strong) NSArray *data;

@end
