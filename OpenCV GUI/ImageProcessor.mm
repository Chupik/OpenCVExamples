//
//  ImageProcessor.m
//  OpenCV Labs
//
//  Created by Alexander on 25.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/ml/ml.hpp>
#import <opencv2/core/core.hpp>
#include <opencv2/imgproc.hpp>
#include "opencv2/imgcodecs.hpp"
#include <opencv2/highgui.hpp>
#include <opencv2/ml.hpp>

#import "NSImage+OpenCV.h"
#endif

using namespace cv;
using namespace cv::ml;

#import "ImageProcessor.h"

@implementation ImageProcessor
@synthesize sourceImage;

-(NSImage *)calculateImageBounds {
    cv::Mat matSourceImage = [[self sourceImage] CVMat];
    cv::Mat gray, grayThresh;
    cvtColor(matSourceImage, gray, CV_BGR2GRAY);
    
    threshold(gray, grayThresh, 100, 255, CV_THRESH_TRIANGLE); //наилучшая, еще OTSU ничего
    // поиск контуров
    std::vector<std::vector<cv::Point> > contours;
    findContours(grayThresh, contours, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE); // отображение контуров
    
    cv::Scalar color(0, 255, 0);
    drawContours(matSourceImage, contours, -1, color, 2); // отображение изображений
    NSImage *result = [NSImage imageWithCVMat:matSourceImage];
    // освобождение ресурсов
    gray.release();
    grayThresh.release();
    matSourceImage.release();
    return result;
}

-(NSImage *)calculateFilter2DImage {
    cv::Mat matSourceImage = [[self sourceImage] CVMat];
    
    const float kernelData[] = {-0.1f, 0.2f, -0.1f,
        0.2f, 3.0f, 0.2f,
        -0.1f, 0.2f, -0.1f};
    const cv::Mat kernel(3, 3, CV_32FC1, (float *)kernelData);
    
    filter2D(matSourceImage, matSourceImage, -1, kernel);
    
    NSImage *result = [NSImage imageWithCVMat:matSourceImage];
    // освобождение ресурсов
    matSourceImage.release();
    return result;
}

-(NSImage *)calculateAntiAlliasedImage {
    cv::Mat matSourceImage = [[self sourceImage] CVMat];
    
    blur(matSourceImage, matSourceImage, cv::Size(5, 5));
    
    NSImage *result = [NSImage imageWithCVMat:matSourceImage];
    // освобождение ресурсов
    matSourceImage.release();
    return result;
}

-(NSImage *)calculateMorphImage {
    cv::Mat matSourceImage = [[self sourceImage] CVMat];
    cv::Mat element;
    
    erode(matSourceImage, matSourceImage, element);
    
    NSImage *result = [NSImage imageWithCVMat:matSourceImage];
    // освобождение ресурсов
    matSourceImage.release();
    element.release();
    return result;
}

-(NSImage *)calculateSobelImage {
    cv::Mat matSourceImage = [[self sourceImage] CVMat];
    cv::Mat grayImg, xGrad, yGrad, xGradAbs, yGradAbs, grad;
    int ddepth = CV_16S;
    double alpha = 0.5, beta = 0.5;
    
    GaussianBlur(matSourceImage, matSourceImage, cv::Size(3,3), 0, 0, BORDER_DEFAULT);
    
    cvtColor(matSourceImage, grayImg, CV_RGB2GRAY);
    
    Sobel(grayImg, xGrad, ddepth, 1, 0); // по Ox
    Sobel(grayImg, yGrad, ddepth, 0, 1); // по Oy
    // преобразование градиентов в 8-битные
    convertScaleAbs(xGrad, xGradAbs);
    convertScaleAbs(yGrad, yGradAbs);
    // поэлементное вычисление взвешенной
    // суммы двух массивов
    addWeighted(xGradAbs, alpha, yGradAbs, beta, 0, grad);
    
    NSImage *result = [NSImage imageWithCVMat:grad];
    // освобождение ресурсов
    matSourceImage.release();
    grayImg.release();
    xGrad.release();
    yGrad.release();
    xGradAbs.release();
    yGradAbs.release();
    grad.release();
    return result;
}

