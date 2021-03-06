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

#import "GameonModel.h"
#import "GameonModelData.h"
#import "GLVertex.h"
#import "GLShape.h"
#import "ColorFactory.h"
#import "GLFace.h"
#import "TextureFactory.h"
#import "GameonModelRef.h"
#import "GameonWorld.h"
#import "AnimData.h"
#import "AnimFactory.h"
#import "GameonCS.h"
#import "GameonApp.h"
#import "GMath.h"
#import "RenderDomain.h"
#import "LayoutArea.h"
#import "AreaIndexPair.h"
#import "FloatBuffer.h"

@implementation GameonModelRefId
@synthesize name;
@synthesize refid;
@synthesize alias;
@end



@implementation GameonModel

@synthesize mHasAlpha;
@synthesize mIsModel;
@synthesize mSubmodels;
@synthesize mModelTemplate;
@synthesize mName;
@synthesize mOnClick;
@synthesize mParentArea;

static float mStaticBoundsPlane[] =  
{ 
    -0.5f,-0.5f,0.0f,1.0f,
    0.5f,-0.5f,0.0f,1.0f,
    -0.5f,0.5f,0.0f,1.0f,
    0.5f,0.5f,0.0f,1.0f 
};

static float mStaticBounds[] =  
{ 
    0.0f,0.0f,0.0f,1.0f,
    0.0f,0.0f,0.0f,1.0f,
    0.0f,0.0f,0.0f,1.0f,
    0.0f,0.0f,0.0f,1.0f 
};

- (id) initWithName:(NSString*)name app:(GameonApp*)app parenArea:(LayoutArea*)parent
{
	if (self = [super initWithApp:app])
	{
        mParentArea = parent;
        mRefs = [[NSMutableArray alloc] init] ;
		mVisibleRefs = [[NSMutableArray alloc] init] ;
        mSubmodels = 0;
        mModelTemplate = GMODEL_NONE;
        mHasAlpha = false;
        mIsModel = false;
		mTextureID = [mApp.textures get:TFT_DEFAULT];
		mWorld = app.world;
		mApp = app;
		mActive = true;
    }
    
    return self;
}

- (void) dealloc 
{
    [mRefs release];
    [mVisibleRefs release];
    [super dealloc];  
}


- (void) createModel2:(GameonModelData_Type)type left:(float)aleft bottom:(float)abottom back:(float)aback 
                    right:(float)aright top:(float)atop front:(float)afront tid:(int) textid 
{
    float ratiox = aright - aleft;
    float ratioy = afront - abottom;
    float ratioz = atop - aback;    	
    
    modeldata* data;
    data = GameonModelData_getData(type);

    GLColor* color = mApp.colors.white;
    
    int len = GameonModelData_getDataLen(type);
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    float xmid = (aright + aleft) /2;
    float ymid = (atop + abottom) /2;
    float zmid = (afront + aback) /2;
    
    for (int a=0; a< len; a+=9 ) {
        float vx1 = (*data)[a][0];
        float vy1 = (*data)[a][1];
        float vz1 = (*data)[a][2];
        
        float tu1 = (*data)[a+2][0];
        float tv1 = 1.0f- (*data)[a+2][1];    		
        vx1 *= ratiox; vx1 += xmid;
        vy1 *= ratioy; vy1 += ymid;
        vz1 *= ratioz; vz1 += zmid;
        GLVertex* v1 = [shape addVertex:vx1 y:vy1 z:vz1 tu:tu1 tv:tv1 c:color];
        
        float vx2 = (*data)[a+3][0];
        float vy2 = (*data)[a+3][1];
        float vz2 = (*data)[a+3][2];
        
        float tu2 = (*data)[a+5][0];
        float tv2 = 1.0f- (*data)[a+5][1];    		
        
        vx2 *= ratiox; vx2 += xmid;
        vy2 *= ratioy; vy2 += ymid;
        vz2 *= ratioz; vz2 += zmid;
        GLVertex* v2 = [shape addVertex:vx2 y:vy2 z:vz2 tu:tu2 tv:tv2 c:color];
        
        float vx3 = (*data)[a+6][0];
        float vy3 = (*data)[a+6][1];
        float vz3 = (*data)[a+6][2];
        
        float tu3 = (*data)[a+8][0];
        float tv3 = 1.0f- (*data)[a+8][1];    		
        
        vx3 *= ratiox; vx3 += xmid;
        vy3 *= ratioy; vy3 += ymid;
        vz3 *= ratioz; vz3 += zmid;
        GLVertex* v3 = [shape addVertex:vx3 y:vy3 z:vz3 tu:tu3 tv:tv3 c:color];    		
        
        GLFace* fc = [[[GLFace alloc] init] autorelease];
        [fc setVertex:v1 v2:v2 v3:v3];
        [shape addFace:fc];
        //shape.setFaceColor(a/9, color);
    }
    
    [self addShape:shape];
    mTextureID = textid;
    
}


- (void) createModel:(GameonModelData_Type)type ti:(int)textid color:(GLColor*)color grid:(float*)grid
{
    
    
    modeldata* data;
    data = GameonModelData_getData(type);
    
    int len = GameonModelData_getDataLen(type);

    float divx = 1; 
    float divy = 1;
    float divz = 1;
    float countx = 1; 
    float county = 1;
    float countz = 1;
    
    if (grid != nil)
    {
        divx = 1 / grid[0];
        divy = 1 / grid[1];
        divz = 1 / grid[2];
        countx = grid[0]*2; 
        county = grid[1]*2;
        countz = grid[2]*2;
        
    }
    
    for (float x = 1.0f; x <= countx; x+= 2)
    {
        for (float y = 1.0f; y <= county; y+= 2)
        {    		
            for (float z = 1.0f; z <= countz; z+= 2)
            {  
                
                GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
                
                for (int a=0; a< len; a+=9 ) {
                    float vx1 = (*data)[a][0] * divx+ -0.5f + divx*x/2;
                    float vy1 = (*data)[a][1] * divy+ -0.5f + divy*y/2;
                    float vz1 = (*data)[a][2] * divz+ -0.5f + divz*z/2;
                    
                    float tu1 = (*data)[a+2][0];
                    float tv1 = 1.0f - (*data)[a+2][1];    		
                    GLVertex* v1 = [shape addVertex:vx1 y:vy1 z:vz1 tu:tu1 tv:tv1 c:color];
                    
                    float vx2 = (*data)[a+3][0] * divx+ -0.5f + divx*x/2;
                    float vy2 = (*data)[a+3][1] * divy+ -0.5f + divy*y/2;
                    float vz2 = (*data)[a+3][2] * divz+ -0.5f + divz*z/2;
                    
                    float tu2 = (*data)[a+5][0];
                    float tv2 = 1.0f - (*data)[a+5][1];    		
                    
                    GLVertex* v2 = [shape addVertex:vx2 y:vy2 z:vz2 tu:tu2 tv:tv2 c:color];
                    
                    float vx3 = (*data)[a+6][0] * divx+ -0.5f + divx*x/2;
                    float vy3 = (*data)[a+6][1] * divy+ -0.5f + divy*y/2;
                    float vz3 = (*data)[a+6][2] * divz+ -0.5f + divz*z/2;
                    
                    float tu3 = (*data)[a+8][0];
                    float tv3 = 1.0f - (*data)[a+8][1];    		
                    
                    GLVertex* v3 = [shape addVertex:vx3 y:vy3 z:vz3 tu:tu3 tv:tv3 c:color];    		
                    
                    GLFace* fc = [[[GLFace alloc] init] autorelease] ;
                    [fc setVertex:v1 v2:v2 v3:v3];
                    [shape addFace:fc];
                    
                }
                [self addShape:shape];

            }
        }
    }
    
    mTextureID = textid;
    
}    

