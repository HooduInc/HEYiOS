//
//  LoginWebService.m
//  GTSpeed
//
//  Created by Kaustav Shee on 2/4/15.
//  Copyright (c) 2015 Kaustav Shee. All rights reserved.
//

#import "HeyWebService.h"


@interface NSURLRequest (DummyInterface)
@end

@implementation HeyWebService

-(id)init
{
    if (self=[super init])
    {
        self.strRegisterURL=@"registration/register";
        self.strRegistrationPushNotificationURL=@"registration/push_notification";
        self.strProfileUpdateURL=@"api/user/update";
        self.strSendMsgURL=@"api/user/message_send";
        self.strFetchAccountDetailsURL=@"api/user/account_details";
        self.strImageURL=@"api/user/image_path";
        self.strCreateRenewSubsciptionURL=@"api/user/subscription";
        self.strFetchSubsciptionURL=@"api/user/check_app_validity";
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

-(void)callGenerateImageURL:(NSData*)imageData UDID:(NSString*)strUDID WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strImageURL]];
    NSLog(@"Image Upload URL: %@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120.0];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737800031466499882746641949";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token"     : strUDID,
                             @"image_title"    : @"Image",
                             @"image_desc" : @"Image Description",
                             @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    
    //The file to upload
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: attachment; name=\"image\"; filename=\"image.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //The file to upload
    
    
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
            
            NSLog(@"resultDict: %@",resultDict);
            
            if ([[resultDict valueForKey:@"status"] boolValue]==true)
            {
                NSString *imageURL=[resultDict valueForKey:@"error"];
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
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token": strUDID,
                             @"user_name": strFullName,
                             @"contact_number" : strContactNumber,
                             @"account_updated" : strTimeStamp,
                             @"account_started" : strAccountCreated,
                             @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // close the form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    /*NSString *postString = [NSString stringWithFormat:@"unique_token=%@&user_name=%@&contact_number=%@&timestamp=%@&account_started=%@",strUDID,strFullName,strContactNumber,strTimeStamp,strAccountCreated];
     NSLog(@"postString: %@",postString);
     [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];*/
    
    
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
            
            if ([[resultDict valueForKey:@"status"] boolValue]==true)
            {
                //Error
                NSLog(@"Successfully registered.");
                handler(resultDict,NO,@"Successfully registered.");
                
            }
            else
            {
                //OK
                NSLog(@"Registration unsuccessfull");
                handler(err,YES,[resultDict valueForKey:@"error"]);
            }
        }
    }];
}



-(void) updateProfileWithUDID:(NSString *)strUDID FullName:(NSString *)strFullName ContactNumber:(NSString *)strContactNumber TimeStamp:(NSString*)strTimeStamp WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strProfileUpdateURL]];
    NSLog(@"Update url: %@",url);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641459";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token"     : strUDID,
                             @"user_name"    : strFullName,
                             @"contact_number" : strContactNumber,
                             @"account_updated" : strTimeStamp};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
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
            NSLog(@"resultDict for Update: %@",resultDict);
            
            if ([[resultDict valueForKey:@"status"] boolValue]==true)
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
    
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641469";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token"     : strUDID,
                             @"template_id"    : strTemplateId,
                             @"message" : strMsgText,
                             @"to" : strTo,
                             @"from" : strFrom,
                             @"msg_insertion_date" : strTimeStamp,
                             @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // close the form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    /*NSString *postString = [NSString stringWithFormat:@"unique_token=%@&templateId=%@&timestamp=%@&to=%@&from=%@&message=%@&platform=%@",strUDID,strTemplateId,strTimeStamp,strTo,strFrom,strMsgText,@"iOS"];
    NSLog(@"postString: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];*/
    
    
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
            
            if ([[resultDict valueForKey:@"status"] boolValue]==true)
            {
                //Error
                NSLog(@"Message successfully sent.");
                handler(resultDict,NO,@"Message successfully sent.");
                
            }
            else
            {
                //OK
                NSLog(@"Message not sent.");
                handler(err,YES,[resultDict valueForKey:@"error"]);
            }
        }
    }];
}


-(void) fetchAccountDetailsFromServerWithUDID:(NSString *)strUDID WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strFetchAccountDetailsURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641479";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token": strUDID, @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // close the form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    /*NSString *postString = [NSString stringWithFormat:@"unique_token=%@",strUDID];
    NSLog(@"postString: %@",postString);
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];*/
    
    
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
            
            if ([[resultDict valueForKey:@"status"] boolValue]==false)
            {
                //Error
                NSLog(@"Account Details not recieved.");
                handler(err,YES,@"Account Details not recieved.");
            }
            else
            {
                //OK
                NSLog(@"Successfully Recieved.");
                handler([resultDict valueForKey:@"error"],NO,@"Successfully Recieved.");
            }
        }
    }];
}


-(void) fetchPushNotificationFromServerWithPushToken:(NSString *)pushToken UDID:(NSString*)strUDID WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strRegistrationPushNotificationURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641479";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"registration_id": pushToken, @"unique_token": strUDID, @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
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
            NSLog(@"resultDict for notification Details: %@",resultDict);
            
            handler(err,NO,@"Push Notifcation for Registration sent.");
        }
    }];
}


-(void) fetchSubscriptionDateWithUDID:(NSString *)strUDID WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strFetchSubsciptionURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641479";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token": strUDID, @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
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
            NSLog(@"resultDict for Subscription Details: %@",resultDict);
            
            if ([[resultDict valueForKey:@"status"] boolValue]==false)
            {
                //Error
                NSLog(@"Subscription Details not recieved.");
                handler(err,YES,@"Subscription Details not recieved.");
            }
            else
            {
                //OK
                NSLog(@"Subscription Recieved.");
                handler(resultDict ,NO,@"Successfully Recieved.");
            }
        }
    }];
}

-(void) createSubscriptionWithUDID:(NSString *)strUDID PurchaseTime:(NSString *)purchaseTime PurchaseState:(NSString *)purchaseState WithCompletionHandler:(WebServiceCompletionHandler)handler
{
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HeyBaseURL,self.strCreateRenewSubsciptionURL]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"hey" forHTTPHeaderField:@"Authorization"];
    [request addValue:@"appsbee" forHTTPHeaderField:@"companyID"];
    
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641479";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"unique_token"     : strUDID,
                             @"purchase_time"    : purchaseTime,
                             @"purchase_state"   : purchaseState,
                             @"platform" : @"iOS"};
    
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
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
            NSLog(@"resultDict for Subscription registration: %@",resultDict);
            
            if ([[resultDict valueForKey:@"status"] boolValue]==false)
            {
                //Error
                handler(err,YES,@"Not Subscribed.");
            }
            else
            {
                //OK
                handler(resultDict,NO,@"Subscribed.");
            }
        }
    }];
}


@end
