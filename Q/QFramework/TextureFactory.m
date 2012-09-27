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

#import "TextureFactory.h"
#import "GameonApp.h"
#import "ServerkoParse.h"
#import "GLColor.h"
#import "ColorFactory.h"
#import "GameonApp.h"

@implementation MaterialData

@synthesize ambient;
@synthesize diffuse;
@synthesize alpha;
@synthesize ambientMap;
@synthesize diffuseMap;
@synthesize ambientMapId;
@synthesize diffuseMapId;
@synthesize  t;


- (id)initWithApp:(GameonApp*)app
{
    self = [super init];
    
    if (self) {
        alpha = 1.0f;
        t = NULL;
        mApp = app;
        ambientMapId = 1;
        diffuseMapId = 1;
    }
    return  self;

}

- (void) dealloc
{

    [ambientMap release];
    [diffuseMap release];
    [diffuse release];
    [ambient release];
    if (t)
    {
        free(t);
    }
    [super dealloc];
}

-(void)setDiffuseMap:(NSString*)folder data:(NSString*)data
{
    diffuseMap = [[NSString alloc]initWithString:data];
    diffuseMapId = [[mApp textures] newTexture:data file:data];
}

-(void)setAmbientMap:(NSString*)folder data:(NSString*) data
{
    ambientMap = [[NSString alloc]initWithString:data];
    ambientMapId = [[mApp textures] newTexture:data file:data];
}

-(void)setAlphaVal:(NSString*)strdata
{
    //
    alpha = [strdata floatValue];
}

-(void)setAlpha2:(NSString*) strdata
{
    //
    alpha = 1.0f-[strdata floatValue];
}

-(void)setDiffuse_:(NSString*)data
{
    float difdata[4];
    [ServerkoParse parseFloatArray2:difdata max:4 forData:data sep:@" "];
    diffuse = [[GLColor alloc] initWithRGBA:
                  (int)(difdata[0]*255.0f)
                g:(int)(difdata[1]*255.0f)
                b:(int)(difdata[2]*255.0f)
                a:alpha*255.0f];
}

-(void)setAmbient_:(NSString*) data
{
    float ambdata[4];
    [ServerkoParse parseFloatArray2:ambdata max:4 forData:data sep:@" "];
    
    
    ambient = [[GLColor alloc] initWithRGBA:
               (int)(ambdata[0]*255.0f)
                                          g:(int)(ambdata[1]*255.0f)
                                          b:(int)(ambdata[2]*255.0f)
                                          a:alpha*255.0f];
    
}

-(void)setTransform:(NSString*) data
{
    t = (float*)malloc(sizeof(float)*4);
    [ServerkoParse parseFloatArray2:t max:4 forData:data sep:@" "];
}


@end



@implementation TextureFactory

@synthesize mU1;
@synthesize mV1;
@synthesize mU2;
@synthesize mV2;
@synthesize mCp;
@synthesize mTextureDefault;

//static bool mInitialized = false;

- (id)initWithApp:(GameonApp*) app;
{
    self = [super init];
    
    if (self) {
		mTextureDefault = 1;
		mUpdated = false;
		mTextures = [[NSMutableDictionary alloc] init];
        mToDelete = [[NSMutableArray alloc] init];
        mMaterials = [[NSMutableDictionary alloc]init];
        
		[self newTexture:@"white" file:@"whitesys.png"];
		[self newTexture:@"font" file:@"fontsys.png"];
		mU1 = 0.01;
		mV1 = 0.01;
		mU2 = 0.01;
		mV2 = 0.01;
		mCp = 0.00;
        mApp = app;
    }
	
    return  self;
}

- (void) dealloc 
{    
    [mToDelete release];
    [mTextures release];
    [mMaterials release];
    [super dealloc];  
}

-(int) loadTexture:(NSString*)textname
{
    
    GLuint textures[1];
    glGenTextures(1, &textures[0]);
    
    int textureid = textures[0];
    glBindTexture(GL_TEXTURE_2D, textureid);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE,GL_MODULATE);
    
    NSString* textPath  = [[NSBundle mainBundle] resourcePath];
    textPath = [textPath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    mUpdated = true;
    NSArray* fnames = [textname componentsSeparatedByString:@"/"];
    NSString* tname = [fnames objectAtIndex: [fnames count]-1];
    
    NSString* filepath = [NSString stringWithFormat:@"%@//%@", textPath , tname];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:filepath];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
    {
        NSLog(@"Failed to load texture %@ " , textname);
        return -1;
    }
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(context);
    
    free(imageData);
    [image release];
    [texData release];
    
    return textureid;
    
}

-(int) getTexture:(NSString*) strData {
    NSNumber* num = [mTextures objectForKey:strData];
    if (num != nil)
    {
        return [num intValue];
    }
    
    return mTextureDefault;
}

