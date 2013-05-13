//
//  PKTabBarView.m
//  Pumpkin
//
//  Created by lv on 7/15/12.
//  Copyright (c) 2012 XXX. All rights reserved.
//

#import "PKTabBarView.h"
#import "PKUtils.h"
#import "PKDefine.h"

@interface PKTabBarView ()
- (void)buttonPressed:(UIButton*)sender;
@end

@implementation PKTabBarView
@synthesize delegate = delegate_;
@synthesize curSeletedIndex = curSeletedIndex_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		tabBarItemsButtonArr_ = [[NSMutableArray alloc] initWithCapacity:0];
		cellImageN_ = [[PKUtils commonImageWithName:@"tab_normal.png"] retain];
		cellImageH_ = [[PKUtils commonImageWithName:@"tab_selected.png"] retain];
		curSeletedIndex_ = 0;
    }
    return self;
}

- (void)dealloc
{
	delegate_ = nil;
	[tabBarItemsButtonArr_  release];
	[cellImageN_			release];
	[cellImageH_			release];
	[imageNArray_			release];
	[imageHArray_			release];
	[super dealloc];
}

#pragma mark - Public Method

- (void)addTabBarItemsButtonCount:(NSInteger)count
{
	NSInteger buttonW = self.frame.size.width/count;
	NSInteger buttonH = kTabbarHeight;//self.frame.size.height;

	for (NSInteger i=0 ; i<count; i++)
	{
		UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setBackgroundImage:cellImageN_ forState:UIControlStateNormal];
		[button setBackgroundImage:cellImageH_ forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
		button.tag = i;
		[button setFrame:CGRectMake(i*buttonW, 0, buttonW, buttonH)];
		[tabBarItemsButtonArr_ addObject:button];
		[self addSubview:button];
	}
}

- (void)setTabBarItemNormalImage:(NSArray*)imageNArray highlightImage:(NSArray*)imageHArray
{
	NSInteger itemsCount = [tabBarItemsButtonArr_ count];
	if ([imageNArray count]==[imageHArray count]&&[imageNArray count]==itemsCount)
	{
		[imageNArray_   release];
		[imageHArray_	release];
		imageNArray_ = [[NSArray arrayWithArray:imageNArray] retain];
		imageHArray_ = [[NSArray arrayWithArray:imageHArray] retain];
		for (NSInteger i=0 ; i< itemsCount; i++) 
		{
			UIButton* button = [tabBarItemsButtonArr_ objectAtIndex:i];
			[button setImage:[imageNArray objectAtIndex:i] forState:UIControlStateNormal];
			[button setImage:[imageHArray objectAtIndex:i] forState:UIControlStateHighlighted];
		}
	}
}

- (void)setTabBarItemTitle:(NSArray*)titleArray
{
	NSInteger itemsCount = [tabBarItemsButtonArr_ count];
	if ([titleArray count]==itemsCount)
	{
		for (NSInteger i=0 ; i< itemsCount; i++) 
		{
			UIButton* button = [tabBarItemsButtonArr_ objectAtIndex:i];
			[button setTitle:[titleArray objectAtIndex:i] forState:UIControlStateNormal];
		}
	}
}
		 
- (void)setTabBarItemSeletedIndex:(NSInteger)index
{
	if (index<[tabBarItemsButtonArr_ count])
	{
		//revert the original setting
		if (curSeletedIndex_!=index) 
		{
			UIButton* button = objectAtIndex(tabBarItemsButtonArr_, curSeletedIndex_);
			[button setBackgroundImage:cellImageN_ forState:UIControlStateNormal];
			[button setImage:objectAtIndex(imageNArray_, curSeletedIndex_) forState:UIControlStateNormal];
		}
		//set current seleted 
		curSeletedIndex_ = index;
		UIButton* button = objectAtIndex(tabBarItemsButtonArr_, index);
		[button setBackgroundImage:cellImageH_ forState:UIControlStateNormal];
		[button setImage:objectAtIndex(imageHArray_, index) forState:UIControlStateNormal];
	}
}

#pragma mark - Private Method 

- (void)buttonPressed:(UIButton*)sender
{
	if (delegate_&&[delegate_ respondsToSelector:@selector(tabBarSelectedItem:)]) 
	{
		[self setTabBarItemSeletedIndex:sender.tag];
		[delegate_ tabBarSelectedItem:sender.tag];
	}
}

@end