- (void) createModel:(GameonModelData_Type)type left:(float)aleft bottom:(float)abottom back:(float)aback 
               right:(float)aright top:(float)atop front:(float)afront c:(GLColor*) color
{
    float ratiox = aright - aleft;
    float ratioy = afront - abottom;
    float ratioz = atop - aback;    	
    
    
    modeldata* data;
    data = GameonModelData_getData(type);
    
    int len = GameonModelData_getDataLen(type);
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    float xmid = (aright + aleft) /2;
    float ymid = (atop + abottom) /2;
    float zmid = (afront + aback) /2;
    
    for (int a=0; a< len; a+=9 ) {
        float vx1 = (*data)[a][0];
        float vy1 = (*data)[a][1];
        float vz1 = (*data)[a][2];
        
        vx1 *= ratiox; vx1 += xmid;
        vy1 *= ratioy; vy1 += ymid;
        vz1 *= ratioz; vz1 += zmid;
        float tu1 = (*data)[a+2][0];
        float tv1 = 1.0f - (*data)[a+2][1];    		
        GLVertex* v1 = [shape addVertex:vx1 y:vy1 z:vz1 tu:tu1 tv:tv1 c:color];
        
        float vx2 = (*data)[a+3][0];
        float vy2 = (*data)[a+3][1];
        float vz2 = (*data)[a+3][2];
        
        vx2 *= ratiox; vx2 += xmid;
        vy2 *= ratioy; vy2 += ymid;
        vz2 *= ratioz; vz2 += zmid;
        float tu2 = (*data)[a+5][0];
        float tv2 = 1.0f - (*data)[a+5][1];    		
        GLVertex* v2 = [shape addVertex:vx2 y:vy2 z:vz2 tu:tu2 tv:tv2 c:color];
        
        float vx3 = (*data)[a+6][0];
        float vy3 = (*data)[a+6][1];
        float vz3 = (*data)[a+6][2];
        
        vx3 *= ratiox; vx3 += xmid;
        vy3 *= ratioy; vy3 += ymid;
        vz3 *= ratioz; vz3 += zmid;
        float tu3 = (*data)[a+8][0];
        float tv3 = 1.0f - (*data)[a+8][1];    		
        GLVertex* v3 = [shape addVertex:vx3 y:vy3 z:vz3 tu:tu3 tv:tv3 c:color];    		
        
        GLFace* fc = [[[GLFace alloc] init] autorelease];
        [fc setVertex:v1 v2:v2 v3:v3];
        [shape addFace:fc];
        
    }
    
    [self addShape:shape];
}
- (void) createOctogon:(float)left btm:(float)bottom b:(float)back 
                 r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];

    float divx = (right - left ) / 4;
    float divy = (top - bottom ) / 4;
    GLColor* c = [[[GLColor alloc] init] autorelease];
    c.red = color.red;
    c.blue = color.blue;
    c.green = color.green;
    c.alpha = color.alpha/2;    
    
    GLVertex* p1 = [shape addVertex:(left + divx) y:top z:front tu:0.0f tv:1.00f c:c ];
    GLVertex* p2 = [shape addVertex:(left + 3 * divx) y:top z:front tu:0.0f tv:1.00f c:c];
    GLVertex* p3 = [shape addVertex:right  y:(bottom + 3 * divy) z:front tu:0.0f tv:1.00f c:c];
    GLVertex* p4 = [shape addVertex:right  y:(bottom +  divy) z:front tu:0.0f tv:1.00f c:c];
    GLVertex* p5 = [shape addVertex:(left + 3*divx) y:bottom z:front tu:0.0f  tv:1.00f c:c];
    GLVertex* p6 = [shape addVertex:(left + divx) y:bottom z:front  tu:0.0f  tv:1.00f c:c];
    GLVertex* p7 = [shape addVertex:left y:(bottom + divy) z:front tu:0.0f tv:1.00f c:c ];
    GLVertex* p8 = [shape addVertex:left y:(bottom + 3* divy) z:front tu:0.0f tv:1.00f c:c ];
    
    
    //GLColor* ccolor = [cf getColor:@"AAFFFFFF"];
    GLVertex* center = [shape addVertex:( (right + left) / 2) y:((top + bottom ) / 2) z:front tu:0.5f tv:0.5f c:mApp.colors.white];
    // front

    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:center v2:p1 v3:p8];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:center v2:p2 v3:p1];
    [shape addFace:face2];
    
    GLFace* face3 = [[[GLFace alloc] init] autorelease];
    [face3   setVertex:center v2:p3 v3:p2];
    [shape addFace:face3];
    
    GLFace* face4 = [[[GLFace alloc] init] autorelease];
    [face4   setVertex:center v2:p4 v3:p3];
    [shape addFace:face4];
    
    GLFace* face5 = [[[GLFace alloc] init] autorelease];
    [face5   setVertex:center v2:p5 v3:p4];
    [shape addFace:face5];
    
    GLFace* face6 = [[[GLFace alloc] init] autorelease];
    [face6   setVertex:center v2:p6 v3:p5];
    [shape addFace:face6];    

    GLFace* face7 = [[[GLFace alloc] init] autorelease];
    [face7  setVertex:center v2:p7 v3:p6];
    [shape addFace:face7];    

    GLFace* face8 = [[[GLFace alloc] init] autorelease];
    [face8   setVertex:center v2:p8 v3:p7];
    [shape addFace:face8];    
    
    [self addShape:shape];

}    



