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

#import "ObjectsFactory.h"
#import "GameonModel.h"
#import "GameonWorld.h"
#import "ColorFactory.h"
#import "TextureFactory.h"
#import "LayoutItem.h"
#import "GameonApp.h"
#import "GameonModelRef.h"
#import "ItemFactory.h"

@implementation ObjectsFactory


-(id) initWithApp:(GameonApp*) app
{
	if (self = [super init])
	{
		mApp = app;
		mItems = [[NSMutableDictionary alloc] init];
	}
    return self;
}

- (void) dealloc 
{
	[mItems release];
    [super dealloc];  
}
	
-(LayoutItem*) get:(NSString*)name
{
	LayoutItem* model = [mItems objectForKey:name];
	return model;
/*		
	if ( mItems.containsKey(name))
	{
		return nil;
	}
	LayoutItem model = mItems.get(name);
	return model;*/
}
-(void)addModel:(NSString*)name item:(LayoutItem*) item
{
	LayoutItem* itemsearch = [mItems objectForKey:name];
	if (itemsearch != nil)
	{
		return;
	}	

	item.mModel.mEnabled = true;
	[mApp.mWorld add:item.mModel];
	[mItems setObject:item forKey:name];
}

	

-(void)create:(NSString*)name data:(NSString*)data color:(NSString*)color
{
	LayoutItem* item = [mItems objectForKey:name];
	if (item != nil)
	{
		return;
	}		
	
	GameonModel* model = [mApp.items getFromTemplate:name data:data color:color];
	if (model != nil)
	{
        GameonModel* modelnew = [model copyOfModel];
		LayoutItem* item = [[LayoutItem alloc]init];
		item.mModel = modelnew;
		[self addModel:name item:item];
	}
}

-(void)place:(NSString*)name data:(NSString*)data state:(NSString*)state
{
    GameonModelRefId* refid = [self refId:name];    
	LayoutItem* item = [mItems objectForKey:refid.name];
	if (item == nil)
	{
		return;
	}
	GameonModel* model = item.mModel;

	// TODO submodels
    /*
	if ([model ref:0] == nil)
	{
		GameonModelRef* ref = [[GameonModelRef alloc] initWithParent:model];
		[model addref:ref];
		item.mModelRef = ref;
	}*/
	float coords[5] = {0,0,0,0,0};
	[ServerkoParse parseFloatArray:coords max:5 forData:data]; 
    GameonModelRef* ref = [model getRefById:refid domain:0];
    [ref setPosition:coords];
    [ref set];
	
    if (state != nil)
    {
        bool visible = false;
        if ([state isEqualToString:@"visible"])
        {
            visible = true;
        }
        [ref setVisible:visible];
    }

}

-(void)scale:(NSString*)name data:(NSString*)data 
{
    GameonModelRefId* refid = [self refId:name];
	LayoutItem* item = [mItems objectForKey:refid.name];
	if (item == nil)
	{
		return;
	}
	GameonModel* model = item.mModel;
	
	// TODO submodels
	if ([model ref:0] == nil)
	{
		GameonModelRef* ref = [[GameonModelRef alloc] initWithParent:model andDomain:0];
		[model addref:ref];
	}
	float scale[5] = {0,0,0,0,0};
	[ServerkoParse parseFloatArray:scale max:5 forData:data]; 
	
    GameonModelRef* ref = [model getRefById:refid domain:0];
    [ref setScale:scale];
    [ref set];
}

-(void)rotate:(NSString*)name data:(NSString*)data 
{
    GameonModelRefId* refid = [self refId:name];
	LayoutItem* item = [mItems objectForKey:refid.name];
	if (item == nil)
	{
		return;
	}
	GameonModel* model = item.mModel;
	
	// TODO submodels
	if ([model ref:0] == nil)
	{
		GameonModelRef* ref = [[GameonModelRef alloc] initWithParent:model  andDomain:0];
		[model addref:ref];
	}
	float rotate[3] = {0,0,0};
	[ServerkoParse parseFloatArray:rotate max:3 forData:data]; 
	
    GameonModelRef* r = [model getRefById:refid domain:0];
	[r setRotate:rotate];
	[r set];
}




-(void)texture:(NSString*)name data:(NSString*)data submodel:(NSString*)submodel
{
    GameonModelRefId* refid = [self refId:name];
    
	LayoutItem* item = [mItems objectForKey:refid.name];
	if (item == nil)
	{
		return;
	}
	GameonModel* model = item.mModel;
    GameonModelRef* r = [model getRefById:refid domain:0];
    
    if (data != nil && [data length] > 0)
    {        
        int text = [mApp.textures getTexture:data];
        [model setTexture:text ];
    }
    
    if (submodel != nil && [submodel length] > 0)
    {
        int arr[2];
        [ServerkoParse parseIntArray:arr max:2 forData:submodel];
        [r setOwner:arr[0] max:arr[1]];
    }
}

