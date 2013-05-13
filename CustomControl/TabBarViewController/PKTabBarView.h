//
//  PKTabBarView.h
//  Pumpkin
//
//  Created by lv on 7/15/12.
//  Copyright (c) 2012 XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTabbarHeight  50

@protocol PKTabBarViewDelegate <NSObject>
//Handle tab bar touch events, sending the index of the selected tab
-(void)tabBarSelectedItem:(NSInteger)index;
@end

@interface PKTabBarView : UIView
{
	id<PKTabBarViewDelegate>	delegate_;
	NSMutableArray*				tabBarItemsButtonArr_;
	NSInteger					curSeletedIndex_;
	UIImage*					cellImageN_;
	UIImage*					cellImageH_;
	NSArray*					imageNArray_;
	NSArray*					imageHArray_;
}

@property(nonatomic,assign)   id<PKTabBarViewDelegate> delegate;
@property(nonatomic,readonly) NSInteger curSeletedIndex;

- (void)addTabBarItemsButtonCount:(NSInteger)count;
- (void)setTabBarItemNormalImage:(NSArray*)imageNArray highlightImage:(NSArray*)imageHArray;
- (void)setTabBarItemTitle:(NSArray*)titleArray; 
- (void)setTabBarItemSeletedIndex:(NSInteger)index;
@end
