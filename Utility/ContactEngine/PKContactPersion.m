//
//  PKContactPersion.m
//  Pumpkin
//
//  Created by lv on 2/29/12.
//  Copyright 2012 XXXXX. All rights reserved.
//

#import "PKContactPersion.h"
#import "PKUtils.h"


@interface PKContactPersion()

@end

@implementation PKContactPersion
@synthesize record = record_;

- (id) initWithRecord: (ABRecordRef) record 
{
	self = [super init];
	if (self) {
		record_ = CFRetain(record);
		NSString* str =[PKUtils firstWordPinYinOfChineseString:[self lastname]];
		NSAssert([str length]>0,@"First Letter Of Name Is NULL!!");
		firstWordPinyin_ = [[NSString alloc] initWithString:str];
		//NSLog(@">>%@",[self compositeName]);
	}
	return self;
}

-(void)dealloc
{
	if (record_) 
	{
		CFRelease(record_);
		record_ = nil;
	}
	[firstWordPinyin_	release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ pinyin=%@",NSStringFromClass([self class]),firstWordPinyin_];
	//return firstWordPinyin_;
}

#pragma mark - Public Method
+ (id) contactPersonWithRecord: (ABRecordRef) record 
{
	return [[[PKContactPersion alloc] initWithRecord:record] autorelease];
}

+ (id) createNewContactPerson
{
    ABRecordRef person = ABPersonCreate();
    id contact = [PKContactPersion contactPersonWithRecord:person];
    CFRelease(person);
    return contact;
}

- (BOOL)isEqual:(id)object
{
	//NSLog(@"%p %p",record_,[object record]);
	return (record_ == [object record]);
}
- (NSUInteger)hash
{
	NSUInteger hash = (NSUInteger)record_; 
	return hash;
}


- (NSComparisonResult)firstLetterCompare:(PKContactPersion*)person
{
	return [firstWordPinyin_ compare:person.firstWordPinyin];
}


- (NSString *)firstWordPinyin
{
	return [NSString stringWithString:firstWordPinyin_];
}


#pragma mark Record ID and Type

- (ABRecordID) recordID {return ABRecordGetRecordID(record_);}
- (ABRecordType) recordType {return ABRecordGetRecordType(record_);}
- (BOOL) isPerson {return self.recordType == kABPersonType;}


#pragma mark String Retrieval

- (NSString *) getRecordString:(ABPropertyID) anID
{
    NSString *result = ( NSString *) ABRecordCopyValue(record_, anID);
    return [result autorelease];
}
- (NSString *) firstname {return [self getRecordString:kABPersonFirstNameProperty];}
- (NSString *) middlename {return [self getRecordString:kABPersonMiddleNameProperty];}
- (NSString *) lastname {return [self getRecordString:kABPersonLastNameProperty];}

- (NSString *) prefix {return [self getRecordString:kABPersonPrefixProperty];}
- (NSString *) suffix {return [self getRecordString:kABPersonSuffixProperty];}
- (NSString *) nickname {return [self getRecordString:kABPersonNicknameProperty];}

- (NSString *) firstnamephonetic {return [self getRecordString:kABPersonFirstNamePhoneticProperty];}
- (NSString *) middlenamephonetic {return [self getRecordString:kABPersonMiddleNamePhoneticProperty];}
- (NSString *) lastnamephonetic {return [self getRecordString:kABPersonLastNamePhoneticProperty];}

- (NSString *) organization {return [self getRecordString:kABPersonOrganizationProperty];}
- (NSString *) jobtitle {return [self getRecordString:kABPersonJobTitleProperty];}
- (NSString *) department {return [self getRecordString:kABPersonDepartmentProperty];}
- (NSString *) note {return [self getRecordString:kABPersonNoteProperty];}


#pragma mark - Rest Property
- (BOOL) resetProperty:(ABPropertyID) anID
{
	BOOL success = NO;
	CFErrorRef cfError = NULL;
	success =  ABRecordRemoveValue(record_, anID,  &cfError);
	
	if (!success)
	{
		NSError *error = ( NSError *) cfError;
		NSLog(@"Error: %@", error.localizedFailureReason);
	}
    return success;
}
- (BOOL) resetFirstName{ return [self resetProperty:kABPersonFirstNameProperty];}

#pragma mark Setting Strings
- (BOOL) setString: (NSString *) aString forProperty:(ABPropertyID) anID
{
	BOOL success = NO;
	if ([aString length]>0)
	{
		CFErrorRef cfError = NULL;
		success = ABRecordSetValue(record_, anID, ( CFStringRef) aString, &cfError);
		if (!success) 
		{
			NSError *error = ( NSError *) cfError;
			NSLog(@"Error: %@", error.localizedFailureReason);
		}
	}
	else
	{
		success = [self resetProperty:anID];
	}
    return success;
}


- (void) setFirstname: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNameProperty];}
- (void) setMiddlename: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNameProperty];}
- (void) setLastname: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNameProperty];}

