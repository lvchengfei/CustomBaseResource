//
//  PKReachAbilityManager.h
//  Pumkin
//
//  Created by lv on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKReachability;



@interface PKReachAbilityManager : NSObject
{
    PKReachability* internetReach_;
    PKReachability* wifiReach_;
}

- (void) updateStatusWithReachability: (PKReachability*) curReach;
- (void) reachabilityChanged: (NSNotification* )note;


+(BOOL) isWifiAvailable;
+(BOOL) isInternetAvailable;

@end
