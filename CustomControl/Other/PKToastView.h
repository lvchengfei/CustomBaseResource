//
//  PKToastView.h
//  Pumpkin
//
//  Created by lv on 7/14/12.
//  Copyright (c) 2012 XXX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKToastView : UIView
{
	UIView*							backGroundView_;
	UILabel*						titleLabel_;
	UIActivityIndicatorView*		activityView_;
}
+ (void)showWithTitle:(NSString*)title animation:(BOOL)animation;
+ (void)dismissWithAnimation:(BOOL)animation;
@end
