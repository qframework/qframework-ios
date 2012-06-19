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

#define MAPPING_XY 0
#define MAPPING_YZ 1
#define MAPPING_XZ 2

#define TYPE_FIXED 0
#define TYPE_DYNAMIC 1
#define TYPE_KINEMATIC 2
#define TYPE_AREA 3

#define SHAPE_BOX 0
#define SHAPE_CIRCLE 1

@class LayoutArea;
@class GameonModelRef;

@interface ObjectProps : NSObject 
{
    int 	mType;
    int 	mShape;
    int 	mGroupIndex; 
    float 	mFriction;
    float 	mDensity;
    float 	mRestitution;    
}

@property (nonatomic, assign)int 	mType;
@property (nonatomic, assign)int 	mShape;
@property (nonatomic, assign)int 	mGroupIndex; 
@property (nonatomic, assign)float 	mFriction;
@property (nonatomic, assign)float 	mDensity;
@property (nonatomic, assign)float 	mRestitution;    
@end

@interface BodyData : NSObject 
{
    LayoutArea*	    mArea;
    GameonModelRef* mRef;
    void* 		    mBody;//b2Body
    ObjectProps*	   mProps;
}

@property (nonatomic, assign)LayoutArea*	    mArea;
@property (nonatomic, assign)GameonModelRef* mRef;
@property (nonatomic, assign)void* 		    mBody;//b2Body
@property (nonatomic, assign)ObjectProps*	   mProps;

@end

@interface Box2dData : NSObject 
{
    void* mWorld; //b2World
    NSString* mName;
    NSMutableArray* mAreaModels;
    NSMutableArray* mDynModels;
    NSMutableArray* mFixModels;
    int mMapping;
}

@property (nonatomic, assign)int mMapping;
@property (nonatomic, assign)NSString* mName;
@property (nonatomic, assign)void* mWorld;
@property (nonatomic, assign)NSMutableArray* mAreaModels;
@property (nonatomic, assign)NSMutableArray* mDynModels;
@property (nonatomic, assign)NSMutableArray* mFixModels;

@end


@class GameonApp;


@interface Box2dWrapper : NSObject {
	GameonApp*    	mApp;
	NSMutableDictionary* mBox2dWorlds;
	NSMutableArray*	mBox2dWorldsVec;    
    bool mActive;

}


- (id)initWithApp:(GameonApp*) app;
-(void)initWorld:(NSString*)resptype gravity:(NSString*)respdata mapping:(NSString*)respdata2;
- (void)initObjects:(NSDictionary*)response;
- (void)processObject:(NSString*)worldid data:(NSDictionary*)objData;
- (void)doFrame:(long) delay;
-(void)removeWorld:(NSString*)name;
-(bool) isActive;

@end

