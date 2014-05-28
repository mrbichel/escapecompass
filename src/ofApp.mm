#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    gratio = 1.61803398875;
    
	ofBackground(225, 225, 225);
    ofEnableAntiAliasing();
    
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
    
}


//--------------------------------------------------------------
void ofApp::update(){	
	heading = ofLerpDegrees(heading, -coreLocation->getTrueHeading(), 0.7);
    
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
    
}

void compassbox() {
    ofFill();
    ofSetColor(255);
    ofDrawBox(0, 0, 0, 20, 20, 2);
    ofSetColor(0);
    ofNoFill();
    ofDrawBox(0, 0, 0, 20, 20, 2);
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofEnableDepthTest();
    glEnable(GL_DEPTH_TEST);
    
    ofQuaternion quat = coreMotion.getQuaternion();
    ofVec3f g = coreMotion.getGyroscopeData();
    ofVec3f m = coreMotion.getMagnetometerData();
    
    // quaternion rotations
    float angle;
    ofVec3f axis;//(0,0,1.0f);
    quat.getRotate(angle, axis);// rotate with quaternion
    
    
	ofSetColor(100);
    //grabber.draw(0, 0);
    ofSetColor(255);
	//tex.draw(0, 0, tex.getWidth(), tex.getHeight());
    
    //float angle = 180 - RAD_TO_DEG * atan2( ofxAccelerometer.getForce().y, ofxAccelerometer.getForce().x );
    
	//ofDrawBitmapString("Kompass", 8, 20);
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    float cradius = 60;
    ofEnableAlphaBlending();
	ofSetColor(255);
		ofPushMatrix();
		ofTranslate(ofGetWidth()/2, ofGetHeight()-(ofGetHeight()/gratio), 0);
		ofRotateZ(heading);
    
        ofFill();
    
    ofPushMatrix();
    ofTranslate(cradius, 0,0);
    ofRotateZ(-heading);
    ofRotate(angle, axis.x, -axis.y, axis.z);
    
    ofSetColor(0);
    ofNoFill();
    ofDrawBox(0, 0, 0, 21, 21, 21);
    
    ofFill();
    ofSetColor(255);
    ofDrawBox(0, 0, 0, 20, 20, 20);

    ofPopMatrix();
    
    ofPushMatrix();
    ofTranslate(-cradius, 0,0);
    ofRotateZ(-heading);
    ofRotate(angle, axis.x, -axis.y, axis.z);
    
    ofSetColor(0);
    ofNoFill();
    ofDrawBox(0, 0, 0, 21, 21, 21);
    
    ofFill();
    ofSetColor(255);
    ofDrawBox(0, 0, 0, 20, 20, 20);

    ofPopMatrix();
    
    ofPushMatrix();
    ofTranslate(0, cradius,0);
    ofRotateZ(-heading);
    ofRotate(angle, axis.x, -axis.y, axis.z);
    
    ofSetColor(0);
    ofNoFill();
    ofDrawBox(0, 0, 0, 21, 21, 21);
    
    ofFill();
    ofSetColor(255);
    ofDrawBox(0, 0, 0, 20, 20, 20);

    ofPopMatrix();
    
    ofPushMatrix();
    ofTranslate(0, -cradius,0);
    ofRotateZ(-heading);
    ofRotate(angle, axis.x, -axis.y, axis.z);
    
    ofSetColor(0);
    ofNoFill();
    ofDrawBox(0, 0, 0, 21, 21, 21);
    
    ofFill();
    ofSetColor(255);
    ofDrawBox(0, 0, 0, 20, 20, 20);

    ofPopMatrix();
    

	ofPopMatrix();
	
	//arrowImg.draw(160, 220);
    float aw = 4;
    ofSetColor(0);
    
    ofFill();
    
    
    float far = ofMap(coreMotion.getPitch(), 0, PI, 100, 600);;
    ofDrawBox(ofGetWidth()/2, ofGetHeight()-(ofGetHeight()/gratio), 0, aw, far, 2);
    ofSetColor(255);

    
    //ofSetColor(54);
	//ofDrawBitmapString("LAT: ", 8, ofGetHeight() - 8);
	//ofDrawBitmapString("LON: ", ofGetWidth() - 108, ofGetHeight() - 8);

    // accelerometer
    ofVec3f a = coreMotion.getAccelerometerData();
    /*ofDrawBitmapStringHighlight("Accelerometer: (x,y,z)", 20, 125);
    ofSetColor(0);
    ofDrawBitmapString(ofToString(a.x,3), 20, 150);
    ofDrawBitmapString(ofToString(a.y,3), 120, 150);
    ofDrawBitmapString(ofToString(a.z,3), 220, 150);*/
    
    // gyroscope
    /*ofDrawBitmapStringHighlight("Gyroscope: (x,y,z)", 20, 175);
    ofSetColor(0);
    ofDrawBitmapString(ofToString(g.x,3), 20, 200 );
    ofDrawBitmapString(ofToString(g.y,3), 120, 200 );
    ofDrawBitmapString(ofToString(g.z,3), 220, 200 );*/
    
    // magnetometer
    /*ofDrawBitmapStringHighlight("Magnetometer: (x,y,z)", 20, 225);
    ofSetColor(0);
    ofDrawBitmapString(ofToString(m.x,3), 20, 250);
    ofDrawBitmapString(ofToString(m.y,3), 120, 250);
    ofDrawBitmapString(ofToString(m.z,3), 220, 250);
    */
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2, ofGetHeight()/2);
    
    // 2) rotate by multiplying matrix directly
    //ofMatrix4x4 mat = coreMotion.getRotationMatrix();
    //mat.rotate(180, 0, -1.0f, 0);
    //ofMultMatrix(mat); // OF 0.74: glMultMatrixf(mat.getPtr());
    
    // 3) rotate with eulers
    //ofRotateX( ofRadToDeg( coreMotion.getPitch() ) );
    //ofRotateY( -ofRadToDeg( coreMotion.getRoll() ) );
    //ofRotateZ( ofRadToDeg( coreMotion.getYaw() ) );
    
    ofNoFill();
	//ofDrawBox(0, 0, 0, 220);
    //ofDrawAxis(100);
    ofPopMatrix();
    
    ofSetColor(0);
    float w = font.getStringBoundingBox("Go!", 0, 0).width;
    font.drawString("Go!", ofGetWidth()/2-(w/2), ofGetHeight()-40);
    
    /*float Speed = 1.0;     // Speed rather than velocity, as it is only the magnitude
    float Angle = angle * RAD_TO_DEG;      // Initial angle of 30º
    
    ofVec3f pos = ofVec3f(0.0,0.0,0.0);  // Set the origin to (0,0)
    ofVec3f vel = ofVec3f(0.0,0.0,0.0);

    ofPushMatrix();
    
    float v = 0.2;
    for(int i=0;i<10000;i++){
        
        float x = i;
        float y = x * tan(Angle) - (9.8 * x) / (2 * v * cos(Angle));
        
        ofCircle(x/10,y/100,10);
    }
    ofPopMatrix();
    */
  //  float g = 9.8;
   // float x = 0;
   // float v = 1;
    
    //float y = x * tan(theta) - pow(x, 2) * g / ( 2* pow(v,2)
    
    //ofFill();
    //ofDrawBitmapString(ofToString("Double tap to reset \nAttitude reference frame"), 20, ofGetHeight() - 50);
    
    
	/*if(hasGPS){
		//cout<<coreLocation->getLatitude()<<" | "<< coreLocation->getLatitude() <<endl;
		
		ofSetHexColor(0x009d88);
		ofDrawBitmapString(ofToString(coreLocation->getLatitude()), 8 + 33, ofGetHeight() - 8);

		ofSetHexColor(0x0f7941d);
		ofDrawBitmapString(ofToString(coreLocation->getLongitude()), (ofGetWidth() - 108) + 33, ofGetHeight() - 8);
		
	}*/
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
