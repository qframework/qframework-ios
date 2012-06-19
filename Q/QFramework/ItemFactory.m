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

#import "ItemFactory.h"
#import "GameonModel.h"
#import "GameonWorld.h"
#import "ColorFactory.h"
#import "TextureFactory.h"
#import "LayoutItem.h"
#import "GameonApp.h"
#import "ServerkoParse.h"
#import "GMath.h"

@implementation ItemFactory


-(id) initWithApp:(GameonApp*) app
{
	if (self = [super init])
	{
        mApp = app;
		mWorld = app.world;
		mModels = [[NSMutableDictionary alloc] init];
        memset(mDefaultTransf, 0, 9 * sizeof(float) );
        mDefaultTransf[3] = 1.0f;
        mDefaultTransf[4] = 1.0f;        
        mDefaultTransf[5] = 1.0f;
        
        mDefaultUV[0] = 0.0f;
        mDefaultUV[1] = 0.0f;
        mDefaultUV[2] = 1.0f;
        mDefaultUV[3] = 1.0f;
        mDefaultColors[0] = 0xFFFFFFFF;        
	}
    return self;
}

- (void) dealloc 
{
	[mModels release];
    [super dealloc];  
}
	

-(LayoutItem*) createItemFromModel:(GameonModel*)model itemid:(int)itemID data:(int)data  item:(LayoutItem*) item
{
    LayoutItem* fig = item;
    if (fig == nil)
    {
        fig = [[LayoutItem alloc] init];
    }
    fig.mType = model.mModelTemplate;
    fig.mModel = model;
    fig.mOwnerMax = model.mSubmodels;
    fig.mOwner = itemID;
    
    return fig;
    
}

-(LayoutItem*)	createItem:(NSString*)type userdata:(int)userdata item:(LayoutItem*) item
{
    NSArray* tokens = [type componentsSeparatedByString:@"."];
    
    if ([tokens count] == 0) return nil;
    
    NSString* imageset = [tokens objectAtIndex:0];
    //NSString* imagetype = [tokens objectAtIndex:1]; 
    
    GameonModel* model = [mModels  objectForKey:imageset];
    if (model == nil) {
        return nil;
    }
    int  imageid = -1;
    if ([tokens count] > 1)
        imageid = [[tokens objectAtIndex:1] intValue];
    
    return [self createItemFromModel:model itemid:imageid data:userdata item:item];
    
}


-(LayoutItem*)	createItem:(NSString*)data source:(LayoutItem*)item
{
    NSString* type = nil;
    NSArray* tokens = [data componentsSeparatedByString:@"|"];
    int userdata = 0;
    if ([tokens count] == 1)
    {
        type = data;
    }
    else {
        
        if ([tokens count] > 0)type = [tokens objectAtIndex:0];
        if ([tokens count] > 1)userdata = [[tokens objectAtIndex:1] intValue];
        
    }
    
    return [self createItem:type userdata:userdata item:item];
}

-(GameonModel*)getFromTemplate:(NSString*)strType data:(NSString*)strData color:(NSString*)strColor
{
    if ( [mModels objectForKey:strData] != nil)
    {
        return [mModels objectForKey:strData];
    }
    
    int textid = mApp.textures.mTextureDefault;

    GLColor* color = nil;
    if (strColor == nil)
    {
        color = mApp.colors.white;
    }else
    {
        color = [mApp.colors getColor:strColor ];
    }
    
    float grid[3] = {1,1,1};
    
    NSArray* tok = [strData componentsSeparatedByString:@"."];
    NSString* template = nil;
    
    if ([tok count] == 1)
    {
        template = strData;
    }else
    {
        template = [tok objectAtIndex:0];
        grid[0] = [[tok objectAtIndex:1] floatValue];
        grid[1] = [[tok objectAtIndex:2] floatValue];
        grid[2] = [[tok objectAtIndex:3] floatValue];
    }
    

    
    
	if ([template isEqualToString:@"sphere"])
    {
        GameonModel* model = [self createFromType:GMODEL_SPHERE color:color texture:textid grid:grid];
        model.mModelTemplate = GMODEL_SPHERE;
        model.mIsModel = true;
        return model;
        
    }else if ([template isEqualToString:@"cube"])
    {
        GameonModel* model = [self createFromType:GMODEL_CUBE color:color texture:textid grid:grid];
        model.mModelTemplate = GMODEL_CUBE;
        model.mIsModel = true;
        return model;
        
    }
		
    GameonModel* model = [[GameonModel alloc] initWithName:template app:mApp];
	
    if ([template isEqualToString:@"cylinder"])
    {
        [model createModel:GMODEL_CYLYNDER ti:[mApp.textures get:TFT_DEFAULT] color:color grid:grid ];
        model.mModelTemplate = GMODEL_CYLYNDER;
        model.mIsModel = true;        
    } else if ([template isEqualToString:@"plane"])
    {
        [model createPlane:(-0.5) btm:(-0.5) b:(0) r:(0.5) t:(0.5) f:(0) c:color grid:grid ];
        model.mModelTemplate = GMODEL_CYLYNDER;
        model.mIsModel = true;
    } else if ([template isEqualToString:@"card52"])
    {
        [model createCard2:-0.5f btm:-0.5f b:0.0f r:0.5f t:0.5f f:0.0f c:mApp.colors.transparent];
        model.mModelTemplate = GMODEL_CARD52;
		model.mForceHalfTexturing = true;
		model.mForcedOwner = 32;   
        model.mHasAlpha = true;
        model.mIsModel = true;        
    } else if ([template isEqualToString:@"cardbela"])
    {
        [model createCard:-0.5f btm:-0.5f b:0.0f r:0.5f t:0.5f f:0.0f c:mApp.colors.transparent];
        model.mModelTemplate = GMODEL_CARD52;
		model.mForceHalfTexturing = true;
		model.mForcedOwner = 32;   
        model.mHasAlpha = true;
        model.mIsModel = true;        
    } else if ([template isEqualToString:@"background"])
    {
        [model createPlane:(-0.5) btm:(-0.5) b:(0) r:(0.5) t:(0.5) f:(0) c:color grid:grid ];
        model.mModelTemplate = GMODEL_BACKGROUND;
        model.mHasAlpha = true;
        model.mIsModel = false;        
    } else
    {
        [model release];
        return nil;
    }
    [model setTexture:textid];
    return model;
    
}

