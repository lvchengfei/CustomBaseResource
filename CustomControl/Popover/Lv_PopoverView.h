//
//  Lv_PopoverView.h
//
//  Created by lv on 12/5/12.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
	BIPopoverArrowUpLeft,
	BIPopoverArrowUpCenter,
	BIPopoverArrowUpRight,
	BIPopoverArrowDownLeft,
	BIPopoverArrowDownCenter,
	BIPopoverArrowDownRight,
}BIPopoverArrowType;

@interface Lv_PopoverView : UIView
{
	BIPopoverArrowType	arrowType_;
	UIEdgeInsets		margins_;
	UIColor*			backColor_;
	UIImage*			backImage_;
	CGFloat				arrowHeight_;
}
@property (nonatomic, assign)BIPopoverArrowType arrowType;
@property (nonatomic, assign)UIEdgeInsets	margins;
@property (nonatomic, retain)UIColor* backColor;
@property (nonatomic, retain)UIImage* backImage;
@property (nonatomic, assign)CGFloat  arrowHeight;

@end
