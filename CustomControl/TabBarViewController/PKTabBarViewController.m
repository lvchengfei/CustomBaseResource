//
//  PKTabBarViewController.m
//  Pumpkin
//
//  Created by lv on 7/15/12.
//  Copyright (c) 2012 XXX. All rights reserved.
//

#import "PKTabBarViewController.h"
#import "PKDialAnimationViewController.h"
#import "PKConst.h"

@interface PKTabBarViewController ()

- (void)hideExistingTabBar;

@end

@implementation PKTabBarViewController

-(id)init
{
	self = [super init];
	if (self)
	{
		customTabBarView_ = [[PKTabBarView alloc] initWithFrame:CGRectMake(0, kScreenHeight-kTabbarHeight, 320, kTabbarHeight)];
		customTabBarView_.delegate = self;
		//customTabBarView_.backgroundColor = [UIColor blueColor];
	}
	return self;
}

- (void)dealloc
{
	[customTabBarView_ release];
	[super dealloc];
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	[self hideExistingTabBar];
    [self.view addSubview:customTabBarView_];
	[customTabBarView_ setTabBarItemSeletedIndex:customTabBarView_.curSeletedIndex];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	//useless when add code here
	//[self hideExistingTabBar];
    //[self.view addSubview:customTabBarView_];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setViewControllers:(NSArray *)viewControllers
{
	[super setViewControllers:viewControllers];
	[customTabBarView_  addTabBarItemsButtonCount:[viewControllers count]];
}

#pragma mark - Public Method

- (void)setTabBarItemNormalImage:(NSArray*)imageNArray highlightImage:(NSArray*)imageHArray
{
	[customTabBarView_ setTabBarItemNormalImage:imageNArray highlightImage:imageHArray];
}

- (void)setTabBarItemTitle:(NSArray*)titleArray
{
	[customTabBarView_ setTabBarItemTitle:titleArray];
}

- (void)setFrame:(CGRect)frame
{
	[self.view setFrame:frame];
}

- (void)setCustomTabBarHide:(BOOL)isHide
{
	[customTabBarView_ setHidden:isHide];
}

- (void)setCustomSelectedIndex:(NSUInteger)selectedIndex
{
	self.selectedIndex = selectedIndex;
	[customTabBarView_	setTabBarItemSeletedIndex:selectedIndex];
}

#pragma mark - Private Method

- (void)hideExistingTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
			break;
		}
	}
}

#pragma mark -  PKTabBarViewDelegate
//Handle tab bar touch events, sending the index of the selected tab
-(void)tabBarSelectedItem:(NSInteger)index
{
	self.selectedIndex = index;
}

@end
