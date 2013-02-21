//
//  Lv_PopoverView.m
//
//  Created by lv on 12/5/12.
//
//

#import "Lv_PopoverView.h"
#import <QuartzCore/QuartzCore.h>


//Curvature value for the arc.
#define kArcCurvature		12.0f
//Control Point Offset.
#define kArcCurvatureOff	roundf(kArcCurvature/2)
//Height/width of the actual arrow
#define kArrowHeight		10.f
//Curvature value for the arrow.  Set to 0.f to make it linear.
#define kArrowCurvature		3.f
//Alpha value for the shadow
#define kShadowAlpha		1.0f
//Radius for the shadow
#define kShadowRadius		5.0f

@implementation Lv_PopoverView
@synthesize arrowType = arrowType_;
@synthesize margins   = margins_;
@synthesize backImage = backImage_;
@synthesize backColor = backColor_;
@synthesize arrowHeight = arrowHeight_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		margins_	 = UIEdgeInsetsZero;
		arrowHeight_ = kArrowHeight;
		arrowType_ = BIPopoverArrowDownCenter;
		backColor_ = [UIColor darkGrayColor];
		self.layer.shadowColor  = backColor_.CGColor;
		self.layer.shadowOffset = CGSizeZero;
		self.layer.shadowRadius = kShadowRadius;
		self.layer.shadowOpacity = kShadowAlpha;
		//backImage_ = [[UIImage imageNamed:@"backImage"] retain];
    }
    return self;
}

- (void)dealloc
{
	[backImage_ release];
	[backColor_	release];
	[super dealloc];
}

- (void)setArrowType:(BIPopoverArrowType)arrowType
{
	if (arrowType_!=arrowType)
	{
		arrowType_ = arrowType;
		[self setNeedsDisplay];
	}
}

- (void)setBackImage:(UIImage *)backImage
{
	if (backImage!=backImage_)
	{
		[backImage_ release];
		backImage_ = [backImage retain];
		self.layer.contents = (id)backImage_.CGImage;
	}
}

- (void)setBackColor:(UIColor *)backColor
{
	if (backColor_!=backColor)
	{
		[backColor_	release];
		backColor_ = [backColor	retain];
		if (!backImage_) {
			[self setNeedsDisplay];
		}
	}
}

#pragma mark - Drawing Routines