- (void) setPrefix: (NSString *) aString {[self setString: aString forProperty: kABPersonPrefixProperty];}
- (void) setSuffix: (NSString *) aString {[self setString: aString forProperty: kABPersonSuffixProperty];}
- (void) setNickname: (NSString *) aString {[self setString: aString forProperty: kABPersonNicknameProperty];}

- (void) setFirstnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonFirstNamePhoneticProperty];}
- (void) setMiddlenamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonMiddleNamePhoneticProperty];}
- (void) setLastnamephonetic: (NSString *) aString {[self setString: aString forProperty: kABPersonLastNamePhoneticProperty];}

- (void) setOrganization: (NSString *) aString {[self setString: aString forProperty: kABPersonOrganizationProperty];}
- (void) setJobtitle: (NSString *) aString {[self setString: aString forProperty: kABPersonJobTitleProperty];}
- (void) setDepartment: (NSString *) aString {[self setString: aString forProperty: kABPersonDepartmentProperty];}

- (void) setNote: (NSString *) aString {[self setString: aString forProperty: kABPersonNoteProperty];}

#pragma mark Contact Name

- (NSString *) fullName
{
	NSMutableString *string = [NSMutableString string];
    if (self.firstname || self.lastname)
	{
		if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
		if (self.middlename) [string appendFormat:@"%@ ", self.middlename];
		if (self.lastname) [string appendFormat:@"%@", self.lastname];
	}
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) contactName
{
    NSMutableString *string = [NSMutableString string];
    
    if (self.firstname || self.lastname)
    {
        if (self.prefix) [string appendFormat:@"%@ ", self.prefix];
        if (self.lastname) [string appendFormat:@"%@", self.lastname];
        if (self.firstname) [string appendFormat:@"%@ ", self.firstname];
        if (self.nickname) [string appendFormat:@"\"%@\" ", self.nickname];
        
        if (self.suffix && string.length)
            [string appendFormat:@", %@ ", self.suffix];
        else
            [string appendFormat:@" "];
    }
    
    if (self.organization) [string appendString:self.organization];
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) compositeName
{
    return ( NSString *)ABRecordCopyCompositeName(record_);
}

#pragma mark Numbers

- (NSNumber *) getRecordNumber: (ABPropertyID) anID
{
    return ( NSNumber *) ABRecordCopyValue(record_, anID);
}

- (NSNumber *) kind {return [self getRecordNumber:kABPersonKindProperty];}


