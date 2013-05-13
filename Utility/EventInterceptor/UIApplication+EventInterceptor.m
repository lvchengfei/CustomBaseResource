//
//  UIApplication+EventInterceptor.m
//  EventInterceptor
//
//  Created by David Fox on 8/2/12.
//  Copyright (c) 2012 David Fox. All rights reserved.
//

#import "UIApplication+EventInterceptor.h"
#import <objc/runtime.h>
//#import "EventLogger.h"

@implementation UIApplication (EventInterceptor)


+(void) load
{
    //Swap the implementations of our interceptor and the original sendEvent:
    Method oldMethod = class_getInstanceMethod(self, @selector(sendEvent:));
    Method newMethod = class_getInstanceMethod(self, @selector(interceptSendEvent:));
    method_exchangeImplementations(oldMethod, newMethod);
}

-(void) interceptSendEvent: (UIEvent *) event
{
	NSLog(@">>> sendEvent= %@",event);
	/*
    for (UITouch *touch in event.allTouches){
        if (touch.phase == UITouchPhaseBegan){
            NSLog(@">>>%@",touch);
			//[EventLogger logEvent:EVENT_LOGGER_TOUCHED forObject:touch.view];
        }
    }
	*/
    [self interceptSendEvent:event];
}

@end
