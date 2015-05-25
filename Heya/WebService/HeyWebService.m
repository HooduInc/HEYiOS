//
//  LoginWebService.m
//  GTSpeed
//
//  Created by Kaustav Shee on 2/4/15.
//  Copyright (c) 2015 Kaustav Shee. All rights reserved.
//

#import "HeyWebService.h"

@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation HeyWebService

-(id)init
{
    if (self=[super init])
    {
        self.strImageURL=@"https://api.edhubs.com/lo";
        self.strRegisterURL=@"profile_details/create";
        self.strProfileUpdateURL=@"profile_details/update";
        self.strSendMsgURL=@"msgSend";
        self.strFetchAccountDetailsURL=@"account_details";
    }
    return self;
}

+(HeyWebService*)service
{
    static HeyWebService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service=[[HeyWebService alloc] init];
    });
    return service;
}

-(void)callGenerateImageURL:(NSData*)imageData WithCompletionHandler:(WebServiceCompletionHandler)handler
{
      NSURL *url=[NSURL URLWithString:self.strImageURL];
    
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
      [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:HostOne];
        
      [request setHTTPMethod:@"POST"];
      [request addValue:@"Token cf8b69e720eee6a09159c41c0ad96555" forHTTPHeaderField:@"Authorization"];
      [request addValue:@"LMPPROD" forHTTPHeaderField:@"companyID"];
      [request addValue:@"IOS" forHTTPHeaderField:@"User-Agent"];

      //[request setValue:@"Image" forKey:@"title"];
      //[request setValue:@"Image Description" forKey:@"description"];

      NSMutableData *body = [NSMutableData data];

      NSString *boundary = @"---------------------------14737809831466499882746641449";
      NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
      [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
      //The file to upload
      [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"file\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
      [body appendData:[NSData dataWithData:imageData]];
      [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

      NSMutableDictionary *form=[NSMutableDictionary dictionary];
      [form setObject:@"Image" forKey:@"title"];
      [form setObject:@"Image Description" forKey:@"description"];
    
      // close the form
      [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

      // set request body
      [request setHTTPBody:body];
      
      [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
          handler(connectionError,YES,@"Something is wrong, please try again later.");
        }
        else
        {
            NSError *err;
            NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
              
            //NSLog(@"resultDict: %@",resultDict);
            NSString *status=[resultDict valueForKey:@"status"];
            
            if ([status isEqualToString:@"success"])
            {
                NSString *imageURL=[resultDict valueForKey:@"fileUrl"];
                handler(imageURL,NO,@"Successfully uploaded.");
            }
            else
            {
                NSLog(@"Image has not been uploaded");
                handler(err,YES,@"Image has not been uploaded.");
            }
        }
          
      }];
}

-(void) registerWithUDID:(NSString *)strUDID FullName:(NSString *)strFullName ContactNumber:(NSString *)strContactNumber TimeStamp:(NSString *)strTimeStamp AccountCreated:(NSString*)strAccountCreated WithCompletionHandler:(WebServiceCompletionHandler)handler
{
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strRegisterURL]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:HostTwo];
    
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
        NSString *postString = [NSString stringWithFormat:@"unique_token=%@&user_name=%@&contact_number=%@&timestamp=%@&account_started=%@",strUDID,strFullName,strContactNumber,strTimeStamp,strAccountCreated];
        NSLog(@"postString: %@",postString);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    

        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError)
            {
                handler(connectionError,YES,@"Something is wrong, please try again later.");
            }
            else
            {
                NSError *err;
                NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
                NSLog(@"resultDict for Register: %@",resultDict);
                
                if ([[resultDict valueForKey:@"success"] boolValue]==true)
                {
                    //Error
                    NSLog(@"Successfully registered.");
                    handler(resultDict,NO,@"Successfully registered.");
                    
                }
                else
                {
                    //OK
                    NSLog(@"Registration unsuccessfull");
                    handler(err,YES,[resultDict valueForKey:@"message"]);
                }
            }
        }];
}



-(void) updateProfileWithUDID:(NSString *)strUDID FullName:(NSString *)strFullName ContactNumber:(NSString *)strContactNumber TimeStamp:(NSString*)strTimeStamp WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strProfileUpdateURL]];
    NSLog(@"Update url: %@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:HostTwo];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postString = [NSString stringWithFormat:@"unique_token=%@&user_name=%@&contact_number=%@&timestamp=%@",strUDID,strFullName,strContactNumber,strTimeStamp];
    NSLog(@"postString: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
            handler(connectionError,YES,@"Something is wrong, please try again later.");
        }
        else
        {
            NSError *err;
            NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            NSLog(@"resultDict for Update: %@",resultDict);
            
            if ([[resultDict valueForKey:@"success"] boolValue]==true)
            {
                //Error
                NSLog(@"Successfully updated.");
                handler(resultDict,NO,@"Successfully updated.");
                
            }
            else
            {
                //OK
                NSLog(@"Updatation not possible.");
                handler(err,YES,@"Updatation not possible.");
            }
        }
    }];
}



-(void) sendMessageDetailsToServerWithUDID:(NSString *)strUDID TemplateId:(NSString *)strTemplateId MsgText:(NSString *)strMsgText TimeStamp:(NSString *)strTimeStamp From:(NSString *)strFrom To:(NSString *)strTo WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strSendMsgURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:HostTwo];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postString = [NSString stringWithFormat:@"unique_token=%@&templateId=%@&timestamp=%@&to=%@&from=%@&message=%@&platform=%@",strUDID,strTemplateId,strTimeStamp,strTo,strFrom,strMsgText,@"iOS"];
    NSLog(@"postString: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
            handler(connectionError,YES,@"Something is wrong, please try again later.");
        }
        else
        {
            NSError *err;
            NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            NSLog(@"resultDict for Send Message: %@",resultDict);
            
            if ([[resultDict valueForKey:@"success"] boolValue]==true)
            {
                //Error
                NSLog(@"Message successfully sent.");
                handler(resultDict,NO,@"Message successfully sent.");
                
            }
            else
            {
                //OK
                NSLog(@"Message not sent.");
                handler(err,YES,[resultDict valueForKey:@"message"]);
            }
        }
    }];
}


-(void) fetchAccountDetailsFromServerWithUDID:(NSString *)strUDID WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strFetchAccountDetailsURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:HostTwo];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postString = [NSString stringWithFormat:@"unique_token=%@",strUDID];
    NSLog(@"postString: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError)
        {
            handler(connectionError,YES,@"Something is wrong, please try again later.");
        }
        else
        {
            NSError *err;
            NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
            NSLog(@"resultDict for Account Details: %@",resultDict);
            
            if ([[resultDict valueForKey:@"success"] boolValue]==false)
            {
                //Error
                NSLog(@"Account Details not recieved.");
                handler(err,YES,@"Account Details not recieved.");
            }
            else
            {
                //OK
                NSLog(@"Successfully Recieved.");
                handler([resultDict valueForKey:@"data"],NO,@"Successfully Recieved.");
            }
        }
    }];
}

@end
