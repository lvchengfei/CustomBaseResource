//
//  PKBadgeView.m
//  Pumpkin
//
//  Created by lv on 12/7/12.
//
//

#import "PKBadgeView.h"
#import <QuartzCore/QuartzCore.h>


#define kBadgeStrokeColor [UIColor whiteColor]
#define kBadgeStrokeWidth 2.0f
#define kMarginToDrawInside (kBadgeStrokeWidth * 2)
#define kShadowOffset CGSizeMake(0.0f, 3.0f)
#define kShadowOpacity 0.4f
#define kShadowColor [UIColor colorWithWhite:0.0f alpha:kShadowOpacity]
#define kShadowRadius 1.0f
#define kBadgeHeight 16.0f
#define kBadgeTextSideMargin 8.0f
#define kBadgeCornerRadius 10.0f


@interface PKBadgeView()
@property (nonatomic, retain)PKBadgeStyle*	badgeStyle;
- (CGSize)sizeOfTextForCurrentSettings;

@end

@implementation PKBadgeView
@synthesize badgeText  = badgeText_;
@synthesize badgeStyle = badgeStyle_;

- (id)initWithParentView:(UIView *)parentView  badgeStyle:(PKBadgeStyle*)style
{
	self = [super initWithFrame:CGRectZero];
	if (self) {
		//self.badgeText  = text;
		self.badgeStyle = style;
		[parentView addSubview:self];
	}
	return self;
}

- (void)dealloc
{
	[badgeText_		release];
	[badgeStyle_	release];
	[super dealloc];
}



#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    BOOL anyTextToDraw = (self.badgeText.length > 0);
    
    if (anyTextToDraw)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGRect rectToDraw = CGRectInset(rect, kMarginToDrawInside, kMarginToDrawInside);
        
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(kBadgeCornerRadius, kBadgeCornerRadius)];
        
        /* Background and shadow */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetFillColorWithColor(ctx, self.badgeStyle.backColor.CGColor);
            CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowRadius, kShadowColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathFill);
        }
        CGContextRestoreGState(ctx);
        
        BOOL colorForOverlayPresent = self.badgeStyle.overLayColor && ![self.badgeStyle.overLayColor isEqual:[UIColor clearColor]];
        
        if (colorForOverlayPresent)
        {
            /* Gradient overlay */
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, borderPath.CGPath);
                CGContextClip(ctx);
                
                CGFloat height = rectToDraw.size.height;
                CGFloat width = rectToDraw.size.width;
                
                CGRect rectForOverlayCircle = CGRectMake(rectToDraw.origin.x,
                                                         rectToDraw.origin.y - ceilf(height * 0.5),
                                                         width,
                                                         height);
                
                CGContextAddEllipseInRect(ctx, rectForOverlayCircle);
                CGContextSetFillColorWithColor(ctx, self.badgeStyle.overLayColor.CGColor);
                
                CGContextDrawPath(ctx, kCGPathFill);
            }
            CGContextRestoreGState(ctx);
        }
        
        /* Stroke */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetLineWidth(ctx, kBadgeStrokeWidth);
            CGContextSetStrokeColorWithColor(ctx, kBadgeStrokeColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        CGContextRestoreGState(ctx);
        
        /* Text */
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, self.badgeStyle.textColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.badgeStyle.textShadowOffset, 1.0, self.badgeStyle.textShadowColor.CGColor);
            
            CGRect textFrame = rectToDraw;
            CGSize textSize = [self sizeOfTextForCurrentSettings];
            
            textFrame.size.height = textSize.height;
            textFrame.origin.y = rectToDraw.origin.y + ceilf((rectToDraw.size.height - textFrame.size.height) / 2.0f);
            
            [self.badgeText drawInRect:textFrame
                              withFont:self.badgeStyle.textFont
                         lineBreakMode:UILineBreakModeCharacterWrap
                             alignment:UITextAlignmentCenter];
        }
        CGContextRestoreGState(ctx);
    }
}




#pragma mark - Layout

- (void)layoutSubviews
{
    CGRect newFrame = self.frame;
    CGRect superviewFrame =  self.superview.frame ;
    
    CGFloat textWidth = [self sizeOfTextForCurrentSettings].width;
    
    CGFloat viewWidth = textWidth + kBadgeTextSideMargin + (kMarginToDrawInside * 2);
    CGFloat viewHeight = kBadgeHeight + (kMarginToDrawInside * 2);
    
    CGFloat superviewWidth = superviewFrame.size.width;
    CGFloat superviewHeight = superviewFrame.size.height;
    
    newFrame.size.width = viewWidth;
    newFrame.size.height = viewHeight;
    
    switch (self.badgeStyle.badgeAlignment) {
        case BIBadgeAlignmentTopLeft:
            newFrame.origin.x = 0;//-viewWidth / 2.0f;
            newFrame.origin.y = 0;//-viewHeight / 2.0f;
            break;
        case BIBadgeAlignmentTopRight:
            newFrame.origin.x = superviewWidth-viewWidth;//superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = 0;//-viewHeight / 2.0f;
            break;
        case BIBadgeAlignmentTopCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = 0;//-viewHeight / 2.0f;
            break;
        case BIBadgeAlignmentCenterLeft:
            newFrame.origin.x = 0;//-viewWidth / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case BIBadgeAlignmentCenterRight:
            newFrame.origin.x = superviewWidth-viewWidth;//superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case BIBadgeAlignmentBottomLeft:
            newFrame.origin.x = 0;//-textWidth / 2.0f;
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
			break;
        case BIBadgeAlignmentBottomRight:
            newFrame.origin.x = superviewWidth-viewWidth;//superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = superviewHeight - viewHeight;//superviewHeight - (viewHeight / 2.0f);
            break;
        case BIBadgeAlignmentBottomCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = superviewHeight - viewHeight;//superviewHeight - (viewHeight / 2.0f);
            break;
        case BIBadgeAlignmentCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        default://top right
			newFrame.origin.x = superviewWidth-viewWidth;//superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = 0;
			break;
    }
    
    newFrame.origin.x += self.badgeStyle.adjustOffset.x;
    newFrame.origin.y += self.badgeStyle.adjustOffset.y;
    
    self.frame = CGRectIntegral(newFrame);
    [self setNeedsDisplay];
}

#pragma mark - Public Method

- (void)setBadgeText:(NSString *)badgeText
{
    if (badgeText_ != badgeText)
    {
        badgeText_ = [badgeText copy];
        [self setNeedsLayout];
    }
}

#pragma mark - Private

- (CGSize)sizeOfTextForCurrentSettings
{
    return [self.badgeText sizeWithFont:self.badgeStyle.textFont];
}


- (void)setBadgeAlignment:(BIBadgeViewAlignment)badgeAlignment
{
    if (badgeAlignment != badgeStyle_.badgeAlignment)
    {
        badgeStyle_.badgeAlignment = badgeAlignment;
		
        switch (badgeAlignment)
        {
            case BIBadgeAlignmentTopLeft:
                self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case BIBadgeAlignmentTopRight:
                self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
                break;
            case BIBadgeAlignmentTopCenter:
                self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case BIBadgeAlignmentCenterLeft:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case BIBadgeAlignmentCenterRight:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
                break;
            case BIBadgeAlignmentBottomLeft:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case BIBadgeAlignmentBottomRight:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
                break;
            case BIBadgeAlignmentBottomCenter:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case BIBadgeAlignmentCenter:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                break;
            default:
				break;
        }
		
        [self setNeedsLayout];
    }
}

@end