- (void) createPlane:(float)left btm:(float)bottom b:(float)back 
                   r:(float)right t:(float)top f:(float)front c:(GLColor*)color grid:(float*)grid
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
  	float divx = 1; 
    float divy = 1;
    
    float w = right-left;
    float h = top-bottom;
    
    if (grid != nil)
    {
        divx = w / grid[0];
        divy = h / grid[1];
    }
    
    for (float x = left; x < right; x+= divx)
    {
        for (float y = bottom; y < top; y+= divy)
        {    		
            float left2 = x;
            float right2 = divx + x;
            if (right2 > right)
            {
                right2 = right;
            }
            float top2 = divy + y;
            if (top2 > top)
            {
                top2 = top;
            }				    		
            float bottom2 = y;

            GLVertex* leftBottomFront = [shape addVertex:left2 y:bottom2 z:front tu:0.01f tv:0.99f c:color];
            GLVertex* rightBottomFront = [shape addVertex:right2 y:bottom2 z:front tu:0.99f tv:0.99f c:color];
            GLVertex* leftTopFront = [shape addVertex:left2 y:top2 z:front tu:0.01f  tv:0.01f c:color];
            GLVertex* rightTopFront = [shape addVertex:right2 y:top2 z:front tu:0.99f tv:0.01f c:color];

            GLFace* face1 = [[[GLFace alloc] init] autorelease];
            [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
            [shape addFace:face1];
            
            GLFace* face2 = [[[GLFace alloc] init] autorelease];
            [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
            [shape addFace:face2];
          
            [self addShape:shape];
        }
    }
    
}

- (void) createPlane4:(float)left btm:(float)bottom b:(float)back 
                   r:(float)right t:(float)top f:(float)front c1:(GLColor*)c1 c2:(GLColor*)c2
{
    
    if (c1 == nil) c1 = mApp.colors.white;
    if (c2 == nil) c2 = mApp.colors.white;    
    
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front tu:0.0f tv:1.00f c:c1];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front tu:1.0f tv:1.00f c:c1];
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front tu:0.0f  tv:0.00f c:c2];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front tu:1.00f tv:0.00f c:c2];
    
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
    
    [self addShape:shape];
    
}


- (void) createPlaneForLetter:(float)left btm:(float)bottom b:(float)back 
                            r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease ];

    GLVertex* leftBottomFront = [shape addVertexNew:left y:bottom z:front tu:0.00f tv:1.00f c:color];
    GLVertex* rightBottomFront = [shape addVertexNew:right y:bottom z:front tu:1.00f tv:1.00f c:color];
    GLVertex* leftTopFront = [shape addVertexNew:left y:top z:front tu:0.00f  tv:0.00f c:color];
    GLVertex* rightTopFront = [shape addVertexNew:right y:top z:front tu:1.00f tv:0.00f c:color];
    
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
    
    [self addShape:shape];

}

- (void) createPlane2:(float)left btm:(float)bottom b:(float)back 
                    r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front tu:0.0f tv:1.0f c:color];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front tu:1.0f tv:1.0f c:color];
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front tu:0.00f  tv:0.0f c:color];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front tu:1.0f tv:0.0f c:color];
    
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
    
    [self addShape:shape];

}


- (void) createPlane3:(float)left btm:(float)bottom b:(float)back 
                    r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front tu:0.0f tv:1.0f c:color];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front tu:1.0f tv:1.0f c:mApp.colors.white];
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front tu:0.0f  tv:0.0f c:color];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front tu:1.0f tv:0.0f c:color];
    
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
    
    [self addShape:shape];

}

- (void) createCube:(float)left btm:(float)bottom b:(float)back 
                   r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease ];

    GLColor* white = mApp.colors.white;
 
    GLVertex* leftBottomBack = [shape addVertex:left y:bottom z:back tu:0 tv:0  c:white ];
    GLVertex* rightBottomBack = [shape addVertex:right y:bottom z:back tu:0 tv:0 c:white ];
    GLVertex* leftTopBack = [shape addVertex:left y:top z:back tu:0 tv:0 c:white];
    GLVertex* rightTopBack = [shape addVertex:right y:top z:back tu:0 tv:0 c:white];
    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front tu:0 tv:0 c:color];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front tu:0 tv:0 c:color];
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front tu:0 tv:0 c:color];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front tu:0 tv:0 c:white];

    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomBack v2:rightBottomFront v3:leftBottomFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomBack v2:rightBottomBack v3:rightBottomFront];
    [shape addFace:face2];
    
    GLFace* face3 = [[[GLFace alloc] init] autorelease];
    [face3   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face3];
    
    GLFace* face4 = [[[GLFace alloc] init] autorelease];
    [face4   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face4];
    
    
    GLFace* face5 = [[[GLFace alloc] init] autorelease];
    [face5   setVertex:leftBottomBack v2:leftTopFront v3:leftTopBack];
    [shape addFace:face5];
    
    GLFace* face6 = [[[GLFace alloc] init] autorelease];
    [face6   setVertex:leftBottomBack v2:leftBottomFront v3:leftTopFront];
    [shape addFace:face6];
    
    
    GLFace* face7 = [[[GLFace alloc] init] autorelease];
    [face7   setVertex:rightBottomBack v2:rightTopFront v3:rightBottomFront];
    [shape addFace:face7];
    
    GLFace* face8 = [[[GLFace alloc] init] autorelease];
    [face8   setVertex:rightBottomBack v2:rightTopBack v3:rightTopFront];
    [shape addFace:face8];
    

    GLFace* face9 = [[[GLFace alloc] init] autorelease];
    [face9   setVertex:leftBottomBack v2:rightTopBack v3:rightBottomBack];
    [shape addFace:face9];
    
    GLFace* face10 = [[[GLFace alloc] init] autorelease];
    [face10   setVertex:leftBottomBack v2:leftTopBack v3:rightTopBack];
    [shape addFace:face10];

    GLFace* face11 = [[[GLFace alloc] init] autorelease];
    [face11   setVertex:leftTopBack v2:rightTopFront v3:rightTopBack];
    [shape addFace:face11];
    
    GLFace* face12 = [[[GLFace alloc] init] autorelease];
    [face12   setVertex:leftTopBack v2:leftTopFront v3:rightTopFront];
    [shape addFace:face12];
    
    [self addShape:shape];

 }

