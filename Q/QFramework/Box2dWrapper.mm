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

#import "Box2dWrapper.h"
#import <Box2D/Box2D.h>
#import "ServerkoParse.h"
#import "GameonModelRef.h"
#import "LayoutArea.h"
#import "GameonApp.h"
#import "LayoutGrid.h"
#import "ObjectsFactory.h"

@implementation ObjectProps
@synthesize mType;
@synthesize mShape;
@synthesize mGroupIndex; 
@synthesize mFriction;
@synthesize mDensity;
@synthesize mRestitution;    

-(id) init
{
	if (self = [super init])
	{
        mType = TYPE_FIXED;
        mShape = SHAPE_BOX;
        mGroupIndex = 0; 
        mFriction = 0.2f;
        mDensity = 0;
        mRestitution = 0.0f;
	}
    return self;
}

- (void) dealloc 
{
    [super dealloc];  
}

@end

@implementation BodyData

@synthesize mArea;
@synthesize mRef;
@synthesize mBody;//b2Body
@synthesize mProps;

-(id) init
{
	if (self = [super init])
	{
        mBody = NULL;
	}
    return self;        
}

- (void) dealloc 
{
    [mProps release];
    if (mBody != NULL)
    {
        //delete (b2Body*)mBody;
    }
    [super dealloc];  
}

@end

@implementation Box2dData

@synthesize mWorld; //b2World
@synthesize mName;
@synthesize mAreaModels;
@synthesize mDynModels;
@synthesize mFixModels;
@synthesize mMapping;

-(id) init
{
    if (self = [super init])
    {
        mAreaModels = [[NSMutableArray alloc] init];
		mDynModels = [[NSMutableArray alloc] init];
		mFixModels = [[NSMutableArray alloc] init];
		mMapping = MAPPING_XY;  
        mWorld = NULL;
	}
    return self;        
}
    
- (void) dealloc 
{
    [mAreaModels release];
    [mDynModels release];
    [mFixModels release];
    if (mWorld != NULL)
    {
        delete (b2World*)mWorld;
    }
    [super dealloc];  
}
@end


@implementation Box2dWrapper


-(id) initWithApp:(GameonApp*) app
{
	if (self = [super init])
	{
		mApp = app;
        mBox2dWorlds = [[NSMutableDictionary alloc] init ];
        mBox2dWorldsVec = [[NSMutableArray alloc] init];        
        mActive = false;
	}
    return self;
}

- (void) dealloc 
{
    [mBox2dWorlds release];
    [mBox2dWorldsVec release];
    [super dealloc];  
}

-(void)initWorld:(NSString*)worldname gravity:(NSString*)grav mapping:(NSString*)mapping
{
    
    if ([mBox2dWorlds objectForKey:worldname] != nil)
    {
        return;
    }
    
    float gravity[2];
    [ServerkoParse parseFloatArray:gravity max:2 forData:grav];
    
    b2Vec2 vecgrav(gravity[0], gravity[1]);
    
    Box2dData* data = [[Box2dData alloc] init];
    
    b2World* world = new b2World( vecgrav);

    data.mWorld = (void*)world;
    data.mName = [[NSString alloc] initWithString:worldname];
    
    if ([mapping isEqualToString:@"xy"])
    {
        data.mMapping = MAPPING_XY;
    }else if ([mapping  isEqualToString:@"xz"])
    {
        data.mMapping = MAPPING_XZ;
    }else if ([mapping isEqualToString:@"yz"])
    {
        data.mMapping = MAPPING_YZ;
    }
    
    mActive = true;
    
    [mBox2dWorldsVec addObject:data];
    [mBox2dWorlds setObject:data forKey:worldname];    
}

