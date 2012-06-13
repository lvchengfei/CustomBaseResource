//
//  LV_InputButton.h
//  xxxInputLib
//
//  Created by lv on 4/28/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LV_ButtonBase.h"

@interface LV_InputButton : LV_ButtonBase
{
	UIImage* enableImage_;
	UIImage* disableImage_;
	BOOL	 isEnable_;
}
@property (nonatomic,assign)CGSize	 expandSize;
@property (nonatomic,retain) UIImage* enableImage;
@property (nonatomic,retain) UIImage* disableImage;
@property (nonatomic,assign) BOOL isEnable;

@end
