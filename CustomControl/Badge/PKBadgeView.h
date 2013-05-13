//
//  PKBadgeView.h
//  Pumpkin
//
//  Created by lv on 12/7/12.
//
//

#import <UIKit/UIKit.h>
#import "PKBadgeStyle.h"



@interface PKBadgeView : UIView
{
	NSString*	   badgeText_;
	PKBadgeStyle* badgeStyle_;
}
@property (nonatomic, copy)NSString* badgeText;

- (id)initWithParentView:(UIView *)parentView  badgeStyle:(PKBadgeStyle*)style;

@end

