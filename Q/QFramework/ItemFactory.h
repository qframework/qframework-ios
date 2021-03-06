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
#import "LayoutTypes.h"

@class  GameonModel;
@class  GameonWorld;
@class  LayoutItem;
@class  GLColor;
@class  GameonApp;


@interface ItemFactory : NSObject {
	GameonApp*    	mApp;
	GameonWorld*    mWorld;
	NSMutableDictionary* mModels;
    float    mDefaultTransf[9];
    float    mDefaultUV[4];    
    int      mDefaultColors[2];    
}



- (id)initWithApp:(GameonApp*) app;
- (LayoutItem*)	createItem:(NSString*)data source:(LayoutItem*)item;
- (void)newFromTemplate:(NSString*)strType data:(NSString*)strData  color:(NSString*)color;
- (void)setTexture:(NSString*)strType data:(NSString*)strData;
- (void)createModel:(NSString*)strType;
- (void)setSubmodels:(NSString*)strType data:(NSString*)strData;
- (GameonModel*) createFromType:(int)template color:(GLColor*)color texture:(int)texid  grid:(float*)grid;
-(void)initModels:(NSMutableDictionary*)response;
-(GameonModel*)getFromTemplate:(NSString*)strType data:(NSString*)strData color:(NSString*)strColor;
-(void)addShapeFromData:(NSString*)name data:(NSString*)data transform:(NSString*)transform uvbounds:(NSString*) uvbounds;
-(void)addShape:(NSString*)name type:(NSString*)type transform:(NSString*)transform colors:(NSString*)colors uvbounds:(NSString*)uvbounds;
-(void)newEmpty:(NSString*) name;
-(GameonModel*) addModelFromType:(GameonModel*)model template:(int)template color:(GLColor*)color texture:(int)texid grid:(float*)grid;
-(void) createModelFromFile:(NSString*)modelname fromFile:(NSString*) fname;

@end
