//
//  PKContactGroup.m
//  Pumpkin
//
//  Created by lv on 3/1/12.
//  Copyright 2012 XXXXX. All rights reserved.
//

#import "PKContactGroup.h"




@interface PKContactGroup()

@end


@implementation PKContactGroup
@synthesize record = record_;

- (id) initWithRecord: (ABRecordRef) record 

{
	self = [super init];
	if (self) {
		record_ = CFRetain(record);
	}
	return self;
}

-(void)dealloc
{
	if (record_) 
        CFRelease(record_);
	[super dealloc];
}


#pragma mark - Property
- (NSString *) getRecordString:(ABPropertyID) anID
{
	NSString* record = ( NSString *) ABRecordCopyValue(record_, anID);
    return [record autorelease];
}

- (NSString *) groupName
{
    return [self getRecordString:kABGroupNameProperty];
}

- (void) setGroupName:(NSString *)groupName
{
    CFErrorRef cfError = NULL;
    BOOL success;
    success = ABRecordSetValue(record_, kABGroupNameProperty, (CFStringRef) groupName, &cfError);
    if (!success)
    {
        NSError *error = ( NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
}
#pragma mark Record ID and Type
- (ABRecordID) recordID {return ABRecordGetRecordID(record_);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record_);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}


#pragma mark - Public Method

+ (id) contactWithGroupRecord: (ABRecordRef) record 
{
	return [[[PKContactGroup alloc] initWithRecord:record] autorelease];
}

+ (id) creatGroupWithName:(NSString*)groupName
{
    ABRecordRef grouprec = ABGroupCreate();
    PKContactGroup* group = [PKContactGroup contactWithGroupRecord:grouprec];
	ABRecordSetValue(group.record, kABGroupNameProperty,  groupName, nil);
    CFRelease(grouprec);
    return group;
}

- (BOOL) removeFromAddressBook:(ABAddressBookRef)addressBook
{
    BOOL success;
    success = ABAddressBookRemoveRecord(addressBook, record_, nil);	
    return success;
}


@end