-(CGPoint)arrowPointFromRect:(CGRect)rect arrowType:(BIPopoverArrowType)type arrowHeight:(CGFloat)height
{
	CGPoint arrowPoint = CGPointZero;
	if (CGRectIsEmpty(rect))
	{
		return arrowPoint;
	}
	switch (type)
	{
		case BIPopoverArrowUpLeft:
			arrowPoint = CGPointMake(kArcCurvature+kArrowHeight, 0);
			break;
		case BIPopoverArrowUpCenter:
			arrowPoint = CGPointMake(roundf(rect.size.width/2), 0);
			break;
		case BIPopoverArrowUpRight:
			arrowPoint = CGPointMake(rect.size.width-kArcCurvature-kArrowHeight, 0);
			break;
		case BIPopoverArrowDownLeft:
			arrowPoint = CGPointMake(kArcCurvature+kArrowHeight, rect.size.height);
			break;
		case BIPopoverArrowDownCenter:
			arrowPoint = CGPointMake(roundf(rect.size.width/2), rect.size.height);
			break;
		case BIPopoverArrowDownRight:
			arrowPoint = CGPointMake(rect.size.width-kArcCurvature-kArrowHeight, rect.size.height);
			break;
		default:
			arrowPoint = CGPointMake(roundf(rect.size.width/2), 0);
			break;
	}
	return arrowPoint;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	rect = UIEdgeInsetsInsetRect(rect, margins_);
	if (backImage_)
	{
		[backImage_ drawAtPoint:rect.origin];
		return;
	}
	
	//     LT2            RT1
	//  LT1⌜⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⌝RT2
	//     |               |
	//     |    popover    |
	//     |               |
	//  LB2⌞_______________⌟RB1
	//     LB1           RB2
	//
	//     Traverse rectangle in clockwise order, starting at LT1
	//     L = Left
	//     R = Right
	//     T = Top
	//     B = Bottom
	//     1,2 = order of traversal for any given corner
	
	CGPoint arrowPoint = [self arrowPointFromRect:rect arrowType:arrowType_ arrowHeight:arrowHeight_];
	float xMin = CGRectGetMinX(rect);
	float yMin = CGRectGetMinY(rect);
	float xMax = CGRectGetMaxX(rect);
	float yMax = CGRectGetMaxY(rect);
	yMin = (arrowType_<=BIPopoverArrowUpRight)? yMin+arrowHeight_:yMin;
	yMax = (arrowType_<=BIPopoverArrowUpRight)? yMax:yMax-arrowHeight_;
	
	UIBezierPath *popoverPath = [UIBezierPath bezierPath];
	
	[popoverPath moveToPoint:CGPointMake(xMin, yMin + kArcCurvature)];//LT1
	[popoverPath addCurveToPoint:CGPointMake(xMin + kArcCurvature, yMin) controlPoint1:CGPointMake(xMin, yMin + kArcCurvature - kArcCurvatureOff) controlPoint2:CGPointMake(xMin + kArcCurvature - kArcCurvatureOff, yMin)];//LT2
	
	//If the popover is positioned below (!above) the arrowPoint, then we know that the arrow must be on the top of the popover.
	//In this case, the arrow is located between LT2 and RT1
	if(arrowType_<=BIPopoverArrowUpRight)
	{
		[popoverPath addLineToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMin)];//left side
		[popoverPath addCurveToPoint:arrowPoint controlPoint1:CGPointMake(arrowPoint.x - kArrowHeight + kArrowCurvature, yMin) controlPoint2:arrowPoint];//actual arrow point
		[popoverPath addCurveToPoint:CGPointMake(arrowPoint.x + kArrowHeight, yMin) controlPoint1:arrowPoint controlPoint2:CGPointMake(arrowPoint.x + kArrowHeight - kArrowCurvature, yMin)];//right side
	}
	
	[popoverPath addLineToPoint:CGPointMake(xMax - kArcCurvature, yMin)];//RT1
	[popoverPath addCurveToPoint:CGPointMake(xMax, yMin + kArcCurvature) controlPoint1:CGPointMake(xMax - kArcCurvature + kArcCurvatureOff, yMin) controlPoint2:CGPointMake(xMax, yMin + kArcCurvature - kArcCurvatureOff)];//RT2
	[popoverPath addLineToPoint:CGPointMake(xMax, yMax - kArcCurvature)];//RB1
	[popoverPath addCurveToPoint:CGPointMake(xMax - kArcCurvature, yMax) controlPoint1:CGPointMake(xMax, yMax - kArcCurvature + kArcCurvatureOff) controlPoint2:CGPointMake(xMax - kArcCurvature + kArcCurvatureOff, yMax)];//RB2
	
	//If the popover is positioned above the arrowPoint, then we know that the arrow must be on the bottom of the popover.
	//In this case, the arrow is located somewhere between LB1 and RB2
	if(arrowType_>BIPopoverArrowUpRight)
	{
		[popoverPath addLineToPoint:CGPointMake(arrowPoint.x + kArrowHeight, yMax)];//right side
		[popoverPath addCurveToPoint:arrowPoint controlPoint1:CGPointMake(arrowPoint.x + kArrowHeight - kArrowCurvature, yMax) controlPoint2:arrowPoint];//arrow point
		[popoverPath addCurveToPoint:CGPointMake(arrowPoint.x - kArrowHeight, yMax) controlPoint1:arrowPoint controlPoint2:CGPointMake(arrowPoint.x - kArrowHeight + kArrowCurvature, yMax)];
	}
	
	[popoverPath addLineToPoint:CGPointMake(xMin + kArcCurvature, yMax)];//LB1
	[popoverPath addCurveToPoint:CGPointMake(xMin, yMax - kArcCurvature) controlPoint1:CGPointMake(xMin + kArcCurvature - kArcCurvatureOff, yMax) controlPoint2:CGPointMake(xMin, yMax - kArcCurvature + kArcCurvatureOff)];//LB2
	
	[popoverPath addLineToPoint:CGPointMake(xMin , yMin + kArcCurvature)];//LT1
	[popoverPath closePath];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, backColor_.CGColor);
	[popoverPath fill];
	
}

@end
