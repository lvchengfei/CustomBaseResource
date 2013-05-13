//
//  PKContactEngine.m
//  Pumpkin
//
//  Created by lv on 2/29/12.
//  Copyright 2012 XXXXX. All rights reserved.
//

#import "PKContactEngine.h"
#import "PKDefine.h"
#import "PKUtils.h"
#import "PKConst.h"

DEBUGCATEGROY(PKContactEngine)


static PKContactEngine* contactEngine = nil;

@interface PKContactEngine()
@property(nonatomic, retain) NSMutableDictionary* personsDict;
@property(nonatomic, retain) NSMutableArray* groupsArr;

- (ABAddressBookRef) addressBook;
- (NSDictionary*)loadAllPersons;
- (void) loadContactPersons;
- (void) loadContactGroups;
- (void) loadContactPersonsInGroup:(PKContactGroup*)group;
- (BOOL) removePersonFromAddressBook:(PKContactPersion*)person;
@end


@implementation PKContactEngine
@synthesize personsDict = personsDict_;
@synthesize groupsArr = groupsArr_;

#pragma mark - Life Cycle

- (id)init
{
	self = [super init];
	if (self) {
		float version = [[[UIDevice currentDevice] systemVersion] floatValue];
		if (version >= 6.0) {
			contact_ =  ABAddressBookCreateWithOptions(NULL, NULL);
		}else{
			contact_ = ABAddressBookCreate();
		}
		personsDict_ = [[NSMutableDictionary alloc] initWithCapacity:0];
		groupsArr_   = [[NSMutableArray alloc] initWithCapacity:0];
		[self loadContactPersons];
		[self loadContactGroups];
		selGroupIndex_ = kContactGroupNone;
	}
	return self;
}

-(void)dealloc
{
	//NSLog(@"contact engine delloc");
	if (contact_) 
	{
		CFRelease(contact_);
		contact_ = nil;
	}
	[personsDict_		release];
	[groupsArr_			release];
	[super dealloc];
}

- (void)refreshAddressBook
{
	ABAddressBookSave(contact_,nil);
	if (contact_)
    {
        CFRelease(contact_);
		contact_ = NULL;
    }
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if (version >= 6.0) {
		contact_ =  ABAddressBookCreateWithOptions(NULL, NULL);
	}else{
		contact_ = ABAddressBookCreate();
	}

}

- (ABAddressBookRef)contactAddressBook
{
	return contact_;
}
#pragma mark - Public Method

+ (PKContactEngine*)sharedContactEngine
{
	if (contactEngine==nil) {
		contactEngine = [[PKContactEngine alloc] init];
	}
	return contactEngine;
}

+ (void)releaseSharedContactEngine
{
	//[self saveAddressBook];
	[contactEngine release];
	contactEngine = nil;
}

+ (void)refreshSharedContactEngine
{
	
	[contactEngine refreshAddressBook];
	[contactEngine loadContactPersons];
	[contactEngine loadContactGroups];
	contactEngine.selGroupIndex = kContactGroupNone;
}

+ (void)saveAddressBook
{
	ABAddressBookSave([contactEngine addressBook], nil);
}

+(ABAddressBookRef)getContactAddressBook
{
	return [contactEngine contactAddressBook];
}

- (NSDictionary*)getTotalValidatePersonsDictionary
{
	NSMutableDictionary* personsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
	NSArray *thePeople  = ( NSArray *)ABAddressBookCopyArrayOfAllPeople(contact_);
	for (id person in thePeople)
	{
		ABRecordRef pRecord = CFRetain((ABRecordRef)person);
		PKContactPersion* person = [PKContactPersion contactPersonWithRecord:pRecord];
		if([PKUtils phoneNumber:person]==nil)//过滤无效的账户
		{CFRelease(pRecord);	continue;}
		NSMutableArray* personsArr = [personsDict objectForKey:person.firstWordPinyin];
		if (personsArr==nil) {
			personsArr = [[NSMutableArray alloc] initWithCapacity:0];
			[personsDict setObject:personsArr forKey:[NSString stringWithString:person.firstWordPinyin]];
			[personsArr release];
		}
		[personsArr	 addObject:person];
		CFRelease(pRecord);
	}
	NSDictionary* tmpDict = [NSDictionary dictionaryWithDictionary:personsDict];
	[personsDict	release];
	[thePeople		release];
	return tmpDict;
}

- (NSDictionary*)getTotalPersonsDictionary
{
	NSDictionary* tmpPersonDict = [self loadAllPersons];
	if ([tmpPersonDict count]>0) 
	{
		return [NSDictionary dictionaryWithDictionary:tmpPersonDict];
	}
	return nil;
}

