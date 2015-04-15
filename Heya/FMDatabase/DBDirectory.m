//
//  TPUtlis.m
//  TrivPals
//
//  Created by Sayan on 14/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBDirectory.h"

@implementation DBDirectory

//returns Application document directory path
+ (NSString *) applicationDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//return directory path if exixts else create directory and return file path
+ (NSString *)getDirectoryAtPath:(NSString *)path withInterMediateDirectory:(BOOL)isIntermediateDirectory
{
    if ([DBDirectory fileExistsAtPath:path]) 
    {
        return path;
    }
    BOOL bFileCreated;
    bFileCreated=[[NSFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:isIntermediateDirectory
                                                            attributes:nil
                                                                 error:NULL];
    if(bFileCreated) return path;
    else return nil;
}


//returns Application document directory path
+ (NSString *) applicationLibraryDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString *)getTempFilePath
{
    return NSTemporaryDirectory();
}


//crate diretctory at path if created return sucess else false

+ (BOOL) createDirectoryAtPath:(NSString *)path withInterMediateDirectory:(BOOL)isIntermediateDirectory{
    //NSLog(@"NEW DIR PATH : %@",path);
    if ([self fileExistsAtPath:path]) {
        return YES;
    }
    return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                     withIntermediateDirectories:isIntermediateDirectory
                                                      attributes:nil
                                                           error:NULL];
}
//returns temp directory path
+ (NSString *) tempFilePathForDir:(NSString *)dirName{
    //[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:dirName];
}

+ (BOOL) fileExistsAtPath:(NSString *)path {
    BOOL directory;
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory];
}

//write file 

+ (BOOL) writeContent:(NSData *)fileContent ToFile:(NSString *)fileName andPath:(NSString *)filePath {
    NSString *appendeFilePath = [NSString stringWithFormat:@"%@/%@",filePath,fileName];
    //NSLog(@"PATH : %@",appendeFilePath);
    NSError *error = nil;
    if ([[self class] fileExistsAtPath:filePath ]) {
        if ([[self class] fileExistsAtPath:appendeFilePath]) {
            if ([[self class] deleteFileAtPath:appendeFilePath ]) {
                NSLog(@"File Deleted Successfully");
            }
            else{
                NSLog(@"File Not Deleted");
            }
            
        }
        return [[NSFileManager defaultManager] createFileAtPath:appendeFilePath contents:fileContent attributes:nil]; //[fileContent AES256EncryptWithKey:AES256_KEY]
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    return [[NSFileManager defaultManager] createFileAtPath:appendeFilePath contents:fileContent  attributes:nil]; //[fileContent AES256EncryptWithKey:AES256_KEY]
}


//delete file

+ (BOOL) deleteFileAtPath:(NSString *)filepath{
    NSError *err = nil;
    if ([[self class] fileExistsAtPath:filepath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:&err];
    }
    else {
        return NO;
    }
    if (err) {
        return NO;
    }
    return YES;
}

//clear subviews

+ (void)clearSubviewsfromView:(UIView *)view{
    for(UIView *subview in [view subviews]){
        [subview removeFromSuperview];
    }
}


@end

