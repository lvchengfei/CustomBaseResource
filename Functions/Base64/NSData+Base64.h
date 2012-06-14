// http://zh.wikipedia.org/wiki/Base64
// http://www.cocoadev.com/index.pl?BaseSixtyFour

@interface NSData (Base64)

//  Padding '=' characters are optional. Whitespace is ignored.
+ (id)dataWithBase64EncodedString:(NSString *)string;    
- (NSString *)base64Encoding;

@end
