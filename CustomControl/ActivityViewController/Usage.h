//
//  LVActivity.h
//  
//
//  Created   on 5/24/13.
//  Copyright (c) 2013 . All rights reserved.
//

NSArray* activityArray = [NSArray arrayWithObjects: NSLocalizedString(@"String_Unicast", nil),nil];
LVTencentActivity* qqActivity = [[LVTencentActivity alloc] init];
LVSinaActivity*  sinaActivity = [[LVSinaActivity alloc] init];
NSArray* appActArray = [NSArray arrayWithObjects:qqActivity,sinaActivity, nil];
[qqActivity	  release];
[sinaActivity release];
UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityArray applicationActivities:appActArray];
activityViewController.excludedActivityTypes  = [NSArray arrayWithObjects:UIActivityTypePostToFacebook,UIActivityTypePostToTwitter,UIActivityTypePostToWeibo,UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,nil];
[self presentViewController:activityViewController animated:YES completion:NULL];