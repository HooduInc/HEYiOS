//
//  APContact.h
//  APAddressBook
//
//  Created by Alexey Belkevich on 1/10/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "APTypes.h"

@interface APContact : NSObject<NSCopying>

@property (nonatomic, readwrite) APContactField fieldMask;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *compositeName;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, readwrite) NSArray *phones;
@property (nonatomic, readwrite) NSArray *phonesWithLabels;
@property (nonatomic, readwrite) NSArray *emails;
@property (nonatomic, copy) NSArray *addresses;
@property (nonatomic, copy) UIImage *photo;
@property (nonatomic, copy) UIImage *thumbnail;
@property (nonatomic, copy) NSNumber *recordID;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, copy) NSDate *modificationDate;
@property (nonatomic, copy) NSArray *socialProfiles;
@property (nonatomic, copy) NSString *note;


- (id)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(APContactField)fieldMask;
-(id) copyWithZone: (NSZone *) zone;

@end
