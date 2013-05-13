//
//  PKBadgeStyle.h
//  Pumpkin
//
//  Created by lv on 12/7/12.
//
//
#import <UIKit/UIKit.h>

typedef enum{
	BIBadgeAlignmentTopLeft,
	BIBadgeAlignmentTopRight,
    BIBadgeAlignmentTopCenter,
    BIBadgeAlignmentCenterLeft,
    BIBadgeAlignmentCenterRight,
    BIBadgeAlignmentBottomLeft,
    BIBadgeAlignmentBottomRight,
    BIBadgeAlignmentBottomCenter,
    BIBadgeAlignmentCenter,
} BIBadgeViewAlignment;


@interface PKBadgeStyle : NSObject
{
	BIBadgeViewAlignment	badgeAlignment_;	//对齐方式
	UIColor*	backColor_;						//背景颜色
	UIColor*	textColor_;						//字体颜色
	UIFont*		textFont_;						//字体
	CGSize		textShadowOffset_;				//字体阴影
	UIColor*	textShadowColor_;				//字体阴影颜色
	UIColor*	overLayColor_;					//外圈颜色 默认白色
	CGPoint		adjustOffset_;					//对齐偏移，应用对齐方式后偏移
}

@property (nonatomic, assign) BIBadgeViewAlignment badgeAlignment;
@property (nonatomic, retain) UIColor*	backColor;
@property (nonatomic, retain) UIColor*	textColor;
@property (nonatomic, retain) UIFont*	textFont;
@property (nonatomic, assign) CGSize	textShadowOffset;
@property (nonatomic, retain) UIColor*	textShadowColor;
@property (nonatomic, retain) UIColor*	overLayColor;
@property (nonatomic, assign) CGPoint	adjustOffset;

@end