//
//  LoginWebService.h
//  GTSpeed
//
//  Created by Kaustav Shee on 2/4/15.
//  Copyright (c) 2015 Kaustav Shee. All rights reserved.
//

#import "WebServiceBaseClass.h"

@interface HeyWebService : WebServiceBaseClass

+(HeyWebService*)service;

-(void)callGenerateImageURL:(NSData*)imageData WithCompletionHandler:(WebServiceCompletionHandler)handler;

-(void)registerWithUDID:(NSString*)strUDID FullName:(NSString*)strFullName ContactNumber:(NSString*)strContactNumber TimeStamp:(NSString*)strTimeStamp AccountCreated:(NSString*)strAccountCreated WithCompletionHandler:(WebServiceCompletionHandler)handler;

-(void)updateProfileWithUDID:(NSString*)strUDID FullName:(NSString*)strFullName ContactNumber:(NSString*)strContactNumber TimeStamp:(NSString*)strTimeStamp WithCompletionHandler:(WebServiceCompletionHandler)handler;

-(void)sendMessageDetailsToServerWithUDID:(NSString*)strUDID TemplateId:(NSString*)strTemplateId MsgText:(NSString*)strMsgText TimeStamp:(NSString*)strTimeStamp From:(NSString*)strFrom To:(NSString*)strTo WithCompletionHandler:(WebServiceCompletionHandler)handler;

-(void)fetchAccountDetailsFromServerWithUDID:(NSString*)strUDID WithCompletionHandler:(WebServiceCompletionHandler)handler;

@end
