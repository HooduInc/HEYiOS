//
//  ModelMessageSend.h
//  Heya
//
//  Created by jayantada on 04/05/15.
//  Copyright (c) 2015 Jayanta Karmakar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelMessageSend : NSObject

@property(strong,nonatomic) NSString *strMessageInsertId;
@property(strong,nonatomic) NSString *strtemplateId;
@property(strong,nonatomic) NSString *strDeviceId;
@property(strong,nonatomic) NSString *strMessageText;
@property(strong,nonatomic) NSString *strFrom;
@property(strong,nonatomic) NSString *strTo;
@property(strong,nonatomic) NSString *strSendDate;
@property(assign,nonatomic) int points;
@property(assign,nonatomic) int isPushedToServer;
@end
