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


#import "ColorFactory.h"


@implementation ColorFactory

@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize yellow;
@synthesize redL;
@synthesize greenL;
@synthesize blueL;
@synthesize yellowL;
@synthesize orange;
@synthesize white;    
@synthesize gray;
@synthesize grayL;
@synthesize black;
@synthesize transparent;
@synthesize magnenta;
@synthesize magnentaL;
@synthesize brown;
@synthesize brownL;


- (void)dealloc
{
    [red dealloc];
    [green dealloc];
    [blue dealloc];
    [yellow dealloc];
    [redL dealloc];
    [greenL dealloc];
    [blueL dealloc];
    [yellowL dealloc];
    [orange dealloc];
    [white dealloc];
    [gray dealloc];
    [grayL dealloc];    
    [black dealloc];    
    [magnenta dealloc];
    [magnentaL dealloc];
    [brown dealloc];
    [brownL dealloc];    
    [super dealloc];
}


- (id)init
{
    self = [super init];
    
    if (self) {
        int one = 255;//0x10000;
        int half = 128;//0x08000;
        int half2 = 200;//0x0A000;
        //int quarter = 0x04000;
        
        red = [[GLColor alloc] initWithRGBA:half2 g:0 b:0 a:one];
        green = [[GLColor alloc] initWithRGBA:0 g:one b:0 a:half2];
        blue = [[GLColor alloc] initWithRGBA:0 g:0 b:one a:half2];
        yellow = [[GLColor alloc] initWithRGBA:one g:one b:0 a:one];
        
        redL = [[GLColor alloc] initWithRGBA:one g:half2 b:half2  a:half];
        greenL = [[GLColor alloc] initWithRGBA:half2 g:one b:half2 a:half];
        blueL = [[GLColor alloc] initWithRGBA:half2 g:half2 b:one a:half];
        yellowL = [[GLColor alloc] initWithRGBA:one g:one b:half2 a:one];
        grayL = [[GLColor alloc] initWithRGBA:half g:half b:half];
        magnentaL = [[GLColor alloc] initWithRGBA:half2 g:half b:half2];
        brownL = [[GLColor alloc] initWithRGBA:half2 g:half b:0];
        
        orange = [[GLColor alloc] initWithRGBA:one g:half b:0 a:half];
        white = [[GLColor alloc] initWithRGBA:one g:one b:one];
        gray = [[GLColor alloc] initWithRGBA:half2 g:half2 b:half2];
        black = [[GLColor alloc] initWithRGBA:0 g:0 b:0];	
        magnenta = [[GLColor alloc] initWithRGBA:one g:half b:one];	
        brown = [[GLColor alloc] initWithRGBA:one g:half b:0];
        
        transparent = [[GLColor alloc] initWithRGBA:one g:one b:one];        
    }
    return  self;
}



-(GLColor*) getPlayerColor:(int) player
{
    switch (player)
    {
        case 0: return [gray copyColor];
        case 1: return [red copyColor];
        case 4: return [blue copyColor];
        case 2: return [green copyColor];
        case 3: return [orange copyColor];//yellow;    	
    }
    return white;
}
 
-(GLColor*)getPlayerColorFore:(int) player
{
    switch (player)
    {
        case 1: return [redL copyColor];
        case 4: return [blueL copyColor];
        case 2: return [greenL copyColor];
        case 3: return [yellowL copyColor];    	
    }
    return white;
    
}

-(GLColor*)getColor:(NSString*)value
{
    if ([value hasPrefix:@"player"])
    {
        int val = [value characterAtIndex:6];
        return [self getPlayerColorFore:(val-'0')];
    }

    unsigned int dec;
    NSScanner *scan = [NSScanner scannerWithString:value];
    if ([scan scanHexInt:&dec])
    {
        GLColor* color = [[GLColor alloc] initWithRGBA:dec];
        return color;
    }
        
	/*
    try 
    {
    return new GLColor(Color.parseColor("#" + value));
    } catch (IllegalArgumentException e) {
    return white;
    }
 */
    return [white copyColor];
}
 

+(int)getColorVal:(NSString*)value
{
    unsigned int dec;
    NSScanner *scan = [NSScanner scannerWithString:value];
    if ([scan scanHexInt:&dec])
    {
        return dec;
    }
    return 0xFFFFFFFF;
}


-(GLColor*)getColorId:(int) color
{
	switch(color)
	{
		case 0:
			return [white copyColor];
		case 1:
			return [red copyColor];
		case 2:
			return [green copyColor];
		case 3:
			return [blue copyColor];
		case 4:
			return [yellow copyColor];
		case 5:
			return [magnenta copyColor];
		case 6:
			return [brown copyColor];
		case 7:
			return [black copyColor];
		case 8:
			return [gray copyColor];
		case 9:
			return [redL copyColor];
		case 10:
			return [greenL copyColor];
		case 11:
			return [blueL copyColor];
		case 12:
			return [yellowL copyColor];
		case 13:
			return [magnentaL copyColor];
		case 14:
			return [brownL copyColor];
		case 15:
			return [grayL copyColor];
	}
	
	return [white copyColor];
}

+(int) encode:(int)a r:(int)r g:(int)g b:(int)b
{
    return (a <<24) + (r << 16 ) + ( g << 8) + b;
}

+(int) decodeA:(int) a
{
    return (a >> 24) & 255;
}

+(int) decodeR:(int) a
{
    return (a >> 16) & 255;
}
+(int) decodeG:(int) a
{
    return (a >> 8) & 255;
}
+(int) decodeB:(int) a
{
    return a & 255;
}


@end
