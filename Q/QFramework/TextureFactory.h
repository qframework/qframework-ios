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
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class GameonApp;
@class GLColor;

typedef enum  {
    TFT_DEFAULT,
    TFT_FONT
} TextureFactoryType;

@interface MaterialData : NSObject
{
    GLColor* ambient;
    GLColor* diffuse;
    float	alpha;
    NSString* ambientMap;
    NSString* diffuseMap;
    int ambientMapId;
    int diffuseMapId;
    float* t;
    GameonApp* mApp;

}

-(void)setDiffuse_:(NSString*)data;
-(void)setAmbient_:(NSString*) data;
-(void)setAlphaVal:(NSString*)strdata;
-(void)setDiffuseMap:(NSString*)folder data:(NSString*)data;
-(void)setAmbientMap:(NSString*)folder data:(NSString*) data;

@property (nonatomic, assign) GLColor* ambient;
@property (nonatomic, assign) GLColor* diffuse;
@property (nonatomic, assign) float	alpha;
@property (nonatomic, assign) NSString* ambientMap;
@property (nonatomic, assign) NSString* diffuseMap;
@property (nonatomic, assign) int ambientMapId;
@property (nonatomic, assign) int diffuseMapId;
@property (nonatomic, assign) float* t;

@end

@interface TextureFactory : NSObject {

	int mTextureDefault;
	bool mUpdated;
	NSMutableDictionary* mTextures;
    NSMutableDictionary* mMaterials;
    NSMutableArray* mToDelete;
	float mU1;
	float mV1;
	float mU2;
	float mV2;
	float mCp;
    GameonApp*  mApp;
}

@property (nonatomic, readonly) float mU1;
@property (nonatomic, readonly) float mV1;
@property (nonatomic, readonly) float mU2;
@property (nonatomic, readonly) float mV2;
@property (nonatomic, readonly) float mCp;
@property (nonatomic, readonly) int mTextureDefault;

-(id) initWithApp:(GameonApp*) app;
-(int) get:(TextureFactoryType) type;
-(int) getTexture:(NSString*) strData;
-(int)newTexture:(NSString*)textname file:(NSString*)textfile;
-(bool)isUpdated;
-(void)resetUpdate;
-(void)setParam:(float)u1 v1:(float)v1 u2:(float)u2 v2:(float)v2 p:(float)cp;
-(void)initTextures:(NSMutableDictionary*)response;
-(void)flushTextures;
-(void)deleteTexture:(NSString*)textname;
-(MaterialData*)getMaterial:(NSString*) substring;
-(void)loadMaterial:(NSString*)folder file:(NSString*) fname;

@end