#pragma mark Setting Numbers
- (BOOL) setNumber: (NSNumber *) aNumber forProperty:(ABPropertyID) anID
{
    CFErrorRef cfError = NULL;
    BOOL success = ABRecordSetValue(record_, anID, ( CFNumberRef) aNumber, &cfError);
    if (!success) 
    {
        NSError *error = ( NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

// const CFNumberRef kABPersonKindPerson;
// const CFNumberRef kABPersonKindOrganization;
- (void) setKind: (NSNumber *) aKind {[self setNumber:aKind forProperty: kABPersonKindProperty];}

#pragma mark Dates

- (NSDate *) getRecordDate:(ABPropertyID) anID
{
    return ( NSDate *) ABRecordCopyValue(record_, anID);
}

- (NSDate *) birthday {return [self getRecordDate:kABPersonBirthdayProperty];}
- (NSDate *) creationDate {return [self getRecordDate:kABPersonCreationDateProperty];}
- (NSDate *) modificationDate {return [self getRecordDate:kABPersonModificationDateProperty];}

#pragma mark Setting Dates

- (BOOL) setDate: (NSDate *) aDate forProperty:(ABPropertyID) anID
{
    CFErrorRef cfError = NULL;
    BOOL success = ABRecordSetValue(record_, anID, ( CFDateRef) aDate, &cfError);
    if (!success) 
    {
        NSError *error = ( NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return success;
}

- (void) setBirthday: (NSDate *) aDate {[self setDate: aDate forProperty: kABPersonBirthdayProperty];}


#pragma mark Images

- (UIImage *) image
{
    if (!ABPersonHasImageData(record_)) return nil;
    CFDataRef imageData = ABPersonCopyImageData(record_);
    if (!imageData) return nil;
    
    NSData *data = ( NSData *)imageData;
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

- (void) setImage: (UIImage *) image
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    if (image == nil) // remove
    {
        if (!ABPersonHasImageData(record_)) return; // no image to remove
        success = ABPersonRemoveImageData(record_, &cfError);
        if (!success) 
        {
            NSError *error = ( NSError *) cfError;
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
        return;
    }
    
    NSData *data = UIImagePNGRepresentation(image);
    success = ABPersonSetImageData(record_, (  CFDataRef) data, &cfError);
    if (!success) 
    {
        NSError *error = ( NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return;
}

- (void) setImageWithData: (NSData*)imageData
{
    CFErrorRef cfError = NULL;
    BOOL success;
    
    if ([imageData length]==0) // remove
    {
        if (!ABPersonHasImageData(record_)) return; // no image to remove
        success = ABPersonRemoveImageData(record_, &cfError);
        if (!success) 
        {
            NSError *error = ( NSError *) cfError;
            NSLog(@"Error: %@", error.localizedFailureReason);
        }
        return;
    }
    
    success = ABPersonSetImageData(record_, (  CFDataRef) imageData, &cfError);
    if (!success) 
    {
        NSError *error = ( NSError *) cfError;
        NSLog(@"Error: %@", error.localizedFailureReason);
    }
    return;
}


#pragma mark MultiValue
+ (BOOL) propertyIsMultiValue: (ABPropertyID) aProperty;
{
    if (aProperty == kABPersonFirstNameProperty) return NO;
    if (aProperty == kABPersonMiddleNameProperty) return NO;
    if (aProperty == kABPersonLastNameProperty) return NO;
    
    if (aProperty == kABPersonPrefixProperty) return NO;
    if (aProperty == kABPersonSuffixProperty) return NO;
    if (aProperty == kABPersonNicknameProperty) return NO;
    
    if (aProperty == kABPersonFirstNamePhoneticProperty) return NO;
    if (aProperty == kABPersonMiddleNamePhoneticProperty) return NO;
    if (aProperty == kABPersonLastNamePhoneticProperty) return NO;
    
    if (aProperty == kABPersonOrganizationProperty) return NO;
    if (aProperty == kABPersonJobTitleProperty) return NO;
    if (aProperty == kABPersonDepartmentProperty) return NO;
    
    if (aProperty == kABPersonNoteProperty) return NO;
    
    if (aProperty == kABPersonKindProperty) return NO;
    
    if (aProperty == kABPersonBirthdayProperty) return NO;
    if (aProperty == kABPersonCreationDateProperty) return NO;
    if (aProperty == kABPersonModificationDateProperty) return NO;
    
    return YES;
    
    /*
     if (aProperty == kABPersonEmailProperty) return YES; // multistring
     if (aProperty == kABPersonPhoneProperty) return YES; // multistring
     if (aProperty == kABPersonURLProperty) return YES; // multistring
	 
     if (aProperty == kABPersonAddressProperty) return YES; // multivalue
     if (aProperty == kABPersonDateProperty) return YES; // multivalue
     if (aProperty == kABPersonInstantMessageProperty) return YES; // multivalue
     if (aProperty == kABPersonRelatedNamesProperty) return YES; // multivalue
     if (aProperty == kABPersonSocialProfileProperty) return YES; // multivalue
     */
}

// Determine whether the dictionary is a proper value/label item
+ (BOOL) isMultivalueDictionary: (NSDictionary *) dictionary
{
    if (dictionary.allKeys.count != 2) 
        return NO;
    if (![dictionary objectForKey:@"value"])
        return NO;
    if (![dictionary objectForKey:@"label"])
        return NO;
    
    return YES;
}

// Return multivalue-style dictionary
+ (NSDictionary *) dictionaryWithValue: (id) value andLabel: (CFStringRef) label
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (value) [dict setObject:value forKey:@"value"];
    if (label) [dict setObject:(  NSString *)label forKey:@"label"];
    return dict;
}

#pragma mark Accessing MultiValue Elements (value and label)

- (NSArray *) arrayForProperty: (ABPropertyID) anID
{
    CFTypeRef theProperty = ABRecordCopyValue(record_, anID);
    if (!theProperty) return nil;
    
    NSArray *items = ( NSArray *)ABMultiValueCopyArrayOfAllValues(theProperty);
    CFRelease(theProperty);
    return items;
}

- (NSArray *) labelsForProperty: (ABPropertyID) anID
{
    CFTypeRef theProperty = ABRecordCopyValue(record_, anID);
    if (!theProperty) return nil;
	
    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < ABMultiValueGetCount(theProperty); i++)
    {
        NSString *label = ( NSString *)ABMultiValueCopyLabelAtIndex(theProperty, i);
        [labels addObject:label];
    }
    CFRelease(theProperty);
    return labels;
}

- (NSArray *) emailArray {return [self arrayForProperty:kABPersonEmailProperty];}
- (NSArray *) emailLabels {return [self labelsForProperty:kABPersonEmailProperty];}

- (NSArray *) phoneArray {return [self arrayForProperty:kABPersonPhoneProperty];}
- (NSArray *) phoneLabels {return [self labelsForProperty:kABPersonPhoneProperty];}

- (NSArray *) relatedNameArray {return [self arrayForProperty:kABPersonRelatedNamesProperty];}
- (NSArray *) relatedNameLabels {return [self labelsForProperty:kABPersonRelatedNamesProperty];}

- (NSArray *) urlArray {return [self arrayForProperty:kABPersonURLProperty];}
- (NSArray *) urlLabels {return [self labelsForProperty:kABPersonURLProperty];}

- (NSArray *) dateArray {return [self arrayForProperty:kABPersonDateProperty];}
- (NSArray *) dateLabels {return [self labelsForProperty:kABPersonDateProperty];}

- (NSArray *) addressArray {return [self arrayForProperty:kABPersonAddressProperty];}
- (NSArray *) addressLabels {return [self labelsForProperty:kABPersonAddressProperty];}

- (NSArray *) imArray {return [self arrayForProperty:kABPersonInstantMessageProperty];}
- (NSArray *) imLabels {return [self labelsForProperty:kABPersonInstantMessageProperty];}

//- (NSArray *) socialArray {return [self arrayForProperty:kABPersonSocialProfileProperty];}
//- (NSArray *) socialLabels {return [self labelsForProperty:kABPersonSocialProfileProperty];}

// Multi-string convenience
- (NSString *) phonenumbers {return [self.phoneArray componentsJoinedByString:@" "];}
- (NSString *) emailaddresses {return [self.emailArray componentsJoinedByString:@" "];}
- (NSString *) urls {return [self.urlArray componentsJoinedByString:@" "];}

#pragma mark MultiValue Dictionary Arrays


// MultiValue convenience
- (NSArray *) dictionaryArrayForProperty: (ABPropertyID) aProperty
{
    NSArray *valueArray = [self arrayForProperty:aProperty];
    NSArray *labelArray = [self labelsForProperty:aProperty];
    
    int num = MIN(valueArray.count, labelArray.count);
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < num; i++)
    {
        NSMutableDictionary *md = [NSMutableDictionary dictionary];
        [md setObject:[valueArray objectAtIndex:i] forKey:@"value"];
        [md setObject:[labelArray objectAtIndex:i] forKey:@"label"];
        [items addObject:md];
    }
    return items;
}


- (NSArray *) emailDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonEmailProperty];
}

- (NSArray *) phoneDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonPhoneProperty];
}

- (NSArray *) relatedNameDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonRelatedNamesProperty];
}

