#define NDEBUG

/**
 * Detects faces in a given image using a given haarcascade
 * The detection covers 360 degrees of an image. 
 *
 * @author Samuel Molinari
 * @version 14/04/2012
 */

#include "facedetector.h"
#include "utils.h"
#include "face.h"

using namespace drlib;
using namespace std;

FaceDetector::FaceDetector(cv::Mat &image,const std::string &haarcascadeXML) {
    this->_detector.load(haarcascadeXML);
    this->_image = image;
    this->_source = image;
    this->_maxImageSize = Size(800,800);
    this->_scale = 1.04;
    this->_flag = CV_HAAR_SCALE_IMAGE;
    this->_minNeighbours = 2;
    this->_minFaceSize = cv::Size(0,0);
    this->_maxFaceSize = cv::Size(0,0);
    this->_faces = std::vector<drlib::Face>();
    this->_recogniser = 0; 
    
    Utils::resize(this->_image,this->_image,this->_maxImageSize,true);
    cv::cvtColor(this->_image,this->_image,CV_BGR2GRAY);
    cv::cvtColor(this->_source,this->_source,CV_BGR2GRAY);
}

FaceDetector::FaceDetector(const std::string &imagePath, const std::string &haarcascadeXML) {
    this->_detector.load(haarcascadeXML);
    
    this->_image = cv::imread(imagePath,0);
    this->_source = cv::imread(imagePath,0);
    this->_maxImageSize = Size(800,800);
    this->_scale = 1.04;
    this->_flag = CV_HAAR_SCALE_IMAGE;
    this->_minNeighbours = 2;
    this->_minFaceSize = cv::Size(0,0);
    this->_maxFaceSize = cv::Size(0,0);
    this->_faces = std::vector<drlib::Face>();
    this->_recogniser = 0;
    
    Utils::resize(this->_image,this->_image,this->_maxImageSize,true);
}

vector<drlib::Face> FaceDetector::detect() {
    
    int angleCovered = 360;
    int angleInterval = 30;
    std::vector<cv::Rect> tmpDetectedObjects;
    cv::Mat workingCanvas;
    cv::Point trackingPoint;
    cv::Rect roi;
    int numFaces = 0;
    double avg;

    for(int angle=0;angle<angleCovered;angle+=angleInterval) {
        
        cv::equalizeHist(this->_image,workingCanvas);
        Utils::rotate(workingCanvas,workingCanvas,angle);        
        
        this->_detector.detectMultiScale(
                            workingCanvas,
                            tmpDetectedObjects,
                            this->_scale,
                            this->_minNeighbours,
                            this->_flag,
                            this->_minFaceSize,
                            this->_maxFaceSize
                        );
        
        if(tmpDetectedObjects.size() > 0) {
            double avg = this->getFacesAverageArea();
            int width = sqrt(avg);
            this->_minFaceSize = Size(width*0.7,width*0.7);
            this->_maxFaceSize = Size(width*1.3,width*1.3);
        }

        if(angle==0) {
            for(uint object=0;object<tmpDetectedObjects.size();object++)
                this->addFace(tmpDetectedObjects[object]);
        } else {
            
            numFaces = this->_faces.size();
            avg = this->getFacesAverageArea();
            
            for(uint object=0;object<tmpDetectedObjects.size();object++) {
                
                trackingPoint = Utils::getNormalPosition (
                            tmpDetectedObjects[object],
                            cv::Size(workingCanvas.cols,workingCanvas.rows),
                            cv::Size(this->_image.cols,this->_image.rows),
                            Utils::degreeToRadian(angle)
                        );
                
                roi = cv::Rect(
                            trackingPoint.x-Utils::round(tmpDetectedObjects[object].width/2.0),
                            trackingPoint.y-Utils::round(tmpDetectedObjects[object].height/2.0),
                            tmpDetectedObjects[object].width,
                            tmpDetectedObjects[object].height
                        );
                
                try {
                    this->addFace(roi);
                }  catch(Exception &e) { }

            }
            
        }
        
    }
    
    return this->_faces;
}

cv::Mat FaceDetector::getHighestQualityROI(Rect rect) {
    
    double wScale = 0.0;
    double hScale = 0.0;
    
    if(this->_source.cols > this->_image.cols || this->_source.rows > this->_image.rows) {
        wScale = ((double)this->_source.cols)/this->_image.cols;
        hScale = ((double)this->_source.rows)/this->_image.rows;
        rect.x = rect.x*wScale;
        rect.y = rect.y*hScale;
        rect.width = rect.width*wScale;
        rect.height = rect.height*hScale;
        
        return this->_source(rect);
    }
    
    return this->_image(rect);
    
}

void FaceDetector::addFace(cv::Rect &rect,int index) {
    Mat tmp = this->getHighestQualityROI(rect);
    Utils::setupForRecognition(tmp,tmp);
    Face f = Face(rect,tmp,this->_maxImageSize);
    
    if(this->_recogniser > 0) {
        this->_recogniser->recognise(f,1);
    }
    
    if((this->_recogniser > 0 && f.label > -2) || this->_recogniser == 0 || this->_recogniser->trainingSetSize() == 0) {
        if(index < 0)
            this->_faces.push_back(f);
        else
            this->_faces[index] = f;
    }
}

double FaceDetector::getFacesAverageArea() {
    double avg = 0;
    
    for(uint i=0;i<this->_faces.size();i++)
        avg += this->_faces[i].width*this->_faces[i].height;

    return avg/this->_faces.size();
}

void FaceDetector::linkWithExternalRecogniser(drlib::FaceRecogniser &recogniser) {
    this->_recogniser = &recogniser;
}

void FaceDetector::outputJSON() {
    cout << "{";
    cout << "\"image\":";
    cout << "{";
    cout << "\"width\":" << this->_image.cols << ",";
    cout << "\"height\":" << this->_image.rows;
    cout << "}" << ",";
    cout << "\"faces\":";
    cout << "[";
    for(uint i=0;i<this->_faces.size();i++) {
        Face f = this->_faces[i];
        cout << "{";
        cout << "\"x\":" << f.x << ",";
        cout << "\"y\":" << f.y << ",";
        cout << "\"width\":" << f.width << ",";
        cout << "\"height\":" << f.height << ",";
        cout << "\"id\":" << f.label << ",";
        cout << "\"error_margin\":" << f.recognitionError;
        cout << "}";
        if(i < this->_faces.size()-1) cout << ","; 
    }
    cout << "]";
    cout << "}" << endl;
}

FaceDetector::~FaceDetector() {
    this->_recogniser = 0;
}
