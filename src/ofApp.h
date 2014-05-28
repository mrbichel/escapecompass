#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"

class ofApp : public ofxiOSApp{
	
    public:
        void setup();
        void update();
        void draw();
    
        void exit();

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
    
    
    ofTrueTypeFont font;
    
    float gratio;
    
    
};
