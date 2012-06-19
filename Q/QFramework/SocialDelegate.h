//
//  SocialDelegate.h
//  Bela
//
//  Created by damir kolobaric on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocialDelegate<NSObject>

@required
//@optional

-(void) startLogin:(NSString*)callback;
-(void) startGetScore:(NSString*) leaderBoard callback:(NSString*)callback;
-(void) startSubmitScore:(NSString*)lname score:(NSString*)score message:(NSString*)message callback:(NSString*)callback;
-(void) startShow:(NSString*) leaderBoard ;
-(void) startSubmitAchievement:(NSString*)aname score:(NSString*)score;

@end