-(void)addDynObject:(NSString*)worldname name:(NSString*)objname ref:(GameonModelRef*)ref  props:(ObjectProps*) props
{
    Box2dData* data = [mBox2dWorlds objectForKey:worldname];
    if (data == nil)
    {
        return;
    }
    
    
    // Dynamic Body
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(ref.mPosition[0], ref.mPosition[1]);
    b2World* world = (b2World*)data.mWorld;
    b2Body* body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    if (props.mShape == SHAPE_BOX)
    {
        b2PolygonShape dynamicBox;
        dynamicBox.SetAsBox(ref.mScale[0]/2,ref.mScale[1]/2);
        fixtureDef.shape = &dynamicBox;
    }else
    {
        b2CircleShape dynamicCircle;
        dynamicCircle.m_radius = ref.mScale[0]/2;
        fixtureDef.shape = &dynamicCircle;
    }
    
    fixtureDef.density=props.mDensity;
    fixtureDef.friction=props.mFriction;
    fixtureDef.restitution = props.mRestitution;
    //kinematicBody
    fixtureDef.filter.groupIndex = props.mGroupIndex;
    body->CreateFixture(&fixtureDef);
    
    BodyData* bodydata = [[BodyData alloc] init ];
    bodydata.mRef = ref;
    bodydata.mBody = (void*)body;
    bodydata.mProps = props;
    [ref assignPsyData:bodydata];
    [data.mDynModels addObject:bodydata];
}

-(void)addAreaObject:(NSString*)worldname name:(NSString*)objname area:(LayoutArea*)area  props:(ObjectProps*) props
{
    
    Box2dData* data = [mBox2dWorlds objectForKey:worldname];
    if (data == nil)
    {
        return;
    }

    
    
    // Dynamic Body
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(area.mLocation[0], area.mLocation[1]);
    b2World* world = (b2World*)data.mWorld;
    b2Body* body = world->CreateBody(&bodyDef);
    
    b2FixtureDef fixtureDef;
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(area.mBounds[0]/2,area.mBounds[1]/2);
    fixtureDef.shape = &dynamicBox;
    
    fixtureDef.density=props.mDensity;
    fixtureDef.friction=props.mFriction;
    fixtureDef.restitution = props.mRestitution;
    //kinematicBody
    fixtureDef.filter.groupIndex = props.mGroupIndex;
    body->CreateFixture(&fixtureDef);
    
    BodyData* bodydata = [[BodyData alloc] init ];
    bodydata.mArea = area;
    bodydata.mBody = (void*)body;
    bodydata.mProps = props;
    [area assignPsyData:bodydata];
    [data.mAreaModels addObject:bodydata];
     
}	

-(void)addFixedObject:(NSString*)worldname name:(NSString*)objname ref:(GameonModelRef*)ref  props:(ObjectProps*) props
{
    Box2dData* data = [mBox2dWorlds objectForKey:worldname];
    if (data == nil)
    {
        return;
    }

    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(ref.mPosition[0], ref.mPosition[1]);
    b2World* world = (b2World*)data.mWorld;
    b2Body* groundBody = world->CreateBody(&bodyDef);

    b2FixtureDef fixtureDef;
    fixtureDef.density=props.mDensity;
    fixtureDef.friction=props.mFriction;
    fixtureDef.restitution = props.mRestitution;
    //kinematicBody
    fixtureDef.filter.groupIndex = props.mGroupIndex;
    
    
    if (props.mShape == SHAPE_BOX)
    {	    
        b2PolygonShape shape;
        shape.SetAsBox(ref.mScale[0]/2,ref.mScale[1]/2);
        fixtureDef.shape = &shape;
        groundBody->CreateFixture(&fixtureDef);
    }else
    {
        b2CircleShape shape;
        shape.m_radius = ref.mScale[0]/2;
        fixtureDef.shape = &shape;
        groundBody->CreateFixture(&fixtureDef);
        
    }
    
    
    BodyData* bodydata = [[BodyData alloc] init ];
    bodydata.mRef = ref;
    bodydata.mBody = (void*)groundBody;
    bodydata.mProps = props;
    [ref assignPsyData:bodydata];
    [data.mFixModels addObject:bodydata];
    
}

- (void)doFrame:(long) delay
{
    
    if (!mActive)
    {
        return;
    }
    int velocityIterations = 6;
    int positionIterations = 2;
    float timeStep = (float)delay/1000;
    
    for (Box2dData* data in mBox2dWorldsVec)
    {
        b2World* world = (b2World*)data.mWorld;
        world->Step(timeStep, velocityIterations, positionIterations);
        for (BodyData* bodydata in data.mDynModels)
        {
            if (bodydata.mRef == nil)
            {
                continue;
            }
            b2Body* body = (b2Body*)bodydata.mBody;
            b2Vec2 position = body->GetPosition();
            [bodydata.mRef setPosition:position.x y:position.y z:0.1f];
            //System.out.println( " rot = " + bodydata.mBody.getAngle());
            [bodydata.mRef setRotate:0 y:0 z:body->GetAngle() * 360 / 3.14f];
            [bodydata.mRef set];
        }
        for (BodyData* bodydata in data.mAreaModels)
        {
            if (bodydata.mArea == nil)
            {
                continue;
            }
            b2Body* body = (b2Body*)bodydata.mBody;            
            b2Vec2 position = body->GetPosition();
            bodydata.mArea.mLocation[0] = position.x;
            bodydata.mArea.mLocation[1] = position.y;
            bodydata.mArea.mRotation[2] = body->GetAngle() * 360 / 3.14f;
            [bodydata.mArea updateModelsTransformation];
        }
    }
    
}


