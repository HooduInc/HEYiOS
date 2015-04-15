//
//  TPUtlis.h
//  TrivPals
//
//  Created by Sayan on 14/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBDirectory : NSObject

+ (NSString *) applicationDocumentsDirectory;
+ (NSString *) applicationLibraryDirectory;
+ (BOOL) createDirectoryAtPath:(NSString *)path withInterMediateDirectory:(BOOL)isIntermediateDirectory;
+ (NSString *) tempFilePathForDir:(NSString *)dirName;
+ (BOOL) fileExistsAtPath:(NSString *)path ;
+ (BOOL) deleteFileAtPath:(NSString *)filepath;
+ (BOOL) writeContent:(NSData *)fileContent ToFile:(NSString *)fileName andPath:(NSString *)filePath ;
+ (void)clearSubviewsfromView:(UIView *)view;
+ (NSString *)getTempFilePath;
+ (NSString *)getDirectoryAtPath:(NSString *)path withInterMediateDirectory:(BOOL)isIntermediateDirectory;

@end

