//
//  Lv_PopoverController.h
//
//  Created by lv on 12/5/12.
//
//

#import <UIKit/UIKit.h>
#import "Lv_PopoverView.h"

@class Lv_PopoverController;


@protocol Lv_PopoverControllerDelegate <NSObject>
@optional
- (void)popoverControllerDidDismissPopover:(Lv_PopoverController*)popoverController;
@end


@interface Lv_PopoverController : UIViewController
{
	Lv_PopoverView*		popoverView_;
	UIViewController*	viewController_;
	id<Lv_PopoverControllerDelegate> delegate_;
}

@property (nonatomic, assign) UIEdgeInsets popoverLayoutMargins;
@property (nonatomic, assign) BIPopoverArrowType arrowType;
@property (nonatomic, assign)id<Lv_PopoverControllerDelegate> delegate;

-(id)initWithViewController:(UIViewController*)viewController;
-(void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;

-(void)presentPopoverInView:(UIView *)view arrowType:(BIPopoverArrowType)arrowType animated:(BOOL)animated;
-(void)dismissPopoverAnimated:(BOOL)animated;

@end