- (NSArray *) urlDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonURLProperty];
}

- (NSArray *) dateDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonDateProperty];
}

- (NSArray *) addressDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonAddressProperty];
}

- (NSArray *) imDictionaries
{
    return [self dictionaryArrayForProperty:kABPersonInstantMessageProperty];
}



#pragma mark Setting MultiValue


// Determine whether the dictionary is a proper value/label item
- (BOOL) isMultivalueDictionary: (NSDictionary *) dictionary
{
    if (dictionary.allKeys.count != 2) 
        return NO;
    if (![dictionary objectForKey:@"value"])
        return NO;
    if (![dictionary objectForKey:@"label"])
        return NO;
    
    return YES;
}

- (BOOL) setMultiValue: (ABMutableMultiValueRef) multi forProperty: (ABPropertyID) anID
{
	BOOL success = NO;
	NSInteger count =  ABMultiValueGetCount(multi);
	if (count>0) 
	{
		CFErrorRef cfError = NULL;
		success = ABRecordSetValue(record_, anID, multi, &cfError);
		if (!success) 
		{
			NSError *error = ( NSError *) cfError;
			NSLog(@"Error: %@", error.localizedFailureReason);
		}

	}
	else
	{
		success = ABRecordRemoveValue(record_, anID, NULL);
	}
	return success;
}