- (void)addref:(GameonModelRef*) ref
{
    if ([mRefs indexOfObject:ref] == NSNotFound )
    {
        [mRefs addObject:ref];
        [ref set];
        mEnabled = true;
    }
    [ref setParent:self];
    if ([ref getVisible])
    {
        [self addVisibleRef:ref];
    }
    
    
}

-(void)draw:(int) loc
{

    if (!mEnabled) {
        return;
    }    
    
    int len = [mVisibleRefs count];
    //NSLog(@" refsno %d" , len);

    if (len > 0) {
        [self setupRef];
        for (int a=0; a<len ; a++)
        {
            GameonModelRef* ref = [mVisibleRefs objectAtIndex:a];
            if (ref.mLoc == loc) {
                [self drawRef:ref init:true];
            }
        }
    }
}

-(void) removeref:(GameonModelRef*) ref 
{
    if ([mRefs indexOfObject:ref] != NSNotFound )
    {
        [mRefs removeObject:ref];
        if ([mRefs count] == 0)
        {
            mEnabled = false;
        }
    }
    
}

- (void) setTexture:(int) i 
{
    mTextureID = i;
    
}

- (void) createCard:(float)left btm:(float)bottom b:(float)back 
                   r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    float t =0.002f;
    
    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front+t tu:0.0f tv:0.00f c:color];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front+t tu:1.0f tv:0.00f c:color];
    GLVertex* leftBottom2Front = [shape addVertex:left y:(bottom+top)/2 z:front+t tu:0.0f  tv:1.00f c:color];
    GLVertex* rightBottom2Front = [shape addVertex:right y:(bottom+top)/2 z:front+t tu:1.00f tv:1.00f c:color];

    GLVertex* leftBottom2Front1 = [shape addVertex:left y:(bottom+top)/2 z:front+t tu:0.0f  tv:1.00f c:color];
    GLVertex* rightBottom2Front1 = [shape addVertex:right y:(bottom+top)/2 z:front+t tu:1.00f tv:1.00f c:color];
    
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front+t tu:0.0f  tv:0.00f c:color];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front+t tu:1.00f tv:0.00f c:color];
    
    
    
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottom2Front v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottom2Front v2:rightBottom2Front v3:rightTopFront];
    [shape addFace:face2];

    GLFace* face3 = [[[GLFace alloc] init] autorelease];
    [face3   setVertex:leftBottomFront v2:rightBottom2Front1 v3:leftBottom2Front1];
    [shape addFace:face3];
    
    GLFace* face4 = [[[GLFace alloc] init] autorelease];
    [face4   setVertex:leftBottomFront v2:rightBottomFront v3:rightBottom2Front1];
    [shape addFace:face4];
    
    
    GLVertex* leftBottomFront_ = [shape addVertex:left y:bottom z:front-t tu:0.0f tv:0.00f c:color];
    GLVertex* rightBottomFront_ = [shape addVertex:right y:bottom z:front-t tu:1.0f tv:0.00f c:color];
    GLVertex* leftBottom2Front_ = [shape addVertex:left y:(bottom+top)/2 z:front-t tu:0.0f  tv:1.00f c:color];
    GLVertex* rightBottom2Front_ = [shape addVertex:right y:(bottom+top)/2 z:front-t tu:1.00f tv:1.00f c:color];
    
    GLVertex* leftTopFront_ = [shape addVertex:left y:top z:front-t tu:0.0f  tv:0.00f c:color];
    GLVertex* rightTopFront_ = [shape addVertex:right y:top z:front-t tu:1.00f tv:0.00f c:color];
    
    GLFace* face1_ = [[[GLFace alloc] init] autorelease];
    [face1_   setVertex:leftBottom2Front_ v2:leftTopFront_ v3:rightTopFront_];
    [shape addFace:face1_];
    
    GLFace* face2_ = [[[GLFace alloc] init] autorelease];
    [face2_   setVertex:leftBottom2Front_ v2:rightTopFront_ v3:rightBottom2Front_];
    [shape addFace:face2_];
    
    GLFace* face3_ = [[[GLFace alloc] init] autorelease];
    [face3_   setVertex:rightBottom2Front_ v2:leftBottomFront_ v3:leftBottom2Front_];
    [shape addFace:face3_];
    
    GLFace* face4_ = [[[GLFace alloc] init] autorelease];
    [face4_   setVertex:rightBottomFront_ v2:leftBottomFront_ v3:rightBottom2Front_];
    [shape addFace:face4_];
    
    [self addShape:shape];

}

- (void) createCard2:(float)left btm:(float)bottom b:(float)back 
                   r:(float)right t:(float)top f:(float)front c:(GLColor*)color
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    float w = (right-left) / 30;    
    float t =0.002f;
    
    GLVertex* leftBottomFront = [shape addVertex:left+w y:bottom+w z:front+t tu:0.0f tv:1.00f c:color];
    GLVertex* rightBottomFront = [shape addVertex:right-w y:bottom+w z:front+t tu:1.0f tv:1.00f c:color];
    GLVertex* leftTopFront = [shape addVertex:left+w y:top-w z:front+t tu:0.0f  tv:0.00f c:color];
    GLVertex* rightTopFront = [shape addVertex:right-w y:top-w z:front+t tu:1.00f tv:0.00f c:color];
    
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];

    GLVertex* leftBottomFront_ = [shape addVertex:left+w y:bottom+w z:front-t tu:1.0f tv:1.00f c:color];
    GLVertex* rightBottomFront_ = [shape addVertex:right-w y:bottom+w z:front-t  tu:0.0f tv:1.00f c:color];
    GLVertex* leftTopFront_ = [shape addVertex:left+w y:top-w z:front-t  tu:1.00f tv:0.00f c:color];
    GLVertex* rightTopFront_ = [shape addVertex:right-w y:top-w z:front-t tu:0.0f  tv:0.00f c:color];
    
    GLFace* face1_ = [[[GLFace alloc] init] autorelease];
    [face1_   setVertex:leftBottomFront_ v2:leftTopFront_ v3:rightTopFront_];
    [shape addFace:face1_];
    
    GLFace* face2_ = [[[GLFace alloc] init] autorelease];
    [face2_   setVertex:leftBottomFront_ v2:rightTopFront_ v3:rightBottomFront_];
    [shape addFace:face2_];
    
    
    [self addShape:shape];
    
}

-(void) setState:(int) state
{
	if (!mActive && state == LAS_VISIBLE)
		return;

			
    for (int a=0; a< [mRefs count]; a++)
    {
        GameonModelRef* ref = [mRefs objectAtIndex:a];
        if (state == LAS_HIDDEN)
        {
            [ref setVisible:false];
        }else
        {
            [ref setVisible:true];
        }
    }

}