-(void)newFromTemplate:(NSString*)strType data:(NSString*)strData color:(NSString*)color
{
    GameonModel* model = [self getFromTemplate:strType data:strData color:color];
    
    if (model != nil)
    {
        [mModels setObject:model forKey:strType];
    }
    
}

-(void) setTexture:(NSString*)strType data:(NSString*)strData {
    // get object
    GameonModel* model = [mModels  objectForKey:strType];
    if (model == nil) {
        return;
    }
    
    int offsetx = 1, offsety = 1;
    NSString* texture = nil;
    NSArray* tok = [strData componentsSeparatedByString:@";"];
    if ([tok count] < 2)
    {
        // no offset
        texture = strData;
    }else {
        texture = [tok objectAtIndex:0];
        NSString* offset = [tok objectAtIndex:1];
        NSArray* tok2 = [offset componentsSeparatedByString:@","];
        if ([tok2 count] == 2)
        {
            offsetx = [[tok2 objectAtIndex:0] intValue];
            offsety = [[tok2 objectAtIndex:1] intValue];
        }
    }
    
    model.mTextureID = [mApp.textures getTexture:texture];
    [model setTextureOffset:offsetx h:offsety];
}

-(void) createModel:(NSString*)strType 
{
    // get object
    GameonModel* model = [mModels  objectForKey:strType];
    model.mIsModel = true;
    if (model == nil) {
        return;
    }
    
    
    [mWorld add:model];
}	

-(void) setSubmodels:(NSString*)strType data:(NSString*)strData {
    // get object
    GameonModel* model = [mModels  objectForKey:strType];
    if (model == nil) {
        return;
    }
	int vals[16];	
	int count = [ServerkoParse parseIntArray:vals max:16 forData:strData];
    
	if (count > 0) model.mSubmodels = vals[0];
	if (count > 1) model.mForcedOwner = vals[1];
	
}		

-(GameonModel*) createFromType:(int)template color:(GLColor*)color texture:(int)texid grid:(float*)grid
{

    GameonModel* model = [[[GameonModel alloc] initWithName:@"item" app:mApp] autorelease];
    [self addModelFromType:model template:template color:color texture:texid grid:grid];
    return model;
}

-(GameonModel*) addModelFromType:(GameonModel*)model template:(int)template color:(GLColor*)color texture:(int)texid grid:(float*)grid
{
    
	
    if (template == GMODEL_SPHERE)
    {
        [model createModel:GMODEL_SPHERE ti:texid color:color grid:grid];
        model.mModelTemplate = GMODEL_SPHERE;
        model.mIsModel = true;        
		model.mName = @"sphere";
    } else if (template == GMODEL_CUBE)
    {
        [model createModel:GMODEL_CUBE ti:texid color:color grid:grid];
        model.mModelTemplate = GMODEL_CUBE;
        model.mIsModel = true;        
    } else if (template == GMODEL_CARD52)
    {
        [model createCard2:-0.5f btm:-0.5f b:0.0f r:0.5f t:0.5f f:0.0f c:color];
        model.mModelTemplate = GMODEL_CARD52;
		model.mForceHalfTexturing = true;
		model.mForcedOwner = 32;   
        model.mHasAlpha = true;
        model.mIsModel = true;
        [model setTexture:texid ];
    } else if (template == GMODEL_BACKGROUND)
    {
        [model createPlane:-0.5f btm:-0.5f b:0.0f r:0.5f t:0.5f f:0.0f c:color grid:grid];
        model.mModelTemplate = GMODEL_BACKGROUND;
		model.mForceHalfTexturing = false;
        model.mHasAlpha = true;
		model.mIsModel = false;
        [model setTexture:texid ];
    } else if (template == GMODEL_BACKIMAGE)
    {
        [model createPlane2:-0.5f btm:-0.5f b:0.0f r:0.5f t:0.5f f:0.0f c:color];
        model.mModelTemplate = GMODEL_BACKGROUND;
		model.mForceHalfTexturing = false;
        model.mHasAlpha = true;
		model.mIsModel = false;
        [model setTexture:texid ];
    } else
    {
        [model release];
        return nil;
    }
    
    return model;
    
}