//TODO mutliple references with name.refid , default 0!
-(void)state:(NSString*)name data:(NSString*)data {
    
    GameonModelRefId* refid = [self refId:name];
    
	LayoutItem* item = [mItems objectForKey:refid.name];
	if (item == nil)
	{
		return;
	}

	GameonModel* model = item.mModel;

	bool visible = false;
	if ([data  isEqualToString:@"visible"])
	{
		visible = true;
	}
	if ([model ref:refid.refid] == nil)
	{
		[self place:name data:@"0,0,0" state:nil];
	}
    GameonModelRef* r = [model getRefById:refid domain:0];
	[r setVisible:visible];
}

-(void)remove:(NSString*)name data:(NSString*)data {
	LayoutItem* item = [mItems objectForKey:name];
	if (item == nil)
	{
		return;
	}	
	GameonModel* model = item.mModel;
	[mApp.mWorld remove:model];
	[mItems removeObjectForKey:name];
    [item release];
    ///[model release];
}

-(void)initObjects:(NSMutableDictionary*)response
{
    NSMutableArray* models = [response valueForKey:@"object"];
    for (int a=0; a< [models count]; a++)
    {
		NSMutableDictionary* pCurr = [models objectAtIndex:a];
		[self processObject:pCurr];        
	}	
	
}

-(void) processObject:(NSMutableDictionary*)objData
{
	NSString* name = [objData valueForKey:@"name"];
	NSString* template = [objData valueForKey:@"template"];    
	if (name == nil || template == nil)
	{
		return;
	}
    NSString* color= [objData valueForKey:@"color"];    
    
	[self create:name data:template color:color];
	
	NSString* location = [objData valueForKey:@"location"];
	if (location != nil)
	{
		[self place:name data:location state:nil];
	}
	
	NSString* bounds = [objData valueForKey:@"bounds"];
	if (bounds != nil)
	{
		[self scale:name data:bounds];
	}			
	
	NSString* texture = [objData valueForKey:@"texture"];
	if (texture != nil)
	{
		[self texture:name data:texture submodel:nil];
	}			
	
	NSString* state = [objData valueForKey:@"state"];
	if (state != nil)
	{
		[self state:name data:state];
	}

	NSString* rotate = [objData valueForKey:@"rotate"];
	if (rotate != nil)
	{
		[self rotate:name data:rotate];
	}

	NSString* iter = [objData valueForKey:@"iter"];
	if (iter != nil)
	{
		[self setIter:name data:iter];
	}

	NSString* onclick = [objData valueForKey:@"onclick"];
	if (onclick != nil)
	{
		[self setOnClick:name data:onclick];
	}

}

-(GameonModelRefId*)refId:(NSString*) name
{
    GameonModelRefId* refdata = [[[GameonModelRefId alloc] init]autorelease];

    NSArray* tok = [name componentsSeparatedByString:@"."];
    int count = [tok count];
    if ( count == 2)
    {
   		refdata.name = [tok objectAtIndex:0];
        refdata.refid = [[tok objectAtIndex:1] intValue];
        
    }else if (count == 3)
    {
   		refdata.name = [tok objectAtIndex:0];
        refdata.refid = -1;
   		refdata.alias = [tok objectAtIndex:2];
    }else{
   		refdata.name = name;
        refdata.refid = 0;
    }
        
    return refdata;
}


-(GameonModelRef*) getRef:(NSString*) name
{
    GameonModelRefId* refid = [self refId:name];
    
    LayoutItem* item = [mItems objectForKey:refid.name];
    if (item == nil)
    {
        return nil;
    }
    GameonModel* model = item.mModel;
    GameonModelRef* ref = [model getRefById:refid domain:0];
    return ref;
    
}    

-(void)setIter:(NSString*)name data:(NSString*) data
{
    GameonModelRefId* refid = [self refId:name];
    LayoutItem* item = [mItems objectForKey:refid.name];
    if (item == nil)
    {
        return;
    }
    GameonModel* model = item.mModel;
    int num = [data intValue];
    [model setupIter:num];
}

-(void)setOnClick:(NSString*)name data:(NSString*)data
{
    GameonModelRefId* refid = [self refId:name];
    LayoutItem* item = [mItems objectForKey:refid.name];
    if (item == nil)
    {
        return;
    }
    GameonModel* model = item.mModel;
    model.mOnClick = [[NSString alloc] initWithString:data];
}




@end


