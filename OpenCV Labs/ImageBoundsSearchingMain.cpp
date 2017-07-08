//
//  ImageBoundsSearchingMain.cpp
//  OpenCV Labs
//
//  Created by Alexander on 18.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

#include "ImageBoundsSearchingMain.hpp"

#include <opencv2/opencv.hpp> 
#include <CoreFoundation/CoreFoundation.h>

using namespace cv;

#define imagePath "/Users/Chupik/Desktop/Xcode Projects/OpenCV Labs/Images/"

int main() {
    // создание окон для отображения
    const char *srcWinName = "src", *contourWinName = "contour";
    char path[100], resPath[100];
    sprintf(path, "%s%s", imagePath, "2.jpg");
    sprintf(resPath, "%s%s", imagePath, "2-copy.jpg");
    
    namedWindow(srcWinName, 1);
    namedWindow(contourWinName, 1);
    
    // загрузка исходного изображения
    Mat src = imread(path, 1);
    if (src.data == 0)
    {
        printf("Incorrect image name or format.\n"); return 1;
    }
    // создание копии исходного изображения
    Mat copy = src.clone();
    // создание одноканального изображения для
    // конвертирования исходного изображения в
    // оттенки серого
    Mat gray, grayThresh;
    cvtColor(src, gray, CV_BGR2GRAY);
    
    //threshold(gray, grayThresh, 120, 255, CV_THRESH_BINARY);
    
    threshold(gray, grayThresh, 100, 255, CV_THRESH_TRIANGLE); //наилучшая, еще OTSU ничего
    // поиск контуров
    std::vector<std::vector<cv::Point> > contours;
    findContours(grayThresh, contours, CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE); // отображение контуров
    
    Scalar color(0, 255, 0);
    drawContours(copy, contours, -1, color, 2); // отображение изображений
    imshow(contourWinName, grayThresh);
    imshow(srcWinName, copy);
    imwrite(resPath, gray);
    // ожидание нажатия какой-либо клавиши
    waitKey(0);
    // освобождение ресурсов
    gray.release();
    grayThresh.release();
    copy.release();
    src.release();
    return 0;
}