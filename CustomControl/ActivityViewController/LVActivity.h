//
//  LVActivity.h
//  
//
//  Created   on 5/24/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LVActivity : UIActivity
{
	NSString*		activityType_;
	NSString*		activityTitle_;
	UIImage*		activityImage_;
	UIViewController* viewController_;
	NSUInteger		type_;
	NSString*		shareText_;
}
- (void)loadResouce;
@end

@interface LVTencentActivity : LVActivity
{}
@end


@interface LVSinaActivity : LVActivity
{}
@end