- (void) createFrame:(float)left btm:(float)bottom b:(float)back 
                   r:(float)right t:(float)top f:(float)front 
				   fw:(float)fw fh:(float)fh c:(GLColor*)color
{
	
	GLColor* c;
	if (color == nil)
	{
		c = mApp.colors.white;
	}
	else
	{
		c = color;
	}
	
	[self createPlane2:left-fw/2 btm:bottom-fh/2 b:front   r:left+fw/2 t:top+fh/2 f:front c:color ];
	[self createPlane2:right-fw/2 btm:bottom-fh/2 b:front  r:right+fw/2 t:top+fh/2 f:front c:color];
	
	[self createPlane2:left+fw/2 btm:bottom-fh/2 b:front r:right-fw/2 t:bottom+fh/2 f:front c:color];
	[self createPlane2:left+fw/2 btm:top-fh/2 b:front r:right-fw/2 t:top+fh/2 f:front c:color];
	
}

- (void) createPlaneTex:(float)left btm:(float)bottom b:(float)back r:(float)right t:(float)top f:(float)front 
						tu1:(float)tu1 tv1:(float)tv1 tu2:(float)tu2 tv2:(float)tv2 c:(GLColor**)colors
                        no:(float)no div:(float)div
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];


    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front tu:tu1 tv:tv2 c:mApp.colors.white];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front tu:tu2 tv:tv2 c:mApp.colors.white];
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front tu:tu1  tv:tv1 c:mApp.colors.white];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front tu:tu2 tv:tv1 c:mApp.colors.white];

	float val1 = no * div;
	float val2 = (no+1) * div;

	leftBottomFront.red = colors[0].red + (int)((colors[2].red-colors[0].red) * val1);
	leftBottomFront.green = colors[0].green + (int)((colors[2].green-colors[0].green) * val1);
	leftBottomFront.blue = colors[0].blue + (int)((colors[2].blue-colors[0].blue) * val1);
	leftBottomFront.alpha = colors[0].alpha + (int)((colors[2].alpha-colors[0].alpha) * val1);

	rightBottomFront.red = colors[1].red + (int)((colors[3].red-colors[1].red) * val1);
	rightBottomFront.green = colors[1].green + (int)((colors[3].green-colors[1].green) * val1);
	rightBottomFront.blue = colors[1].blue + (int)((colors[3].blue-colors[1].blue) * val1);
	rightBottomFront.alpha = colors[1].alpha + (int)((colors[3].alpha-colors[1].alpha) * val1);

	leftTopFront.red = colors[0].red + (int)((colors[2].red-colors[0].red) * val2);
	leftTopFront.green = colors[0].green + (int)((colors[2].green-colors[0].green) * val2);
	leftTopFront.blue = colors[0].blue + (int)((colors[2].blue-colors[0].blue) * val2);
	leftTopFront.alpha = colors[0].alpha + (int)((colors[2].alpha-colors[0].alpha) * val2);

	rightTopFront.red = colors[1].red + (int)((colors[3].red-colors[1].red) * val2);
	rightTopFront.green = colors[1].green + (int)((colors[3].green-colors[1].green) * val2);
	rightTopFront.blue = colors[1].blue + (int)((colors[3].blue-colors[1].blue) * val2);
	rightTopFront.alpha = colors[1].alpha + (int)((colors[3].alpha-colors[1].alpha) * val2);
	
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
  
    [self addShape:shape];
}

- (void) createPlaneTex2:(float)left btm:(float)bottom b:(float)back r:(float)right t:(float)top f:(float)front 
                    tu1:(float)tu1 tv1:(float)tv1 tu2:(float)tu2 tv2:(float)tv2 c:(GLColor**)colors
                     no:(float)no div:(float)div
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    
    GLVertex* leftBottomFront = [shape addVertex:left y:bottom z:front tu:tu1 tv:tv2 c:mApp.colors.white];
    GLVertex* rightBottomFront = [shape addVertex:right y:bottom z:front tu:tu2 tv:tv2 c:mApp.colors.white];
    GLVertex* leftTopFront = [shape addVertex:left y:top z:front tu:tu1  tv:tv1 c:mApp.colors.white];
    GLVertex* rightTopFront = [shape addVertex:right y:top z:front tu:tu2 tv:tv1 c:mApp.colors.white];
    
	float val1 = no * div;
	float val2 = (no+1) * div;
    
	leftBottomFront.red = colors[0].red + (int)((colors[2].red-colors[0].red) * val1);
	leftBottomFront.green = colors[0].green + (int)((colors[2].green-colors[0].green) * val1);
	leftBottomFront.blue = colors[0].blue + (int)((colors[2].blue-colors[0].blue) * val1);
	leftBottomFront.alpha = colors[0].alpha + (int)((colors[2].alpha-colors[0].alpha) * val1);
    
	rightBottomFront.red = colors[0].red + (int)((colors[2].red-colors[0].red) * val2);
	rightBottomFront.green = colors[0].green + (int)((colors[2].green-colors[0].green) * val2);
	rightBottomFront.blue = colors[0].blue + (int)((colors[2].blue-colors[0].blue) * val2);
	rightBottomFront.alpha = colors[0].alpha + (int)((colors[2].alpha-colors[0].alpha) * val2);
    
	leftTopFront.red = colors[1].red + (int)((colors[3].red-colors[1].red) * val1);
	leftTopFront.green = colors[1].green + (int)((colors[3].green-colors[1].green) * val1);
	leftTopFront.blue = colors[1].blue + (int)((colors[3].blue-colors[1].blue) * val1);
	leftTopFront.alpha = colors[1].alpha + (int)((colors[3].alpha-colors[1].alpha) * val1);
    
	rightTopFront.red = colors[1].red + (int)((colors[3].red-colors[1].red) * val2);
	rightTopFront.green = colors[1].green + (int)((colors[3].green-colors[1].green) * val2);
	rightTopFront.blue = colors[1].blue + (int)((colors[3].blue-colors[1].blue) * val2);
	rightTopFront.alpha = colors[1].alpha + (int)((colors[3].alpha-colors[1].alpha) * val2);
	
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
    
    [self addShape:shape];
}

