#ifndef FACE_H
#define FACE_H

#include <opencv2/opencv.hpp>

using namespace cv;

namespace drlib {
    class Face {
    public:
        Face();
        Face(cv::Rect &rect,cv::Mat &mat,cv::Size &size);
        
        int width;
        int height;
        int x;
        int y;
        int label;
        int recognitionError;
        cv::Rect rect;
        cv::Size imageSize;
        cv::Mat face;
    };
}

#endif // FACE_H
