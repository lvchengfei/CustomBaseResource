//
//  PKToastView.m
//  Pumpkin
//
//  Created by lv on 7/14/12.
//  Copyright (c) 2012 XXX. All rights reserved.
//

#import "PKToastView.h"
#import <QuartzCore/QuartzCore.h>

static PKToastView* toastView = nil;

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface PKToastView ()
@property(nonatomic,assign) UILabel* titleLabel;
@property(nonatomic,assign) UIActivityIndicatorView* activityView;

- (void) applicationDidEnterBackground:(NSNotification *)notification;
- (UILabel*)addTitleLabel:(NSString*)title;
- (UIActivityIndicatorView*)addActivityIndicatorView;
- (void)layout;
- (void)layoutOnlyActivity;
- (void)layoutTitleAndActivity;
@end

static const CGFloat kLeftMargin   = 2.0;
static const CGFloat kTopMargin    = 16.0;
static const CGFloat kBottomMargin = 15.0;
static const CGFloat kRowMargin	   = 5.0;
static const CGFloat kColumnMargin = 10.0;

static const CGFloat width_ = 100.0;


@implementation PKToastView
@synthesize titleLabel = titleLabel_;
@synthesize activityView = activityView_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		backGroundView_ = [[UIView alloc] initWithFrame:CGRectZero];
		backGroundView_.backgroundColor = [UIColor blackColor];//[UIColor darkGrayColor];
		backGroundView_.alpha= 0.9;
		backGroundView_.layer.cornerRadius = 8.0;
		backGroundView_.layer.masksToBounds = YES;
		[self addSubview:backGroundView_];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
													 name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
	[toastView release];
	toastView = nil;
	[backGroundView_	release];
	[titleLabel_		release];
	[activityView_		release];
	[super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - Public Method

+ (void)showWithTitle:(NSString*)title animation:(BOOL)animation
{

	if (toastView==nil) {
		toastView = [[PKToastView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	}
	
	[toastView addTitleLabel:title];
	[toastView addActivityIndicatorView];
	
	[toastView layout];
	
	toastView.alpha = 0.0f;
	UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
	[keyWindow addSubview:toastView];
	if (animation) 
	{
		toastView.alpha = 0.0;
		[UIView animateWithDuration:0.3 animations:^{[toastView.activityView startAnimating];toastView.alpha=1.0;}]; 
	}
	else
	{
		toastView.alpha = 1.0;
		[toastView.activityView startAnimating];
	}
	
}

+ (void)dismissWithAnimation:(BOOL)animation
{
	if (animation) 
	{

		[UIView animateWithDuration:0.3 animations:^{[toastView.activityView stopAnimating];[toastView removeFromSuperview];}]; 
	}
	else
	{
		[toastView.activityView stopAnimating];
		[toastView removeFromSuperview];
	}
}

#pragma mark -
#pragma mark Notification



- (void) applicationDidEnterBackground:(NSNotification *)notification
{
	[PKToastView dismissWithAnimation:NO];
	
}
#pragma mark - Private Method

- (UILabel*)addTitleLabel:(NSString*)title
{
	if (titleLabel_==nil)
	{
		titleLabel_  = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel_.textColor = [UIColor whiteColor];
		titleLabel_.font = [UIFont systemFontOfSize:14];
		titleLabel_.textAlignment = UITextAlignmentCenter;
		titleLabel_.backgroundColor = [UIColor clearColor];
		titleLabel_.lineBreakMode = UILineBreakModeWordWrap;
		titleLabel_.numberOfLines = 0; 
		[backGroundView_ addSubview:titleLabel_];
	}
	titleLabel_.text = title ;
	return titleLabel_;
}

- (UIActivityIndicatorView*)addActivityIndicatorView
{
	if (activityView_==nil)
	{
		activityView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[backGroundView_ addSubview:activityView_];
	}
	
	return activityView_ ;
}

- (CGSize)titleLabelSize
{
	CGFloat wid = width_-2*kLeftMargin ;
	CGSize size = [titleLabel_.text sizeWithFont:titleLabel_.font constrainedToSize:CGSizeMake(wid, 100) lineBreakMode:UILineBreakModeWordWrap];
	return size;
}

- (CGSize)activityViewSize
{
	CGSize activitySize = [activityView_ sizeThatFits:CGSizeZero];
	return activitySize ;
}



- (void)layoutOnlyActivity
{
	CGSize  activitySize = [self activityViewSize];
	CGFloat activityX = (width_-activitySize.width)/2;
	CGFloat activityY = (width_-activitySize.height)/2;
	CGFloat alertX = (kScreenWidth-width_)/2;
	CGFloat alertY = (kScreenHeight-width_)/2;
	CGRect activityRect = CGRectMake(activityX,activityY,activitySize.width,activitySize.height);
	CGRect viewRect     = CGRectMake(alertX,alertY,width_,width_);
	
	[activityView_		setFrame:activityRect];
	[backGroundView_	setFrame:viewRect];
	
}

- (void)layoutTitleAndActivity
{
	CGSize titleSize    = [self titleLabelSize];
	CGSize activitySize = [self activityViewSize];
	
	CGFloat alertWidth = width_;
	CGFloat alertHeiht = kTopMargin+titleSize.height+kRowMargin+activitySize.height+kBottomMargin;
	CGFloat maxSize = MAX(alertWidth, alertHeiht);
	alertWidth = maxSize;
	alertHeiht = maxSize;
	CGFloat alertX = (kScreenWidth-alertWidth)/2;
	CGFloat alertY = (kScreenHeight-alertHeiht)/2;
	
	CGFloat activityX = (alertWidth-activitySize.width)/2;
	CGFloat activityY = kTopMargin+titleSize.height + kRowMargin + (alertHeiht - kTopMargin-titleSize.height-kRowMargin -activitySize.height - kBottomMargin)/2;
	
	CGFloat titleX = (alertWidth-titleSize.width)/2;
	
	CGRect titleRect    = CGRectMake(titleX,kTopMargin,titleSize.width,titleSize.height);
	CGRect activityRect = CGRectMake(activityX,activityY,activitySize.width,activitySize.height);
	CGRect alertRect    = CGRectMake(alertX,alertY,alertWidth,alertHeiht);
	
	[titleLabel_	setFrame:titleRect];
	[activityView_  setFrame:activityRect];
	[backGroundView_ setFrame:alertRect];
	
	
}

- (void)layout
{
	if (titleLabel_.text==nil || [titleLabel_.text isEqualToString:@""])
	{
		[self layoutOnlyActivity];
	}
	else
	{
		[self layoutTitleAndActivity];
	}
	

}

@end
