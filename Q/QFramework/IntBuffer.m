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

#import "IntBuffer.h"


@implementation IntBuffer


-(id) init 
{
	if (self = [super init])
	{
        step = 128;
        size = step;
        count = 0;
        
        buffer = malloc(size * sizeof(int));
    }
    return self;    
}

-(void) dealloc {
    [super dealloc];
    free(buffer);
}

- (void) grow 
{
    //int sizeold = size;    
    size += step;
    //int* bufferold = buffer;
    //buffer = malloc(size * sizeof(int));
    
    //memcpy(buffer, bufferold, sizeold * sizeof(int));
    //free(bufferold);
    
    buffer = realloc(buffer, size * sizeof(int));
}

- (void) put:(int) val
{
    if (count >= size)
    {
        [self grow];
    }
    buffer[count] = val;
    count ++;
}

- (int*)    get
{
    return buffer;
}

-(void) print
{
    NSLog( @"----int buffer---" );    
    NSMutableString* out = [[NSMutableString alloc] init];
    for (int a=0; a< count; a++)
    {
        [out appendFormat:@"%d ",buffer[a]];
        if (a > 0 && a%10 == 0)
        {
            NSLog( @"%@",out );    

            [out setString:@""];
        }
    }
    NSLog( @"%@",out );    


}


@end
