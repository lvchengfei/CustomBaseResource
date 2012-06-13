//
//  LV_AudioRecorder.h
//   
//
//  Created by lv on 5/28/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

#define kNumberRecordBuffers		 3			//录音缓冲个数
#define kBufferDurationSeconds		 0.2		//录音时间返回数据,可转换为底层语音数据缓冲大小(16k采样,录音1秒 32k字节)
#define k16KSampleRate				16000.0		//采样率
#define k8KSampleRate				8000.0		//采样率
#define kChannelsPerFrame			1			//通道数目

@protocol LV_AudioRecorderDelegate <NSObject>
@required
- (void)handlerAudioRecorderBuffer:(NSData*)data length:(NSInteger)len;
@end

@interface LV_AudioRecorder : NSObject
{
	id<LV_AudioRecorderDelegate> delegate_;
	
	AudioQueueRef				mQueue;
	AudioQueueBufferRef			mBuffers[kNumberRecordBuffers];
	AudioStreamBasicDescription	mRecordFormat;
	BOOL						mIsRunning;
	CGFloat                     mSampleRate;
	CGFloat                     mBufferDuration;
	AudioQueueLevelMeterState*	channelLevels_;
	NSInteger						mRecordPacket; // current packet number in record file
	AudioFileID						mRecordFile;
	BOOL						isShouldStoreRecordAudioData_;
}
@property(assign) id<LV_AudioRecorderDelegate> delegate;
@property(assign) BOOL mIsRunning;

- (id)initWithAudioSampleRate:(CGFloat)sampleRate bufferDuration:(CGFloat)bufDuration;
- (BOOL)startRecord:(NSString*)outputAudioFilePath;
- (BOOL)stopRecord;

- (BOOL)refreshMeters;
- (CGFloat)averagePowerForChannel:(NSUInteger)channelNumber;
- (CGFloat)peakPowerForChannel:(NSUInteger)channelNumber;


@end
