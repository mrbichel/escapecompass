#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    gratio = 1.61803398875;
    ofSetCircleResolution(120);
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
	
    overlay.loadImage("overlay.png");
    overlayRotate.loadImage("overlayRotate.png");
    center.loadImage("center.png");
    for(int i=0;i<6;i++){
        slides[i].loadImage("slide"+ofToString(i+1)+".png");
    }
    
	heading = 0.0;
    
    coreMotion.setupMagnetometer();
    coreMotion.setupGyroscope();
    coreMotion.setupAccelerometer();
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);
    
    font.loadFont("Trebuchet MS.ttf", 24,true, true);
    
    waiting = false;
    ofRegisterURLNotification(this);
    
    // load background - should be async for real app
    ofHttpResponse response = ofLoadURL("http://halfdanj.local:3000/api/bg");
    
    ofxJSONElement jsel;
    jsel.parse(ofToString(response.data));
    
    // load points into somethign we draw as background
    
    PPath * p = new PPath();
    
    for (int d=0;d<jsel.size(); d++) {
        PPathLeg leg;
        
        for(int lp = 0; lp<jsel[d]["points"].size();lp++) {
            PPoint po;
            po.latlng = ofVec2f(
                                jsel[d]["points"][lp][0].asFloat(),
                                jsel[d]["points"][lp][1].asFloat()
                                );
            
            leg.points.push_back(po);
        }
        
        p->legs.push_back(leg);
    }
    
    backgroundPaths.push_back(p);
    
    headingFiltered.setFc(0.02);
    headingFiltered2.setFc(0.025);
    
    ActivePath = NULL;
    
}


//--------------------------------------------------------------
void ofApp::update(){
    heading = headingFiltered.updateDegree(coreLocation->getTrueHeading(), 360);
    heading2 = headingFiltered2.updateDegree(coreLocation->getTrueHeading(), 360);
    // cout<<heading<<endl;
    
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
    myLatLng.set(59.311907,18.078604);
    
    if(lastUpdateHeading > heading + 2 || lastUpdateHeading < heading -2) {
        
        if(!waiting) {
            lastUpdateHeading = heading;
            
            string request = "http://halfdanj.local:3000/api/route/" + ofToString(myLatLng.x) + "/" + ofToString(myLatLng.y) + "/" + ofToString(heading * DEG_TO_RAD);
            ofLoadURLAsync(request);
           // cout<<request<<endl;
            lastRequest = ofGetElapsedTimeMillis();
            waiting = true;
        }
    }
}

