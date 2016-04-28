//
//  PdfManager.m
//  BaoXingTong
//
//  Created by yongjie_zou on 16/4/28.
//  Copyright © 2016年 yongjie_zou. All rights reserved.
//

#import "PdfManager.h"
#import "GuaranteeSlipModel.h"
#import <CoreText/CoreText.h>
#import "UserModel.h"
#import "DataManager.h"

@implementation PdfManager
static PdfManager *sharedManager;      //这个必须在+ (instancetype)sharedManager方法外声明吗？因为作用域的关系？

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PdfManager alloc] init];
    });
    return sharedManager;
}

- (NSString *)folderPath
{
    NSString *tmpFolder = NSTemporaryDirectory();
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *currentString = [formatter stringFromDate:[NSDate date]];
    UserModel *currentUser = [DataManager sharedManager].currentUser;
    NSString *folderString = [NSString stringWithFormat:@"%@%@%@/", tmpFolder, currentUser.name, currentString];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderString]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderString withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            return nil;
        }
    }
    return folderString;
}

- (NSString *)convertModelToString:(GuaranteeSlipModel *)model
{
    NSString *commercialInsuranceString = @"";
    for (NSString *string in model.commercialInsurance) {
        commercialInsuranceString = [commercialInsuranceString stringByAppendingString:string];
    }
    
    NSString *convertString = [NSString stringWithFormat:@"\
                               姓名：%@\n\
                               身份证：%@\n\
                               手机号码：%@\n\
                               车型：%@\n\
                               车牌号：%@\n\
                               保险公司：%@\n\
                               交强险：%@\n\
                               商业险：%@\n\
                               购买日期：%@\n\
                               购买年限：%@\n\
                               是否到期提醒：%@\n\
                               ", model.name, model.IDcard, model.phone, model.carType, model.carId, model.insuranceAgent, model.hasBoughtForceInsurance ? @"已购买" : @"未购买", commercialInsuranceString, model.boughtDate, model.yearInterval, model.isNeedRemind ? @"是" : @"否"];
    return convertString;
}

- (NSString *)creatPdf:(GuaranteeSlipModel *)model
{
    NSString *fileName = [NSString stringWithFormat:@"%@-%ld.html", model.name, model.guaranteeSlipModelId];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", [self folderPath], fileName];
    
    [self creatPdf:[self convertModelToString:model] filePath:filePath];
    return filePath;
}

- (NSString *)creatPdfWithModels:(NSArray<GuaranteeSlipModel *> *)array
{
    NSString *fileName = @"";
    NSString *text = @"";
    NSInteger i = 0;
    for (GuaranteeSlipModel *model in array) {
        NSString *name;
        if (i++ > 0) {
            name = [NSString stringWithFormat:@"-%@", model.name];
        }
        else
        {
            name = model.name;
        }
        fileName = [NSString stringWithFormat:@"%@%@", fileName, name];
        
        text = [NSString stringWithFormat:@"%@%@\n\n", text, [self convertModelToString:model]];
    };
    fileName = [fileName stringByAppendingString:@".pdf"];
    NSString *filePath = [NSString stringWithFormat:@"%@%@", [self folderPath], fileName];
    [self creatPdf:text filePath:filePath];
    return filePath;
}

- (NSString *)creatPdf:(NSString *)text filePath:(NSString *)filePath
{
    // Prepare the text using a Core Text Framesetter.
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (CFStringRef)text, NULL);
    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            // Create the PDF context using the default page size of 612 x 792.
            UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL done = NO;
            
            do {
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++;
//                [self drawPageNumber:currentPage];
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
//                currentRange = [self renderPageWithTextRange:currentRange andFramesetter:framesetter];
                currentRange = [self renderPage:1 withTextRange:currentRange andFramesetter:framesetter];
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                    done = YES;
            } while (!done);
            
//            NSInteger i = 0;
//            for (UIImage *image in model.imageArray) {
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200 * i++, 0, 200, 200)];
//                [imageView setImage:image];
//                [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
//            }
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            
            // Release the framewetter.
            CFRelease(framesetter);
            
            return filePath;
            
        } else {
            NSLog(@"Could not create the framesetter needed to lay out the atrributed string.");
        }
        // Release the attributed string.
        CFRelease(currentText);
    } else {
        NSLog(@"Could not create the attributed string for the framesetter");
    }
    return nil;
}

- (CFRange)renderPage:(NSInteger)pageNum withTextRange:(CFRange)currentRange
       andFramesetter:(CTFramesetterRef)framesetter
{
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect    frameRect = CGRectMake(72, 72, 468, 648);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef);
    currentRange.location += currentRange.length;
    currentRange.length = 0;
    CFRelease(frameRef);
    
    return currentRange;
}

@end
