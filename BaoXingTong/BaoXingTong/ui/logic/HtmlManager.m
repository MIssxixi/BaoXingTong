//
//  HtmlManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/27.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "HtmlManager.h"
#import "DataManager.h"
#import "GuaranteeSlipModel.h"
#import "UserModel.h"
#import <iOS-htmltopdf/NDHTMLtoPDF.h>

@interface HtmlManager ()

@property (nonatomic, copy) NSString *folderPath;

@end

@implementation HtmlManager

static HtmlManager *sharedManager;      //这个必须在+ (instancetype)sharedManager方法外声明吗？因为作用域的关系？

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HtmlManager alloc] init];
    });
    return sharedManager;
}

- (NSString *)creatHtmlWithGuaranteeSlipModel:(GuaranteeSlipModel *)model
{
    NSString *commercialInsuranceString = @"";
    for (NSString *string in model.commercialInsurance) {
        commercialInsuranceString = [commercialInsuranceString stringByAppendingString:string];
    }
    
    NSString *imagesString = @"";
    for (UIImage *image in model.imageArray) {
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
        NSString *base64String = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        NSString *imageString = [NSString stringWithFormat:@"<img src=\"data:image/png;base64,%@\" width=\"200\" height=\"200\" alt=\"test\" />     ", base64String];
        imagesString = [imagesString stringByAppendingString:imageString];
    }
    

    NSString *html = [NSString stringWithFormat:@"<html><body>\
                      姓名：%@<br>\
                      身份证：%@<br>\
                      手机号码：%@<br>\
                      车型：%@<br>\
                      车牌号：%@<br>\
                      保险公司：%@<br>\
                      交强险：%@<br>\
                      商业险：%@<br>\
                      购买日期：%@<br>\
                      购买年限：%@<br>\
                      是否到期提醒：%@<br>\
                      图片：<br>\
                      %@<br>\
                      </body></html>", model.name, model.IDcard, model.phone, model.carType, model.carId, model.insuranceAgent, model.hasBoughtForceInsurance ? @"已购买" : @"未购买", commercialInsuranceString, model.boughtDate, model.yearInterval, model.isNeedRemind ? @"是" : @"否", imagesString];
    NSString *fileName = [NSString stringWithFormat:@"%@-%ld.html", model.name, model.guaranteeSlipModelId];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.folderPath, fileName];
    
    NSError *error;
    [html writeToFile:filePath atomically:NO encoding:NSUnicodeStringEncoding error:&error];
    return filePath;
}

- (NSString *)creatHtmlWithGuaranteeSlipModels:(NSArray<GuaranteeSlipModel *> *)array
{
    for (GuaranteeSlipModel *model in array) {
        [self creatHtmlWithGuaranteeSlipModel:model];
    }
    return self.folderPath;
}

- (NSString *)creatPdfUsingHtmlWithGuaranteeSlipModel:(GuaranteeSlipModel *)model
{
    NSString *htmlPath = [self creatHtmlWithGuaranteeSlipModel:model];
    
    NSString *pdfPath = [self.folderPath stringByAppendingString:@"/testtt.pdf"];
    
    [NDHTMLtoPDF createPDFWithHTML:htmlPath pathForPDF:pdfPath pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NDHTMLtoPDF *htmlToPDF) {
        
    } errorBlock:^(NDHTMLtoPDF *htmlToPDF) {
        
    }];
    return pdfPath;
}

#pragma mark - get
- (NSString *)folderPath
{
    NSString *tmpFolder = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentString = [formatter stringFromDate:[NSDate date]];
    UserModel *currentUser = [DataManager sharedManager].currentUser;
    NSString *folderString = [NSString stringWithFormat:@"%@%@%@", tmpFolder, currentUser.name, currentString];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderString]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderString withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    return folderString;
}

@end
