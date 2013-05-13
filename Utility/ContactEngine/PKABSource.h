//
//  PKABSource.h
//  Pumpkin
//
//  Created by lv on 3/3/12.
//  Copyright 2012 XXXXX. All rights reserved.
//
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define CFRELEASE_AND_NIL(x) CFRelease(x); x=nil;
ABRecordRef sourceWithType (ABSourceType mySourceType)
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    CFArrayRef sources = ABAddressBookCopyArrayOfAllSources(addressBook);
    CFIndex sourceCount = CFArrayGetCount(sources);
    ABRecordRef resultSource = NULL;
    for (CFIndex i = 0 ; i < sourceCount; i++) {
        ABRecordRef currentSource = CFArrayGetValueAtIndex(sources, i);
        CFTypeRef sourceType = ABRecordCopyValue(currentSource, kABSourceTypeProperty);
		
        BOOL isMatch = mySourceType == [(NSNumber *)sourceType intValue];
        CFRELEASE_AND_NIL(sourceType);
		
        if (isMatch) {
            resultSource = currentSource;
            break;
        }
    }
	
    CFRELEASE_AND_NIL(addressBook);    
    CFRELEASE_AND_NIL(sources);
	
    return resultSource;
}

ABRecordRef localSource()
{
    return sourceWithType(kABSourceTypeLocal);
}

ABRecordRef exchangeSource()
{
    return sourceWithType(kABSourceTypeExchange);
}

ABRecordRef mobileMeSource()
{
    return sourceWithType(kABSourceTypeMobileMe);
}
