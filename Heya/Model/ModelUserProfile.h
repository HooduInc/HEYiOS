//
//  ModelUserProfile.h
//  Heya
//
//  Created by jayantada on 12/03/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelUserProfile : NSObject
@property(strong,nonatomic) NSString *strProfileId;
@property(strong,nonatomic) NSString *strFirstName;
@property(strong,nonatomic) NSString *strLastName;
@property(strong,nonatomic) NSString *strHeyName;
@property(strong,nonatomic) NSString *strPhoneNo;
@property(strong,nonatomic) NSString *strDeviceUDID;
@property(strong,nonatomic) NSString *strProfileImage;
@property(strong,nonatomic) NSString *strCurrentTimeStamp;
@property(strong,nonatomic) NSString *strAccountCreated;
@property(assign,nonatomic) int isSendToServer;
@property(assign,nonatomic) int isRegistered;
@end
