//
//  LV_ButtonBase.h
//
//  Created by lv on 4/28/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LV_ButtonBase : UIControl
{
	UIImage* normalImage_;
	UIImage* lightImage_;
	UILabel* buttonTitle_;
	CGSize	 expandSize_;
}
@property(readonly)UILabel*buttonTitle;
@property(retain)  UIImage* normalImage;
@property(retain)  UIImage* lightImage;

- (id)initWithFrame:(CGRect)frame buttonTitle:(NSString*)title;
@end