- (NSDictionary*)getPersonsDictionary
{
	return [NSDictionary dictionaryWithDictionary:personsDict_];
}

- (NSArray*)getGroupsArray
{
	return [NSArray arrayWithArray:groupsArr_];
}


- (NSInteger)selGroupIndex
{	
	return selGroupIndex_;
}

- (void)setSelGroupIndex:(NSInteger)selGroupIndex
{
	
	//NSLog(@"selected group index=%d" , selGroupIndex);
	if (selGroupIndex_==selGroupIndex) {
		return;
	}
	
	if (selGroupIndex==kContactGroupNone&&selGroupIndex_!=kContactGroupNone) 
	{
		[self loadContactPersons];
	}
	else if (selGroupIndex>=0 && selGroupIndex<[groupsArr_ count])
	{
		PKContactGroup* group = [groupsArr_ objectAtIndex:selGroupIndex];
		[self loadContactPersonsInGroup:group];
	}
	selGroupIndex_ = selGroupIndex;
}

- (NSString*)selGroupName
{
	return [self groupNameOfIndex:selGroupIndex_];
}

#pragma mark - Display

- (PKContactPersion*)createNewContactPerson
{
	return [PKContactPersion createNewContactPerson];
}

- (BOOL) addContactPerson: (ABRecordRef ) personRef
{
	//BOOL success = YES;
	PKContactPersion* person  = [[PKContactPersion contactPersonWithRecord:personRef] retain];
	NSMutableArray* personArr = [personsDict_ objectForKey:[person firstWordPinyin]];
	if (personArr&&[personArr containsObject:person]) 
	{
		NSLog(@"For update");
	}
	else
	{
		BOOL success = ABAddressBookAddRecord(contact_, personRef,nil);
		success = ABAddressBookSave(contact_, nil);
		if (success) 
		{	
			if ( objectAtIndex(groupsArr_, selGroupIndex_))
			{
				[self addToSelGroupWithPerson:person];
			}
			else
			{
				[PKContactEngine refreshSharedContactEngine];
			}
			/*
			PKContactGroup* group = objectAtIndex(groupsArr_, selGroupIndex_);
			//I not check is success, becuase always false
			[self addPerson:person toGroup:group];
			if (personArr==nil)
			{
				personArr = [[NSMutableArray alloc] initWithCapacity:0];
				[personsDict_ setObject:personArr forKey:[NSString stringWithString:person.firstWordPinyin]];
				[personArr release];
			}
			[personArr	 addObject:person];
			*/
		}
	}
	[person	release];
	return YES;
}

- (BOOL) addPKContactPerson: (PKContactPersion*) person
{
	BOOL success = ABAddressBookAddRecord(contact_, person.record,nil);
	success = ABAddressBookSave(contact_, nil);
	return success;
}

- (BOOL) addPerson:(PKContactPersion*)person toGroup:(PKContactGroup*)group
{
	ABRecordRef personRef = [person record];
	ABRecordRef groupRef  = [group  record];
	BOOL result = NO;
	if (personRef!=NULL&&groupRef!=NULL) 
	{
		result =  ABGroupAddMember(groupRef,personRef,nil);
		if (result) {
			result = ABAddressBookSave(contact_, nil);
		}
	}
	return result;
}

- (BOOL) removePerson:(PKContactPersion*)person fromGroup:(PKContactGroup*)group
{
	ABRecordRef personRef = [person record];
	ABRecordRef groupRef  = [group  record];
	BOOL result = NO;
	if (personRef!=NULL&&groupRef!=NULL) 
	{
		result = ABGroupRemoveMember(groupRef, personRef, nil);
		ABAddressBookSave(contact_, nil);
	}
	return result;
}

- (BOOL) addToSelGroupWithPerson:(PKContactPersion*)person
{
	PKContactGroup* group = objectAtIndex(groupsArr_, selGroupIndex_);
	BOOL result = [self addPerson:person toGroup:group];
	if (result)
	{
		NSMutableArray* personsArr = [personsDict_ objectForKey:person.firstWordPinyin];
		if (personsArr==nil)
		{
			personsArr = [[NSMutableArray alloc] initWithCapacity:0];
			[personsDict_ setObject:personsArr forKey:[NSString stringWithString:person.firstWordPinyin]];
			[personsArr release];
		}
		[personsArr	 addObject:person];
	}
	return result;
}

