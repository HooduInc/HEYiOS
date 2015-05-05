//
//  WebServiceBaseClass.h
//  GTSpeed
//
//  Created by Kaustav Shee on 2/4/15.
//  Copyright (c) 2015 Kaustav Shee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^WebServiceCompletionHandler)(id result,BOOL isError,NSString *strMsg);


@interface WebServiceBaseClass : NSObject

@property(strong,nonatomic) NSString *strImageURL;
@property(strong,nonatomic) NSString *strRegisterURL;
@property(strong,nonatomic) NSString *strProfileUpdateURL;
@property(strong,nonatomic) NSString *strSendMsgURL;
@property(strong,nonatomic) NSString *strFetchAccountDetailsURL;
@end
