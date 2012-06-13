//
//  LV_AudioRecorder.m
//   
//
//  Created by lv on 5/28/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import "LV_AudioRecorder.h"

@interface LV_AudioRecorder()
@property(assign)AudioFileID mRecordFile;
@property(assign)NSInteger   mRecordPacket;
@property(assign)BOOL	isShouldStoreRecordAudioData;
- (void)copyEncoderCookieToFile;

- (void)setupPCMAudioFormat;
- (NSInteger)computeRecordBufferSize;

@end


// AudioQueue callback function, called when an input buffers has been filled.
static void audioInputBufferHandler(void *							inUserData,
								 AudioQueueRef						inAQ,
								 AudioQueueBufferRef				inBuffer,
								 const AudioTimeStamp *				inStartTime,
								 UInt32								inNumPackets,
								 const AudioStreamPacketDescription*	inPacketDesc)
{
	LV_AudioRecorder *aqr = (LV_AudioRecorder *)inUserData;
    if (inNumPackets > 0) 
	{        
        if (aqr.delegate&&[aqr.delegate respondsToSelector:@selector(handlerAudioRecorderBuffer:length:)])
		{
			NSData *audioData = [[NSData alloc] initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
			[aqr.delegate handlerAudioRecorderBuffer:audioData length:[audioData length]];
			[audioData	release];
        }
		
		// write packets to file
		if (aqr.isShouldStoreRecordAudioData) 
		{
			OSStatus error = AudioFileWritePackets(aqr.mRecordFile, FALSE, inBuffer->mAudioDataByteSize,
												   inPacketDesc, aqr.mRecordPacket, &inNumPackets, inBuffer->mAudioData);
			if (error<0) {
				NSLog(@"AudioFileWritePackets failed");
			}
			aqr.mRecordPacket += inNumPackets;
		}
    }
    
    // if we're not stopping, re-enqueue the buffe so that it gets filled again
    if (aqr.mIsRunning)
	{
        OSStatus error = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        if (error < 0)
		{
            //NSLog(@"AudioQueueEnqueueBuffer failed in myCallback, error:%ld", error);
            //避免内存泄漏
            AudioQueueFreeBuffer(inAQ, inBuffer);
        }
    }
}



@implementation LV_AudioRecorder
@synthesize delegate = delegate_;
@synthesize mIsRunning;
@synthesize mRecordFile;
@synthesize mRecordPacket;
@synthesize isShouldStoreRecordAudioData = isShouldStoreRecordAudioData_;

- (id)initWithAudioSampleRate:(CGFloat)sampleRate bufferDuration:(CGFloat)bufDuration
{
	self = [super init];
	if (self) 
	{
		mIsRunning = NO;
		mSampleRate = sampleRate;
		if (mSampleRate!=k16KSampleRate&&mSampleRate!=k8KSampleRate) 
		{
			mSampleRate = k16KSampleRate;
		}	
		mBufferDuration = bufDuration<0?0.2:bufDuration;
		channelLevels_ = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * kChannelsPerFrame);
		delegate_ = nil;
		mRecordFile = NULL;
		mRecordPacket = 0;
		isShouldStoreRecordAudioData_ = NO;
	}
	return self;
}

- (void)dealloc
{
	free(channelLevels_);
	channelLevels_ = NULL;
	//AudioQueueDispose(mQueue, TRUE);
	if (mRecordFile!=NULL) 
	{
		AudioFileClose(mRecordFile);
		mRecordFile = NULL;
	}

	[super dealloc];
}

#pragma mark - Public Method

