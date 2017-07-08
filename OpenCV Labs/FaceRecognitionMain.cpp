//
//  main.cpp
//  OpenCV Labs
//
//  Created by Alexander on 18.09.16.
//  Copyright © 2016 Alexander Kochupalov. All rights reserved.
//

#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/ocl.hpp>
#include <CoreFoundation/CoreFoundation.h>
#import <pthread/pthread.h>

using namespace cv;

#define DELAY 10
#define ESC_KEY 27
#define modelsPath "/Library/opencv-data/haarcascades/"
#define videosPath "/Users/Chupik/Desktop/Xcode Projects/OpenCV Labs/Videos/"


const char* helper =
"02_FaceDetection.exe <model_file> [<video>]\n \t<model_file> - model file name\n\
\t<video> - video file name (video stream will \n\
be taken from web-camera by default)\n ";

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

int main(int argc, char * argv[]) {
    // insert code here...
    //ocl::setUseOpenCL(true);
    const char* winName = "video";
    char *videoFileName = 0, *originalString = 0, path[100], eyePath[100], eyeGlassPath[100], profilePath[100], videoPath[100];
    __block int i;
    __block char key = -1;
    Mat *image = new Mat(), *gray = new Mat();
    VideoCapture *capture = new VideoCapture();
    std::vector<cv::Rect> *frontObjects = new std::vector<cv::Rect>(), *profileObjects = new std::vector<cv::Rect>(), *eyeObjects = new std::vector<cv::Rect>();
    std::vector<cv::Rect> *currentFrontObjects = new std::vector<cv::Rect>(), *currentProfileObjects = new std::vector<cv::Rect>(), *currentEyeObjects = new std::vector<cv::Rect>();
    
    
    if (argc < 2) {
        printf("%s", helper);
        return 1;
    }
    
    originalString = argv[1];
    
    sprintf(path, "%s%s", modelsPath, originalString);
    sprintf(profilePath, "%s%s", modelsPath, "haarcascade_profileface.xml");
    sprintf(eyePath, "%s%s", modelsPath, "haarcascade_eye.xml");
    sprintf(eyeGlassPath, "%s%s", modelsPath, "haarcascade_eye_tree_eyeglasses.xml");
    sprintf(videoPath, "%s%s", videosPath, "video.mov");
    
    if (argc > 2)
    {
        videoFileName = argv[2];
    }
    // создание классификатора и загрузка модели
    __block CascadeClassifier frontCascade;
    __block CascadeClassifier profileCascade;
    __block CascadeClassifier eyesCascade;
    
    frontCascade.load(path);
    profileCascade.load(profilePath);
    eyesCascade.load(eyePath);
    //cascade.load(eyeGlassPath);
    // загрузка видеофайла или перехват видеопотока
    if (videoFileName == 0)
    {
        capture->open(0);
    }
    else {
        capture->open(videoFileName);
    }
    
    if (!capture->isOpened()) {
        printf("Incorrect capture name.\n");
        return 1;
    }
    // создание окна для отображения видео
    namedWindow(winName);
    
    cv::Size inputSize = cv::Size((int) capture->get(CV_CAP_PROP_FRAME_WIDTH),
                  (int) capture->get(CV_CAP_PROP_FRAME_HEIGHT));
    
    VideoWriter *outputStream = new VideoWriter();
    
    outputStream->open(videoPath, CV_FOURCC('m','p','4','v'), 5, inputSize, true);
    
    if (!outputStream->isOpened()) {
        printf("Can not open output stream.\n");
        return -1;
    }
    
    // получение кадра видеопотока
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (key != ESC_KEY) {
            pthread_mutex_lock(&mutex);
            *capture >> *image;
            for (i = 0; i < frontObjects->size(); i++)
            {
                rectangle(*image, cv::Point(frontObjects->data()[i].x, frontObjects->data()[i].y), cv::Point(frontObjects->data()[i].x + frontObjects->data()[i].width,frontObjects->data()[i].y + frontObjects->data()[i].height), CV_RGB(255, 0, 0), 2);
            }
            for (i = 0; i < profileObjects->size(); i++)
            {
                rectangle(*image, cv::Point(profileObjects->data()[i].x, profileObjects->data()[i].y), cv::Point(profileObjects->data()[i].x+profileObjects->data()[i].width, profileObjects->data()[i].y+profileObjects->data()[i].height), CV_RGB(0, 0, 255), 2);
            }
            for (i = 0; i < eyeObjects->size(); i++)
            {
                rectangle(*image, cv::Point(eyeObjects->data()[i].x, eyeObjects->data()[i].y), cv::Point(eyeObjects->data()[i].x+eyeObjects->data()[i].width, eyeObjects->data()[i].y+eyeObjects->data()[i].height), CV_RGB(0, 255, 0), 2);
            }
            //printf("Лиц: %lu, глаз: %lu\n", frontObjects->size(), eyeObjects->size());
            imshow(winName, *image);
            
            *outputStream << *image;
            pthread_mutex_unlock(&mutex);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (key != ESC_KEY) {
            pthread_mutex_lock(&mutex);
            cvtColor(*image, *gray, CV_BGR2GRAY);
            pthread_mutex_unlock(&mutex);
            //cv::equalizeHist(*gray, *gray);
            frontCascade.detectMultiScale(*gray, *currentFrontObjects);
            eyesCascade.detectMultiScale(*gray, *currentEyeObjects);
            //profileCascade.detectMultiScale(*gray, *currentProfileObjects);
            
            //for (int i = 0; i < currentFrontObjects->size(); i++) {
                //cv::Mat faceMat = cv::Mat(*gray, currentFrontObjects->data()[i]);
                //eyesCascade.detectMultiScale(*gray, *currentEyeObjects);
            //}
            
            pthread_mutex_lock(&mutex);
            frontObjects->clear();
            profileObjects->clear();
            eyeObjects->clear();
            *frontObjects = *currentFrontObjects;
            *profileObjects = *currentProfileObjects;
            *eyeObjects = *currentEyeObjects;
            currentFrontObjects->clear();
            currentProfileObjects->clear();
            currentEyeObjects->clear();
            pthread_mutex_unlock(&mutex);
            
            gray->release();
            
        }
        capture->release();
        outputStream->release();
    });
    
    while(key != ESC_KEY) {
        key = waitKey(DELAY);
    }
    
    return 0;
}
