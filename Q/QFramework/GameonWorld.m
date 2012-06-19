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

#import "GameonWorld.h"
#import "TextRender.h"
#import "GameonModel.h"
#import "GameonModelRef.h"
#import "ColorFactory.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "TextureFactory.h"
#import "GameonApp.h"
#import "RenderDomain.h"
#import "ServerkoParse.h"

@implementation GameonWorld

@synthesize mTexts;

float gAmbientLight[4] = { 1.0f, 1.0f, 1.0f, 1.0f};
bool gAmbientLightChanged = false;

- (id) initWithApp:(GameonApp*)app
{
	if (self = [super init])
	{
        mApp = app;
        mModelList = [[NSMutableArray alloc] init] ;
        mModelList2 = [[NSMutableArray alloc] init] ;        
        mNewModels = [[NSMutableArray alloc] init];
        mDomains = [[NSMutableArray alloc] init];
        
        mTexts = [[TextRender alloc] init];
        mLocked = false;
        mLockedDraw = false;
        mInDraw = false;
		
        [self addDomain:@"world" domain:0 visible:true];
        [self addDomain:@"hud" domain:INT_MAX visible:true];
		
    }
    return self;
}

- (void) dealloc
{
    [mDomains release];
    [mSplashModel release];
    [mModelList release] ;
    [mNewModels release] ;
    [mModelList2 release] ;    
    [mTexts release] ;
    [super dealloc];
}

-(void) test
{
    
    GameonModel* model = [[GameonModel alloc] initWithName:@"test" app:mApp];
    [model createCube:-4.0f  btm:-4.0f b:-4.0f r:4.0f t:4.0f f:4.0f c:mApp.colors.red];
    [model generate];
    model.mEnabled = true;
    [mModelList addObject:model];		
}

-(void)initSplash:(NSString*) name
{
	GameonModel* model = [[GameonModel alloc] initWithName:@"test" app:mApp];
	
//	[model createPlane:-2.0 btm:-1.32f b:0.0f r:2.0f t:1.32f f:0.0f c:mApp.colors.white];
	
    [model createPlane:mApp.mSplashX1 btm:mApp.mSplashY1 b:0.0f r:mApp.mSplashX2 t:mApp.mSplashY2 f:0.0f c:mApp.colors.white grid:nil];    
    
	[mApp.textures newTexture:@"q_splash" file:name];
	[model setTexture:[mApp.textures getTexture:@"q_splash"]];
	GameonModelRef* ref = [[GameonModelRef alloc] init];
	ref.mLoc = INT_MAX;
    [ref setVisible:true];
    [ref set];
	[model addref:ref];
	mSplashModel = model;
	[model generate];
	model.mEnabled = true;		
}

-(void) remove:(GameonModel*) model
{
    if ([mModelList2 indexOfObject:model]!= NSNotFound) {    
        [mModelList2 removeObject:model];
    }
         
    if ([mModelList indexOfObject:model]!= NSNotFound) {    
        [mModelList removeObject:model];
    }
    
    for (RenderDomain* domain in mDomains)
    {
        if ( [domain hasVisible:model])
        {
        
            [domain remVisible:model force:true];
        }
    }
    
    //[model retain];
    
}

-(void) add:(GameonModel*) model
{
    [model generate];
    [mNewModels addObject:model];
    //[model retain];
    
}


-(void) addModels
{
    if (mLocked )return;

    
    for (int a=0; a< [mNewModels count]; a++)
    {
        GameonModel* model = [ mNewModels objectAtIndex:a];
        //[model  retain];
        if (model.mIsModel)
        {
            [mModelList2 addObject:model];
        }else{
            [mModelList addObject:model];
        }
        /*
        if ([model getVisible])
        {
            [self setVisible:model];
        }*/
    }
    
    [mNewModels removeAllObjects];
    
    
}

-(void) setLocked:(bool) locked {
    mLocked = locked;
}

-(void) setLockedDraw:(bool) locked {
    mLockedDraw = locked;
}	

-(void) draw {
    if (gAmbientLightChanged)
	{
        //NSLog(@" set alight %f %f %f %f" , gAmbientLight[0], gAmbientLight[1],gAmbientLight[2],gAmbientLight[3]);
		glLightModelfv(GL_LIGHT_MODEL_AMBIENT, gAmbientLight);
		gAmbientLightChanged = false;
	}	
    //NSLog(@" start draw ---------");
    for (RenderDomain* domain in mDomains)
    {
        [domain draw];
    }

    
    
}

-(void) prepare{
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnable( GL_COLOR_MATERIAL);
    glEnableClientState(GL_VERTEX_ARRAY);	
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CCW);
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
	
    glHint(GL_PERSPECTIVE_CORRECTION_HINT,
              GL_NICEST);
    
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LEQUAL);
	
	
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER,0.05f);
    
	glEnable(GL_LIGHTING);
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, gAmbientLight);
	
	glClearColor(0.0f, 0.0f, 0.0f,1);
	glShadeModel(GL_SMOOTH);

		
    /*
    glHint(GL_PERSPECTIVE_CORRECTION_HINT,
              GL_FASTEST);
    
    glClearColor(1.0f, 1.0f, 1.0f,1);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_DITHER);
    */
}