- (ABMutableMultiValueRef) copyMultiValueFromArray: (NSArray *) anArray withType: (ABPropertyType) aType
{
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(aType);
    for (NSDictionary *dict in anArray)
    {
        if (![self isMultivalueDictionary:dict])
            continue;
		
		if ([[dict objectForKey:@"value"] length]==0)
		{
			continue;
		}
		
      //  ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef) [dict objectForKey:@"value"], (__bridge CFTypeRef) [dict objectForKey:@"label"], NULL);
		ABMultiValueAddValueAndLabel(multi, ( CFTypeRef) [dict objectForKey:@"value"], ( CFTypeRef) [dict objectForKey:@"label"], NULL);
    }
    return multi;
}

- (void) setEmailDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
	
	//ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	//ABMultiValueAddValueAndLabel(multiEmail,[], kABWorkLabel, NULL);
	
    [self setMultiValue:multi forProperty:kABPersonEmailProperty];
    CFRelease(multi);
}

- (void) setPhoneDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonPhoneMobileLabel, kABPersonPhoneIPhoneLabel, kABPersonPhoneMainLabel
    // kABPersonPhoneHomeFAXLabel, kABPersonPhoneWorkFAXLabel, kABPersonPhonePagerLabel
    // kABPersonPhoneOtherFAXLabel
	
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonPhoneProperty];
    CFRelease(multi);
}

- (void) setUrlDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonHomePageLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonURLProperty];
    CFRelease(multi);
}