- (BOOL)startRecord:(NSString*)outputAudioFilePath
{
	BOOL result = NO;
	//路径不为空表示需要保持录音文件
	isShouldStoreRecordAudioData_ = outputAudioFilePath!=nil?YES:NO;
	
    // specify the recording format
	[self setupPCMAudioFormat];
	
    // create the queue
    OSStatus error = AudioQueueNewInput(
										&mRecordFormat,
										audioInputBufferHandler,
										self /* userData */,
										NULL /* run loop */, NULL /* run loop mode */,
										0 /* flags */, &mQueue);
    if (error < 0)
	{
        return result;
    }
    
	if (isShouldStoreRecordAudioData_) 
	{
		mRecordPacket = 0;

		NSLog(@">>>>outputAudioFilePath=%@",outputAudioFilePath);
		CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)outputAudioFilePath, NULL);
		// create the audio file
		error = AudioFileCreateWithURL(url, kAudioFileCAFType, &mRecordFormat, kAudioFileFlags_EraseFile,&mRecordFile);
		if (error<0) 
		{
			//NSLog(@"AudioFileCreateWithURL failed");
			return result;
		}
		CFRelease(url);
		// copy the cookie first to give the file object as much info as we can about the data going in
		// not necessary for pcm, but required for some compressed audio
		[self copyEncoderCookieToFile];
	}
    
    
    // allocate and enqueue buffers
    NSInteger bufferByteSize = [self computeRecordBufferSize];
    //NSLog(@"AudioQueue buffer size: %d", bufferByteSize);
    if (bufferByteSize <= 0)
	{
        AudioQueueDispose(mQueue, true);
        return result;
    }
    
    for (int i = 0; i < kNumberRecordBuffers; ++i) 
	{
        error = AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]);
        if (error < 0)
		{
            //NSLog(@"AudioQueueAllocateBuffer error:%ld", error);
            AudioQueueDispose(mQueue, true);
            return result;
        }
        error = AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL);
        if (error < 0)
		{
            //NSLog(@"AudioQueueEnqueueBuffer failed, error:%ld", error);
            //AudioQueueFreeBuffer(mQueue, mBuffers[i]);
            AudioQueueDispose(mQueue, true);
            return result;
        }
    }

	UInt32 val = 1;
	error = AudioQueueSetProperty(mQueue, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
	if (error < 0)
	{ 
        //NSLog(@"couldn't enable metering");
        AudioQueueDispose(mQueue, true);
        return result;
    }
	
    // start the queue
    error = AudioQueueStart(mQueue, NULL);
    if (error < 0)
	{ 
        //NSLog(@"AudioQueueStart failed");
        AudioQueueDispose(mQueue, true);
        return result;
    }
    mIsRunning = YES;
	result = YES;
    return result;
	
}

- (BOOL)stopRecord
{
	BOOL result = YES;
    if (! mIsRunning){
        return result;
    }
	
	mIsRunning = NO;
	if (mQueue) 
	{
		AudioQueueStop(mQueue, true);
	}
	if (isShouldStoreRecordAudioData_) 
	{
		// a codec may update its cookie at the end of an encoding session, so reapply it to the file now
		[self copyEncoderCookieToFile];
		AudioFileClose(mRecordFile);
	}
	if (mQueue)
	{
		AudioQueueDispose(mQueue, true);
		mQueue = NULL;
	}
    return result;
}


-(BOOL) refreshMeters
{
	Boolean result = false;
	if (mIsRunning) 
	{
		UInt32 channelLevelsDataSize = sizeof(AudioQueueLevelMeterState) * kChannelsPerFrame;
		OSStatus status = AudioQueueGetProperty(mQueue, kAudioQueueProperty_CurrentLevelMeterDB, channelLevels_
												, &channelLevelsDataSize);
		if (status==noErr) {
			result = true;
		}		
	}
	else 
	{
		NSLog(@">>>>refreshMeters when record is not runing");
	}
	return result;
}

- (CGFloat)averagePowerForChannel:(NSUInteger)channelNumber
{
	if (channelNumber>kChannelsPerFrame) 
	{
		return channelLevels_[0].mAveragePower;
	}
	return channelLevels_[channelNumber].mAveragePower;
}

