/*
   Copyright 2012, Telum Slavonski Brod, Croatia.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   This file is part of QFramework project, and can be used only as part of project.
   Should be used for peace, not war :)   
*/

#import <Foundation/Foundation.h>

@class TextRender;
@class GameonModel;
@class GameonApp;
@class GameonCS;
@class TextItem;
@class AreaIndexPair;
@interface RenderDomain : NSObject {

	NSMutableArray* mVisibleModelList;
	NSMutableArray* mVisibleModelList2;    

    TextRender*		mTexts;
    GameonApp*      mApp;
    
    int 	mRenderId;
    NSString*	mName;
    
    float 	mFov;
	float 	mNear;
	float 	mFar;
	float   mOffsetX;
	float   mOffsetY;
	float   mWidth;
	float   mHeight;
	
    int*         mViewport;
	
	float       mOffXPerct;
	float       mOffYPerct;
	float       mWidthPerct;
	float       mHeightPerct;
	float       mAspect;
	GameonCS*	mCS;
    
	bool mVisible;

    bool	mPanX;
    bool	mPanY;
    float   mPanCoords[4];
    float 	mLastPanX;
    float 	mLastPanY;
    float   mSpaceBottomLeft[2];
    float   mSpaceTopRight[2];

	
}

@property (nonatomic, readonly, getter = texts)TextRender*		mTexts;
@property (nonatomic, readonly, getter=cs) GameonCS* mCS;
@property (nonatomic, readonly)int 	mRenderId;
@property (nonatomic, readonly)bool 	mVisible;
@property (nonatomic, readonly)NSString*	mName;

-(void) draw:(double)delay;

-(void) setVisible:(GameonModel*) model;
-(void) remVisible:(GameonModel*) model force:(bool) force;
- (id) initWithName:(NSString*)name forApp:(GameonApp*)app w:(float)w h:(float)h renderid:(int)i;
-(void) remVisible:(GameonModel*) model force:(bool) force;
-(void) clear;
-(void) show ;
-(void) hide ;
- (void) onSurfaceChanged:(int)width h:(int) height ;
- (void) onSurfaceCreated;
-(void)setBounds:(int)width h:(int)height bounds:(float*) coords;
-(void)removeText:(TextItem*) text;
- (void) setFov:(float)fovf near:(float)nearf far:(float)farf ;
-(void) perspective:(float)fovy aspect:(float)aspect zmin:(float)zmin zmax:(float) zmax  updateFrustrum:(bool)update;
-(bool)hasVisible:(GameonModel*)model;
-(AreaIndexPair*)onTouchModel:(float)x y:(float)y click:(bool)click noareas:(bool) noareas;
-(void)pan:(NSString*)mode scroll:(NSString*)scrollers bounds:(NSString*)coords;
-(bool)onPan:(float)x y:(float) y;
-(void) resetPan;

@end

