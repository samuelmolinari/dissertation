/**
 * Face recognition
 * @author Samuel Molinari
 * @version 14/04/2012
 */

#include "facerecogniser.h"
#include "eigenfaces.h"
#include <fstream>
#include "utils.h"

using namespace drlib;

FaceRecogniser::FaceRecogniser() {
    this->_eigenfaces = Eigenfaces();
    this->_faceThreshold = 8000;
    this->_labelThreshold = 6000;
}

FaceRecogniser::FaceRecogniser(const std::string &csvDB) {
    this->_eigenfaces = Eigenfaces();
    this->_faceThreshold = 8000;
    this->_labelThreshold = 6000;
    this->loadCSV(csvDB);
    
    if(this->_images.size() > 0) this->_eigenfaces.compute(this->_images,this->_labels);
}

FaceRecogniser::FaceRecogniser(const std::vector<std::string> &csvDBs) {
    this->_eigenfaces = Eigenfaces();
    this->_faceThreshold = 8000;
    this->_labelThreshold = 6000;
    
    for(uint i=0;i<csvDBs.size();i++)
        this->loadCSV(csvDBs[i]);
    
    if(this->_images.size() > 0) this->_eigenfaces.compute(this->_images,this->_labels);
}

std::vector<std::pair<int,double> > FaceRecogniser::recognise(drlib::Face &face,int limit) {
    std::vector<std::pair<int,double> > predictions = this->_eigenfaces.predictions(face.face,this->_faceThreshold,limit);
    if(predictions.size() > 0) {
        if(predictions[0].second < this->_labelThreshold) {
            face.label = predictions[0].first;
            face.recognitionError = predictions[0].second;
        } else {
            face.label = -1;
            face.recognitionError = -1;
        }
    } else {
        face.label = -2;
        face.recognitionError = -1;
    }
    return predictions;
}

void FaceRecogniser::loadCSV(const std::string &filename) {
    
    Mat img;
    std::ifstream file(filename.c_str(), ifstream::in);
    if(file) {
        std::string line, path, classlabel;
        // for each line
        while (std::getline(file, line)) {
            // get current line
            std::stringstream liness(line);
            // split line
            std::getline(liness, path, ';');
            std::getline(liness, classlabel);
            // push pack the data
            
            img = imread(path,0);
            Utils::resize(img,img,Size(120,120));
            img = img(Rect(20,10,80,100));
            Utils::resize(img,img,Size(120,120));
            cv::equalizeHist(img,img);
            
            this->_images.push_back(img);
            this->_labels.push_back(atoi(classlabel.c_str()));
        }
        
    }
    
}

int FaceRecogniser::trainingSetSize() {
    return this->_images.size();
}
