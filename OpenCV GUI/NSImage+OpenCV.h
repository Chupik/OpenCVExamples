//
//  NSImage+OpenCV.h
//  OpenCV Labs
//
//  Created by Alexander on 25.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif
#import <AppKit/AppKit.h>

@interface NSImage (NSImage_OpenCV)

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end
