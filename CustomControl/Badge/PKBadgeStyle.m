//
//  PKBadgeStyle.m
//  Pumpkin
//
//  Created by lv on 12/7/12.
//
//

#import "PKBadgeStyle.h"


#define kDefaultBadgeTextColor			[UIColor whiteColor]
#define kDefaultBadgeBackColor			[UIColor redColor]
#define kDefaultOverlayColor			[UIColor colorWithWhite:1.0f alpha:0.3]
#define kDefaultBadgeShadowColor		[UIColor clearColor]

#define kDefaultAdjuestOffset			CGPointZero
#define kBadgeStrokeColor				[UIColor whiteColor]
#define kShadowOffset					CGSizeMake(0.0f, 3.0f)
#define kDefaultBadgeAlignment			BIBadgeAlignmentTopRight


@implementation PKBadgeStyle

@synthesize badgeAlignment = badgeAlignment_;
@synthesize backColor = backColor_;
@synthesize textColor = textColor_;
@synthesize textFont  = textFont_;
@synthesize textShadowOffset = textShadowOffset_;
@synthesize textShadowColor	 = textShadowColor_;
@synthesize overLayColor = overLayColor_;
@synthesize adjustOffset = adjustOffset_;

- (void)dealloc
{
	
	[backColor_ release];
	[textColor_	release];
	[textFont_	release];
	[textShadowColor_	release];
	[overLayColor_		release];
	[super dealloc];
}

- (id)init
{
	self = [super init];
	if (self)
	{
		self.backColor  = kDefaultBadgeBackColor;
		self.textColor  = kDefaultBadgeTextColor;
		self.textFont   = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		self.overLayColor = kDefaultOverlayColor;
		self.adjustOffset	  = kDefaultAdjuestOffset;
		self.textShadowColor  = kDefaultBadgeShadowColor;
		self.textShadowOffset = kShadowOffset;
		self.badgeAlignment	  = kDefaultBadgeAlignment;
	}
	return self;
}
 
@end
