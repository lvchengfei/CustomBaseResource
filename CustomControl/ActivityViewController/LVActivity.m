//
//  LVActivity.m
//  
//
//  Created by  on 5/24/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "BI_Activity.h"


@interface LVActivity()

- (void)backButtonPressed:(UIButton*)button;
@end

@implementation LVActivity

- (id)init
{
	self = [super init];
	if (self)
	{
		[self loadResouce];
	}
	return self;
}

-(void)dealloc
{
	[activityType_  release];
	[activityTitle_ release];
	[activityImage_ release];
	[viewController_ release];
	[shareText_		 release];
	[super dealloc];
}

#pragma mark - Virtual function Subclass muset overwirte
- (void)loadResouce
{
	BIDERROR("LVActivity: wrong invoke! pure virtual function:%s",[NSStringFromSelector(_cmd) UTF8String]);
}


#pragma mark - Super Class

- (NSString *)activityType       // default returns nil. subclass may override to return custom activity type that is reported to completion handler
{
	return activityType_;
}


- (NSString *)activityTitle      // default returns nil. subclass must override and must return non-nil value
{
	return activityTitle_;
}

- (UIImage *)activityImage       // default returns nil. subclass must override and must return non-nil value
{
	return activityImage_;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems   // override this to return availability of activity based on items. default returns NO
{
	return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems      // override to extract items and set up your HI. default does nothing
{

#warning ToDo:Create Custom ViewController
	UIViewController* viewController = nil;
	viewController_ = [[UINavigationController alloc] initWithRootViewController:viewController];
	UIButton* backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[backButton  setFrame:CGRectMake(0, 0, 50, 30)];
	[backButton  setTitle:@"返回" forState:UIControlStateNormal];
	[backButton  addTarget:self  action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[[backButton titleLabel] setFont:kNavigationRightBarButtonTitleFont];
    [backButton  setTitleColor:kNavigationRightBarButtonTitleColor_Normal forState:UIControlStateNormal];
    [backButton  setTitleColor:kNavigationRightBarButtonTitleColor_Highlighted forState:UIControlStateHighlighted];
	UIBarButtonItem*backBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	viewController.navigationItem.leftBarButtonItem = backBarItem;
	[backBarItem	release];
	[viewController release];
	
}

- (UIViewController *)activityViewController   // return non-nil to have vC presented modally. call activityDidFinish at end. default returns nil
{
	return viewController_;
}


#pragma mark - Logic Method

- (void)backButtonPressed:(UIButton*)button
{
	[viewController_ release];
	[self activityDidFinish:YES];
}


@end

@implementation BI_TencentActivity

#pragma mark - Super Class

- (void)loadResouce
{
	activityType_  = @"kActivityTypeTencentWeibo";
	activityTitle_ = @"腾讯微博";
	activityImage_ = [[UIImage imageNamed:@"tqq.png"] retain];
	type_ = kBIShareTypeTencentWeibo;
	shareText_ = [[NSString stringWithString:NSLocalizedString(@"String_Broadcast", nil)] retain];
}

#pragma mark - Logic Method

- (void)backButtonPressed:(UIButton*)button
{
	[viewController_ release];
	[self activityDidFinish:YES];
}

@end

@implementation BI_SinaActivity


- (void)loadResouce
{
	activityType_  = @"kActivityTypeSinaWeibo";
	activityTitle_ = @"新浪微博";
	activityImage_ = [[UIImage imageNamed:@"tsina.png"] retain];
	type_ = kBIShareTypeSinaWeibo;
	shareText_ = [[NSString stringWithString:NSLocalizedString(@"String_Broadcast", nil)] retain];
}

#pragma mark - Logic Method

- (void)backButtonPressed:(UIButton*)button
{
	[viewController_ release];
	[self activityDidFinish:YES];
}

@end