-(NSImage *)calculateLaplasImage {
    cv::Mat img = [[self sourceImage] CVMat], grayImg, laplacianImg, laplacianImgAbs;
    int ddepth = CV_16S;
    // сглаживание с помощью фильтра Гаусса
    GaussianBlur(img, img, cv::Size(3,3), 0, 0, BORDER_DEFAULT);
    // преобразование в оттенки серого
    cvtColor(img, grayImg, CV_RGB2GRAY);
    // применение оператора Лапласа
    Laplacian(grayImg, laplacianImg, ddepth);
    convertScaleAbs(laplacianImg, laplacianImgAbs);
    // отображение результата
    NSImage *result = [NSImage imageWithCVMat:laplacianImgAbs];
    img.release();
    grayImg.release();
    laplacianImgAbs.release();
    laplacianImg.release();
    return result;
}

-(NSImage *)calculateKanniImage {
    cv::Mat img = [[self sourceImage] CVMat], grayImg, edgesImg;
    double lowThreshold = 70, uppThreshold = 260;
    // удаление шумов
    blur(img, img, cv::Size(3,3));
    // преобразование в оттенки серого
    cvtColor(img, grayImg, CV_RGB2GRAY);
    // применение детектора Канни
    Canny(grayImg, edgesImg, lowThreshold, uppThreshold);
    NSImage *result = [NSImage imageWithCVMat:edgesImg];
    img.release();
    grayImg.release();
    edgesImg.release();
    return result;
}

-(NSImage *)calculateHistogram {
    Mat img = [[self sourceImage] CVMat], bHist, gHist, rHist, histImg;
    std::vector<cv::Mat> bgrChannels(3);
    int kBins = 256; // количество бинов гистограммы
    // интервал изменения значений бинов
    float range[] = {0.0f, 256.0f};
    const float* histRange = { range };
    // равномерное распределение интервала по бинам
    bool uniform = true;
    // запрет очищения перед вычислением гистограммы
    bool accumulate = false;
    // размеры для отображения гистограммы
    int histWidth = 512, histHeight = 400;
    // количество пикселей на бин
    int binWidth = cvRound((double)histWidth / kBins);
    int i, kChannels = 3;
    Scalar colors[] = {Scalar(255, 0, 0), Scalar(0, 255, 0), Scalar(0, 0, 255)};
    // выделение каналов изображения
    split(img, bgrChannels);
    // вычисление гистограммы для каждого канала
    calcHist(&bgrChannels[0], 1, 0, Mat(), bHist, 1, &kBins, &histRange, uniform, accumulate);
    calcHist(&bgrChannels[1], 1, 0, Mat(), gHist, 1, &kBins, &histRange, uniform, accumulate);
    calcHist(&bgrChannels[2], 1, 0, Mat(), rHist, 1, &kBins, &histRange, uniform, accumulate);
    // построение гистограммы
    histImg = Mat(histHeight, histWidth, CV_8UC3, Scalar(0, 0, 0));
    // нормализация гистограмм в соответствии с размерам
    // окна для отображения
    normalize(bHist, bHist, 0, histImg.rows, NORM_MINMAX, -1, Mat());
    normalize(gHist, gHist, 0, histImg.rows, NORM_MINMAX, -1, Mat());
    normalize(rHist, rHist, 0, histImg.rows, NORM_MINMAX, -1, Mat());
    // отрисовка ломаных
    for (i = 1; i < kBins; i++) {
        line(histImg, cv::Point(binWidth * (i-1), histHeight-cvRound(bHist.at<float>(i-1))), cv::Point(binWidth * i, histHeight-cvRound(bHist.at<float>(i)) ), colors[0], 2, 8, 0);
        line(histImg, cv::Point(binWidth * (i-1), histHeight-cvRound(gHist.at<float>(i-1))), cv::Point(binWidth * i, histHeight-cvRound(gHist.at<float>(i)) ), colors[1], 2, 8, 0);
        line(histImg, cv::Point(binWidth * (i-1), histHeight-cvRound(rHist.at<float>(i-1))), cv::Point(binWidth * i, histHeight-cvRound(rHist.at<float>(i)) ), colors[2], 2, 8, 0);
    }
    // осовобождение памяти img.release();
    for (i = 0; i < kChannels; i++) {
        bgrChannels[i].release();
    }
    NSImage *result = [NSImage imageWithCVMat:histImg];
    bHist.release();
    gHist.release();
    rHist.release();
    histImg.release();
    return result;
}