-(int) get:(TextureFactoryType) type {
    
    switch (type) {
        case TFT_DEFAULT: return [self getTexture:@"white"];
        case TFT_FONT: return [self getTexture:@"font"];
    }
    return mTextureDefault;
}



-(void)deleteTexture:(NSString*)textname
{
	[mToDelete addObject:textname];
}


-(void)clearTexture:(NSString*)textname
{
	if ([mTextures objectForKey:textname])
	{
		NSNumber* num= [mTextures objectForKey:textname];
        GLuint ids[1];
		ids[0] = [num intValue];
		glDeleteTextures(1 , ids);
		[mTextures removeObjectForKey:textname];
		
	}
	
}

-(void)flushTextures
{
	for (int a=0; a< [mToDelete count]; a++)
	{
		[self clearTexture:[mToDelete objectAtIndex:a]];
	}
	
	[mToDelete removeAllObjects];
}


-(int)newTexture:(NSString*)textname file:(NSString*)textfile
{
    int tid = [self loadTexture:textfile];
    if (tid > 0)
    {
        [mTextures setObject:[NSNumber numberWithInt:tid] forKey:textname];        
    }
    return tid;
}

-(bool)isUpdated
{
    return mUpdated;
}

-(void)resetUpdate
{
    mUpdated = false;
}

-(void)setParam:(float)u1 v1:(float)v1 u2:(float)u2 v2:(float)v2 p:(float)cp
{
	mU1 = u1;
	mV1 = v1;
	mU2 = u2;
	mV2 = v2;
	mCp = cp;

}


-(void)processTexture:(NSMutableDictionary*)objData
{
	NSString* name = [objData valueForKey:@"name"];
	NSString* file = [objData valueForKey:@"file"];
        
    if (name != nil && [name length] > 0 && file != nil && [file length] > 0)
    {
        [self newTexture:name file:file];
    }
}

-(void)initTextures:(NSMutableDictionary*)response
{
    NSMutableArray* textures = [response valueForKey:@"texture"];
    
    for (int a=0; a< [textures count]; a++)
    {
		NSMutableDictionary* pCurr = [textures objectAtIndex:a];
		[self processTexture:pCurr];        
	}	
}


-(void)loadMaterial:(NSString*)folder file:(NSString*) fname
{
    //
    NSArray* paths = [fname componentsSeparatedByString:@"/"];
    NSString* matfile = [paths objectAtIndex:[paths count]-1];
    
    
    NSString* matPath  = [[NSBundle mainBundle] resourcePath];
    matPath = [matPath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    
    NSString* filepath = [NSString stringWithFormat:@"%@//%@", matPath , matfile];
    
    //NSLog(@"exec script %@", scriptname);
    NSString* objstr = [NSString stringWithContentsOfFile:filepath usedEncoding:nil error:nil];

    
    //NSString* objstr = [NSString stringWithContentsOfFile:fname encoding:NSUTF8StringEncoding error:nil];
    if (objstr == nil)return;
    NSArray* tok = [objstr componentsSeparatedByString:@"\n"];
    MaterialData* current = nil;
    for(NSString* linein in tok)
    {
        NSString* line = [linein stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        line = [line stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        
        if ([line hasPrefix:@"#"])
        {
            continue;
        }else
			if ([line hasPrefix:@"newmtl"])
			{
				current = [[MaterialData alloc] initWithApp:mApp];
				[mMaterials setObject:current forKey:[line substringFromIndex:7]];
			}else
            if ([line hasPrefix:@"Ka" ])
            {
                [current setAmbient_:[line substringFromIndex:3]];
            }else
            if ([line hasPrefix:@"Kd"])
            {
                [current setDiffuse_:[line substringFromIndex:3]];
            }else
            if ([line hasPrefix:@"d"])
            {
                [current setAlphaVal:[line substringFromIndex:2]];
            }else
            if ([line hasPrefix:@"Tr"])
            {
                [current setAlpha2:[line substringFromIndex:2]];
            }else
            if ([line hasPrefix:@"map_Ka"])
            {
                [current setAmbientMap:folder data:[line substringFromIndex:7]];
            }else
            if ([line hasPrefix:@"map_Kd"])
            {
                [current setDiffuseMap:folder data:[line substringFromIndex:7]];
            }else
            if ([line hasPrefix:@"t "])
            {
                [current setTransform:[line substringFromIndex:2]];
            }
    }
}

-(MaterialData*)getMaterial:(NSString*) substring
{
    if ([mMaterials objectForKey:substring] != nil)
    {
        return [mMaterials objectForKey:substring];
    }
    return nil;
	
}
@end

