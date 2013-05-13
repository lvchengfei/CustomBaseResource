//
//  PKContactGroup.h
//  Pumpkin
//
//  Created by lv on 3/1/12.
//  Copyright 2012 XXXXX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface PKContactGroup : NSObject {
	ABRecordRef record_;

}
@property (nonatomic, assign) NSString *groupName;

#pragma mark RECORD ACCESS
@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

+ (id) contactWithGroupRecord: (ABRecordRef) record ;
+ (id) creatGroupWithName:(NSString*)groupName;
- (BOOL) removeFromAddressBook:(ABAddressBookRef)addressBook;

@end