-(void) createAnimTrans:(NSString*)type delay:(int)delay away:(bool)away  no:(int) no
{
    GameonModelRef*  to = [[GameonModelRef alloc] init];
    [to copy:[mRefs objectAtIndex:0]];
	[to copyMat:[mRefs objectAtIndex:0]];
    GameonModelRef* from = [[GameonModelRef alloc] init];
	float w,h,x,y;
	
    //[to copy:[mRefs objectAtIndex:no]];
    [from copy:to];
    
    RenderDomain* domain = [[mApp world] getDomain:to.mLoc];

    w = [domain.cs worldWidth];
    h = [domain.cs worldHeight];

    x = [domain.cs worldCenterX];
    y = [domain.cs worldCenterY];
    
	//float z = to.mPosition[2];
	if ([type isEqual:@"left"])
	{
		[from addAreaPosition:-w y:0 z:0];	
	}else if ([type isEqual:@"right"])
	{
		[from addAreaPosition:w y:0 z:0];
	}else if ([type isEqual:@"top"])
	{
		[from addAreaPosition:0  y:+h z:0];
	}else if ([type isEqual:@"tophigh"])
	{
		[from addAreaPosition:0  y:+h+h z:0];
	}else if ([type isEqual:@"bottom"])
	{
		[from addAreaPosition:0  y:-h z:0];
	}else if ([type isEqual:@"scaleout"])
	{
		[from mulScale:30 y:30 z:30];
	}else if ([type isEqual:@"scalein"])
	{
		[from mulScale:30 y:30 z:30];
	}else if ([type isEqual:@"swirlin"])
	{
		[from mulScale:30 y:30 z:30];
		[from addAreaRotation:0 y:0 z:720];
	}else if ([type isEqual:@"swirlout"])
	{
		[from mulScale:30 y:30 z:30];
		[from addAreaRotation:0 y:0 z:720];
	}
	
	if (away)
	{
		[mApp.anims createAnim:to end:from def:[mRefs objectAtIndex:no] 
                         delay:delay steps:2 owner:nil repeat:1 hide:true save:true];
	}else
	{
		[mApp.anims createAnim:from end:to def:[mRefs objectAtIndex:no] 
                         delay:delay steps:2 owner:nil repeat:1 hide:false save:true];
	}
    [to release];
    [from release];
		
}

-(void) addVisibleRef:(GameonModelRef*) ref
{
    if (mWorld == nil)
    {
        return;
    }
	if ([ref getVisible] )
	{
		if ( [mVisibleRefs indexOfObject:ref] == NSNotFound )
		{
            [mVisibleRefs addObject:ref];
            RenderDomain* domain = [[mApp world] getDomain:ref.mLoc];
            if (domain != nil)
            {
                [domain setVisible:self];
            }
		}

	}
}

-(void) remVisibleRef:(GameonModelRef*) ref
{
	if (![ref getVisible] )
	{
		if ( [mVisibleRefs indexOfObject:ref] != NSNotFound)
		{
			[mVisibleRefs removeObject:ref];
            RenderDomain* domain = [[mApp world] getDomain:ref.mLoc];
            if (domain != nil)
            {
                [domain remVisible:self force:false];
            }            
		}
	}
}



-(GameonModelRef*) ref:(int)no
{
	if (no < 0 || no >= [mRefs count])
	{
		return nil;
	}
	return [mRefs objectAtIndex:no];
}

	
-(int) findRef:(GameonModelRef*)ref
{
	return [mRefs indexOfObject:ref];
}

-(void) unsetWorld
{
	mWorld = nil;
}    

-(void) createAnim:(NSString*)type forId:(int)refid delay:(NSString*)delay data:(NSString*) data
{
	if (refid < 0 && refid >= [mRefs count])
	{
		return;
	}
	
	GameonModelRef* ref = [mRefs objectAtIndex:refid];
	[[mApp anims] animModelRef:type ref:ref delay:delay data:data];
	
}



-(void)setActive:(bool) active
{
	mActive = active;
}


-(void)createModelFromData:(float*)inputdata length:(int)len transform:(float*)mat uvbounds:(float*) uvb
{
    float umid = (uvb[1] + uvb[0]) /2;
    float vmid = (uvb[3] + uvb[2]) /2;
    float ratiou = uvb[1] - uvb[0];
    float ratiov = uvb[3] - uvb[2];
    
    float outvec[] = { 0 ,0,0,1};
    int cols[] = {0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF};
    float tu,tv;
    
    // model info - vertex offset?
    //  v   c   uv
    // (3 + 4 + 2) * 3
    int off;
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    for (int a=0; a< len; a+= 27 ) 
    {
        off = a;
        
        matrixVecMultiply2(mat, inputdata, off , outvec ,0);
        cols[0] = inputdata[off+3];
        cols[1] = inputdata[off+4];
        cols[2] = inputdata[off+5];
        cols[3] = inputdata[off+6];
        tu = inputdata[off+7] * ratiou + umid;
        tv  = inputdata[off+8] * ratiov + vmid;
        GLVertex* v1 = [shape addVertexColor:outvec[0] y:outvec[1] z:outvec[2] tu:tu tv:tv c:cols];
        
        off += 9;
        matrixVecMultiply2(mat, inputdata, off , outvec ,0);
        cols[0] = inputdata[off+3];
        cols[1] = inputdata[off+4];
        cols[2] = inputdata[off+5];
        cols[3] = inputdata[off+6];
        tu = inputdata[off+7] * ratiou + umid;
        tv  = inputdata[off+8] * ratiov + vmid;
        GLVertex* v2 = [shape addVertexColor:outvec[0] y:outvec[1] z:outvec[2] tu:tu tv:tv c:cols];
        
        off += 9;
        matrixVecMultiply2(mat, inputdata, off , outvec ,0);
        cols[0] = inputdata[off+3];
        cols[1] = inputdata[off+4];
        cols[2] = inputdata[off+5];
        cols[3] = inputdata[off+6];
        tu = inputdata[off+7] * ratiou + umid;
        tv  = inputdata[off+8] * ratiov + vmid;
        
        GLVertex* v3 = [shape addVertexColor:outvec[0] y:outvec[1] z:outvec[2] tu:tu tv:tv c:cols];
        
        GLFace* fc = [[[GLFace alloc] init] autorelease];
        [fc setVertex:v1 v2:v2 v3:v3];
        [shape addFace:fc];
        
    }
    
    [self addShape:shape];
    mTextureID = 1;

}

