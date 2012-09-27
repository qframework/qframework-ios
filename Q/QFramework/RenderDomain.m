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

#import "RenderDomain.h"
#import "TextRender.h"
#import "GameonModel.h"
#import "GameonModelRef.h"
#import "ColorFactory.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "TextureFactory.h"
#import "GameonApp.h"
#import "GameonCS.h"
#import "AreaIndexPair.h"
#import "LayoutArea.h"

@implementation RenderDomain

@synthesize mTexts;
@synthesize mCS;
@synthesize mRenderId;
@synthesize mName;
@synthesize mVisible;


- (id) initWithName:(NSString*)name forApp:(GameonApp*)app w:(float)w h:(float)h renderid:(int)i
{
	if (self = [super init])
	{
        mApp = app;
		mVisibleModelList = [[NSMutableArray alloc] init] ;
		mVisibleModelList2 = [[NSMutableArray alloc] init] ;        
        
        mTexts = [[TextRender alloc] initWithDomain:self];
        mRenderId = i;
        
        mFov = 45;
        mNear = 0.1f;
        mFar = 8.7f;
        mOffsetX = 0;
        mOffsetY = 0;
        
        mName = [[NSString alloc] initWithString:name];
        mViewport = (int*)malloc(sizeof(int)* 4);
        mViewport[0] = 0;
        mViewport[1] = 0;        
        mViewport[2] = w;
        mViewport[3] = h;        
        mOffXPerct = 0.0f;
        mOffYPerct = 0.0f;
        mWidthPerct = 1.0f;
        mHeightPerct = 1.0f;
        mAspect = 1.0f;
        mVisible = false;
        mCS = [[GameonCS alloc] initWithApp:app];
        
        mPanX = false;
        mPanY = false;
        mPanCoords[0] = -1000.0f;
        mPanCoords[1] = 1000.0f;
        mPanCoords[2] = -1000.0f;
        mPanCoords[3] = 1000.0f;
        
        mLastPanX = -1;
        mLastPanY = -1;
        mSpaceBottomLeft[0] = 0;
        mSpaceBottomLeft[1] = 0;
        mSpaceTopRight[0] = 0;
        mSpaceTopRight[1] = 0;
        
    }
    return self;
}

- (void) dealloc
{
    free(mViewport);
    [mName release];
	[mVisibleModelList release] ;
	[mVisibleModelList2 release] ;    
    [mTexts release] ;
    [mCS release];
    [super dealloc];
}

