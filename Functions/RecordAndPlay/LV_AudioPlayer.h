//
//  LV_AudioPlayer.h
//   
//
//  Created by lv on 6/4/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

#define kNumberPlayerBuffers			2							//播放队列缓冲个数
#define kPlayBufferDurationSeconds		0.05						//计算播放队列缓冲大小的时间
#define kPlayProgressFrequency			60.0						//播放时更新进度条频率
#define kPlayProgressPercent			(1/kPlayProgressFrequency)	//播放时更新进度条幅度
#define kAudioInputSampleRate			8000						//录音8k采样率
#define kDataSizePerSeconds				(kAudioInputSampleRate*2)

@class LV_AudioPlayer;

@protocol LV_AudioPlayerDelegate <NSObject>
@required
- (void)audioPlayer:(LV_AudioPlayer*)audioPlayer finishedPlayRecord:(BOOL)isFinished;
@end


@interface LV_AudioPlayer : NSObject
{		
	id<LV_AudioPlayerDelegate>		delegate_;
	AudioQueueRef					queue_;
	AudioQueueBufferRef				queueBuffers_[kNumberPlayerBuffers];
	AudioStreamBasicDescription		dataFormat_;
	NSString*						audioFilePath_;
	AudioFileID						audioFileID_;
	SInt64							currentPacket_;
	UInt32							numPacketsToRead_;
	BOOL							isRuning_;
	BOOL							isPlayDone_;
	BOOL							isLooping_;
}
@property(assign)BOOL  isRuning;
@property(assign)id<LV_AudioPlayerDelegate> delegate;

- (BOOL)startPlayAudioFile:(NSString*)audioFilePath isResum:(BOOL)isResume;
- (BOOL)stopPlay;
- (BOOL)pausePlay;
- (BOOL)resumePlay;
@end
