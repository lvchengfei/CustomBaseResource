//
//  PKTutorialView.m
//  Pumpkin
//
//  Created bylv on 6/16/12.
//  Copyright (c) 2012年 XXXXX. All rights reserved.
//

#import "PKTutorialView.h"
#import "PKUtils.h"


#define kImportCantactRectWidth  206
#define kImportCantactRectHeight 58

@interface PKTutorialView ()
- (void)updatePosition;
- (void)removeFromView;
@end


#pragma mark -
#pragma mark Subclass
@implementation PKTutorialView
@synthesize tutorialDelegate = tutorialDelegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden       = YES;
        self.scrollsToTop = NO;
        self.pagingEnabled = YES;
        self.showsVerticalScrollIndicator   = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        NSArray *names= [NSArray arrayWithObjects:@"tutorial0.png",@"tutorial1.png",@"tutorial2.png",@"tutorial3.png",nil];

        for (NSString *name in names)
        {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            
            imageView.image=[PKUtils tutorialImageWithName:name];
            imageView.contentMode  = UIViewContentModeCenter;
            [self addSubview:imageView];
            [imageView release];
        }
        
        [self updatePosition];
    }
    return self;
}

- (void)setContentOffset:(CGPoint)offset 
{
	NSInteger max = self.frame.size.width * ([self.subviews count] - 1);
    if (offset.x < 0|| offset.x > max)
	{
        if (offset.x>0&&offset.x>max+4)
		{
			[self performSelector:@selector(removeFromView) withObject:nil afterDelay:0.3];
        }
		return;
	}
    [super setContentOffset:offset];
}


- (void)showInView:(UIView*)view
{
	if (self.hidden)
	{
		self.hidden = NO;
		[view addSubview:self];
	}
}

- (void)dismiss
{
	if (NO == self.hidden) 
	{
		self.hidden = YES;
		[self removeFromSuperview] ;
	}
}

#pragma mark -
#pragma mark TouchEvent

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch   *touch = [touches anyObject];
    CGPoint	   point = [touch locationInView:self];
	NSUInteger width = self.frame.size.width ;
    CGPoint  pt = CGPointMake(((NSInteger)point.x) % width, point.y) ;
    
	if(CGRectContainsPoint(CGRectMake(260, 20, 60, 45), pt))
	{
		 [self performSelector:@selector(removeFromView) withObject:nil afterDelay:0.3];
	}
	
//	if((((NSInteger)point.x) / width ==1) && CGRectContainsPoint(CGRectMake(60, 360, kImportCantactRectWidth, kImportCantactRectHeight), pt))
//	{
//        [self importContacts];
//	}
//    else if((((NSInteger)point.x) / width ==2) && CGRectContainsPoint(CGRectMake(0,0, self.frame.size.width, self.frame.size.height), pt))
//	{
//        [self inputMethodSettings];
//        [self performSelector:@selector(removeFromView) withObject:nil afterDelay:0.3];
//		[self setNeverShowTutorialViewAgain];
//	}
}

#pragma mark -
#pragma mark Private Method

- (void)updatePosition 
{
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView* view = (UIView*)obj;
        view.center  = CGPointMake(self.frame.size.width * idx + self.frame.size.width / 2, 
                                   (self.frame.size.height ) / 2);
    }];
    self.contentSize = CGSizeMake(self.frame.size.width * [self.subviews count], self.frame.size.height);
}


- (void)removeFromView
{
	if (self.superview)
	{
	    self.hidden = YES;
		[self removeFromSuperview];
		
		if (tutorialDelegate_&&[tutorialDelegate_ respondsToSelector:@selector(tutorialViewDidDismiss)])
		{
			[tutorialDelegate_ tutorialViewDidDismiss];
		}	
	}
}



@end