-(void) draw:(double)delay {

    if (!mVisible)
    {
        return;
    }
    // TODO cache old call
    glViewport(mViewport[0], mViewport[1], mViewport[2], mViewport[3] );
    //NSLog(@" %d %d %d %d %d " , mRenderId , mViewport[0], mViewport[1], mViewport[2], mViewport[3] );
    glClear(GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    [self perspective:mFov aspect:(float)mWidth/(float)mHeight zmin:mNear zmax:mFar  updateFrustrum:true];
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    [mCS applyCamera:delay];

    
    //NSLog(@" start draw ---------");
    int len = [mVisibleModelList count];
    for (int a=0; a< len; a++) {
        GameonModel* model = [mVisibleModelList objectAtIndex:a];
        
        if (!model.mHasAlpha)
            [model draw:mRenderId];
    }

    for (int a=0; a < len; a++) {
        GameonModel* model = [mVisibleModelList objectAtIndex:a];
        if (model.mHasAlpha)
            [model draw:mRenderId];
    }
    
    len = [mVisibleModelList2 count];    
    for (int a=0; a< len; a++) {
        GameonModel* model = [mVisibleModelList2 objectAtIndex:a];
        
        if (!model.mHasAlpha)
            [model draw:mRenderId];
    }    
    for (int a=0; a< len; a++) {
        GameonModel* model = [mVisibleModelList2 objectAtIndex:a];
        
        if (model.mHasAlpha)
            [model draw:mRenderId];
    }    
    
	[mTexts render];
    
    
}



-(void) clear
{
    for (GameonModel* model in mVisibleModelList)
    {
        [model hideDomainRefs:mRenderId];
    }
    for (GameonModel* model in mVisibleModelList2)
    {
        [model hideDomainRefs:mRenderId];
    }		
    
    [mTexts clear];
    
}


-(void) setVisible:(GameonModel*) model
{
 	if (model.mIsModel)
	{
		if ([mVisibleModelList2 indexOfObject:model] == NSNotFound)
		{
            for (int b = 0; b < [mVisibleModelList2 count]; b++)
            {
                GameonModel* oldmodel = [mVisibleModelList2 objectAtIndex:b];
                if (model.mTextureID == oldmodel.mTextureID)
                {
                    [mVisibleModelList2 insertObject:model atIndex:b];
                    return;
                }                
            }
            
			[mVisibleModelList2 addObject:model];	
		} 
	}else
	{
		if ([mVisibleModelList indexOfObject:model]  == NSNotFound)
		{
            for (int b = 0; b < [mVisibleModelList count]; b++)
            {
                GameonModel* oldmodel = [mVisibleModelList objectAtIndex:b];
                if (model.mTextureID == oldmodel.mTextureID)
                {
                    [mVisibleModelList insertObject:model atIndex:b];
                    return;
                }                
            }
            
            
			[mVisibleModelList addObject:model];	
		}		
	}
}

-(void) remVisible:(GameonModel*) model force:(bool) force
{
    int countvis = [model getVisibleRefs:mRenderId];
    if (countvis > 0 && !force)
    {
        return;
    }
    
	if (model.mIsModel)
	{
		if ([mVisibleModelList2 indexOfObject:model] != NSNotFound)
		{
			[mVisibleModelList2 removeObject:model];	
		}
	}else
	{
		if ([mVisibleModelList indexOfObject:model]  != NSNotFound)
		{
			[mVisibleModelList removeObject:model];	
		}		
	}
}

-(void) perspective:(float)fovy aspect:(float)aspect zmin:(float)zmin zmax:(float) zmax  updateFrustrum:(bool)update
{
    GLfloat xmin, xmax, ymin, ymax;
    ymax = zmin * tan(fovy * M_PI / 360.0);
    ymin = -ymax;
    xmin = ymin * aspect;
    xmax = ymax * aspect;
	if (update)
	{
		glFrustumf(xmin, xmax, ymin, ymax, zmin, zmax);
	}else
	{
		[mCS saveProjection:xmin r:xmax t:ymin b:ymax n:zmin f:zmax];
	}
}

- (void) setFov:(float)fovf near:(float)nearf far:(float)farf 
{
	mFar = farf;
	mNear = nearf;
	mFov = fovf;
	[self perspective:mFov aspect:(float)mWidth/(float)mHeight zmin:mNear zmax:mFar  updateFrustrum:false];
	
}

- (void) onSurfaceChanged:(int)width h:(int) height 
{
    float newWidth = (float)width;
    float newHeight = (float)height;
    
    mWidth = mWidthPerct * newWidth;
    mHeight = mHeightPerct * newHeight;
    
    mOffsetX = mOffXPerct * newWidth;
    
    mOffsetY = mOffYPerct * newHeight;
    
    
    mViewport[0] = (int)mOffsetX;
    mViewport[1] = (int)mOffsetY;
    mViewport[2] = (int)mWidth;
    mViewport[3] = (int)mHeight;
    

    [mCS saveViewport:mViewport w:width h:height];
    
	[self perspective:mFov aspect:(float)mWidth/(float)mHeight zmin:mNear zmax:mFar  updateFrustrum:false];
}

- (void) onSurfaceCreated
{
    
}


-(void)removeText:(TextItem*) text
{
    [mTexts remove:text];
}



-(void)setBounds:(int)width h:(int)height bounds:(float *)coords
{
    mOffXPerct = coords[0];
    mOffYPerct = coords[1];
    mWidthPerct = coords[2];
    mHeightPerct = coords[3];
    
    [self onSurfaceChanged:width h:height];
    
}



-(void) show 
{
    mVisible = true;
    
}

-(void)hide
{
    mVisible = false;
    
}	

-(bool)hasVisible:(GameonModel*)model
{
    if ([mVisibleModelList2 indexOfObject:model] != NSNotFound)
    {
        return true;
    }
    if ([mVisibleModelList indexOfObject:model]  != NSNotFound)
    {
        return true;
    }		
    
    return false;
}

-(AreaIndexPair*)onTouchModel:(float)x y:(float)y click:(bool)click noareas:(bool) noareas
{
    float rayVec[3];
    float* eye;
    
    [mCS screen2spaceVec:x y:y vec:rayVec];
    eye = [mCS eye];
    
    AreaIndexPair* data = nil;
    int len = [mVisibleModelList count];
    for (int a=0; a< len; a++)
    {
        GameonModel* model = [mVisibleModelList objectAtIndex:a];
        if (noareas && model.mParentArea!= nil)
        {
            continue;
        }
        
        data = [model onTouch:eye ray:rayVec domain:mRenderId doclick:click];
        if (data != nil)
        {
            return data;
        }
    }
    
    len = [mVisibleModelList2 count];
    for (int a=0; a< len; a++)
    {
        GameonModel* model = [mVisibleModelList2 objectAtIndex:a];
        if (noareas && model.mParentArea!= nil)
        {
            continue;
        }
        data = [model onTouch:eye  ray:rayVec  domain:mRenderId doclick:click];
        if (data != nil)
        {
            return data;
        }
    }
    
    return nil;
}



-(void)pan:(NSString*)mode scroll:(NSString*)scrollers bounds:(NSString*)coords
{
    if ([mode isEqualToString:@"enable"])
    {
        // enable x and y
        mPanX = true;
        mPanY = true;
    }else if ([mode isEqualToString:@"enablex"])
    {
        // enable x
        mPanX = true;
        mPanY = false;
    }else if ([mode isEqualToString:@"enabley"])
    {
        // enable y
        mPanX = false;
        mPanY = true;
    }else if ([mode isEqualToString:@"disable"])
    {
        // disable all
        mPanX = false;
        mPanY = false;
    }
    if (coords != nil)
    {
        [ServerkoParse parseFloatArray:mPanCoords max:4 forData:coords];
    }
    
    if (scrollers != nil && [scrollers isEqualToString:@"true"])
    {
        if (mPanX)
        {
            //mHorizontalScroller = new GameonModel("horscroll", mApp, null);
        }
    }
}



-(bool)onPan:(float)x y:(float) y
{
    
    if (!mPanX && !mPanY)
    {
        return false;
    }
    
    if ( x < mOffsetX || x > mOffsetX + mWidth || y < mOffsetY || y > mOffsetY + mHeight)
    {
        return false;
    }
    
    // calculate delta
    if (mLastPanX == -1)
    {
        mLastPanX = x; mLastPanY = y;
        return true;
    }
    
    float deltax = x - mLastPanX;
    float deltay = y - mLastPanY;
    
    
    float* eye = [mCS eye];
    
    float* lookat = [mCS lookat];
    
    float lasteyex = eye[0];
    float lasteyey = eye[1];
    float lastlookx = lookat[0];
    float lastlooky = lookat[1];
    
    
    if (mPanX)
    {
        eye[0] -= deltax/50.0f;
        lookat[0] -= deltax/50.0f;
    }
    if (mPanY)
    {
        eye[1] += deltay/50.0f;
        lookat[1] += deltay/50.0f;
    }
    
    
    [mCS setCamera:lookat eye:eye];
    mLastPanX = x; mLastPanY = y;
    
    bool canreturn = false;
    float lastrunx = eye[0];
    float lastruny = eye[1];
    
    do
    {
        
        lastrunx = eye[0];
        lastruny = eye[1];
        
        
        
        [mCS screen2space:mOffsetX+mWidth sy:-mOffsetY sc:mSpaceTopRight];
        [mCS screen2space:mOffsetX sy:-mOffsetY+mHeight sc:mSpaceBottomLeft];
        
        
        canreturn = true;
        if (mPanCoords[0] != -1000)
        {
            if (mPanX)
            {
                if ((mPanCoords[1] - mPanCoords[0]) < (mSpaceTopRight[0] - mSpaceBottomLeft[0]))
                {
                    eye[0] = lasteyex;
                    lookat[0] = lastlookx;
                    [mCS setCamera:lookat eye:eye];
                    canreturn = true;
                    
                }else
					if (mSpaceBottomLeft[0] < mPanCoords[0]+0.001 || mSpaceTopRight[0] > mPanCoords[1]-0.001)
					{
						eye[0] = (lasteyex + eye[0]) / 2;
						lookat[0] = (lastlookx + lookat[0]) / 2;
                    [mCS setCamera:lookat eye:eye];
						canreturn = false;
					}
            }
            
            if (mPanY )
            {
                if ((mPanCoords[3] - mPanCoords[2]) < (mSpaceTopRight[1] - mSpaceBottomLeft[1]))
                {
                    eye[1] = lasteyey;
                    lookat[1] = lastlooky;
                    [mCS setCamera:lookat eye:eye];
                    canreturn = true;						
                }else
					if (mSpaceBottomLeft[1] < mPanCoords[2]+0.001 || mSpaceTopRight[1] > mPanCoords[3]-0.001)
					{
						eye[1] = (lasteyey + eye[1]) / 2;
						lookat[1] = (lastlooky + lookat[1]) / 2;
                        [mCS setCamera:lookat eye:eye];
						canreturn = false;
					}
            }
        }
        if (lastrunx == eye[0] && lastruny == eye[1])
        {
            break;
        }
    }while(!canreturn);
    return true;
}



-(void) resetPan
{
    mLastPanX = -1;
    mLastPanY = -1;
    
}	



@end