void ofApp::urlResponse(ofHttpResponse & response) {
    
    if (response.status==200) {
        waiting = false;
        
        result.parse(ofToString(response.data));
        
        //result.isArray();
        //cout<<"data received"<<endl;
        //cout<<result.getRawString()<<endl;
        
        
        PPath * p = new PPath();
        p->duration =result["route"]["duration"].asInt();
        p->radius = result["radius"].asFloat();
        p->heading = result["heading"].asFloat();
        
        p->path.setFilled(false);
        p->path.setStrokeWidth(6);
        //p->path.setPolyWindingMode(OF_POLY_WINDING_ABS_GEQ_TWO);
        
        //p->path.setMode(OF_PRIMITIVE_LINE_STRIP);
        
        if(ActivePath == NULL || ActivePath->heading != p->heading) {
            
            ofVec2f latlngratio = ofVec2f(1.0/0.01798, 1.0/0.031825);
            float scaleFactor = 1100 / p->radius ;
            
            if(result["route"]["legs"].size() > 0) {
                
                bool firstWalk = false;
                
                for (int i=0;i<result["route"]["legs"].size(); i++) {
                    
                    PPathLeg leg;
                    
                    leg.mode = result["route"]["legs"][i]["mode"].asString();
                    
                    if(!firstWalk && leg.mode != "WALK") {
                        firstWalk = true;
                        
                        firstStation = result["route"]["legs"][i]["from"]["name"].asString();
                        firstTransportName = leg.mode + " " + result["route"]["legs"][i]["route"].asString();
                        
                        //cout<<firstStation<<firstTransportName<<endl;
                    }
                    
                    for (int d=0;d<result["route"]["legs"][i]["decodedLine"].size(); d++) {
                        
                        
                        
                        
                        PPoint po;
                        po.latlng = ofVec2f(
                                            result["route"]["legs"][i]["decodedLine"][d][0].asFloat(),
                                            result["route"]["legs"][i]["decodedLine"][d][1].asFloat()
                                            );
                        
                        if(d==0 && i==0) { // start in center hack
                            po.pos = ofVec2f(0,0);
                        } else {
                            // scaled and relative to us
                            po.pos = ((po.latlng*latlngratio) - (myLatLng*latlngratio)) * scaleFactor;
                        }
                        
                        if(leg.mode != "WALK") {
                            
                            p->path.curveTo(po.pos);
                            
                        } else {
                            
                            if(d == result["route"]["legs"][i]["decodedLine"].size()-1 || d == 0) {
                                p->path.curveTo(po.pos);
                            }
                            
                        }
                        
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
    
    ofBackground(225, 225, 225);
    
    if(slide <= 5){
        slides[slide].draw(0,0);
    } else {
        
        ofQuaternion quat = coreMotion.getQuaternion();
        //ofVec3f g = coreMotion.getGyroscopeData();
        //ofVec3f m = coreMotion.getMagnetometerData();
        
        // quaternion rotations
        //float angle;
        //ofVec3f axis;//(0,0,1.0f);
        //quat.getRotate(angle, axis);// rotate with quaternion
        
        ofSetRectMode(OF_RECTMODE_CENTER);
        float cradius = ofGetWidth() - (ofGetWidth()/gratio);
        
        if(ActivePath != NULL) {
            
            // drawing hack for sweden
            // "aspec ratio"
            ofVec2f latlngratio = ofVec2f(1.0/0.01798, 1.0/0.031825);
            float scaleFactor = 1100 / ActivePath->radius ;
            
            ofPushMatrix(); {
                ofTranslate(ofGetWidth()/2, ofGetHeight()/gratio);
                
                // Draw background
                ofSetColor(224,224,224, 255);
                ofFill();
                ofCircle(0,0, cradius);
                
                ofPushMatrix(); {
                    
                    ofSetLineWidth(6);
                    
                    ofRotateZ(-heading -90);
                    ofNoFill();
                    
                    for(int bp=0; bp<backgroundPaths.size(); bp++) {
                        
                        for(int i=0; i<backgroundPaths[bp]->legs.size(); i++) {
                            
                            ofPolyline line;
                            
                            ofPath path;
                            for(int p=0; p<backgroundPaths[bp]->legs[i].points.size(); p++) {
                                
                                ofVec2f newlatlng = backgroundPaths[bp]->legs[i].points[p].latlng*latlngratio - myLatLng*latlngratio;
                                
                                line.curveTo(newlatlng*scaleFactor);
                            }
                            
                            ofSetColor(100,100,100,10);
                            line.draw();
                        }
                    }
                    
                }ofPopMatrix();
                
                ofSetLineWidth(2);
                ofFill();
                ofDisableDepthTest();
                ofSetColor(0);
                
                // End draw background
                /*
                 ofPushMatrix(); {
                 ofRotateZ(-heading);
                 ofSetLineWidth(2);
                 ofFill();
                 ofSetColor(0, 0, 0, 80);
                 ofLine(0, 0, -0.1,  0, -cradius, -0.1);
                 ofSetColor(0, 0, 0, 120);
                 ofLine(0, -cradius, -0.1, 0, -ofGetHeight(), -0.1);
                 
                 ofDisableDepthTest();
                 ofSetColor(255);
                 //ofCircle(0, -cradius, 24);
                 ofSetColor(0);
                 font.drawString("N", 4, -cradius - 4 );
                 }ofPopMatrix();*/
                
                ofPushMatrix(); {
                    
                    ofRotateZ(-heading -90);
                    
                    for(int pp=0;pp<paths.size();pp++) {
                        
                        ofNoFill();
                        if(paths[pp] == ActivePath) {
                            if(paths[pp]->opacity < 1.6) paths[pp]->opacity += 0.2;
                        } else {
                            if(paths[pp]->opacity > 0.0) paths[pp]->opacity -= 0.1;
                        }
                        if(paths[pp]->opacity > 0){
                            
                            ofFill();
                            ofSetColor(255);
                            
                            ofColor color1;
                            color1.set(119,145,219, 255*ofClamp(paths[pp]->opacity,0,1));
                            
                            paths[pp]->path.setColor(color1);
                            paths[pp]->path.draw();
                            
                            for(int i=0; i<paths[pp]->legs.size(); i++) {
                                
                                ofPath path;
                                //ofPolyline line;
                                
                                ofColor color;
                                color = color1;
                                
                                /*if(paths[pp]->legs[i].mode == "WALK") {
                                 color.set(80,10,10);
                                 } else if(paths[pp]->legs[i].mode == "BUS") {
                                 color.set(40,10,10);
                                 } else if(paths[pp]->legs[i].mode == "RAIL") {
                                 color.set(40,10,10);
                                 } else if(paths[pp]->legs[i].mode == "METRO") {
                                 color.set(10,0,0);
                                 } else {
                                 color.set(80,10,10);
                                 }*/
                                
                                for(int p=0; p<paths[pp]->legs[i].points.size(); p++) {
                                    
                                    ofVec2f thisPoint = paths[pp]->legs[i].points[p].pos;
                                    
                                    if(paths[pp]->legs[i].mode != "WALK") {
                                        ofNoFill();
                                        color.setBrightness(120);
                                        ofSetColor(color);
                                        ofCircle(thisPoint, 6);
                                        
                                        ofFill();
                                        color.setBrightness(100);
                                        ofSetColor(color);
                                        ofCircle(thisPoint, 4);
                                    }
                                }
                                
                                ofVec2f point = paths[pp]->legs[i].points[0].pos;
                                ofNoFill();
                                color.setBrightness(40);
                                ofSetColor(color);
                                ofCircle(point, 12);
                                
                                ofFill();
                                color.setBrightness(100);
                                ofSetColor(color);
                                
                                ofCircle(point, 4);
                            }
                            
                        }
                    }
                    
                    ofSetColor(255);
                    center.draw(0,0);
                    
                    ofPushMatrix(); {
                        
                        ofRotateZ(heading);
                        
                        ofTranslate(-25,0);
                        ofRotateZ(-heading2);
                        
                        //   ofScale(0.985, 0.985);
                        ofPushMatrix(); {
                            ofRotateZ(90 +heading2);
                            overlay.draw(0, 0);
                        } ofPopMatrix();
                        
                        ofPushMatrix(); {
                            ofRotateZ(90);
                            overlayRotate.draw(0,0);
                        }ofPopMatrix();
                        
                    }ofPopMatrix();
                    
                }ofPopMatrix();
                
            }ofPopMatrix();
            
        }
        
        ofSetColor(60);
        
        float s1w = font.getStringBoundingBox(firstStation, 0, 0).width/2;
        float s2w = font.getStringBoundingBox(firstTransportName, 0, 0).width/2;
        
        font.drawString(firstStation, ofGetWidth()/2 - s1w, ofGetHeight()-90-20);
        font.drawString(firstTransportName, ofGetWidth()/2 - s2w, ofGetHeight()-124-20);
        
    }
    
}

//--------------------------------------------------------------
void ofApp::exit(){
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    slide ++;
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
