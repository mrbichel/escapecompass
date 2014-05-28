#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxJSONElement.h"


//enum TRANSPORT_TYPE = {}

struct PPoint {
    ofVec2f pos;
    int type;
    
    ofVec2f latlng;
};

struct PPathLeg {
    vector<PPoint> points;
};

class PPath {
public:
    vector<PPathLeg> legs;
    int duration;
    
    float radius;
    
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
    
        ofVideoGrabber grabber;
        ofTexture tex;
        unsigned char * pix;
    
        float heading;
        bool hasCompass;
        bool hasGPS;
	
        ofImage arrowImg;
        ofImage compassImg;
    
    ofVec2f myLatLng;
    
    ofTrueTypeFont font;
    
    float gratio;
    
    float lastUpdateHeading;
    long int lastRequest;
    bool waiting;
    
    ofxJSONElement result;
    
    int pathHistory = 10;
    
    vector<PPath*>  paths;
    PPath * ActivePath;
    
};