- (CGFloat)peakPowerForChannel:(NSUInteger)channelNumber
{
	if (channelNumber>kChannelsPerFrame) 
	{
		return channelLevels_[0].mPeakPower;
	}
	return channelLevels_[channelNumber].mPeakPower;
}

#pragma mark - Private Method

- (void)setupPCMAudioFormat
{
	memset(&mRecordFormat, 0, sizeof(mRecordFormat));
    
    mRecordFormat.mFormatID = kAudioFormatLinearPCM;
    // if we want pcm, default to signed 16-bit little-endian
    mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    mRecordFormat.mBitsPerChannel = 16;
    mRecordFormat.mSampleRate = mSampleRate;
    //mRecordFormat.mChannelsPerFrame = 1;
	mRecordFormat.mChannelsPerFrame = kChannelsPerFrame;
    mRecordFormat.mFramesPerPacket = 1;
    mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
}

// Determine the size, in bytes, of a buffer necessary to represent the supplied number
// of seconds of audio data.
- (NSInteger)computeRecordBufferSize
{
	//16k sample rate ,1 sec data = 16k*2byte = 32kbytes 
	AudioStreamBasicDescription* format = &mRecordFormat;
	CGFloat seconds = mBufferDuration;
	int packets, frames, bytes = 0;
    frames = (int)ceil(seconds * format->mSampleRate);
    //NSLog(@"seconds: %f; sampleRate: %f; frames: %d, bytesPerFrame: %u, bitesPerChannel:%u; chanelsPerFrame:%u ", seconds, format->mSampleRate, frames, format->mBytesPerFrame, format->mBitsPerChannel, format->mChannelsPerFrame);
    
    if (format->mBytesPerFrame > 0)
        bytes = frames * format->mBytesPerFrame;
    else {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0)
            maxPacketSize = format->mBytesPerPacket;	// constant packet size
        else {
            UInt32 propertySize = sizeof(maxPacketSize);
            if (AudioQueueGetProperty(mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
                                      &propertySize) < 0){
                return 0;
            }
        }
        if (format->mFramesPerPacket > 0)
            packets = frames / format->mFramesPerPacket;
        else
            packets = frames;	// worst-case scenario: 1 frame in a packet
        if (packets == 0)		// sanity check
            packets = 1;
        bytes = packets * maxPacketSize;
    }
	return bytes;
}


// Copy a queue's encoder's magic cookie to an audio file.
-(void)copyEncoderCookieToFile
{
	UInt32 propertySize;
	// get the magic cookie, if any, from the converter		
	OSStatus err = AudioQueueGetPropertySize(mQueue, kAudioQueueProperty_MagicCookie, &propertySize);
	
	// we can get a noErr result and also a propertySize == 0
	// -- if the file format does support magic cookies, but this file doesn't have one.
	if (err == noErr && propertySize > 0) {
		Byte *magicCookie = malloc(sizeof(Byte)*propertySize);//new Byte[propertySize];
		UInt32 magicCookieSize;
		OSStatus error = AudioQueueGetProperty(mQueue, kAudioQueueProperty_MagicCookie, magicCookie, &propertySize);
		
		if (error<0) 
		{
			NSLog(@"get audio converter's magic cookie");
		}
		magicCookieSize = propertySize;	// the converter lies and tell us the wrong size
		
		// now set the magic cookie on the output file
		UInt32 willEatTheCookie = false;
		// the converter wants to give us one; will the file take it?
		err = AudioFileGetPropertyInfo(mRecordFile, kAudioFilePropertyMagicCookieData, NULL, &willEatTheCookie);
		if (err == noErr && willEatTheCookie) {
			err = AudioFileSetProperty(mRecordFile, kAudioFilePropertyMagicCookieData, magicCookieSize, magicCookie);
			if (err<0) 
			{
				NSLog( @"set audio file's magic cookie");
			}
		}
		free(magicCookie);
	}
}


@end
