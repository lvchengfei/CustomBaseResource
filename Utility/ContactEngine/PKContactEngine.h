//
//  PKContactEngine.h
//  Pumpkin
//
//  Created by lv on 2/29/12.
//  Copyright 2012 XXXXX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PKContactPersion.h"
#import "PKContactGroup.h"

#define kContactGroupNone -1		//表示“全部”，即包括通讯录内所有用户


@interface PKContactEngine : NSObject {
	ABAddressBookRef	 contact_;
	NSMutableDictionary* personsDict_;		//<PKContactPersion,"A~Z#">
	NSMutableArray*		 groupsArr_;		//<PKContactGroup object>
	NSInteger			 selGroupIndex_;	//current selectd group index
}
@property(nonatomic, assign) NSInteger selGroupIndex;



+ (PKContactEngine*)sharedContactEngine;
+ (void)releaseSharedContactEngine;
+ (void)saveAddressBook;
+ (void)refreshSharedContactEngine;
- (ABAddressBookRef)contactAddressBook;
+ (ABAddressBookRef)getContactAddressBook;

- (void)refreshAddressBook;

- (NSDictionary*)getTotalValidatePersonsDictionary;
- (NSDictionary*)getTotalPersonsDictionary;
- (NSDictionary*)getPersonsDictionary;
- (NSArray*)getGroupsArray;
- (NSInteger)selGroupIndex;
- (void)setSelGroupIndex:(NSInteger)selGroupIndex;
- (NSString*)selGroupName;


#pragma mark - Display
- (PKContactPersion*)createNewContactPerson;
- (BOOL) addContactPerson: (ABRecordRef) personRef;
- (BOOL) addPKContactPerson: (PKContactPersion*) person;
- (BOOL) addPerson:(PKContactPersion*)person toGroup:(PKContactGroup*)group;
- (BOOL) removePerson:(PKContactPersion*)person fromGroup:(PKContactGroup*)group;
- (BOOL) addToSelGroupWithPerson:(PKContactPersion*)person;
- (void) removeFromSelGroupWithPerson:(PKContactPersion*)person;

//- (NSInteger)displayPersionsCount;
//- (NSString*)firstNameOfIndex:(NSInteger)index;
//- (NSString*)lastNameOfIndex:(NSInteger)index;
//- (NSString*)middleNameOfIndex:(NSInteger)index;
//- (NSString*)fullNameOfIndex:(NSInteger)index;
//- (NSString*)contactNameOfIndex:(NSInteger)index;
//- (PKContactPersion*)personOfIndex:(NSInteger)index;
//
//- (BOOL) addMemberAtIndex:(NSInteger)personIndex toGroup:(NSInteger)groupIndex;
//- (BOOL) removeMemberAtIndex:(NSInteger)personIndex fromGroup:(NSInteger)groupIndex;
//- (BOOL) removeMemberFromCurSeletedGroup:(NSInteger)personIndex;

#pragma mark - Groups
- (NSInteger)contactGroupsCount;
- (NSString*)groupNameOfIndex:(NSInteger)index;
- (BOOL)addGroupWithName:(NSString*)groupName;
- (void)removeGroupAtIndex:(NSInteger)index;
- (void)moveGroupFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex; 
- (void)modifyGroupName:(NSString*)groupName atIndex:(NSInteger)index;

#pragma mark -Find Math person
- (NSArray *) contactsMatchingPhone: (NSString *) number;

@end
