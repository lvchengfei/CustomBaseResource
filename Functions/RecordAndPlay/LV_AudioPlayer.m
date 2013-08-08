//
//  LV_AudioPlayer.m
//   
//
//  Created by lv on 6/4/12.
//  Copyright (c) 2012 xxx. All rights reserved.
//

#import "LV_AudioPlayer.h"

@interface LV_AudioPlayer()
@property(nonatomic,retain) NSString* audioFilePath;
@property(nonatomic,assign) UInt32 numPacketsToRead;
@property(nonatomic,assign) AudioFileID	audioFileID;
@property(nonatomic,assign) SInt64 currentPacket;
@property(assign) BOOL  isLooping;
@property(assign) BOOL  isPlayDone;


- (BOOL)preparePlayForFile:(NSString*)audioFilePath;
- (void)calculateBytesForTime:(CGFloat)seconds inMaxBufSize:(UInt32)inMaxPacketSize outBufSize:(UInt32*)outBufferSize outNumPackets:(UInt32*) outNumPackets;
- (BOOL)setupNewQueue;

@end



void isRunningProc (void* inUserData,
							  AudioQueueRef           inAQ,
							  AudioQueuePropertyID    inID)
{
	//LV_AudioPlayer *player = (LV_AudioPlayer *)inUserData;
	UInt32	mIsRunning;
	UInt32 size = sizeof(mIsRunning);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &mIsRunning, &size);
	
	if ((result == noErr) && (!mIsRunning))
	{
		
		//[[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
	}
}

@implementation LV_AudioPlayer
@synthesize delegate = delegate_;
@synthesize audioFilePath = audioFilePath_;
@synthesize numPacketsToRead = numPacketsToRead_;
@synthesize audioFileID = audioFileID_;
@synthesize currentPacket =currentPacket_;
@synthesize isRuning   = isRuning_;
@synthesize isLooping  = isLooping_;
@synthesize isPlayDone = isPlayDone_;
 
static void playBufferCallback(void *			inUserData,
						AudioQueueRef			inAQ,
						AudioQueueBufferRef		inCompleteAQBuffer) 
{
	LV_AudioPlayer *player = (LV_AudioPlayer *)inUserData;
	//NSLog(@">>>> playBufferCallback numPackets=%lu curPacket=%lld",player.numPacketsToRead,player.currentPacket);
	if ([player isPlayDone]) 
		return;
	UInt32 numBytes;
	UInt32 nPackets = player.numPacketsToRead;
	OSStatus error  = AudioFileReadPackets(player.audioFileID,false,&numBytes,inCompleteAQBuffer->mPacketDescriptions,player.currentPacket,&nPackets,inCompleteAQBuffer->mAudioData);
	//NSLog(@">>>>1 playBufferCallback numPackets=%lu curPacket=%lld",nPackets,player.currentPacket);
	if (error)
		NSLog(@"AudioFileReadPackets failed: %ld", error);
	if (nPackets > 0) 
	{
		inCompleteAQBuffer->mAudioDataByteSize = numBytes;		
		inCompleteAQBuffer->mPacketDescriptionCount = nPackets;		
		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
		player.currentPacket = (player.currentPacket + nPackets);
	} 
	else 
	{
		if (player.isLooping)
		{
			player.currentPacket= 0;
			playBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
		}
		else
		{
			// stop
			player.isPlayDone = YES;
			AudioQueueStop(inAQ, false);
            [player performSelectorOnMainThread:@selector(finishedPlay:) withObject:nil waitUntilDone:NO];

		}
	}
}

- (id)init
{
	self = [super init];
	if (self) 
	{
		audioFilePath_ = nil;
		audioFileID_   = NULL ;
		currentPacket_ = 0 ;
		numPacketsToRead_ = 0;
		isRuning_   = NO;
		isPlayDone_ = NO;
		isLooping_  = NO;
	}
	return self;
}

- (void)dealloc
{
	[self stopPlay];
	self.audioFilePath = nil;
	[super dealloc];
}

#pragma mark - Public Method

