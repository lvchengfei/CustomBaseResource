//
//  PKContactPersion.h
//  Pumpkin
//
//  Created by lv on 2/29/12.
//  Copyright 2012 XXXXX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>



@interface PKContactPersion : NSObject {
	ABRecordRef record_;
	NSString*   firstWordPinyin_;
}

//+ (id) contactPersonWithRecord: (ABRecordRef) record groupRecord:(ABRecordRef) groupRecord;
+ (id) contactPersonWithRecord: (ABRecordRef) record ;
+ (id) createNewContactPerson;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;
- (NSComparisonResult)firstLetterCompare:(PKContactPersion*)person;


@property (nonatomic, readonly) NSString*   firstWordPinyin;

#pragma mark RECORD ACCESS
@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) BOOL isPerson;

#pragma mark SINGLE VALUE STRING
@property (nonatomic, assign) NSString *firstname;
@property (nonatomic, assign) NSString *lastname;
@property (nonatomic, assign) NSString *middlename;
@property (nonatomic, assign) NSString *prefix;
@property (nonatomic, assign) NSString *suffix;
@property (nonatomic, assign) NSString *nickname;
@property (nonatomic, assign) NSString *firstnamephonetic;
@property (nonatomic, assign) NSString *lastnamephonetic;
@property (nonatomic, assign) NSString *middlenamephonetic;
@property (nonatomic, assign) NSString *organization;
@property (nonatomic, assign) NSString *jobtitle;
@property (nonatomic, assign) NSString *department;
@property (nonatomic, assign) NSString *note;

@property (nonatomic, readonly) NSString *fullName; 
@property (nonatomic, readonly) NSString *contactName; // my friendly utility
@property (nonatomic, readonly) NSString *compositeName; // via AB

#pragma mark RESET
- (BOOL) resetFirstName;

#pragma mark NUMBER
@property (nonatomic, assign) NSNumber *kind;

#pragma mark DATE
@property (nonatomic, assign) NSDate *birthday;
@property (nonatomic, readonly) NSDate *creationDate;
@property (nonatomic, readonly) NSDate *modificationDate;

#pragma mark IMAGES
@property (nonatomic, assign) UIImage *image;
- (void) setImageWithData: (NSData*)imageData;

#pragma mark MULTIVALUE
@property (nonatomic, readonly) NSArray *emailArray;
@property (nonatomic, readonly) NSArray *emailLabels;
@property (nonatomic, readonly) NSArray *phoneArray;
@property (nonatomic, readonly) NSArray *phoneLabels;
@property (nonatomic, readonly) NSArray *relatedNameArray;
@property (nonatomic, readonly) NSArray *relatedNameLabels;
@property (nonatomic, readonly) NSArray *urlArray;
@property (nonatomic, readonly) NSArray *urlLabels;
@property (nonatomic, readonly) NSArray *dateArray;
@property (nonatomic, readonly) NSArray *dateLabels;
@property (nonatomic, readonly) NSArray *addressArray;
@property (nonatomic, readonly) NSArray *addressLabels;
@property (nonatomic, readonly) NSArray *imArray;
@property (nonatomic, readonly) NSArray *imLabels;


#pragma mark Setting MultiValue

- (void) setEmailDictionaries: (NSArray *) dictionaries;
- (void) setPhoneDictionaries: (NSArray *) dictionaries;
- (void) setUrlDictionaries: (NSArray *) dictionaries;
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries;
- (void) setDateDictionaries: (NSArray *) dictionaries;
- (void) setAddressDictionaries: (NSArray *) dictionaries;
- (void) setImDictionaries: (NSArray *) dictionaries;
- (void) setSocialDictionaries:(NSArray *)dictionaries;

@end
