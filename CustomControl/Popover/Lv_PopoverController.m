//
//  Lv_PopoverController.m
//
//  Created by lv on 12/5/12.
//
//

#import "Lv_PopoverController.h"
#import "Lv_PopoverView.h"

#define kAnimationInterval		0.3
#define kPopoverPortRect CGRectMake(0, 0, kKeyBoardPortraitWidth, 180)
#define kPopoverLandRect CGRectMake(0, 0, kKeyBoardLandscapeWidth, 140)






@interface Lv_PopoverController()
@property (nonatomic, retain)UIViewController* viewController;
- (void)addObserver;
- (void)removeObserver;
@end

@implementation Lv_PopoverController
@synthesize viewController = viewController_;
@synthesize delegate = delegate_;

-(id)initWithViewController:(UIViewController*)viewController
{
	self = [super init];
	if (self)
	{
		viewController_ = [viewController retain];
		popoverView_	= [[Lv_PopoverView alloc] initWithFrame:kPopoverPortRect];
		[popoverView_	addSubview:viewController.view];
	}
	return self;
}

- (void)loadView
{
	self.view = popoverView_;
}

- (void)dealloc
{
	[self removeObserver];
	delegate_ = nil;
	[popoverView_		release];
	[viewController_	release];
	[super dealloc];
}

#pragma mark - Public Method

-(void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController)
	{
		[self.viewController.view	removeFromSuperview];
		self.viewController = viewController;
		if (animated)
		{
			[UIView animateWithDuration:kAnimationInterval
							 animations:^{[popoverView_ addSubview:viewController.view];}
							 completion:^(BOOL finished){
								 if (delegate_&&[delegate_ respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
								 {
									 [delegate_ popoverControllerDidDismissPopover:self];
								 } }];
			
		}
		else
		{
			[popoverView_ addSubview:viewController.view];
			if (delegate_&&[delegate_ respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
			{
				[delegate_ popoverControllerDidDismissPopover:self];
			}
		}
	}
}

-(void)presentPopoverInView:(UIView *)view arrowType:(BIPopoverArrowType)arrowType animated:(BOOL)animated
{
	if (view&&self.view.superview != view)
	{
		popoverView_.arrowType = arrowType;
		if (animated)
		{
			[UIView animateWithDuration:kAnimationInterval
							 animations:^{[view addSubview:self.view];}
							 completion:^(BOOL finished){[self addObserver];}];
		}
		else
		{
			[view addSubview:self.view];
			[self addObserver];
		}
	}
}

-(void)dismissPopoverAnimated:(BOOL)animated
{
	if (animated)
	{
		[UIView animateWithDuration:kAnimationInterval
						 animations:^{[self.view removeFromSuperview];}
						 completion:^(BOOL finished) {
							 [self removeObserver];
						 }];
	}
	else
	{
		[self.view removeFromSuperview];
		[self removeObserver];
	}
}


#pragma mark -  Orientation Notifications
- (void) applicationWillChangeStatusBarOrientation:(NSNotification *)notification
{
	//UIDeviceOrientation orientation = [[[notification userInfo] objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
	//NSLog(@"applicationWillChangeStatusBarOrientation=%d" , orientation);
}

#pragma mark - Private Method

- (void)setArrowType:(BIPopoverArrowType)arrowType
{
	popoverView_.arrowType = arrowType;
}

- (BIPopoverArrowType)arrowType
{
	return popoverView_.arrowType;
}

- (void)setPopoverLayoutMargins:(UIEdgeInsets)popoverLayoutMargins
{
	if (!UIEdgeInsetsEqualToEdgeInsets(popoverView_.margins, popoverLayoutMargins))
	{
		popoverView_.margins = popoverLayoutMargins;
	}
}

- (UIEdgeInsets)popoverLayoutMargins
{
	return popoverView_.margins;
}

- (void)addObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillChangeStatusBarOrientation:)
												 name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)removeObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
