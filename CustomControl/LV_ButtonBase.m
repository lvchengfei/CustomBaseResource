//
//  LV_ButtonBase.m
//  xxxInputLib
//
//  Created by lv on 4/28/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//


#import "LV_ButtonBase.h"

#define kButtonHotSizeExpand CGSizeMake(4, 4)

@implementation LV_ButtonBase
@synthesize buttonTitle = buttonTitle_;
//@synthesize lightImage  = lightImage_;
//@synthesize normalImage = normalImage_;

- (id)initWithFrame:(CGRect)frame buttonTitle:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		UIImage* tmpImage = nil;
		tmpImage = [UIImage imageNamed:@"audioButtonLight.png"];
		self.lightImage  = [tmpImage stretchableImageWithLeftCapWidth:tmpImage.size.width/2 topCapHeight:tmpImage.size.height/2];
		tmpImage = [UIImage imageNamed:@"audioButtonNormal.png"];
		self.normalImage = [tmpImage stretchableImageWithLeftCapWidth:tmpImage.size.width/2 topCapHeight:tmpImage.size.height/2];
		buttonTitle_ = [[UILabel alloc] init];
		buttonTitle_.text = title?title:@"";
		buttonTitle_.font = [UIFont systemFontOfSize:15];
		buttonTitle_.textColor = [UIColor whiteColor];
		buttonTitle_.backgroundColor = [UIColor clearColor];
		buttonTitle_.textAlignment = UITextAlignmentCenter;
		expandSize_  = kButtonHotSizeExpand; 
		self.backgroundColor = [UIColor clearColor];
		[self addSubview:buttonTitle_];
    }
    return self;
}



- (void)dealloc
{
	[lightImage_	release];
	[normalImage_	release];
	[buttonTitle_	release];
    [super      dealloc];
}

-(void)setFrame:(CGRect)frame
{
	frame = CGRectOffset(frame, -expandSize_.width, -expandSize_.height);
	frame.size.width  += expandSize_.width*2;
	frame.size.height += expandSize_.height*2;
	CGSize  titleSize = [buttonTitle_ sizeThatFits:CGSizeZero];
	CGFloat offX = (NSInteger)(frame.size.width - titleSize.width)/2;
	CGFloat offY = (NSInteger)(frame.size.height - titleSize.height)/2;
	[buttonTitle_ setFrame:CGRectMake(offX, offY, titleSize.width, titleSize.height)];
	[super setFrame:frame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGRect frame = CGRectOffset(rect, expandSize_.width, expandSize_.height);
	frame.size.width  -= expandSize_.width*2;
	frame.size.height -= expandSize_.height*2;
	
	if (self.highlighted) 
	{
		[lightImage_  drawInRect:frame];
	}
	else
	{
		[normalImage_ drawInRect:frame];
	}
}


- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	[self  setNeedsDisplay];
}

- (void)setLightImage:(UIImage *)lightImage
{
	if (lightImage_!=lightImage) 
	{
		[lightImage_ release];
		lightImage_ = [lightImage retain];
	}
	[self	setNeedsDisplay];
}

- (UIImage *)lightImage
{
	return lightImage_;
}

- (void)setNormalImage:(UIImage *)normalImage
{
	if (normalImage_!=normalImage)
	{
		[normalImage_	release];
		normalImage_ = [normalImage	retain];
	}
	[self setNeedsDisplay];
}

- (UIImage *)normalImage
{
	return normalImage_;
}

@end