-(void) processObject:(NSMutableDictionary*)objData
{
	NSString* name = [objData valueForKey:@"name"];
	NSString* template = [objData valueForKey:@"template"];
	if (name == nil || template == nil)
	{
		return;
	}
	NSString* color = [objData valueForKey:@"color"];

	[self newFromTemplate:name data:template color:color];
		
	NSString* texture = [objData valueForKey:@"texture"];
	if (texture != nil)
	{
		[self setTexture:name data:texture];
	}

	NSString* submodels = [objData valueForKey:@"submodels"];
	if (submodels != nil)
	{
		[self setSubmodels:name data:submodels];
	}			
	
	[self createModel:name];

}

-(void)initModels:(NSMutableDictionary*)response
{
    NSMutableArray* models = [response valueForKey:@"model"];
    for (int a=0; a< [models count]; a++)
    {
		NSMutableDictionary* pCurr = [models objectAtIndex:a];
		[self processObject:pCurr];        
	}	
	
}

-(void)newEmpty:(NSString*) name
{
    GameonModel* model = [[GameonModel alloc] initWithName:name app:mApp];
    model.mIsModel = true;
    if (model != nil)
    {
        [mModels setObject:model forKey:name];
    }
}

-(void)addShape:(NSString*)name type:(NSString*)type transform:(NSString*)transform colors:(NSString*)colors uvbounds:(NSString*)uvbounds
{
    GameonModel* model = [mModels objectForKey:name];
    if (model == nil) 
    {
        return;
    }
    
    float transf[9];
    float uvb[6];
    int* cols;
    
    if (transform != nil)
    {
        for (int a=0; a< 9; a++)
        {
            transf[a] = mDefaultTransf[a];
        }
        [ServerkoParse parseFloatArray:transf max:9  forData:transform];
    }
    else
    {
        memcpy(transf,mDefaultTransf, sizeof(float)*9);
    }
    
    
    float mat[16];
    matrixIdentity(mat);
    matrixTranslate(mat, transf[0],transf[1],transf[2]);
    matrixRotate(mat,transf[6], 1, 0, 0);
    matrixRotate(mat,transf[7], 0, 1, 0);
    matrixRotate(mat,transf[8], 0, 0, 1);
    matrixScale(mat, transf[3],transf[4],transf[5]);		
    
    
    if (uvbounds != nil)
    {
        [ServerkoParse parseFloatArray:uvb max:6  forData:uvbounds];        
    }
    else
    {
        memcpy(uvb ,mDefaultUV, sizeof(float)*4);
    }
    
    int clen = 1;
    if (colors != nil)
    {
        cols = [ServerkoParse parseColorVector:colors datalen:&clen];
    }else
    {
        cols = malloc(sizeof(int));
        cols[0]  = mDefaultColors[0];
    }
    
    
    if ([type isEqualToString:@"plane"])
    {
        [model addPlane:mat colors:cols colorlen:clen uvbounds:uvb];
    }
    free(cols);
    /*
     else if (type.equals("cube"))
     {
     model.addCube(bounds, cols, uvb);
     }else if (type.equals("cylinder"))
     {
     model.addCyl(bounds, cols, uvb);
     }else if (type.equals("sphere"))
     {
     model.addSphere(bounds, cols, uvb);
     }else if (type.equals("pyramid"))
     {
     model.addPyramid(bounds, cols, uvb);
     }*/
    
}

-(void)addShapeFromData:(NSString*)name data:(NSString*)data transform:(NSString*)transform uvbounds:(NSString*) uvbounds
{
    GameonModel* model = [mModels objectForKey:name];
    if (model == nil) 
    {
        return;
    }
    
    float transf[9];
    float uvb[6];

    for (int a=0; a< 9; a++)
    {
        transf[a] = mDefaultTransf[a];
    }    
    if (transform != nil)
    {

        [ServerkoParse parseFloatArray:transf max:9  forData:transform];
    }
    
    if (uvbounds != nil)
    {
        [ServerkoParse parseFloatArray:uvb max:6  forData:uvbounds];        
    }
    else
    {
        memcpy(uvb ,mDefaultUV, sizeof(float)*4);
    }
    
    
    float mat[16];
    matrixIdentity(mat);
    matrixTranslate(mat, transf[0],transf[1],transf[2]);
    matrixRotate(mat,transf[6], 1, 0, 0);
    matrixRotate(mat,transf[7], 0, 1, 0);
    matrixRotate(mat,transf[8], 0, 0, 1);
    matrixScale(mat, transf[3],transf[4],transf[5]);		
    
    int datalen = 0;
    float* inputdata = [ServerkoParse parseFloatVector:data datalen:&datalen];
    [model createModelFromData:inputdata length:datalen transform:mat uvbounds:uvb];
    free(inputdata);
}

@end


