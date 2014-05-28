#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    gratio = 1.61803398875;
    
    ofEnableDepthTest();
    ofEnableAlphaBlending();
    glEnable(GL_DEPTH_TEST);
    
	ofBackground(225, 225, 225);
    ofEnableAntiAliasing();
    
    ofRegisterURLNotification(this);
    
	// initialize the accelerometer
	ofxAccelerometer.setup();
    
	coreLocation = new ofxiOSCoreLocation();
	hasCompass = coreLocation->startHeading();
	hasGPS = coreLocation->startLocation();
	
	arrowImg.loadImage("arrowLong.png");
	compassImg.loadImage("compass.png");
	
	compassImg.setAnchorPoint(160, 200);
	arrowImg.setAnchorPercent(0.5, 1.0);
	heading = 0.0;
    
    coreMotion.setupMagnetometer();
    coreMotion.setupGyroscope();
    coreMotion.setupAccelerometer();
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);
    
    grabber.initGrabber(ofGetWidth(), ofGetHeight(), OF_PIXELS_BGRA);
	tex.allocate(grabber.getWidth(), grabber.getHeight(), GL_RGB);
	
	pix = new unsigned char[ (int)( grabber.getWidth() * grabber.getHeight() * 3.0) ];
    
    font.loadFont("Arial.ttf", 24);
    
    waiting = false;
    ofRegisterURLNotification(this);
}


//--------------------------------------------------------------
void ofApp::update(){	
	heading = coreLocation->getTrueHeading(); // ofLerpDegrees(heading, -coreLocation->getTrueHeading(), 0.7);
    //cout<<coreLocation->getTrueHeading()<<endl;
    coreMotion.update();
    
    
    /*grabber.update();
	
	unsigned char * src = grabber.getPixels();
	int totalPix = grabber.getWidth() * grabber.getHeight() * 3;
	
	for(int k = 0; k < totalPix; k+= 3){
		pix[k  ] = 255 - src[k];
		pix[k+1] = 255 - src[k+1];
		pix[k+2] = 255 - src[k+2];
	}
	
	tex.loadData(pix, grabber.getWidth(), grabber.getHeight(), GL_RGB);*/
    
    //myLatLng = ofVec2f(coreLocation->getLatitude(), coreLocation->getLongitude());
    myLatLng.set(55.5866,13.0316);
    
    if(lastUpdateHeading > heading + 2 || lastUpdateHeading < heading -2) {
        
        if(!waiting) {
            lastUpdateHeading = heading;
        
            string request = "http://halfdanj.local:3000/api/route/" + ofToString(myLatLng.x) + "/" + ofToString(myLatLng.y) + "/" + ofToString(heading * DEG_TO_RAD);
            ofLoadURLAsync(request);
        cout<<request<<endl;
            lastRequest = ofGetElapsedTimeMillis();
            waiting = true;
        }
        
    }
}

void ofApp::urlResponse(ofHttpResponse & response) {
    
    if (response.status==200) {
        waiting = false;
        
        result.parse(ofToString(response.data));
        
        result.isArray();
        cout<<"data received"<<endl;
        //cout<<result.getRawString()<<endl;

        PPath * p = new PPath();
        p->duration =result["route"]["duration"].asInt();
        
        p->radius =result["radius"].asFloat();
        
        
        if(result["route"]["legs"].size() > 0) {
        for (int i=0;i<result["route"]["legs"].size(); i++) {
            
            PPathLeg leg;
            
            for (int d=0;d<result["route"]["legs"][i]["decodedLine"].size(); d++) {
                
                PPoint po;
                
                po.latlng = ofVec2f(
                        result["route"]["legs"][i]["decodedLine"][d][0].asFloat(),
                        result["route"]["legs"][i]["decodedLine"][d][1].asFloat()
                        );
                
                leg.points.push_back(po);
            }
            
            p->legs.push_back(leg);
        }
        
        paths.push_back(p);
        ActivePath = p;
        
        if(paths.size() > pathHistory) {
            paths.erase(paths.begin());
        }
        }
        
    } else {
        cout << response.status << " " << response.error << endl;
        if (response.status != -1) waiting = false;
    }
    
}

// may not work
ofVec2f LatLon(ofVec3f position)
{
    float sphereRadius = 6378.1; // radius of earth
    float x = (float)acos(position.y * DEG_TO_RAD / sphereRadius); //theta
    float y = (float)atan(position.x * DEG_TO_RAD / position.z); //phi
    return ofVec2f(x, y);
}

//--------------------------------------------------------------
void ofApp::draw(){

    
    ofQuaternion quat = coreMotion.getQuaternion();
    //ofVec3f g = coreMotion.getGyroscopeData();
    //ofVec3f m = coreMotion.getMagnetometerData();
    
    // quaternion rotations
    float angle;
    ofVec3f axis;//(0,0,1.0f);
    quat.getRotate(angle, axis);// rotate with quaternion
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    float cradius = ofGetWidth() - (ofGetWidth()/gratio);
	ofSetColor(255);
		ofPushMatrix();
		ofTranslate(ofGetWidth()/2, ofGetHeight()-(ofGetHeight()/gratio), 0);
		ofRotateZ(-heading);
    
        ofFill();
    
    ofPushMatrix();
    ofTranslate(0, -cradius,0);
    
    ofFill();
    ofSetColor(255,0,0);
    ofDrawBox(0, 0, 0, 20, 20, 20);
    
    ofSetColor(0);
    ofNoFill();
    ofDrawBox(0, 0, 0, 21, 21, 21);

    ofPopMatrix();
    
	ofPopMatrix();
	
	//arrowImg.draw(160, 220);
    
    /*float aw = 8;
    ofSetColor(100);
    ofFill();
    float far = ofMap(coreMotion.getPitch(), 0, PI, 100, 600);;
    ofDrawBox(ofGetWidth()/2, ofGetHeight()-(ofGetHeight()/gratio), 0, aw, far, 2);
    ofSetColor(255);*/
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2, ofGetHeight()/gratio);
    
    ofRotateZ(-heading -90);
    
    ofSetColor(255,0,0);
    ofNoFill();
    ofCircle(0,0, 5);
    
    ofSetColor(0);
    ofFill();
    
    // drawing hack for sweden
    // "aspec ratio"

    
    if(ActivePath != NULL) {
        
        ofVec2f latlngratio = ofVec2f(1.0/0.01798, 1.0/0.031825);
        float scaleFactor = (600) / ActivePath->radius ;
        
        
        ofPolyline line;
        
    for(int i=0; i<ActivePath->legs.size(); i++) {
        
        ofPath path;
        
        for(int p=0; p<ActivePath->legs[i].points.size(); p++) {

            ofVec2f newlatlng = ActivePath->legs[i].points[p].latlng*latlngratio - myLatLng*latlngratio;
            
            line.curveTo(newlatlng*scaleFactor);
            ofCircle(newlatlng*scaleFactor, 5);
        }
        
        line.draw();
        
    }

        
    }
    
    ofPopMatrix();

    
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    coreMotion.resetAttitude();
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}
