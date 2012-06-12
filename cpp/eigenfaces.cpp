#include "helper.h"
#include "eigenfaces.h"

bool comparePreditions(pair<int,double> i, pair<int,double> j) {
    return i.second<j.second;
}

Eigenfaces::Eigenfaces(const Mat& src, const vector<int>& labels, int num_components, bool dataAsRow) {
	_num_components = num_components;
	_dataAsRow = dataAsRow;
	// compute the eigenfaces
	compute(src, labels);
}

Eigenfaces::Eigenfaces(const vector<Mat>& src, const vector<int>& labels, int num_components, bool dataAsRow) {
	_num_components = num_components;
	_dataAsRow = dataAsRow;
	// compute the eigenfaces
	compute(src, labels);
}

void Eigenfaces::compute(const Mat& src, const vector<int>& labels) {
	// observations in row
	Mat data = _dataAsRow ? src : transpose(src);
	// number of samples
	int n = data.rows;
	// dimensionality of data
	int d = data.cols;
	// assert there are as much samples as labels
	if(n != labels.size())
		CV_Error(CV_StsBadArg, "The number of samples must equal the number of labels!");
	// clip number of components to be valid
	if((_num_components <= 0) || (_num_components > n))
		_num_components = n;
	// perform the PCA
	PCA pca(data,
			Mat(),
			CV_PCA_DATA_AS_ROW,
			_num_components);
	// set the data
	_mean = _dataAsRow ? pca.mean.reshape(1,1) : pca.mean.reshape(1, pca.mean.total()); // store the mean vector
	_eigenvalues = pca.eigenvalues.clone(); // store the eigenvectors
	_eigenvectors = transpose(pca.eigenvectors); // OpenCV stores the Eigenvectors by row (??)
	_labels = vector<int>(labels); // store labels for projections
        
	// projections
	for(int sampleIdx = 0; sampleIdx < data.rows; sampleIdx++) {
		this->_projections.push_back(project(_dataAsRow ? src.row(sampleIdx) : src.col(sampleIdx)));
	}
}

void Eigenfaces::compute(const vector<Mat>& src, const vector<int>& labels) {
	compute(_dataAsRow ? asRowMatrix(src) : asColumnMatrix(src), labels);
}

int Eigenfaces::predict(const Mat& src) {
	Mat q = project(_dataAsRow ? src.reshape(1,1) :	src.reshape(1, src.total()));
	// find 1-nearest neighbor
	double minDist = numeric_limits<double>::max();
	int minClass = -1;
	for(int sampleIdx = 0; sampleIdx < _projections.size(); sampleIdx++) {
		double dist = norm(_projections[sampleIdx], q, NORM_L2);
		if(dist < minDist) {
			minDist = dist;
			minClass = _labels[sampleIdx];
		}
	}
	return minClass;
}

vector<pair<int,double> > Eigenfaces::predictions(const Mat &src, double threshold,int limit) {
    vector<pair<int,double> > toplist = vector<pair<int,double> >();
    Mat q = project(_dataAsRow ? src.reshape(1,1) :	src.reshape(1, src.total()));
    // find 1-nearest neighbor
    for(int sampleIdx = 0; sampleIdx < _projections.size(); sampleIdx++) {
        double dist = norm(_projections[sampleIdx], q, NORM_L2);
        
        if(dist < threshold) {
            if(toplist.size() < limit) {
                toplist.push_back(pair<int,double>(_labels[sampleIdx],dist));
                sort(toplist.begin(),toplist.end(),comparePreditions);
            } else {
                if(dist < toplist.back().second) {
                    toplist.pop_back();
                    toplist.push_back(pair<int,double>(_labels[sampleIdx],dist));
                    sort(toplist.begin(),toplist.end(),comparePreditions);
                }
            }
        }
    }
    return toplist;
}

Mat Eigenfaces::project(const Mat& src) {
	Mat data, X, Y;
	int n = _dataAsRow ? src.rows : src.cols;
	// convert to correct type
	src.convertTo(data, _mean.type());
	// center data
	subtract(_dataAsRow ? data : transpose(data),
			repeat(_mean.reshape(1,1), n, 1),
			X);
	// Y = (X-mean)*W
	gemm(X, _eigenvectors, 1.0, Mat(), 0.0, Y);
	return _dataAsRow ? Y : transpose(Y);
}

Mat Eigenfaces::reconstruct(const Mat& src) {
	Mat X;
	int n = _dataAsRow ? src.rows : src.cols;
	// X = Y*W'+mean
	gemm(_dataAsRow ? src : transpose(src),
			_eigenvectors,
			1.0,
			repeat(_mean.reshape(1,1), n, 1),
			1.0,
			X,
			GEMM_2_T);
	return _dataAsRow ? X : transpose(X);
}
