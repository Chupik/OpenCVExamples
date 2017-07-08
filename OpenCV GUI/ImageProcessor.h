//
//  ImageProcessor.h
//  OpenCV Labs
//
//  Created by Alexander on 25.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageProcessor : NSObject

@property (nonatomic, strong) NSImage *sourceImage;

-(NSImage *)calculateImageBounds;
-(NSImage *)calculateFilter2DImage;
-(NSImage *)calculateAntiAlliasedImage;
-(NSImage *)calculateMorphImage;
-(NSImage *)calculateSobelImage;
-(NSImage *)calculateLaplasImage;
-(NSImage *)calculateKanniImage;
-(NSImage *)calculateHistogram;
-(NSImage *)calculateImproveHistogram;

-(NSImage *)caclulateSVMTree;

@end