- (void)initObjects:(NSDictionary*)response
{
    NSString* worldid = [response valueForKey:@"worldid"];
    NSMutableArray* models = [response valueForKey:@"object"];
    for (int a=0; a< [models count]; a++)
    {
		NSMutableDictionary* pCurr = [models objectAtIndex:a];
		[self processObject:worldid data:pCurr];        
	}	
    
    /*
    try {
        JSONArray areas;
        
        String worldid = response.getString("worldid");
        
        areas = response.getJSONArray("object");
        
        for (int a=0; a< areas.length(); a++)
        {
            JSONObject pCurr = areas.getJSONObject(a);
            processObject(gl, worldid,pCurr);
        }
    } catch (JSONException e) {
        e.printStackTrace();
    }
    
    */
}

- (void)processObject:(NSString*)worldid data:(NSDictionary*)objData
{
	NSString* name = [objData valueForKey:@"name"];
	if (name == nil)
	{
		return;
	}
    NSString* type= [objData valueForKey:@"type"];    
    NSString* refid= [objData valueForKey:@"refid"];        
    
    ObjectProps* props = [[ObjectProps alloc] init];
    
    NSString* templat= [objData valueForKey:@"template"];    
    if (templat != nil)
    {
        if ([templat isEqualToString:@"box"])
        {
            props.mShape = SHAPE_BOX;
        }else
        {
            props.mShape = SHAPE_CIRCLE;
        }
    }
    
    NSString* friction= [objData valueForKey:@"friction"];    
    if (friction != nil)
    {
        props.mFriction = [friction floatValue];
    }

    NSString* density= [objData valueForKey:@"density"];        
    if (density != nil)
    {
        props.mDensity = [density floatValue];
    }

    NSString* restitution= [objData valueForKey:@"restitution"];        
    if (restitution != nil)
    {
        props.mRestitution = [restitution floatValue];
    }
    
    NSString* groupIndex= [objData valueForKey:@"groupIndex"];        
    if (groupIndex != nil)
    {
        props.mGroupIndex = [groupIndex intValue];
    }			
    
    
    if ([type isEqualToString:@"dynamic"])
    {
        GameonModelRef* ref = [mApp.objects getRef:refid];
        if (ref == nil)
        {
            return;
        }
        
        props.mType = TYPE_DYNAMIC;
        [self addDynObject:worldid name:name ref:ref props:props];
    }else if ([type isEqualToString:@"fixed"])
    {
        GameonModelRef* ref = [mApp.objects getRef:refid];
        if (ref == nil)
        {
            return;
        }
        
        props.mType = TYPE_FIXED;
        [self addFixedObject:worldid name:name ref:ref props:props];
    }else if ([type isEqualToString:@"area"])
    {
        LayoutArea* area = [mApp.grid getArea:refid];
        props.mType = TYPE_AREA;
        [self addAreaObject:worldid name:name area:area props:props];
    }
}

-(bool) isActive
{
    return mActive;
}

-(void)removeWorld:(NSString*)name
{
    Box2dData* data = [mBox2dWorlds objectForKey:name];
    if (data == nil)
    {
        return;
    }

    
    for (BodyData* bdata in data.mDynModels)
    {
        [bdata.mRef assignPsyData:nil];
    }
    
    for (BodyData* bdata in data.mFixModels)
    {
        [bdata.mRef assignPsyData:nil];
    }
    
    for (BodyData* bdata in data.mAreaModels)
    {
        [bdata.mArea assignPsyData:nil];
    }				
    
    [mBox2dWorlds removeObjectForKey:name];
    [mBox2dWorldsVec removeObject:data];
    
    if ([mBox2dWorldsVec count] == 0)
    {
        mActive = false;
    }    
}

@end


