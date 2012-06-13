//
//  LV_InputButton.m
//
//  Created by lv on 4/28/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import "LV_InputButton.h"


@implementation LV_InputButton
@synthesize enableImage  = enableImage_;
@synthesize disableImage = disableImage_;
//@synthesize isEnable = isEnable_;

- (void)dealloc
{
	[enableImage_		release];
	[disableImage_		release];
	[super dealloc];
}

- (CGSize)expandSize
{
	return expandSize_;
}

- (void)setExpandSize:(CGSize)expandSize
{
	expandSize_ = expandSize;
}

- (BOOL)isEnable
{
	return isEnable_;
}

- (void)setIsEnable:(BOOL)isEnable
{
	isEnable_ = isEnable;
	if (isEnable_) 
	{
		self.normalImage = self.enableImage;
	}
	else 
	{
		self.normalImage = self.disableImage;
	}
}

@end
