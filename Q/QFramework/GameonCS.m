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


#import "GameonCS.h"
#import "GMath.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "GameonApp.h"
#import "GameonModelRef.h"
#import "AnimFactory.h"

@implementation GameonCS

@synthesize mCameraEye;


- (void) dealloc
{
    free(mCameraEye);
    free(mCameraLookAt);

    free(mBBox);
    free(mLookAt);
    free(mProjection);
    free(mProjectionSaved);
    [super dealloc];
}


- (id)initWithApp:(GameonApp*)app
{
    self = [super init];
    
    if (self) {
        
        mApp = app;
        mCameraData = [[GameonModelRef alloc]initWithParent:nil andDomain:0];        
        mCameraEye = mCameraData.mAreaPosition;
        mCameraLookAt = mCameraData.mPosition;
        mUpZ = mCameraData.mScale;

        
        mCanvasW = 0;
        mCanvasH = 0;
        
        mViewport = malloc( 4 * sizeof(int) );
        mViewport[0] =0;
        mViewport[1] =0;
        mViewport[2] =0;
        mViewport[3] =0;
        
        mLookAt = malloc( 16 * sizeof(float));
        matrixIdentity(mLookAt);
        mProjection = malloc( 16 * sizeof(float));
        matrixIdentity(mProjection);

        mProjectionSaved = malloc( 8 * sizeof(float));
        memset(mProjectionSaved , 0 , 8 * sizeof(float));
        
        mBBox = malloc( 8 * sizeof(float));
        memset(mBBox , 0 , 8 * sizeof(float));
        
        mCameraEye = malloc( 3 * sizeof(float));
        mCameraEye[0] =0;
        mCameraEye[1] =0;
        mCameraEye[2] =5;        

        mCameraLookAt= malloc( 3 * sizeof(float));    
        mCameraLookAt[0] = 0;
        mCameraLookAt[1] = 0;
        mCameraLookAt[2] = 0;        
        
		mUpZ = malloc( 3 * sizeof(float));    
		mUpZ[0] = 0;
		mUpZ[1] = 1;
		mUpZ[2] = 0;
        mSpaceInit = false;        
    }
    return self;
}


-(void) saveViewport:(int*)viewport w:(int)aw h:(int) ah 
{

    mScreenWidth = aw;
    mScreenHeight = ah;
    mViewport[0] = viewport[0];
    mViewport[1] = viewport[1];    
    mViewport[2] = viewport[2];
    mViewport[3] = viewport[3];
    
}

-(void)saveProjection:(float)left r:(float)right t:(float)top b:(float)bottom n:(float)near f:(float) far 
{
    memset(mProjection , 0 , 16 * sizeof(float));
	frustrumMat(left,right,top,bottom,near,far, mProjection);

    mProjectionSaved[0] = left;
    mProjectionSaved[1] = right;
    mProjectionSaved[2] = top;
    mProjectionSaved[3] = bottom;
    mProjectionSaved[4] = near;
    mProjectionSaved[5] = far;    
}

-(void) initCanvas:(float) canvasw h:(float) canvash o:(int)orientation
{
    
    
    mCanvasW = (float)canvasw;
    mCanvasH = (float)canvash;

    
}

- (void) screen2spaceVec:(float)x y:(float)y  vec:(float*) vec
{
	float c[3];
	y = mScreenHeight - y;
	gluUnProject(x,y, 1.0f,mLookAt, 
			mProjection, 
			mViewport, 
			&c[0],&c[1],&c[2]);
	vec[0] = c[0] - mCameraEye[0];
	vec[1] = c[1] - mCameraEye[1];
	vec[2] = c[2] - mCameraEye[2];
}

 
- (void) screen2space:(float)x sy:(float)y sc:(float*) spacecoords 
{
     float c[3];
     float f[3];
        
     y = mViewport[3] - y;
    gluUnProject(x,y, 1.0f,mLookAt,
                  mProjection,
                  mViewport,
                  &f[0] , &f[1] , &f[2]);
    
    gluUnProject(x,y, 0.0f,mLookAt,
                  mProjection,
                  mViewport,
                  &c[0],&c[1],&c[2]);    	
    
     f[0] -= c[0];
     f[1] -= c[1];
     f[2] -= c[2];
     float rayLength = (float)sqrt(c[0]*c[0] + c[1]*c[1] + c[2]*c[2]);
     //normalize
     f[0] /= rayLength;
     f[1] /= rayLength;
     f[2] /= rayLength;
     
     //T = [planeNormal.(pointOnPlane - rayOrigin)]/planeNormal.rayDirection;
     //pointInPlane = rayOrigin + (rayDirection * T);
     
     float dot1, dot2;
     
     float pointInPlaneX = 0;
     float pointInPlaneY = 0;
     float pointInPlaneZ = 0;
     float planeNormalX = 0;
     float planeNormalY = 0;
     float planeNormalZ = -1;
     
     pointInPlaneX -= c[0];
     pointInPlaneY -= c[1];
     pointInPlaneZ -= c[2];
     
     dot1 = (planeNormalX * pointInPlaneX) + (planeNormalY * pointInPlaneY) + (planeNormalZ * pointInPlaneZ);
     dot2 = (planeNormalX * f[0]) + (planeNormalY * f[1]) + (planeNormalZ * f[2]);
     
     float t = dot1/dot2;
     
     f[0] *= t;
     f[1] *= t;
     spacecoords[0] = f[0] + c[0];
     spacecoords[1] = f[1] + c[1];
}
 

