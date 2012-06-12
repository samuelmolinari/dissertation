#ifndef FACERECOGNISER_H
#define FACERECOGNISER_H

#include "opencv2/opencv.hpp"
#include "eigenfaces.h"
#include "face.h"
#include <vector>

using namespace std;
using namespace cv;

namespace drlib {
    class FaceRecogniser {
    public:
        FaceRecogniser();
        FaceRecogniser(const std::string &csvDB);
        FaceRecogniser(const std::vector<std::string> &csvDBs);
        
        std::vector<std::pair<int,double> > recognise(drlib::Face &face,int limit=1);
        void loadCSV(const std::string &filename);
        int trainingSetSize();
        
    private:
        Eigenfaces _eigenfaces;
        std::vector<cv::Mat> _images;
        std::vector<int> _labels;
        double _faceThreshold;
        double _labelThreshold;
    };
}

#endif // FACERECOGNISER_H