- (void) removeFromSelGroupWithPerson:(PKContactPersion*)person
{
	//删除用户
	if (selGroupIndex_==kContactGroupNone) 
	{
		if ([self removePersonFromAddressBook:person]) 
		{
			[self loadContactPersons];	
		}		
		return;
	}
	//从组删除用户
	PKContactGroup* group = objectAtIndex(groupsArr_, selGroupIndex_);
	BOOL result = [self removePerson:person fromGroup:group];
	if (result)
	{
		NSString* key = [NSString stringWithString:[person firstWordPinyin]];
		NSMutableArray* arr = [personsDict_ objectForKey:key];
		[arr removeObject:person];
		if ([arr count]==0) 
		{
			[personsDict_ removeObjectForKey:key];
		}
	}
	
}

/*
- (NSString*)firstNameOfIndex:(NSInteger)index
{
	if (index<0||index>=[displayPersonsArr_ count]) {
		return nil;
	}
	return [[displayPersonsArr_ objectAtIndex:index] firstname];
}

- (NSString*)lastNameOfIndex:(NSInteger)index
{
	if (index<0||index>=[displayPersonsArr_ count]) {
		return nil;
	}
	return [[displayPersonsArr_ objectAtIndex:index] lastname];
}

- (NSString*)middleNameOfIndex:(NSInteger)index
{
	if (index<0||index>=[displayPersonsArr_ count]) {
		return nil;
	}
	return [[displayPersonsArr_ objectAtIndex:index] middlename];
}

- (NSString*)fullNameOfIndex:(NSInteger)index
{
	if (index<0||index>=[displayPersonsArr_ count]) {
		return nil;
	}
	return [[displayPersonsArr_ objectAtIndex:index] contactName];
}

- (NSString*)contactNameOfIndex:(NSInteger)index
{
	if (index<0||index>=[displayPersonsArr_ count]) {
		return nil;
	}
	return [[displayPersonsArr_ objectAtIndex:index] contactName];
}
- (PKContactPersion*)personOfIndex:(NSInteger)index
{
	PKContactPersion* person = nil;
	if (index>=0 && index<[displayPersonsArr_ count]) {
		person = [displayPersonsArr_ objectAtIndex:index];
	}
	return person;
}




- (BOOL) addMemberAtIndex:(NSInteger)personIndex toGroup:(NSInteger)groupIndex
{
	BOOL result = NO;
	if (validateIndex(displayPersonsArr_,personIndex)&& validateIndex(groupsArr_,groupIndex))
	{
		PKContactPersion* person = [displayPersonsArr_ objectAtIndex:personIndex];
		PKContactGroup*   group  = [groupsArr_ objectAtIndex:groupIndex];
		result = ABGroupAddMember(group.record,person.record,nil);
		ABAddressBookSave(contact_, nil);
	}
	return result;
}

- (BOOL) removeMemberAtIndex:(NSInteger)personIndex fromGroup:(NSInteger)groupIndex
{
	BOOL result = NO;
	if (validateIndex(displayPersonsArr_,personIndex)&& validateIndex(groupsArr_,groupIndex))
	{
		PKContactPersion* person = [displayPersonsArr_ objectAtIndex:personIndex];
		PKContactGroup*   group  = [groupsArr_ objectAtIndex:groupIndex];
		
		result = ABGroupRemoveMember(group.record, person.record,nil);
		if (result) {
			[displayPersonsArr_ removeObject:person];
		}
		ABAddressBookSave(contact_, nil);
	}
	return result;
}

- (BOOL) removeMemberFromCurSeletedGroup:(NSInteger)personIndex
{
	return [self removeMemberAtIndex:personIndex fromGroup:selGroupIndex_];
}
*/

#pragma mark - Groups


- (NSInteger)contactGroupsCount
{
	return [groupsArr_ count];
}

- (NSString*)groupNameOfIndex:(NSInteger)index
{
	if (index<0||index>=[groupsArr_ count]) {
		return nil;
	}
	return [[groupsArr_ objectAtIndex:index] groupName];
}

- (BOOL)addGroupWithName:(NSString*)groupName 
{
	BOOL result = NO;
	PKContactGroup*group = [PKContactGroup creatGroupWithName:groupName];
	result = ABAddressBookAddRecord(contact_,group.record,nil);
	ABAddressBookSave(contact_, nil);
	if (result) 
	{
		[groupsArr_ addObject:group];
		[self setSelGroupIndex:[groupsArr_ count]-1];
	}
	return result;
}

- (void)removeGroupAtIndex:(NSInteger)index
{
	PKContactGroup* group = objectAtIndex(groupsArr_, index);
	if (group) 
	{
		[group removeFromAddressBook:contact_];
		[groupsArr_ removeObjectAtIndex:index];
		self.selGroupIndex = kContactGroupNone;
		ABAddressBookSave(contact_, nil);
	}
}