-(void)createModelFromData2:(const float[][3])inputdata length:(int)len transform:(float*)mat uvbounds:(float*) uvb cols:(int*)cols
{
    float umid = uvb[0];//(uvb[2] + uvb[0]) /2;
    float vmid = uvb[1];//(uvb[3] + uvb[1]) /2;
    float ratiou = uvb[2] - uvb[0];
    float ratiov = uvb[3] - uvb[1];
    
    float outvec[] = { 0 ,0,0,1};
    float tu,tv;
    
    // model info - vertex offset?
    //  v   c   uv
    // (3 + 4 + 2) * 3
    int off;
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    float temp[4];
    for (int a=0; a< len; a+= 9 )
    {
        // v3 + n3+ t2 = 8
        temp[0] = inputdata[a][0];
        temp[1] = inputdata[a][1];
        temp[2] = inputdata[a][2];
        
        matrixVecMultiply2(mat, temp, off , outvec ,0);
        tu = inputdata[a+2][0] * ratiou + umid;
        tv  = inputdata[a+2][1] * ratiov + vmid;
        GLVertex* v1 = [shape addVertexColor:outvec[0] y:outvec[1] z:outvec[2] tu:tu tv:tv c:cols];
        
        temp[0] = inputdata[a+3][0];
        temp[1] = inputdata[a+3][1];
        temp[2] = inputdata[a+3][2];
        
        matrixVecMultiply2(mat, temp, off , outvec ,0);
        tu = inputdata[a+5][0] * ratiou + umid;
        tv  = inputdata[a+5][1] * ratiov + vmid;
        GLVertex* v2 = [shape addVertexColor:outvec[0] y:outvec[1] z:outvec[2] tu:tu tv:tv c:cols];
        
        temp[0] = inputdata[a+6][0];
        temp[1] = inputdata[a+6][1];
        temp[2] = inputdata[a+6][2];
        
        matrixVecMultiply2(mat, temp, off , outvec ,0);
        tu = inputdata[a+8][0] * ratiou + umid;
        tv  = inputdata[a+8][1] * ratiov + vmid;
        GLVertex* v3 = [shape addVertexColor:outvec[0] y:outvec[1] z:outvec[2] tu:tu tv:tv c:cols];
        
        GLFace* fc = [[[GLFace alloc] init] autorelease];
        [fc setVertex:v1 v2:v2 v3:v3];
        [shape addFace:fc];
        
    }
    
    [self addShape:shape];
    mTextureID = 1;
}


-(void)addPlane:(float*)mat colors:(int*) cols colorlen:(int)colslength uvbounds:(float*)uvb 
{

    float ulow = uvb[0];
    float uhigh =uvb[2];
    float vlow = uvb[1];
    float vhigh =uvb[3];
    
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    matrixVecMultiply2(mat, mStaticBoundsPlane, 0 , mStaticBounds,0);
    matrixVecMultiply2(mat, mStaticBoundsPlane, 4 , mStaticBounds,4);
    matrixVecMultiply2(mat, mStaticBoundsPlane, 8 , mStaticBounds,8);
    matrixVecMultiply2(mat, mStaticBoundsPlane, 12 , mStaticBounds,12);
    
    int count = 0;
    GLVertex* leftBottomFront = [shape addVertexColorInt:mStaticBounds[0] y:mStaticBounds[1] z:mStaticBounds[2] tu:ulow tv:vhigh c:cols[count]];

    count++; if (count >= colslength) count = 0;
    GLVertex* rightBottomFront = [shape addVertexColorInt:mStaticBounds[4] y:mStaticBounds[5] z:mStaticBounds[6] tu:uhigh tv:vhigh c:cols[count]];    

    count++; if (count >= colslength) count = 0;
    GLVertex* leftTopFront = [shape addVertexColorInt:mStaticBounds[8] y:mStaticBounds[9] z:mStaticBounds[10] tu:ulow tv:vlow c:cols[count]];    
    
    count++; if (count >= colslength) count = 0;
    GLVertex* rightTopFront = [shape addVertexColorInt:mStaticBounds[12] y:mStaticBounds[13] z:mStaticBounds[14] tu:uhigh tv:vlow c:cols[count]];    

    count++; if (count >= colslength) count = 0;
    // front
    GLFace* face1 = [[[GLFace alloc] init] autorelease];
    [face1   setVertex:leftBottomFront v2:rightTopFront v3:leftTopFront];
    [shape addFace:face1];
    
    GLFace* face2 = [[[GLFace alloc] init] autorelease];
    [face2   setVertex:leftBottomFront v2:rightBottomFront v3:rightTopFront];
    [shape addFace:face2];
    
    [self addShape:shape];
    
}

-(GameonModel*) copyOfModel
{
    GameonModel* model = [[GameonModel alloc] initWithName:mName app:mApp parenArea:mParentArea];
    model.mEnabled = mEnabled;
    model.mForceHalfTexturing = false;
    model.mForcedOwner = 0;
    [model freeArrays];
    model.mShapeList = [[NSMutableArray alloc] initWithArray:mShapeList];	
    model.mVertexList = [[NSMutableArray alloc] initWithArray:mVertexList];
    model.mVertexOffset = mVertexOffset;
    model.mTextureID = mTextureID;
    model.mIndexCount = mIndexCount;
    
    model.mForcedOwner = mForcedOwner;
    model.mTextureW = mTextureW;
    model.mTextureH = mTextureH;
    return model;
}

-(GameonModelRef*)getRef:(int) count domain:(int)loc
{
    if (count < [mRefs count]) 
    {
        return [mRefs objectAtIndex:count];
    } else 
    {
        while (count >= [mRefs count])
        {
            GameonModelRef* ref = [[[GameonModelRef alloc] initWithParent:self andDomain:loc] autorelease];
            [mRefs addObject:ref];
            if ([mRefs count] > 1)
            {
                [ref copyData:[mRefs objectAtIndex:0]];
                [ref set];
            }
            
        }
        return [mRefs objectAtIndex:count];
    }
}

-(int) getVisibleRefs:(int)renderId 
{
    int count = 0;
    for (GameonModelRef* ref in mVisibleRefs)
    {
        if (ref.mLoc  == renderId && ref.mVisible)
        {
            count ++;
        }
    }
    
    return count;
}

-(void) hideDomainRefs:(int)renderId 
{
    for (GameonModelRef* ref in mRefs)
    {
        if (ref.mLoc == renderId)
        {
            [self remVisibleRef:ref];
        }
    }
}

-(void) setupIter:(int) num
{
    
    
    mIterQueue = [[NSMutableArray alloc]init];
    while ([mRefs count] < num)
    {
        GameonModelRef* ref = [[GameonModelRef alloc]initWithParent:self andDomain:0];
        [mRefs addObject:ref];
        if ([mRefs count] > 1)
        {
            [ref copyData:[mRefs objectAtIndex:0]];
            [ref set];
        }
    }
    for (int a=0; a< num; a++)
    {
        [mIterQueue  addObject:[NSNumber numberWithInt:a]];
    }
    
}

