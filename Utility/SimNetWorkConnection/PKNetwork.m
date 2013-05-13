//
//  PKNetwork.m
//  Pumpkin
//
//  Created by lv on 6/10/12.
//  Copyright (c) 2012 XXXXX. All rights reserved.
//

#import "PKNetwork.h"
#import "PKConst.h"

@interface PKNetwork ()
@property(retain)NSURLConnection* connection;
@property(retain)NSTimer* timer;

- (void)startTimeOutTimer;
- (void)timeOutFired:(NSTimer*)timer;
//- (void)responseSuccessResult;
//- (void)responseErrorResult;
@end


@implementation PKNetwork
@synthesize connection = connection_;
@synthesize timer = timer_;
@synthesize timeOutInterval = timeOutInterval_;
@synthesize responseDataFormat = responseDataFormat_;
@synthesize tag  = tag_;
@synthesize flag = flag_;

- (id)init
{
	self = [super init];
	if (self) {
		responseData_ = [[NSMutableData alloc] initWithCapacity:0];
		timeOutInterval_ = kDefaultTimeOut;
		tag_ = -1;
	}
	return self;
}

- (void)dealloc
{
	delegate_ = nil;
	[connection_	release];
	[timer_			invalidate];
	[timer_			release];
	[responseData_	release];
	[flag_			release];
	[super dealloc];
}

#pragma mark - Public Method

- (BOOL)startConnectionWithURLRequest:(NSURLRequest*)urlRequest   synchronise:(BOOL)isSynchronise
{
	if (urlRequest) 
	{
		if (!isSynchronise) 
		{
			[responseData_	setLength:0];
			NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
			self.connection = connection;
			[connection	release];
			[self startTimeOutTimer];
		}
		else 
		{
			NSHTTPURLResponse* response = nil;
			NSData* responseData =	[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
			if ([response statusCode]==200&&responseData) 
			{
				if (netWorkFlags_.responseResult)
				{
					[delegate_ network:self responseResult:[NSData dataWithData:responseData]];
				}
			}
			else 
			{
				if (netWorkFlags_.responseError)
				{
					[delegate_ network:self responseError:kNetWorkCannotConnection];
				}
			}
		}
	}
	else 
	{
		if (netWorkFlags_.responseError) 
		{
			[delegate_ network:self responseError:kNetWorkURLEmpty];
		}
	}
	return YES;
}

- (void)cancelConnection
{
	[self.timer invalidate];
	self.timer = nil;
	[self.connection cancel];
	self.connection = nil;
}

- (id<PKNetworkProtocol>)delegate
{
	return delegate_;
}

- (void)setDelegate:(id<PKNetworkProtocol>)delegate
{
	if (delegate!=delegate_) 
	{
		delegate_ = delegate;
		netWorkFlags_.responseResult = [delegate_ respondsToSelector:@selector(network:responseResult:)];
		netWorkFlags_.responseError = [delegate_ respondsToSelector:@selector(network:responseError:)];
		netWorkFlags_.getURLConnection = [delegate_ respondsToSelector:@selector(getURLConnection)]; 
	}
}

#pragma mark - Private Method

- (void)startTimeOutTimer
{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:timeOutInterval_ target:self selector:@selector(timeOutFired:) userInfo:nil repeats:NO];
}

- (void)timeOutFired:(NSTimer*)timer
{
	//NSLog(@">>>timeOutFired");
	[timer invalidate];
	self.timer = nil;
	
	if (netWorkFlags_.responseError) 
	{
		[delegate_ network:self responseError:kNetWorkTimeOut];
	}	
}




#pragma mark -
#pragma mark Conncetion Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData_ setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	if (data) 
	{
		[responseData_ appendData:data];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
	[self.timer invalidate];
	self.timer = nil;
	if (netWorkFlags_.responseResult)
	{
		[delegate_ network:self responseResult:[NSData dataWithData:responseData_]];
	}	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	[self.timer invalidate];
	self.timer = nil;
	if (netWorkFlags_.responseError)
	{
		[delegate_ network:self responseError:kNetWorkCannotConnection];
	}
}


@end
