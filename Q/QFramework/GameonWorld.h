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
@class RenderDomain;
@class AreaIndexPair;

@interface GameonWorld : NSObject {

    NSMutableArray* mDomains;
        
    NSMutableArray* mModelList;
    NSMutableArray* mModelList2;    
    NSMutableArray* mNewModels;
    bool            mLocked;
    bool            mLockedDraw;
    bool            mInDraw;    
	GameonModel* 	mSplashModel;
    GameonApp*      mApp;
	float mViewWidth;
    float mViewHeight;
}

@property (nonatomic, readonly, getter = texts)TextRender*		mTexts;


-(void) add:(GameonModel*) model;
-(void) remove:(GameonModel*) model;

-(void) addModels;
-(void) draw:(double)delay;
-(void) prepare;

-(void) test;

-(void) initSplash:(NSString*) name;
-(void) drawSplash;
-(void) setAmbientLight:(float)r g:(float)g b:(float)b a:(float) a;
-(void) getAmbientLight:(float*) ret;
-(void) setAmbientLightGl:(float)r g:(float)g b:(float)b a:(float)a;
- (id) initWithApp:(GameonApp*)app;
-(RenderDomain*) getDomain:(int) id;
-(RenderDomain*) getDomainByName:(NSString*) name;
-(void)domainCreate:(NSString*)name domainid:(NSString*)domid bounds:(NSString*)coordsstr ;
-(void)domainRemove:(NSString*) name;
-(void)domainHide:(NSString*) name;
-(void)domainShow:(NSString*) name;
-(float) gerRelativeX:(float) x;
-(float) gerRelativeY:(float) y;
-(void)onSurfaceChanged:(int)width h:(int) height;
-(void)onSurfaceCreated;
-(RenderDomain*) addDomain:(NSString*)name domain:(int)i visible:(bool) visible;
-(AreaIndexPair*)onTouchModel:(float)x y:(float)y dotouch:(bool)click;
-(void) resetDomainPan;
-(bool) panDomain:(float)x y:(float) y;
-(void)domainPan:(NSString*)name mode:(NSString*)mode scrolls:(NSString*) scrollers
          bounds:(NSString*) coords;
@end