-(void) saveLookAt:(float*)eye  c:(float*)center u:(float*) up 
{
    memset(mLookAt , 0 , 16 * sizeof(float));
    lookAtf(mLookAt,eye,center,up);
}
 
 
 

- (float) snap_cam_z:(float*)eye  center:(float*)center up:(float*) up 
{

    float lookAt[16];
    float eye2[3];
    memcpy(eye2, eye, sizeof(float)*3);
    
    for (float  ez = 1; ez <100; ez += 0.05)
    {
        float cordx = mCanvasW;
        float cordy = 0;

        float x,y,z;
        eye2[2] = ez;
        
        lookAtf(lookAt,eye2,center,up);
        if (gluProject(cordx, cordy, 0, 
                    lookAt, 
                     mProjection,
                     mViewport,
                     &x,&y,&z) == GL_TRUE &&  x> 0 && x < mViewport[2] )
        {
            //glhLookAtf2(mLookAt,eye,center,up);
			mCameraEye[0] = 0;
			mCameraEye[1] = 0;
            mCameraEye[2] = ez;
            
            mCameraLookAt[0] = 0;
            mCameraLookAt[1] = 0;
            mCameraLookAt[2] = 0;
            
            mUpZ[0] = 0;
            mUpZ[1] = 1;
            mUpZ[2] = 0;
            
            [self saveLookAt:mCameraEye  c:mCameraLookAt u:mUpZ];            
            //NSLog(@" done x = %f z = %f",x, ez);
            return ez;
        }
        //NSLog(@" x = %f ",x);
    }
    return 0;
}



-(void)setCamera:(float*)lookat eye:(float*)eye
{
    mCameraEye[0] = eye[0];
    mCameraEye[1] = eye[1];
    mCameraEye[2] = eye[2];    

    mCameraLookAt[0] = lookat[0];
    mCameraLookAt[1] = lookat[1];
    mCameraLookAt[2] = lookat[2];    
    
    [self saveLookAt:mCameraEye  c:mCameraLookAt u:mUpZ];
    
}

-(void)applyCamera:(double)delta
{
    //glMatrixMode(GL_MODELVIEW);
    //glLoadIdentity();
    if ([mCameraData animating])
    {
        [mCameraData animate:delta];
        [self saveLookAt:mCameraEye  c:mCameraLookAt u:mUpZ];
    }

    
    gluLookAt(mCameraEye[0], mCameraEye[1], mCameraEye[2], 
              mCameraLookAt[0], mCameraLookAt[1], mCameraLookAt[2],    
              0, 1.0f, 0.0f);    
    
    
    if (!mSpaceInit)
    {
        mSpaceInit = true;
        [self saveLookAt:mCameraEye  c:mCameraLookAt u:mUpZ];
        
    }
    
}


-(void)getScreenBounds:(float*)world
{
    
    
    float temp[2];
    [self screen2space:mViewport[0] sy:mViewport[1] sc:temp];
    world[0] = temp[0] ;world[1] = temp[1];
    
    [self screen2space:mViewport[2] sy:mViewport[1] sc:temp];
    world[2] = temp[0] ;world[3] = temp[1];
    
    [self screen2space:mViewport[2] sy:mViewport[3] sc:temp];
    world[4] = temp[0] ;world[5] = temp[1];
    
    [self screen2space:mViewport[0] sy:mViewport[3] sc:temp];
    world[6] = temp[0] ;world[7] = temp[1];
    
    
    for (int a=0; a< 8; a++)
    {
        mBBox[a] = world[a];
    }
    
    
    
}

-(float)getCanvasW
{
    return mViewport[2] - mViewport[0];
}
-(float)getCanvasH
{
    return mViewport[3] - mViewport[1];
}

-(void)applyPerspective
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();    
    glFrustumf(mProjectionSaved[0], mProjectionSaved[1], mProjectionSaved[2], 
               mProjectionSaved[3], mProjectionSaved[4], mProjectionSaved[5]);    
}


-(float) worldWidth
{
	return mBBox[2] - mBBox[0];
}

-(float) worldHeight
{
	return mBBox[2] - mBBox[0];
}	

-(float) worldCenterX
{
	return (mBBox[2] + mBBox[0]) / 2;
}
-(float) worldCenterY
{
	return (mBBox[1] + mBBox[5]) / 2;
}	

-(void) moveCamera:(float*)lookat eye:(float*)eye delay:(double)animdelay
{
    if (mAnimDataStart == nil)
    {
        mAnimDataStart = [[GameonModelRef  alloc] initWithParent:nil andDomain:0];
    }
    if (mAnimDataEnd == nil)
    {
        mAnimDataEnd = [[GameonModelRef  alloc] initWithParent:nil andDomain:0];
    }
    
    [mAnimDataStart copy:mCameraData];
    [mAnimDataEnd copy:mCameraData];
    [mAnimDataEnd setAreaPosition:eye];
    [mAnimDataEnd setPosition:lookat ];
 
    [mApp.anims createAnim:mAnimDataStart end:mAnimDataEnd def:mCameraData
                     delay:animdelay steps:2 owner:nil repeat:1 hide:false save:false];
    
}


-(float*)eye
{
    
    return mCameraEye;
}

-(float*)lookat
{
    return mCameraLookAt;
}

-(float*)up
{
    return mUpZ;
}

@end