// Not used/shown on iPhone
- (void) setRelatedNameDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonMotherLabel, kABPersonFatherLabel, kABPersonParentLabel, 
    // kABPersonSisterLabel, kABPersonBrotherLabel, kABPersonChildLabel, 
    // kABPersonFriendLabel, kABPersonSpouseLabel, kABPersonPartnerLabel, 
    // kABPersonManagerLabel, kABPersonAssistantLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiStringPropertyType];
    [self setMultiValue:multi forProperty:kABPersonRelatedNamesProperty];
    CFRelease(multi);
}

- (void) setDateDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel
    // kABPersonAnniversaryLabel
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDateTimePropertyType];
    [self setMultiValue:multi forProperty:kABPersonDateProperty];
    CFRelease(multi);
}

- (void) setAddressDictionaries: (NSArray *) dictionaries
{
    // kABPersonAddressStreetKey, kABPersonAddressCityKey, kABPersonAddressStateKey
    // kABPersonAddressZIPKey, kABPersonAddressCountryKey, kABPersonAddressCountryCodeKey
    //ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
	
	ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    for (NSDictionary *dict in dictionaries)
    {
        if (![self isMultivalueDictionary:dict])
            continue;
		if ([[dict objectForKey:@"value"] length]==0)
			continue;
		
		NSMutableDictionary* addressDictionary = [[NSMutableDictionary alloc] init];
		[addressDictionary setObject:[dict objectForKey:@"value"] forKey:(NSString *) kABPersonAddressStreetKey];
		//[addressDictionary setObject:@"Chicago" forKey:(NSString *)kABPersonAddressCityKey];
		//[addressDictionary setObject:@"IL" forKey:(NSString *)kABPersonAddressStateKey];
		//[addressDictionary setObject:@"60654" forKey:(NSString *)kABPersonAddressZIPKey];
		 ABMultiValueAddValueAndLabel(multi, addressDictionary, (CFTypeRef) [dict objectForKey:@"label"], NULL);
		[addressDictionary release];
    }

    [self setMultiValue:multi forProperty:kABPersonAddressProperty];
    CFRelease(multi);
}

- (void) setImDictionaries: (NSArray *) dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
    // kABPersonInstantMessageServiceKey, kABPersonInstantMessageUsernameKey
    // kABPersonInstantMessageServiceYahoo, kABPersonInstantMessageServiceJabber
    // kABPersonInstantMessageServiceMSN, kABPersonInstantMessageServiceICQ
    // kABPersonInstantMessageServiceAIM, 
   // ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
	ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    for (NSDictionary *dict in dictionaries)
    {
        if (![self isMultivalueDictionary:dict])
            continue;
		if ([[dict objectForKey:@"value"] length]==0)
			continue;
		
		NSMutableDictionary* message = [[NSMutableDictionary alloc] init];
		[message setObject:[dict objectForKey:@"value"] forKey:(NSString *) kABPersonInstantMessageUsernameKey];
		[message setObject:[dict objectForKey:@"label"] forKey:(NSString *)kABPersonInstantMessageServiceKey];
		ABMultiValueAddValueAndLabel(multi, message, (CFTypeRef)[dict objectForKey:@"label"] , NULL);
		[message release];
	}
		
    [self setMultiValue:multi forProperty:kABPersonInstantMessageProperty];
    CFRelease(multi);
}

- (void) setSocialDictionaries:(NSArray *)dictionaries
{
    // kABWorkLabel, kABHomeLabel, kABOtherLabel, 
    // kABPersonSocialProfileServiceTwitter
    // kABPersonSocialProfileServiceGameCenter
    // kABPersonSocialProfileServiceFacebook
    // kABPersonSocialProfileServiceMyspace
    // kABPersonSocialProfileServiceLinkedIn
    // kABPersonSocialProfileServiceFlickr
	
    ABMutableMultiValueRef multi = [self copyMultiValueFromArray:dictionaries withType:kABMultiDictionaryPropertyType];
    [self setMultiValue:multi forProperty:kABPersonSocialProfileProperty];
    CFRelease(multi);
}


//- (NSArray *) socialDictionaries
//{
//    return [self dictionaryArrayForProperty:kABPersonSocialProfileProperty];
//}


#pragma mark - Private Method

@end