- (BOOL)startPlayAudioFile:(NSString*)audioFilePath isResum:(BOOL)isResume
{	
	BOOL result = NO;
	if (self.isRuning==NO) 
	{

		// init audio file path
		if ([audioFilePath length]>0) 
		{
			self.audioFilePath = [NSString stringWithString:audioFilePath];
		}
		//NSLog(@">>>start play file=%@",self.audioFilePath);
		// if we have a file but no queue, create one now
		if ((queue_ == NULL) && (audioFilePath_))
		{
			result =[self preparePlayForFile:audioFilePath_];
			// prepare audio queue error
			if (!result) {
				return result;
			}
		}
			
		// if we are not resuming, we also should restart the file read index
		if (!isResume)
			currentPacket_ = 0;	
		
		isPlayDone_ = NO;
		
		// prime the queue with some data before starting
		for (int i = 0; i < kNumberPlayerBuffers; ++i) 
		{
			playBufferCallback (self, queue_, queueBuffers_[i]);			
		}
		isRuning_   = YES;
		result = (AudioQueueStart(queue_, NULL)==noErr);
	}
	return result;
}

- (BOOL)stopPlay
{
	BOOL result = YES;
	if (self.isRuning) 
	{
		if (queue_) 
		{
			AudioQueueStop(queue_, true);
		}
		if (queue_)
		{
			AudioQueueDispose(queue_, true);
			queue_ = NULL;
		}
		if (audioFileID_)
		{		
			AudioFileClose(audioFileID_);
			audioFileID_ = NULL;
		}	
		isRuning_   = NO;
	}
	return result;
}

- (BOOL)pausePlay
{
	return [self stopPlay];
}

- (BOOL)resumePlay
{
	return [self startPlayAudioFile:nil isResum:YES];
}

- (void)getCurrentTime:(NSTimeInterval*)time duration:(NSTimeInterval*)duration
{
    if (time != NULL)
    {
        *time = [self getCurrentTime];
    }
    if (duration != NULL) {
        *duration = duration_;
        
    }
}

#pragma mark - Private Method

- (BOOL)preparePlayForFile:(NSString*)audioFilePath 
{	
	BOOL result = NO;
	if ([audioFilePath length]>0) 
	{		
		CFURLRef urlFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)audioFilePath, kCFURLPOSIXPathStyle, false);
		if (!urlFile) 
		{ 
			NSLog(@"can't parse file path\n");
			return result; 
		}
		OSStatus error = 0;
		error = AudioFileOpenURL (urlFile, kAudioFileReadPermission, 0/*inFileTypeHint*/, &audioFileID_);
		if (error<0) 
		{
			NSLog(@"can't open file");
			CFRelease(urlFile);
			return result;
		}
		
		UInt32 size = sizeof(dataFormat_);
		error = AudioFileGetProperty(audioFileID_,kAudioFilePropertyDataFormat, &size, &dataFormat_);
		if (error<0) 
		{
			NSLog(@"couldn't get file's data format");
			CFRelease(urlFile);
			return result;
		}
		CFRelease(urlFile);
		// setup new audio severice queue
		result = [self setupNewQueue];
		if (!result)
		{
			if (queue_)
			{
				AudioQueueDispose(queue_, true);
				queue_ = NULL;
			}
			if (audioFileID_)
			{		
				AudioFileClose(audioFileID_);
				audioFileID_ = NULL;
			}	
		}
	}
	return result;
}


- (void)calculateBytesForTime:(CGFloat)seconds inMaxBufSize:(UInt32)inMaxPacketSize outBufSize:(UInt32*)outBufferSize outNumPackets:(UInt32*) outNumPackets
{
	// we only use time here as a guideline
	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
	static const int maxBufferSize = 0x10000; // limit size to 64K
	static const int minBufferSize = 0x4000; // limit size to 16K
	
	if (dataFormat_.mFramesPerPacket) {
		Float64 numPacketsForTime = dataFormat_.mSampleRate / dataFormat_.mFramesPerPacket * seconds;
		*outBufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// if frames per packet is zero, then the codec has no predictable packet == time
		// so we can't tailor this (we don't know how many Packets represent a time period
		// we'll just return a default buffer size
		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
	}
	
	// we're going to limit our size to our default
	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
		*outBufferSize = maxBufferSize;
	else {
		// also make sure we're not too small - we don't want to go the disk for too small chunks
		if (*outBufferSize < minBufferSize)
			*outBufferSize = minBufferSize;
	}
	*outNumPackets = *outBufferSize / inMaxPacketSize;
}