- (void)moveGroupFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
	if (fromIndex>=0&&fromIndex<[groupsArr_ count]&&toIndex>=0&&toIndex<[groupsArr_ count])
	{
		[groupsArr_ exchangeObjectAtIndex:fromIndex withObjectAtIndex:toIndex];
		self.selGroupIndex = (self.selGroupIndex==fromIndex)?toIndex:self.selGroupIndex;
	}
}

- (void)modifyGroupName:(NSString*)groupName atIndex:(NSInteger)index
{
	if (index>=0&&index<[groupsArr_ count])
	{
		PKContactGroup* group = [groupsArr_ objectAtIndex:index];
		[group setGroupName:groupName];
	}
}

#pragma mark -Find Math person

//- (NSArray*)totalPersonsArray
//{
//	NSArray* array = [NSArray arrayWithArray:totalPersonsArr_];
//	return array;
//}

- (NSArray *) contactsMatchingPhone: (NSString *) number
{
	NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:0];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"phonenumbers contains[cd] %@", number];
    NSArray* allKeys = [personsDict_ allKeys];
	for (NSString* key in allKeys)
	{
		NSArray* persons = [personsDict_ objectForKey:key];
		NSArray* person = [persons filteredArrayUsingPredicate:pred];
		if ([person count]>0)
		{
			[resultArray addObjectsFromArray:person];
		}
	}
    return resultArray;
}

#pragma mark - Private Method

- (ABAddressBookRef) addressBook
{
	return contact_;
}

- (NSDictionary*)loadAllPersons
{
	NSMutableDictionary* personsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
	NSArray *thePeople  = ( NSArray *)ABAddressBookCopyArrayOfAllPeople(contact_);
	for (id person in thePeople)
	{
		ABRecordRef pRecord = CFRetain((ABRecordRef)person);
		PKContactPersion* person = [PKContactPersion contactPersonWithRecord:pRecord];
		NSMutableArray* personsArr = [personsDict objectForKey:person.firstWordPinyin];
		if (personsArr==nil) {
			personsArr = [[NSMutableArray alloc] initWithCapacity:0];
			[personsDict setObject:personsArr forKey:[NSString stringWithString:person.firstWordPinyin]];
			[personsArr release];
		}
		[personsArr	 addObject:person];
		CFRelease(pRecord);
	}
	NSDictionary* tmpDict = [NSDictionary dictionaryWithDictionary:personsDict];
	[personsDict	release];
	[thePeople		release];
	return tmpDict;
}

- (void) loadContactPersons
{
	NSDictionary* tmpPersonDict = [self loadAllPersons];
	if ([tmpPersonDict count]>0) 
	{
		[self.personsDict removeAllObjects];
		[self.personsDict setDictionary:tmpPersonDict];
	}
}

- (void) loadContactGroups
{
	NSArray* theGroup = (NSArray*)ABAddressBookCopyArrayOfAllGroups(contact_);
	[groupsArr_ removeAllObjects];
    for (id group in theGroup)
    {
		ABRecordRef pRecord = CFRetain((ABRecordRef)group);
		[groupsArr_ addObject:[PKContactGroup contactWithGroupRecord:pRecord]];
		CFRelease(pRecord);
	}
	[theGroup	release];
}

- (void) loadContactPersonsInGroup:(PKContactGroup*)group
{
	[personsDict_ removeAllObjects];
	NSArray *thePersons = ( NSArray *)ABGroupCopyArrayOfAllMembers(group.record);
	for (id person in thePersons)
	{
		ABRecordRef pRecord = CFRetain((ABRecordRef)person);
		PKContactPersion* person = [PKContactPersion contactPersonWithRecord:pRecord];
		NSMutableArray* personsArr = [personsDict_ objectForKey:person.firstWordPinyin];
		if (personsArr==nil) {
			personsArr = [[NSMutableArray alloc] initWithCapacity:0];
			[personsDict_ setObject:personsArr forKey:[NSString stringWithString:person.firstWordPinyin]];
			[personsArr release];
		}
		[personsArr	 addObject:person];
		CFRelease(pRecord);
	}
	[thePersons	release];
}

- (BOOL) removePersonFromAddressBook:(PKContactPersion*)person
{
	BOOL result = NO;
	ABRecordRef personRef = [person record];
	if (personRef!=NULL) 
	{
		if(ABAddressBookRemoveRecord(contact_, personRef, nil))
			result = ABAddressBookSave(contact_, nil);
	}
	return result;
}

@end
