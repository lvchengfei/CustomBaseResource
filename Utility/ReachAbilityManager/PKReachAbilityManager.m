//
//  PKReachAbilityManager.m
//  Pumkin
//
//  Created by lv on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PKReachAbilityManager.h"
#import "PKReachability.h"


static PKNetworkStatus    internetReachStatus = kNotReachable;
static PKNetworkStatus    wifiReachStatus = kNotReachable;
static PKReachAbilityManager*	reachAbilityManager = nil;

@implementation PKReachAbilityManager

-(id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

        internetReach_ = [[PKReachability reachabilityForInternetConnection] retain];
        [internetReach_ startNotifier];
        [self updateStatusWithReachability: internetReach_];
        

        wifiReach_ = [[PKReachability reachabilityForLocalWiFi] retain];
        [wifiReach_ startNotifier];
        [self updateStatusWithReachability: wifiReach_];
		
		reachAbilityManager = self;

    }
    
    return self;
}


-(void) dealloc
{

	reachAbilityManager = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [internetReach_ dealloc];
    [wifiReach_ dealloc];
    [super dealloc];
}


//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	PKReachability* curReach = [note object];
	if ([curReach isKindOfClass: [PKReachability class]]) 
	{
		[self updateStatusWithReachability: curReach];
	}
}


- (void) updateStatusWithReachability: (PKReachability*) curReach
{
    if(curReach == internetReach_)
	{	
        internetReachStatus = [curReach currentReachabilityStatus];

	}
	if(curReach == wifiReach_)
	{	
        wifiReachStatus = [curReach currentReachabilityStatus];
	}
}



+(BOOL) isWifiAvailable
{
	if (reachAbilityManager)
	{
		return wifiReachStatus != kNotReachable;
	}
	else 
	{
		NSLog(@">>>You Should Alloc PKReachAbilityManager First!!");
	}
	return NO;
}


+(BOOL) isInternetAvailable
{
	if (reachAbilityManager)
	{
		return internetReachStatus != kNotReachable;
	}
	else
	{
		NSLog(@">>>You Should Alloc PKReachAbilityManager First!!");
	}
	return NO;
}


@end