- (BOOL)setupNewQueue
{
	BOOL result = NO;
	OSStatus error = AudioQueueNewOutput(&dataFormat_, playBufferCallback, self,
										 CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue_);
	if (error<0)
	{
		NSLog(@"AudioQueueNew failed");
		return  result;
	}
	UInt32 bufferByteSize;		
	// we need to calculate how many packets we read at a time, and how big a buffer we need
	// we base this on the size of the packets in the file and an approximate duration for each buffer
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
	UInt32 maxPacketSize;
	UInt32 size = sizeof(maxPacketSize);
	error = AudioFileGetProperty(audioFileID_, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);
	if(error<0)
	{
		NSLog(@"couldn't get file's max packet size");
		return  result;
	}
	// maxPacketSize acctual is only usefull for VBR,VBR(Variable BitRate),CBR(Constant BitRate),more information see "Audio Queue Services Programming Guide" lv
	// adjust buffer size to represent about a half second of audio based on this format
	[self calculateBytesForTime:kPlayBufferDurationSeconds inMaxBufSize:maxPacketSize outBufSize:&bufferByteSize outNumPackets:&numPacketsToRead_];
	//NSLog(@">>>%lu %lu %lu",maxPacketSize,bufferByteSize,numPacketsToRead_);
	
	//printf ("Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)mNumPacketsToRead);
	// (2) If the file has a cookie, we should get it and set it on the AQ
	size = sizeof(UInt32);
	error = AudioFileGetPropertyInfo (audioFileID_, kAudioFilePropertyMagicCookieData, &size, NULL);
	if (error==noErr && size) 
	{
		char* cookie = (char*)malloc(size);
		error =  AudioFileGetProperty (audioFileID_, kAudioFilePropertyMagicCookieData, &size, cookie);
		if (error<0) 
		{
			NSLog(@"get cookie from file");
			free(cookie);
			return  result;
		}
		error = AudioQueueSetProperty(queue_, kAudioQueueProperty_MagicCookie, cookie, size);
		if (error<0) 
		{
			NSLog(@"set cookie on queue");
			free(cookie);
			return  result;
		}
		free(cookie);
	}
	
	// channel layout?
	error = AudioFileGetPropertyInfo(audioFileID_, kAudioFilePropertyChannelLayout, &size, NULL);
	if (error == noErr && size > 0) 
	{
		AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
		error =  AudioFileGetProperty(audioFileID_, kAudioFilePropertyChannelLayout, &size, acl);
		if (error<0) 
		{
			NSLog(@"get audio file's channel layout");
			free(acl);
			return  result;
		}
		error =  AudioQueueSetProperty(queue_, kAudioQueueProperty_ChannelLayout, acl, size);
		if (error<0) 
		{
			NSLog(@"set channel layout on queue");
			free(acl);
			return  result;
		}
		free(acl);
	}
	
	error =  AudioQueueAddPropertyListener(queue_, kAudioQueueProperty_IsRunning, isRunningProc, self);
	if (error<0) 
	{
		NSLog(@"adding property listener");
		return  result;
	}

	//VBR(Variable BitRate) lv
	BOOL isFormatVBR = (dataFormat_.mBytesPerPacket == 0 || dataFormat_.mFramesPerPacket == 0);
	for (int i = 0; i < kNumberPlayerBuffers; ++i) 
	{
		error =  AudioQueueAllocateBufferWithPacketDescriptions(queue_,bufferByteSize,(isFormatVBR ? numPacketsToRead_ : 0),&queueBuffers_[i]);
		if (error) 
		{
			NSLog(@"AudioQueueAllocateBuffer failed");
			return  result;
		}
	}	
	
	// set the volume of the queue
	error =  AudioQueueSetParameter(queue_, kAudioQueueParam_Volume, 10.0);
	if (error<0) 
	{
		NSLog(@"set queue volume error!");
		return  result;
	}
	result = YES;
	return result;
}

- (void)finishedPlay:(id)sender
{
    if (delegate_ && [delegate_ respondsToSelector:@selector(audioPlayer:finishedPlayRecord:)])
    {
        [delegate_ audioPlayer:self finishedPlayRecord:YES];
    }
}

- (NSTimeInterval)getCurrentTime
{
    int timeInterval = 0;
    AudioQueueTimelineRef timeLine;
    OSStatus status = AudioQueueCreateTimeline(queue_, &timeLine);
    if(status == noErr) {
        AudioTimeStamp timeStamp;
        AudioQueueGetCurrentTime(queue_, timeLine, &timeStamp, NULL);
        timeInterval = timeStamp.mSampleTime / dataFormat_.mSampleRate; // modified
    }
    return timeInterval;
}

- (NSTimeInterval)getTotalDuration
{
    UInt64 nPackets;
    UInt32 propsize = sizeof(nPackets);
    AudioFileGetProperty(audioFileID_, kAudioFilePropertyAudioDataPacketCount, &propsize, &nPackets);
    Float64 fileDuration = (nPackets * dataFormat_.mFramesPerPacket) / dataFormat_.mSampleRate;
    
    return fileDuration;
}


@end
