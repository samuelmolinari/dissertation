/**
 * Face
 * @author Samuel Molinari
 * @version 14/04/2012
 */

#include "face.h"

using namespace drlib;
Face::Face(){}

Face::Face(cv::Rect &rect, cv::Mat &mat, cv::Size &size) {
    this->face = mat;
    this->imageSize = size;
    this->width = rect.width;
    this->height = rect.height;
    this->x = rect.x;
    this->y = rect.y;
    this->label = -1;
    this->recognitionError = -1;
    this->rect = rect;
}
