#ifndef FACEDETECTOR_H
#define FACEDETECTOR_H

#include <face.h>
#include <opencv2/opencv.hpp>
#include <vector>
#include "facerecogniser.h"

using namespace std;
using namespace cv;

namespace drlib {
    class FaceDetector {
    public:
        FaceDetector(cv::Mat &image, const std::string &haarcascadeXML="/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt2.xml");
        FaceDetector(const std::string &imagePath, const std::string &haarcascadeXML="/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt2.xml");
        ~FaceDetector();
        std::vector<Face> detect();
        void linkWithExternalRecogniser(drlib::FaceRecogniser &recogniser);
        void outputJSON();
        
    private:
        float                       _scale;
        int                         _flag;
        int                         _minNeighbours;
        cv::Size                    _minFaceSize;
        cv::Size                    _maxFaceSize;
        cv::Mat                     _image;
        cv::Mat                     _source;
        cv::Size                    _maxImageSize;
        std::vector<drlib::Face>    _faces;
        cv::CascadeClassifier       _detector;
        drlib::FaceRecogniser*      _recogniser;
        
        cv::Mat getHighestQualityROI(cv::Rect rect);
        void addFace(cv::Rect &rect,int index=-1);
        double getFacesAverageArea();
    };
}

#endif // FACEDETECTOR_H