-(GameonModelRef*) getRefById:(GameonModelRefId*)refid domain:(int) loc
{
    if (refid.refid >= 0)
    {
        return [self getRef:refid.refid domain:loc];
    }
    
    // go through references and find id with name
    for (int a=0; a< [mIterQueue count]; a++)
    {
        NSNumber* index = [mIterQueue objectAtIndex:a];
        GameonModelRef* ref = [mRefs objectAtIndex:[index intValue] ];
        if ([refid.alias isEqualToString:ref.mRefAlias])
        {
            // put it on the end
            [mIterQueue removeObjectAtIndex:a];
            [mIterQueue addObject:index];
            refid.refid = [index intValue];
            return ref;
        }
    }
    
    // we didn't find alias get first ref
    NSNumber* index = [mIterQueue objectAtIndex:0];
    GameonModelRef* ref = [mRefs objectAtIndex:[index intValue]];
    ref.mRefAlias = refid.alias;
    // now remove it - and put to back
    [mIterQueue removeObjectAtIndex:0];
    [mIterQueue addObject:index];
    refid.refid = [index intValue];
    return ref;
}

-(AreaIndexPair*)onTouch:(float*)eye ray:(float*)ray domain:(int)renderId doclick:(bool)click
{
    float loc[3];
    
    if (mParentArea != nil)
    {
        if (![mParentArea acceptTouch:self doclick:click])
        {
            return nil;
        }
    }else
    {
        if (mOnClick == nil)
            return nil;
    }
    
    int count = 0;
    for (GameonModelRef* ref in mRefs)
    {
        if (ref.mVisible && ref.mLoc == renderId)
        {
            float dist = [ref intersectsRay:eye ray:ray loc:loc];
            if (dist >=0 && dist < 1e06f)
            {
                dist = [ref distToCenter:loc];
                AreaIndexPair* pair = [[AreaIndexPair alloc] init];
                pair.mLoc[0] = loc[0];
                pair.mLoc[1] = loc[1];
                pair.mLoc[2] = loc[2];
                pair.mDist = dist;
                if (mParentArea != nil)
                {
                    pair.mArea = mParentArea.mID;
                    pair.mOnclick = mParentArea.mOnclick;
                    pair.mOnFocusLost = mParentArea.mOnFocusLost;
                    pair.mOnFocusGain = mParentArea.mOnFocusGain;
                    pair.mIndex = [mParentArea indexOfRef:ref];
                }
                else
                {
                    pair.mArea = mName;
                    pair.mOnclick = mOnClick;
                    pair.mAlias = ref.mRefAlias;
                    pair.mOnFocusLost = nil;
                    pair.mOnFocusGain =nil;
                    pair.mIndex = count;
                    
                    
                }
                
                return pair;
                
            }
        }
        count++;
    }
    
    return nil;
}

-(void)addShapeFromString:(FloatBuffer*)vertices textv:(FloatBuffer*)textvertices data:(NSString*) data
{
    GLShape* shape = [[[GLShape alloc] initWithWorld:self] autorelease];
    
    NSArray* tok = [data componentsSeparatedByString:@" "];
    
    GLVertex* vert[4];
    
    int count = 0;
    GLColor* c =  [mApp colors].white;
    
    if (mCurrentMaterial != nil && mCurrentMaterial.diffuse != nil)
    {
        c = mCurrentMaterial.diffuse;
    }else
    if (mCurrentMaterial != nil && mCurrentMaterial.ambient != nil)
    {
        c = mCurrentMaterial.ambient;
    }
    else
    {
        c = [mApp colors].white;
    }
    for (int a=0; a< [tok count]; a++)
    {
        NSString* value = [tok objectAtIndex:a];
        if ([value length] == 0)
        {
            continue;
        }
        NSRange loc = [value rangeOfString:@"/"];
        
        if (loc.location !=  NSNotFound)
        {
            NSArray* tok2 = [value componentsSeparatedByString:@"/"];
            
            int index = [[tok2 objectAtIndex:0] intValue]-1;
            int index2 = [[tok2 objectAtIndex:1] intValue]-1;
            float* vdata = [vertices get:index*3];
            float* tdata = [textvertices get:index2*2];
            GLVertex* v = nil;
            if (mCurrentMaterial.t != nil)
            {
                float t0 = 0.0f;
                float t1 = 0.0f;
                if (tdata[0] < 0)
                {
                    tdata[0] = 0;
                }
                if (tdata[0] > 1)
                {
                    tdata[0] = 1;
                }
                if (tdata[1] < 0)
                {
                    tdata[1] = 0;
                }
                if (tdata[1] > 1)
                {
                    tdata[1] = 1;
                }
                t0 = tdata[0] / mCurrentMaterial.t[2];
                t1 = (1.0f-tdata[1]) / mCurrentMaterial.t[3];
                
                t0 += mCurrentMaterial.t[0];
                t1 += mCurrentMaterial.t[1];
                v = [shape addVertex:vdata[0] y:vdata[2] z:vdata[1] tu:t0 tv:t1 c:c];
            }else
            {
                v = [shape addVertex:vdata[0] y:vdata[2] z:vdata[1] tu:tdata[0] tv:1.0f-tdata[1] c:c];
            }
            
            vert[count] = v;
        }else
        {
            int index = [value intValue]-1;
            float* vdata = [vertices get:index*3];
            GLVertex* v = [shape addVertex:vdata[0] y:vdata[2] z:vdata[1] tu:0 tv:0 c:c];
            vert[count] = v;
        }
        count ++;
    }
    if (count == 3)
    {
        GLFace* fc = [[[GLFace alloc] init] autorelease];
        [fc setVertex:vert[0] v2:vert[1] v3:vert[2]];
        [shape addFace:fc];
    }else
    if (count == 4)
    {
        GLFace* fc = [[[GLFace alloc] init] autorelease];
        [fc setVertex:vert[0] v2:vert[1] v3:vert[2]];
        [shape addFace:fc];

        GLFace* fc2 = [[[GLFace alloc] init] autorelease];
        [fc2 setVertex:vert[0] v2:vert[2] v3:vert[3]];
        [shape addFace:fc2];
        
    }
    [self addShape:shape];
}

-(void)useMaterial:(NSString*) substring
{
    mCurrentMaterial = [[mApp textures] getMaterial:substring];
    if (mTextureID == 1)
    {
        mTextureID = mCurrentMaterial.diffuseMapId;
    }
}


@end
