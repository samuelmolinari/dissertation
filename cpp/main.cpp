#define NDEBUG

/**
 * This program was written for the undergraduate third yead project, Newcastle University.
 * One can detect faces, build a training set and recognise faces.
 *
 * @author Samuel Molinari (09308393)
 * @version 14/04/2012
 */

#include "facedetector.h"
#include "facerecogniser.h"
#include "vector"

using namespace drlib;
using namespace std;

int main(int argc, char *argv[]) {
    try {
        std::string image = argv[1];
        drlib::FaceRecogniser recogniser;
        
        if(argc > 3) {
            std::vector<std::string> csvs = std::vector<std::string>();
            for(uint i=2;i<argc;i++) {
                std::string csv = argv[i];
                csvs.push_back(csv);
            }
            
            recogniser = drlib::FaceRecogniser(csvs);

        } else if(argc == 3) {
            std::string csv = argv[2];
            recogniser = drlib::FaceRecogniser(csv);
        }

        drlib::FaceDetector detector(image);
        
        if(argc >= 3 && recogniser.trainingSetSize() > 0) detector.linkWithExternalRecogniser(recogniser);
        
        detector.detect();
        
        detector.outputJSON();
    } catch (Exception &e) {
        cout << "failed" << endl;
    }
    
    return 0;
}
