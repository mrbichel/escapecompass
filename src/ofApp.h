#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxJSONElement.h"
#include "ofxBiquadFilter.h"

struct PPoint {
    ofVec2f pos;
    int type;
    
    ofVec2f latlng;
};

struct PPathLeg {
    vector<PPoint> points;
    string mode;
};

class PPath {
public:
    vector<PPathLeg> legs;
    int duration;
    float radius;
    
    float heading;
    float opacity;
    ofPath path;
    
};

class ofApp : public ofxiOSApp{
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
    
    void urlResponse(ofHttpResponse & response);
    
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);
	
        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        ofxCoreMotion coreMotion;
        ofxiOSCoreLocation * coreLocation;

        float heading, heading2;
        bool hasCompass;
        bool hasGPS;
	
    ofImage overlay;
    ofImage overlayRotate;
    ofImage center;
    ofImage slides[6];
    int slide;
    
    ofVec2f myLatLng;
    
    ofTrueTypeFont font;
    
    float gratio;
    
    float lastUpdateHeading;
    long int lastRequest;
    bool waiting;
    
    ofxJSONElement result;
    
    int pathHistory = 10;
    
    vector<PPath*>  paths;
    vector<PPath*> backgroundPaths;
    
    PPath * ActivePath;
    
    ofxBiquadFilter1f headingFiltered;
    ofxBiquadFilter1f headingFiltered2;
    
    
    bool hasBacground;
    
    string firstStation;
    string firstTransportName;
    
};
