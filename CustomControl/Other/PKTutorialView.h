//
//  PKTutorialView.h
//  Pumpkin
//
//  Created by lv on 6/16/12.
//  Copyright (c) 2012年 XXXXX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PKTutorialView;
@protocol PKTutorialViewDelegate <NSObject>
- (void)tutorialViewDidDismiss;

@end

@interface PKTutorialView : UIScrollView 
{
	id<PKTutorialViewDelegate> tutorialDelegate_;
}
@property(nonatomic, assign) id<PKTutorialViewDelegate> tutorialDelegate;

- (void)showInView:(UIView*)view;
- (void)dismiss;

@end
