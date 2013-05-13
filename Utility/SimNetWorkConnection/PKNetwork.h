//
//  PKNetwork.h
//  Pumpkin
//
//  Created by lv on 6/10/12.
//  Copyright (c) 2012 XXXXX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	kNetWorkURLEmpty,
	kNetWorkCannotConnection,
	kNetWorkTimeOut,
	kNetWorkDataFormatError,
}PKNetWorkErrorCode;

@class PKNetwork;
@protocol PKNetworkProtocol <NSObject>
@required
- (void) network:(PKNetwork*)network responseResult:(id)result;
- (void) network:(PKNetwork *)network responseError:(PKNetWorkErrorCode)errorCode;
@end

@interface PKNetwork : NSObject
{
	id<PKNetworkProtocol>delegate_;
	NSURLConnection*	connection_;
	NSMutableData*		responseData_;

	NSTimer*			timer_;
	NSInteger			timeOutInterval_;
	NSInteger			tag_;
	NSString*			flag_;
	struct{
		unsigned int  responseResult:1;
		unsigned int  responseError:1;
		unsigned int  getURLConnection:1;
	}netWorkFlags_;
}
@property(assign) id<PKNetworkProtocol>delegate;
@property(assign) NSInteger timeOutInterval;
@property(assign) NSInteger responseDataFormat;
@property(assign) NSInteger tag;
@property(retain) NSString* flag;

- (BOOL)startConnectionWithURLRequest:(NSURLRequest*)urlRequest  synchronise:(BOOL)isSynchronise;
- (void)cancelConnection;
@end