int f(Mat sample)
{
    return (int)((sample.at<float>(0) < 0.5f && sample.at<float>(1) < 0.5f) || (sample.at<float>(0) > 0.5f && sample.at<float>(1) > 0.5f));
}

-(NSImage *)caclulateSVMTree {
    // Data for visual representation
    int width = 512, height = 512;
    Mat image = Mat::zeros(height, width, CV_8UC3);
    // Set up training data
    int labels[4] = {1, -1, -1, -1};
    float trainingData[4][2] = { {501, 10}, {255, 10}, {501, 255}, {10, 501} };
    
    
    Mat trainingDataMat(4, 2, CV_32FC1, trainingData);
    Mat labelsMat(4, 1, CV_32SC1, labels);
    // Train the SVM
    Ptr<SVM> svm = SVM::create();
    svm->setType(SVM::C_SVC);
    svm->setKernel(SVM::LINEAR);
    svm->setTermCriteria(TermCriteria(TermCriteria::MAX_ITER, 100, 1e-6));
    svm->train(trainingDataMat, ROW_SAMPLE, labelsMat);
    // Show the decision regions given by the SVM
    Vec3b green(0,255,0), blue (255,0,0);
    for (int i = 0; i < image.rows; ++i)
        for (int j = 0; j < image.cols; ++j)
        {
            Mat sampleMat = (Mat_<float>(1,2) << j,i);
            float response = svm->predict(sampleMat);
            if (response == 1)
                image.at<Vec3b>(i,j)  = green;
            else if (response == -1)
                image.at<Vec3b>(i,j)  = blue;
        }
    // Show the training data
    int thickness = -1;
    int lineType = 8;
    circle( image, cv::Point(501,  10), 5, Scalar(  0,   0,   0), thickness, lineType );
    circle( image, cv::Point(255,  10), 5, Scalar(255, 255, 255), thickness, lineType );
    circle( image, cv::Point(501, 255), 5, Scalar(255, 255, 255), thickness, lineType );
    circle( image, cv::Point( 10, 501), 5, Scalar(255, 255, 255), thickness, lineType );
    // Show support vectors
    thickness = 2;
    lineType  = 8;
    Mat sv = svm->getUncompressedSupportVectors();
    for (int i = 0; i < sv.rows; ++i)
    {
        const float* v = sv.ptr<float>(i);
        circle( image,  cv::Point( (int) v[0], (int) v[1]),   6,  Scalar(128, 128, 128), thickness, lineType);
    }
    NSImage *result = [NSImage imageWithCVMat:image];
    image.release();
    svm.release();
    trainingDataMat.release();
    labelsMat.release();
    
    return result;
}

-(NSImage *)calculateImproveHistogram {
    cv::Mat matSourceImage = [[self sourceImage] CVMat], grayImg, equalizedImg;
    
    cvtColor(matSourceImage, grayImg, CV_RGB2GRAY);
    // выравнивание гистограммы
    equalizeHist(grayImg, equalizedImg);
    
    NSImage *result = [NSImage imageWithCVMat:equalizedImg];
    // освобождение ресурсов
    matSourceImage.release();
    grayImg.release();
    equalizedImg.release();
    return result;
}


@end