-(void) clear {

    while (mInDraw) {
/*        
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
 */
    }
    mLockedDraw = true;
    [mModelList2 removeAllObjects];
    [mModelList removeAllObjects];    
    [mNewModels removeAllObjects];
    [mTexts clear];
    for (RenderDomain* domain in mDomains)
    {
        [domain clear];
    }
    
    mLocked = false;
    mLockedDraw = false;
    
}
-(void) reinit
{
    /*
    mLockedDraw = true;
    int len = [mModelList count];
    for (int a=0; a< len; a++) {
        GameonModel* model = [mModelList objectAtIndex:a];
        model.reset();
    }
    
    mLockedDraw = false;*/
}


-(void) drawSplash
{
	if (mSplashModel != nil)
	{
        if (gAmbientLightChanged)
        {
            //NSLog(@" set alight %f %f %f %f" , gAmbientLight[0], gAmbientLight[1],gAmbientLight[2],gAmbientLight[3]);
            glLightModelfv(GL_LIGHT_MODEL_AMBIENT, gAmbientLight);
            gAmbientLightChanged = false;
        }  
        [mSplashModel setState:LAS_VISIBLE];
		[mSplashModel draw:INT_MAX];
        [mSplashModel setState:LAS_HIDDEN];        
	}
	
}

-(void) setAmbientLight:(float)r g:(float)g b:(float)b a:(float) a
{
	gAmbientLight[0] = r;
	gAmbientLight[1] = g;
	gAmbientLight[2] = b;
//	mAmbientLight[3] = a;
	gAmbientLightChanged = true;
    //NSLog(@" %f %f %f %f " , r,g,b,a);
}

-(void)getAmbientLight:(float*)ret
{
	ret[0] = gAmbientLight[0];
	ret[1] = gAmbientLight[1];
	ret[2] = gAmbientLight[2];
//	ret[3] = mAmbientLight[3]; 
}

-(void)setAmbientLightGl:(float)r g:(float)g b:(float)b a:(float)a
{
	gAmbientLight[0] = r;
	gAmbientLight[1] = g;
	gAmbientLight[2] = b;
//	mAmbientLight[3] = a;
	//gAmbientLightChanged = true;
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, gAmbientLight);

	
}

-(RenderDomain*) getDomain:(int) id
{
    for (RenderDomain* domain in mDomains)
    {
        if (domain.mRenderId == id)
        {
            return domain;
        }
    }
    return nil;
}

-(RenderDomain*) getDomainByName:(NSString*) name
{
    for (RenderDomain* domain in mDomains)
    {
        if ([domain.mName isEqualToString:name])
        {
            return domain;
        }
    }
    return nil;
}	

-(RenderDomain*) addDomain:(NSString*)name domain:(int)i visible:(bool) visible
{
    for (RenderDomain* domain in mDomains)
    {
        if ([domain.mName isEqualToString:name] || domain.mRenderId == i)
        {
            return nil;
        }
    }
    RenderDomain* newdomain = [[RenderDomain alloc] initWithName:name forApp:mApp w:mViewWidth h:mViewHeight renderid:i];
    if (visible)
    {
        [newdomain show];
    }
    
    bool inserted = false;
    for (int a= 0 ; a< [mDomains count]; a++)
    {
        RenderDomain* old = [mDomains objectAtIndex:a];
        if (old.mRenderId > i)
        {
            [mDomains insertObject:newdomain atIndex:a];
            inserted = true;
            break;
        }
    }
    
    if (!inserted)
    {
        [mDomains addObject:newdomain];
    }
    return newdomain;
}


-(void)onSurfaceChanged:(int)width h:(int) height
{
    mViewWidth = (float)width;
    mViewHeight = (float)height;
    for (RenderDomain* domain in mDomains)
    {
        [domain onSurfaceChanged:width h:height];
    }
}

-(void)onSurfaceCreated
{
    for (RenderDomain* domain in mDomains)
    {
        [domain onSurfaceCreated];
    }
}

-(void)domainCreate:(NSString*)name domainid:(NSString*)domid bounds:(NSString*)coordsstr 
{
    RenderDomain* domain = [self getDomainByName:name];
    if (domain != nil)
    {
        return;
    }
    
    RenderDomain* newdomain  = [self addDomain:name domain:[domid intValue] visible:false];
    if (newdomain != nil && coordsstr != nil && [coordsstr length] > 0)
    {
        float coords[4];
        [ServerkoParse parseFloatArray:coords max:4 forData:coordsstr];
        [newdomain setBounds:(int)mViewWidth h:(int)mViewHeight bounds:coords];
        
        
    }
}

-(void)domainRemove:(NSString*) name
{
    RenderDomain* domain = [self getDomainByName:name];
    if (domain != nil)
    {
        [domain clear];
        [mDomains removeObject:domain];
    }
}

-(float) gerRelativeX:(float) x
{
    return x/mViewWidth;
}

-(float) gerRelativeY:(float) y
{
    return y/mViewHeight;
}

-(void)domainShow:(NSString*) name
{
    RenderDomain* domain = [self getDomainByName:name];
    if (domain != nil)
    {
        [domain show];
    }
}

-(void)domainHide:(NSString*) name
{
    RenderDomain* domain = [self getDomainByName:name];
    if (domain != nil)
    {
        [domain hide];
    }		
}


@end
