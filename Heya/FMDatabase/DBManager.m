//
//  DBManager.m
//  iCompliance
//
//  Created by Boudhayan Biswas on 5/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DBManager.h"
#import "DBDirectory.h"

#import "ModelMenu.h"
#import "ModelSubMenu.h"

#import "ModelPickListMenu.h"
#import "ModelPickListSubMenu.h"
#import "ModelUserProfile.h"
#import "ModelFevorite.h"
#import "ModelGroup.h"
#import "ModelGroupMembers.h"
#import "ModelMessageSend.h"
#import "ModelSubscription.h"

@implementation DBManager

#pragma mark
#pragma mark Database Initialization
#pragma mark

+ (NSString *)getDBPath
{
    NSString *dbPath=[DBDirectory applicationDocumentsDirectory];
    dbPath=[dbPath stringByAppendingPathComponent:DATABASE_FILE_PATH];
    dbPath=[DBDirectory getDirectoryAtPath:dbPath withInterMediateDirectory:NO];
    dbPath=[dbPath stringByAppendingPathComponent:DATABASE_NAME];
    
    return dbPath;
}

+ (FMDatabase *)getDatabase
{
    FMDatabase *database = [FMDatabase databaseWithPath:[DBManager getDBPath]];
    if([database open]) return database;
    else return nil;
}


#pragma mark - Search if database exists at that path else copy it there from application bundle

+ (void) checkAndCreateDatabaseAtPath:(NSString *)databasePath
{
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:databasePath];
	if(success) return;
    
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	//[fileManager release];
}


#pragma mark
#pragma mark Menu
#pragma mark


+ (NSMutableArray*)fetchAllMenu
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM menulist ORDER BY menuOrder"];
            
            //NSLog(@"Executed Menu Query: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"Executed successfully....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelMenu *obj = [[ModelMenu alloc] init];
                    
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strMenuPageNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    obj.arrSubMenu=[DBManager fetchSubmenuWithmenuIdUpdated:obj.strMenuId];
                    obj.isSubMenuOpen=NO;
                    obj.isShowSaveBtn=NO;
                    obj.iscellAddDelBtnPressed=NO;
                    [arr addObject:obj];
                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}

+ (NSMutableArray*)fetchMenuForPageNo:(NSInteger)menuPageNo
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM menulist where menuPageNo=%ld ORDER BY menuOrder",(long)menuPageNo];
            
            //NSLog(@"Executed Menu Query: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"Executed successfully....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelMenu *obj = [[ModelMenu alloc] init];
                    
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strMenuPageNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    obj.arrSubMenu=[DBManager fetchSubmenuWithmenuIdUpdated:obj.strMenuId];
                    obj.isSubMenuOpen=NO;
                    obj.isShowSaveBtn=NO;
                    obj.iscellAddDelBtnPressed=NO;
                    [arr addObject:obj];
                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}


+(void) updatemenuWithMenuId:(NSString*)strId withMenuTitle:(NSString*)menuText
{
    
    if([menuText containsString:@"'"])
        menuText= [menuText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            if([menuText containsString:@"'"])
                menuText= [menuText stringByReplacingOccurrencesOfString:@"\'" withString:@"`"];
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set menuname ='%@'where  menuId ='%@'",menuText,strId];
            NSLog(@"Update Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Updation Successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
                //if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
                NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
}

+(void) updatemenuWithMenuId:(NSString*)menuId withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set %@ ='%@' where  menuId ='%@'",tableColoumName,tableColoumValue,menuId];
            NSLog(@"Update Menu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                /*if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
                 NSLog(@"SQL Error: %s",sqlite3_errmsg(database));*/
                
                NSLog(@"Updation Successful....");
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
}

+(BOOL) checkmenuWithMenuText:(NSString*)tableColoumValue withTableColoum:(NSString*)tableColoumName
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM menulist  where %@ ='%@'",tableColoumName,tableColoumValue];
    NSLog(@"Select Querystring: %@", stm);
    
    BOOL recordExist = [self recordExistOrNot:stm];
    NSLog(@"recordExist: %d",recordExist);
    
    if(recordExist)
        return true;
    else
        return false;
}

+(void) updateMenuOrderWithMenuId:(NSString*)menuId withMenuOrder:(NSString*)menuOrder
{
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set menuOrder ='%@' where menuId ='%@' ",menuOrder,menuId];
            NSLog(@"MenuUpdate for menuOrder Query: %@", stm);
            
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"MenuOrderSource Updated successfully....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
}

+(void) updateMenuOrderWithMenuId:(NSString*)menuIdSource withMenuOrder:(NSString*)menuOrderSource withMenuIdDestination:(NSString*)menuIdDestination withMenuOrderDestination:(NSString*)menuOrderDestination
{
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE menulist Set menuOrder ='%@' where menuId ='%@' ",menuOrderDestination,menuIdSource];
            NSLog(@"MenuUpdate for sourcemenu Query: %@", stm);
            
            NSString *stmDest = [NSString stringWithFormat:@"UPDATE menulist Set menuOrder ='%@' where menuId ='%@' ",menuOrderSource,menuIdDestination];
            NSLog(@"MenuUpdate for destinationmenu Query: %@", stmDest);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"MenuOrderSource Updated successfully....");
                
                const char *sqlQuerryDest= [stmDest UTF8String];
                sqlite3_stmt *querryStatementDest;
                if(sqlite3_prepare_v2(database, sqlQuerryDest, -1, &querryStatementDest, NULL)==SQLITE_OK)
                {
                    NSLog(@"MenuOrderDestination Updated successfully....");
                    
                    if(SQLITE_DONE != sqlite3_step(querryStatementDest))
                    {
                        NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    }
                    sqlite3_reset(querryStatementDest);
                }
                
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
}


#pragma mark
#pragma mark Submenu
#pragma mark

+ (NSMutableArray*)fetchTotalSubmenu
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT DISTINCT menuId FROM submenulist ORDER BY menuId"];
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelMenu *obj = [[ModelMenu alloc] init];
                    
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strMenuPageNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    obj.arrSubMenu=[DBManager fetchSubmenuWithmenuIdUpdated:obj.strMenuId];
                    obj.isSubMenuOpen=NO;
                    obj.isShowSaveBtn=NO;
                    obj.iscellAddDelBtnPressed=NO;
                    
                    [arr addObject:obj];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}


+ (NSMutableArray*) fetchSubmenuWithmenuIdUpdated:(NSString*)menuId
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where  menuId ='%@' ORDER BY submenuOrder",menuId];
            //NSLog(@"Executed QUery: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelSubMenu *obj = [[ModelSubMenu alloc] init];
                    obj.strMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strSubMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strSubMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strSubMenuColor=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    obj.strSubMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    [arr addObject:obj];
                    
                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    
    
    return arr;
}


+ (NSMutableArray*) fetchSubmenuWithmenuId:(NSString*)menuId
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where  menuId ='%@' ORDER BY submenuOrder",menuId];
            //NSLog(@"Executed QUery: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    NSMutableDictionary *subMenuDict = [[NSMutableDictionary alloc] init];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)] forKey:@"MenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] forKey:@"SubmenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)] forKey:@"SubMenuName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)] forKey:@"ColourName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)] forKey:@"SubMenuOrder"];
                    [arr addObject:subMenuDict];

                }
                sqlite3_finalize(querryStatement);
                
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }

    
    
    return arr;
}


+ (NSMutableArray*) fetchSubmenuWithmenuId:(NSString*)menuId subMenuID:(NSString*)subMenuID
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where  menuId ='%@' AND submenuId='%@' ORDER BY submenuOrder" ,menuId,subMenuID];
            //NSLog(@"Executed SUbmenu Color QUery: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                //NSLog(@"conversion successful for SUbmenu Color QUery....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    NSMutableDictionary *subMenuDict = [[NSMutableDictionary alloc] init];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)] forKey:@"MenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] forKey:@"SubmenuId"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)] forKey:@"SubMenuName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)] forKey:@"ColourName"];
                    [subMenuDict  setValue: [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)] forKey:@"SubMenuOrder"];
                    [arr addObject:subMenuDict];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}


+(void)addSubMenuWithMenuId:(NSString *)strMenuId withSubMenuText:(NSString *)strSubMenuText
{
    
    if([strSubMenuText containsString:@"'"])
        strSubMenuText= [strSubMenuText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            NSMutableArray *submenuexists=[[NSMutableArray alloc] init];
            
            submenuexists=[DBManager fetchSubmenuWithmenuIdUpdated:strMenuId];
            NSLog(@"%ld",(long)submenuexists.count);
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm =
                [NSString stringWithFormat:@"INSERT INTO submenulist(menuId,submenuId,submenuname,colorName,submenuOrder) values(\"%@\", \"%ld\", \"%@\", \"%@\",\"%ld\")",strMenuId,(long)submenuexists.count+1, strSubMenuText, @"",(long)submenuexists.count+1];
                
                NSLog(@"submenu Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"submenu insertion successful....");
                    
                    if(sqlite3_step(querryStatement)!=SQLITE_DONE)
                    {
                        NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    }
                    sqlite3_reset(querryStatement);
                }
                else {
                    NSLog(@"error while inserting submenu....");
                }

                sqlite3_close(database);
            }
        }
}


+(void) deleteAllSubMenuWithMenuId:(NSString *)strMenuId
{
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =
            [NSString stringWithFormat:@"Delete from submenulist where menuId='%@'",strMenuId];
            
            NSLog(@"All Submenu Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"All submenus deleted....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while deleting submenus....");
            }
            
            sqlite3_close(database);
        }
    }
}


+(void)deleteSubMenuWithMenuId:(NSString *)strMenuId withSubMenuId:(NSString *)strSubMenuID
{
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =
            [NSString stringWithFormat:@"Delete from submenulist where menuId='%@' AND submenuId='%@'",strMenuId,strSubMenuID];
            
            
            NSLog(@"Submenu Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"submenu deleted....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while deleting submenu....");
            }
            
            sqlite3_close(database);
        }
    }
}



+(BOOL) checkSubmenuWithMenuText:(NSString*)tableColoumValue withTableColoum:(NSString*)tableColoumName
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM submenulist  where %@ ='%@'",tableColoumName,tableColoumValue];
    NSLog(@"Select Querystring: %@", stm);
    
    BOOL recordExist = [self recordExistOrNot:stm];
    NSLog(@"recordExist: %d",recordExist);
    
    if(recordExist)
        return true;
    else
        return false;
}


+(void) updatesubnemuWithMenuId:(NSString*)str withsubmenutitle:(NSString*)submenu_txt
{
    if([submenu_txt containsString:@"'"])
        submenu_txt= [submenu_txt stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSArray *arr = [str componentsSeparatedByString:@","];
    
    NSString *menuId = [arr objectAtIndex:0];
    NSString *submenuId = [arr objectAtIndex:1];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set submenuname ='%@'where  menuId ='%@' and submenuId ='%@'",submenu_txt,menuId,submenuId];
            NSLog(@"Update Querystring for submenu: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Updation Successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    // [self fetchmenu];
    
    
}


+(void) updateSubmenuWithMenuId:(NSString*)menuId subMenuID:(NSString*)subMenuID withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm= [NSString stringWithFormat:@"UPDATE submenulist Set %@ ='%@' where menuId ='%@' AND submenuId='%@'",tableColoumName,tableColoumValue,menuId,subMenuID];
            NSLog(@"Update submenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
}



+(void) updateSubMenuTableMenuId:(NSString*)MenuID withcolorName:(NSString*)subMenuColorName
{
    if([subMenuColorName containsString:@"'"])
        subMenuColorName= [subMenuColorName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set colorName ='%@' where menuId ='%@'",subMenuColorName,MenuID];
            NSLog(@"Update Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"ColorMenu Updated successfully....");
                
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                /*if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK) NSLog(@"SQL Error: %s",sqlite3_errmsg(database));*/
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
}


+(void) updateSubMenuColorWithMenuId:(NSString*)MenuID subMenuID:(NSString*)subMenuID withcolorName:(NSString*)subMenuColorName
{
    if([subMenuColorName containsString:@"'"])
        subMenuColorName= [subMenuColorName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            //NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set colorName ='%@' where menuId ='%@' AND submenuId='%@' ",subMenuColorName,MenuID,subMenuID];
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE submenulist Set colorName ='%@' where menuId ='%@' ",subMenuColorName,MenuID];
            NSLog(@"SubMenuUpdate Query: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"ColorMenu Updated successfully....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement))
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
            }
            else
            {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
}


#pragma mark
#pragma mark Favorite
#pragma mark

/*+(NSMutableArray*)insertToFavoriteTable:(NSMutableArray*)fevoriteArray
{
    long long lastInsertedId;
    NSMutableArray *favArray=[[NSMutableArray alloc] init];
    ModelFevorite *fevObj=[fevoriteArray objectAtIndex:0];

    NSString *query  = [NSString stringWithFormat:@"select * from favoriteList where mobNumber = '%@'",fevObj.strMobNumber];
    
    NSLog(@"query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];
    
    if (!recordExist)
    {
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm = [NSString stringWithFormat:@"INSERT INTO favoriteList(firstName, lastName, mobNumber, homeNumber, profileImage) values(\"%@\", \"%@\", \"%@\",\"%@\", \"%@\") ",fevObj.strFirstName,fevObj.strLastName,fevObj.strMobNumber,fevObj.strHomeNumber,fevObj.strProfileImage];
                
                NSLog(@"Favorite Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"Favorite Insertion successful....");

                    bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                    
                    if(!executeQueryResults)
                    {
                        NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    }
                    else
                    {
                        int affectedRows = sqlite3_changes(database);
                        NSLog(@"affectedRows: %d",affectedRows);
                        
                        lastInsertedId=sqlite3_last_insert_rowid(database);
                        
                        NSLog(@"lastInsertedId: %lld",lastInsertedId);
                        
                        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
                        {
                            NSString *stmUpdate = [NSString stringWithFormat:@"UPDATE favoriteList SET favouriteOrder='%d' where fevoriteId ='%d'",(int)lastInsertedId,(int)lastInsertedId];
                            
                            NSLog(@"Favorite Update Querystring: %@", stmUpdate);
                            const char *sqlQuerryTwo= [stmUpdate UTF8String];
                            sqlite3_stmt *querryStatementTwo;
                            if(sqlite3_prepare_v2(database, sqlQuerryTwo, -1, &querryStatementTwo, NULL)==SQLITE_OK)
                            {
                                NSLog(@"Favorite Updation successful....");
                                
                                favArray=[DBManager fetchFavorite];
                                
                                bool executeQueryResultsTwo = sqlite3_step(querryStatementTwo) == SQLITE_DONE;
                                
                                if(!executeQueryResultsTwo)
                                {
                                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                                }
                                
                                sqlite3_reset(querryStatementTwo);
                            }
                            else
                            {
                                NSLog(@"error while Updating Favourite contacts....");
                            }
                        
                        }
                    }
                    sqlite3_reset(querryStatement);
                }
                else
                {
                    NSLog(@"error while inserting Favourite contacts....");
                }
                sqlite3_close(database);
            }
        }
        
        
        return favArray;
    }
    else
    {
        favArray=[DBManager fetchFavorite];
        return favArray;
    }
}*/

+(long long)insertToFavoriteTable:(NSMutableArray*)fevoriteArray
{
    long long lastInsertedId=0;
    ModelFevorite *fevObj=[fevoriteArray objectAtIndex:0];
    
    NSString *query  = [NSString stringWithFormat:@"select * from favoriteList where mobNumber = '%@'",fevObj.strMobNumber];
    
    NSLog(@"MobileNUm Exists or not query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];
    
    if (!recordExist)
    {
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm = [NSString stringWithFormat:@"INSERT INTO favoriteList(firstName, lastName, mobNumber, homeNumber, profileImage) values(\"%@\", \"%@\", \"%@\",\"%@\", \"%@\") ",fevObj.strFirstName,fevObj.strLastName,fevObj.strMobNumber,fevObj.strHomeNumber,fevObj.strProfileImage];
                
                NSLog(@"Favorite Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"Favorite Insertion successful....");
                    
                    bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                    
                    if(!executeQueryResults)
                    {
                        NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    }
                    else
                    {
                        int affectedRows = sqlite3_changes(database);
                        NSLog(@"affectedRows: %d",affectedRows);
                        
                        lastInsertedId=sqlite3_last_insert_rowid(database);
                        
                        NSLog(@"lastInsertedId: %lld",lastInsertedId);
                        
                        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
                        {
                            NSString *stmUpdate = [NSString stringWithFormat:@"UPDATE favoriteList SET favouriteOrder='%d' where fevoriteId ='%d'",(int)lastInsertedId,(int)lastInsertedId];
                            
                            NSLog(@"Favorite Update Querystring: %@", stmUpdate);
                            const char *sqlQuerryTwo= [stmUpdate UTF8String];
                            sqlite3_stmt *querryStatementTwo;
                            if(sqlite3_prepare_v2(database, sqlQuerryTwo, -1, &querryStatementTwo, NULL)==SQLITE_OK)
                            {
                                NSLog(@"Favorite Updation successful....");
                                bool executeQueryResultsTwo = sqlite3_step(querryStatementTwo) == SQLITE_DONE;
                                
                                if(!executeQueryResultsTwo)
                                {
                                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                                }
                                
                                sqlite3_reset(querryStatementTwo);
                            }
                            else
                            {
                                NSLog(@"error while Updating Favourite contacts....");
                            }
                            
                        }
                    }
                    sqlite3_reset(querryStatement);
                }
                else
                {
                    NSLog(@"error while inserting Favourite contacts....");
                }
                sqlite3_close(database);
            }
        }
    }
    return  lastInsertedId;
}


+(void) UpdateFavoriteWithId:(NSString *)favoriteId withTableColoum:(NSString *)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE favoriteList Set %@ ='%@' where  fevoriteId ='%@'",tableColoumName,tableColoumValue,favoriteId];
            NSLog(@"Update Favorite Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                if(sqlite3_step(querryStatement)!=SQLITE_DONE){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                /*if (sqlite3_exec(database, "COMMIT TRANSACTION", 0, 0, 0) != SQLITE_OK)
                 NSLog(@"SQL Error: %s",sqlite3_errmsg(database));*/
                
                NSLog(@"Favorite Updation Successful....");
            }
            else
            {
                NSLog(@"error while favorite updation....");
            }
            sqlite3_close(database);
        }
    }
    
}


+(BOOL) UpdateFavoriteWithId:(NSString *)favoriteId  withColoumValue:(NSString*)tableColoumValue
{
    BOOL isUpdated;
    NSArray *fullNameArray=[tableColoumValue componentsSeparatedByString:@" "];
    NSString *strFirstName, *strLastName;
    
    if(fullNameArray.count==1)
    {
        strFirstName=[fullNameArray objectAtIndex:0];
        strLastName=@"";
    }
    else if (fullNameArray.count>1)
    {
        strFirstName=[fullNameArray objectAtIndex:0];
        strLastName=[fullNameArray objectAtIndex:1];
    }
    
    if([strFirstName containsString:@"'"])
        strFirstName= [strFirstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    if([strLastName containsString:@"'"])
        strLastName= [strLastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE favoriteList Set firstName='%@', lastName ='%@' where  fevoriteId ='%@'",strFirstName,strLastName,favoriteId];
            NSLog(@"Update Favorite Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                isUpdated=YES;
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isUpdated=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
                NSLog(@"Favorite Updation Successful....");
            }
            else
            {
                NSLog(@"error while favorite updation....");
            }
            sqlite3_close(database);
        }
    }
    return isUpdated;
}


+(BOOL) deleteFavoriteDetailsWithFavoriteId:(NSString *)favoriteId
{
    BOOL isDeleted;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from favoriteList where fevoriteId='%@'",favoriteId];
            
            NSLog(@"Favorite Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Favorite Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else {
                NSLog(@"error while deleting favorite....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}


+(NSMutableArray*)fetchFavorite
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM favoriteList ORDER BY favouriteOrder"];
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful for favourites....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelFevorite *favObj = [[ModelFevorite alloc]init];
                    
                    favObj.strFevoriteId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    
                    favObj.strFirstName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    favObj.strLastName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    favObj.strMobNumber=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    favObj.strHomeNumber=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    favObj.strProfileImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 5)] ;
                    favObj.strFavouriteOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 6)] ;
                    
                    [arr addObject:favObj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion for favorites....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

+(NSMutableArray*)fetchFavoriteWithMobileNumber:(NSString *)Mob
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM favoriteList where mobNumber='%@'",Mob];
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelFevorite *favObj = [[ModelFevorite alloc]init];
                    
                    favObj.strFevoriteId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    
                    favObj.strFirstName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    favObj.strLastName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    favObj.strMobNumber=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    favObj.strHomeNumber=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    favObj.strProfileImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 5)] ;
                    favObj.strFavouriteOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 6)] ;
                    
                    [arr addObject:favObj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion for favorites....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

+(BOOL)checkMobileNumExistsinFavoriteTable:(NSString*)MobileNum
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM favoriteList where mobNumber='%@'",MobileNum];
   return [DBManager recordExistOrNot:stm];
}


#pragma mark
#pragma mark Group
#pragma mark

+(NSMutableArray*)saveGroupNameToTable:(NSString*)groupName
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSString *query  = [NSString stringWithFormat:@"select * from groupList where groupName = '%@'",groupName];
    
    NSLog(@"query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];
    
    if (!recordExist) {
        FMDatabase *database=[DBManager getDatabase];
        if(database){
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm = [NSString stringWithFormat:@"INSERT INTO groupList(groupName) values(\"%@\") ",groupName];
                
                NSLog(@"groupList Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"conversion successful....");
                    
                    
                    if(SQLITE_DONE != sqlite3_step(querryStatement))
                    {
                        NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    }
                    sqlite3_reset(querryStatement);
                }
                else {
                    NSLog(@"error while inserting GroupList contacts....");
                }
                
                
                NSString *stm1 = [NSString stringWithFormat:@"SELECT * FROM groupList"];
                
                const char *sqlQuerry1= [stm1 UTF8String];
                sqlite3_stmt *querryStatement1;
                if(sqlite3_prepare_v2(database, sqlQuerry1, -1, &querryStatement1, NULL)==SQLITE_OK)
                {
                    NSLog(@"Select conversion successful....");
                    while (sqlite3_step(querryStatement1)==SQLITE_ROW)
                    {
                        //
                        NSMutableDictionary *dik = [[NSMutableDictionary alloc]init];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 0)] forKey:@"groupId"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 1)] forKey:@"groupName"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 2)] forKey:@"groupMembers"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 3)] forKey:@"groupOrder"];
                        
                        [arr addObject:dik];
                    }
                    sqlite3_finalize(querryStatement);
                }
                else {
                    NSLog(@"error while conversion....");
                }
                
                
                
                sqlite3_close(database);
            }
        }
        
        
        return arr;
    }
    else{
        
        FMDatabase *database=[DBManager getDatabase];
        if(database){
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm1 = [NSString stringWithFormat:@"SELECT * FROM groupList"];
                
                const char *sqlQuerry1= [stm1 UTF8String];
                sqlite3_stmt *querryStatement1;
                if(sqlite3_prepare_v2(database, sqlQuerry1, -1, &querryStatement1, NULL)==SQLITE_OK)
                {
                    NSLog(@"Select conversion successful....");
                    while (sqlite3_step(querryStatement1)==SQLITE_ROW)
                    {
                        //
                        NSMutableDictionary *dik = [[NSMutableDictionary alloc]init];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 0)] forKey:@"groupName"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 1)] forKey:@"groupMembers"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 2)] forKey:@"groupMembers"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 3)] forKey:@"groupOrder"];
                        
                        [arr addObject:dik];
                    }
                    sqlite3_finalize(querryStatement1);
                }
                else {
                    NSLog(@"error while conversion....");
                }
                sqlite3_close(database);
            }
        }
        return arr;
    }

    
}

+(NSMutableArray*)saveGroupMembersToGroup:(NSMutableDictionary *)infoGroupMember
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSString *groupId = [infoGroupMember valueForKey:@"groupId"];
    
    NSString *fnm = [infoGroupMember valueForKey:@"firstName"];
    NSString *lnm = [infoGroupMember valueForKey:@"lastName"];
    NSString *mob = [infoGroupMember valueForKey:@"mobileNumber"];
    NSString *homeph = [infoGroupMember valueForKey:@"homeNumber"];
    NSString *profileImage = [infoGroupMember valueForKey:@"image"];
    
    NSString *query  = [NSString stringWithFormat:@"select * from groupMembers where mob = '%@'",mob];
    
    NSLog(@"query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];
    
    if (!recordExist) {
        FMDatabase *database=[DBManager getDatabase];
        if(database){
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm =
                [NSString stringWithFormat:@"INSERT INTO groupMembers(FstName, LstNmae, Mob, HomePh, profileimage,groupId) values(\"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\") ",fnm,lnm,mob,homeph,profileImage,groupId];
                
                NSLog(@"Favorite Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"conversion successful....");
                    
                    
                    if(SQLITE_DONE != sqlite3_step(querryStatement))
                    {
                        NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    }
                    sqlite3_reset(querryStatement);
                }
                else {
                    NSLog(@"error while inserting GroupMembers contacts....");
                }
                
                
                NSString *stm1 = [NSString stringWithFormat:@"SELECT * FROM groupMembers Where groupId='%@'", groupId];
                
                const char *sqlQuerry1= [stm1 UTF8String];
                sqlite3_stmt *querryStatement1;
                if(sqlite3_prepare_v2(database, sqlQuerry1, -1, &querryStatement1, NULL)==SQLITE_OK)
                {
                    NSLog(@"Select conversion successful....");
                    while (sqlite3_step(querryStatement1)==SQLITE_ROW)
                    {
                        //
                        NSMutableDictionary *dik = [[NSMutableDictionary alloc]init];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 0)] forKey:@"firstName"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 1)] forKey:@"lastName"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 2)] forKey:@"mobileNumber"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 3)] forKey:@"homeNumber"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 4)] forKey:@"image"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 5)] forKey:@"groupMemberOrder"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement1, 6)] forKey:@"groupId"];
                        [arr addObject:dik];
                    }
                    sqlite3_finalize(querryStatement1);
                }
                else {
                    NSLog(@"error while conversion....");
                }
                
                sqlite3_close(database);
            }
        }
        
        
        return arr;
    }
    else
    {
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm = [NSString stringWithFormat:@"SELECT * FROM groupMembers Where groupId='%@'", groupId];
                
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"Fetch GroupMembers conversion successful....");
                    while (sqlite3_step(querryStatement)==SQLITE_ROW)
                    {
                        NSMutableDictionary *dik = [[NSMutableDictionary alloc]init];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)] forKey:@"firstName"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] forKey:@"lastName"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)] forKey:@"mobileNumber"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)] forKey:@"homeNumber"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)] forKey:@"image"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 5)] forKey:@"groupMemberOrder"];
                        [dik setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 6)] forKey:@"groupId"];
                        [arr addObject:dik];
                        
                    }
                    sqlite3_finalize(querryStatement);
                }
                else {
                    NSLog(@"error while conversion....");
                }
                sqlite3_close(database);
            }
        }
        return arr;
    }
}

+(NSMutableArray*)fetchDetailsFromGroup
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM groupList ORDER BY groupOrder"];
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful for groups....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelGroup *objGroup = [[ModelGroup alloc]init];
                    objGroup.strGroupId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    objGroup.strGroupName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] ;
                    objGroup.strGroupOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    
                    [arr addObject:objGroup];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
    
}

+(NSMutableArray*)fetchDataFromGroupWithGroupId:(NSString*)groupId
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM groupList where groupId= '%@'",groupId];
            
            NSLog(@"Select groupList Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelGroup *objGroup = [[ModelGroup alloc]init];
                    objGroup.strGroupId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    objGroup.strGroupName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] ;
                    objGroup.strGroupOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    
                    [arr addObject:objGroup];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

+(NSMutableArray*)fetchGroupMembersWithGroupId:(NSString *)groupId
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM groupMembers where groupId= '%@' ORDER BY memberOrder",groupId];
           
            NSLog(@"Select groupMembers Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelGroupMembers *objMember = [[ModelGroupMembers alloc]init];
                    objMember.strMemberId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    objMember.strGroupId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    objMember.strFirstName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    objMember.strLastName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    objMember.strMobileNumber=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    objMember.strHomePhone=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 5)];
                    objMember.strProfileImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 6)];
                    objMember.strMemberOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 7)];
                    
                    
                    [arr addObject:objMember];

                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
    
    
    
}



+(long long) insertGroup:(NSString*)groupName
{
    long long insertID=0;
    NSString *query  = [NSString stringWithFormat:@"select * from groupList where groupName = '%@'",groupName];
    
    NSLog(@"groupList Select Query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];
    
    if (!recordExist)
    {
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm = [NSString stringWithFormat:@"INSERT INTO groupList(groupName) values(\"%@\")",groupName];
                
                NSLog(@"groupList Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"conversion successful....");
                    
                    bool executeQueryResults= sqlite3_step(querryStatement)==SQLITE_DONE;
                    
                    if(!executeQueryResults)
                    {
                        NSAssert1(0, @"error while inserting GroupList contacts '%s'", sqlite3_errmsg(database));
                    }
                    else
                    {
                        int affectedRows = sqlite3_changes(database);
                        NSLog(@"affectedRows: %d",affectedRows);
                        
                        insertID=sqlite3_last_insert_rowid(database);
                        
                        NSLog(@"lastInsertedId: %lld",insertID);
                        
                        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
                        {
                            NSString *stmUpdate = [NSString stringWithFormat:@"UPDATE groupList SET groupOrder='%d' where groupId ='%d'",(int)insertID,(int)insertID];
                            
                            NSLog(@"groupOrder Update Querystring: %@", stmUpdate);
                            const char *sqlQuerryTwo= [stmUpdate UTF8String];
                            sqlite3_stmt *querryStatementTwo;
                            if(sqlite3_prepare_v2(database, sqlQuerryTwo, -1, &querryStatementTwo, NULL)==SQLITE_OK)
                            {
                                NSLog(@"groupOrder Updation successful....");
                                
                                bool executeQueryResultsTwo = sqlite3_step(querryStatementTwo) == SQLITE_DONE;
                                
                                if(!executeQueryResultsTwo)
                                {
                                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                                }
                                
                                sqlite3_reset(querryStatementTwo);
                            }
                            else
                            {
                                NSLog(@"error while Updating groupMembers contacts....");
                            }
                            
                        }
                    }
                    sqlite3_reset(querryStatement);
                }
                else
                {
                    NSLog(@"error while inserting GroupList contacts....");
                }
                sqlite3_close(database);
            }
        }
    }
    return  insertID;
}



+(BOOL) updateGroupNameWithGroupId:(NSString *)groupId withGroupName:(NSString *)groupName
{
    BOOL isUpdated;
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE groupList Set groupName='%@' where  groupId ='%@'",groupName,groupId];
            NSLog(@"Update Group Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                isUpdated=YES;
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isUpdated=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
                NSLog(@"Group Updation Successful....");
            }
            else
            {
                NSLog(@"error while Group updation....");
            }
            sqlite3_close(database);
        }
    }
    return isUpdated;
}


+(void) updateGroupWithId:(NSString *)groupId withTableColoum:(NSString *)tableColoumName withColoumValue:(NSString *)tableColoumValue
{
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            
            NSString *stm = [NSString stringWithFormat:@"UPDATE groupList Set %@ ='%@' where  groupId ='%@'",tableColoumName,tableColoumValue,groupId];
            NSLog(@"Update Group Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                if(sqlite3_step(querryStatement)!=SQLITE_DONE)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
        
                NSLog(@"Group Updation Successful....");
            }
            else
            {
                NSLog(@"error while Group updation....");
            }
            sqlite3_close(database);
        }
    }
    
}


+(BOOL) deleteGroupWithGroupId:(NSString *)groupId
{
    BOOL isDeleted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from groupList where groupId='%@'",groupId];
            
            NSLog(@"Group Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Group Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while deleting Group....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}

+(BOOL)checkGroupNameExistsinGroupTable:(NSString *)GroupName
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM groupList where groupName='%@'",GroupName];
    return [DBManager recordExistOrNot:stm];
}

+(BOOL)checkGroupMembersExistsinGroupTable:(NSString *)memberMobileNum groupID:(NSString*)groupId
{
    NSString *stm = [NSString stringWithFormat:@"SELECT * FROM groupMembers where mobNumber='%@' AND groupId='%@'",memberMobileNum,groupId];
    NSLog(@"check mobilenum groupMembers Select Query: %@",stm);
    return [DBManager recordExistOrNot:stm];
}

//Member
+(long long) insertGroupMember:(NSMutableArray*)groupMemberArray
{
    long long lastInsertedId=0;
    ModelGroupMembers *memeberObj=[groupMemberArray objectAtIndex:0];
    
    NSString *query  = [NSString stringWithFormat:@"select * from groupMembers where mobNumber = '%@'",memeberObj.strMobileNumber];
    
    NSLog(@"query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];

    if (!recordExist)
    {
        FMDatabase *database=[DBManager getDatabase];
        if(database)
        {
            sqlite3 *database;
            NSString *dbpath = [DBManager getDBPath];
            const char* dbPath=[dbpath UTF8String];
            
            if(sqlite3_open(dbPath, &database)==SQLITE_OK)
            {
                NSString *stm = [NSString stringWithFormat:@"INSERT INTO groupMembers(groupId,firstName,lastName, mobNumber, homePhone, profileImage) values(\"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\") ",memeberObj.strGroupId,memeberObj.strFirstName,memeberObj.strLastName,memeberObj.strMobileNumber,memeberObj.strHomePhone,memeberObj.strProfileImage];
                
                NSLog(@"groupMembers Insertion Querystring: %@", stm);
                const char *sqlQuerry= [stm UTF8String];
                sqlite3_stmt *querryStatement;
                if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
                {
                    NSLog(@"groupMembers Insertion successful....");
                    
                    bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                    
                    if(!executeQueryResults)
                    {
                        NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    }
                    else
                    {
                        int affectedRows = sqlite3_changes(database);
                        NSLog(@"affectedRows: %d",affectedRows);
                        
                        lastInsertedId=sqlite3_last_insert_rowid(database);
                        
                        NSLog(@"lastInsertedId: %lld",lastInsertedId);
                        
                        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
                        {
                            NSString *stmUpdate = [NSString stringWithFormat:@"UPDATE groupMembers SET memberOrder='%d' where memberId ='%d'",(int)lastInsertedId,(int)lastInsertedId];
                            
                            NSLog(@"groupMembers Update Querystring: %@", stmUpdate);
                            const char *sqlQuerryTwo= [stmUpdate UTF8String];
                            sqlite3_stmt *querryStatementTwo;
                            if(sqlite3_prepare_v2(database, sqlQuerryTwo, -1, &querryStatementTwo, NULL)==SQLITE_OK)
                            {
                                NSLog(@"groupMemberOrder Updation successful....");
                                
                                bool executeQueryResultsTwo = sqlite3_step(querryStatementTwo) == SQLITE_DONE;
                                
                                if(!executeQueryResultsTwo)
                                {
                                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                                }
                                
                                sqlite3_reset(querryStatementTwo);
                            }
                            else
                            {
                                NSLog(@"error while Updating groupMembers contacts....");
                            }
                            
                        }
                    }
                    sqlite3_reset(querryStatement);
                }
                else
                {
                    NSLog(@"error while inserting groupMembers contacts....");
                }
                sqlite3_close(database);
            }
        }
    }
    else
    {
        lastInsertedId=-1;
    }

    return lastInsertedId;
}


+(BOOL) updateGroupMemberNameWithMemberId:(NSString*)memberId withGroupName:(NSString*)memberName
{
    
    BOOL isUpdated=NO;
    NSArray *fullNameArray=[memberName componentsSeparatedByString:@" "];
    
    NSString *strFirstName, *strLastName;
    
    if(fullNameArray.count==1)
    {
        strFirstName=[fullNameArray objectAtIndex:0];
        strLastName=@"";
    }
    else if (fullNameArray.count>1)
    {
        strFirstName=[fullNameArray objectAtIndex:0];
        strLastName=[fullNameArray objectAtIndex:1];
    }
    
    if([strFirstName containsString:@"'"])
        strFirstName= [strFirstName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    if([strLastName containsString:@"'"])
        strLastName= [strLastName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE groupMembers Set firstName ='%@', lastName ='%@' where  memberId ='%@'",strFirstName,strLastName,memberId];
            NSLog(@"Update Favorite Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"groupMember Updation successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isUpdated=NO;
                }
                else
                    isUpdated=YES;
                
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                {
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                }

            }
            else
            {
                NSLog(@"error while groupMember updation....");
            }
            sqlite3_close(database);
        }
    }
    return  isUpdated;
    
}

+(BOOL) deleteGroupMemberWithMemberId:(NSString*)memberId
{
    BOOL isDeleted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from groupMembers where memberId='%@'",memberId];
            
            NSLog(@"GroupMember Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"GroupMember Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while deleting GroupMember....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}

+(BOOL) deleteGroupMemberWithGroupId:(NSString *)groupId
{
    BOOL isDeleted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from groupMembers where groupId='%@'",groupId];
            
            NSLog(@"GroupMember Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"GroupMember Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while deleting GroupMember....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}


#pragma mark
#pragma mark Picklist
#pragma mark

+ (NSMutableArray*)fetchAllPickFromListUpdated
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        
        
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM pickFromListMenu ORDER BY pickMenuOrder"];
            //NSLog(@"FetchAllPickFromList Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelPickListMenu *obj=[[ModelPickListMenu alloc] init];
                    
                    obj.strPickMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    obj.strPickMenuName= [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    obj.strPickImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    obj.strPickMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 3)];
                    obj.arrPickSubMenu=[DBManager fetchPickSubMenuWithPickMenuIdUpdated:obj.strPickMenuId];
                    obj.isSubMenuOpen=NO;
                    [arr addObject:obj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return arr;
}


+ (NSMutableArray*) fetchPickSubMenuWithPickMenuIdUpdated:(NSString *)pickMenuId
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM pickFromListSubMenu where pickMenu ='%@' AND pickText!='' ORDER BY pickOrder",pickMenuId];
            
            //NSLog(@"Executed Query: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelPickListSubMenu *subObj=[[ModelPickListSubMenu alloc] init];
                    
                    subObj.strPickSubMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    subObj.strPickSubMenuName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    subObj.strPickMenuId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    subObj.strPickSubMenuOrder=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    subObj.strPickSubMenuFlag=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 4)];
                    [arr addObject:subObj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

+(void) updatePickSubMenuWithPickId:(NSString *)pickId withTableColoum:(NSString *)tableColoumName withColoumValue:(NSString *)tableColoumValue
{

    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE pickFromListSubMenu Set %@ ='%@' where  pickId ='%@'",tableColoumName,tableColoumValue,pickId];
            
            if ([tableColoumName isEqualToString:@"pickOrder"])
            {
                stm=[NSString stringWithFormat:@"UPDATE pickFromListSubMenu Set %@ ='%d' where  pickId ='%d'",tableColoumName,[tableColoumValue intValue],[pickId intValue]];
            }
            
            NSLog(@"Update picklistsubmenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");

                if(SQLITE_DONE != sqlite3_step(querryStatement)){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            //sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
    
}


+(void) updatePickSubMenuWithPickName:(NSString*)pickName withTableColoum:(NSString*)tableColoumName withColoumValue:(NSString*)tableColoumValue
{
    //NSLog(@"pick Text: %@",tableColoumValue);
    /*NSMutableString *muPickName = [NSMutableString stringWithString:pickName];
    if([muPickName rangeOfString:@"'"].location !=NSNotFound)
    {
        [muPickName insertString:@"'" atIndex:[muPickName rangeOfString:@"'"].location];
        pickName=muPickName;
    }*/
    
    if([tableColoumValue containsString:@"'"])
        tableColoumValue= [tableColoumValue stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE pickFromListSubMenu Set %@ ='%@' where  pickText ='%@'",tableColoumName,tableColoumValue,pickName];
            //NSLog(@"Update picklistsubmenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                
                if(SQLITE_DONE != sqlite3_step(querryStatement)){
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                sqlite3_reset(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
    
}


+(long long) insertPickSubMenu:(NSMutableArray *)pickArray
{
    long long lastInsertedId=0;
    ModelPickListSubMenu *objPickSub=[pickArray objectAtIndex:0];
    
    NSLog(@"Database End PickText: %@",objPickSub.strPickMenuId);
    
    if([objPickSub.strPickSubMenuName containsString:@"'"])
        objPickSub.strPickSubMenuName= [objPickSub.strPickSubMenuName stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"INSERT INTO pickFromListSubMenu(pickText, pickMenu,  displayFlag) values(\"%@\",%d,%d)",objPickSub.strPickSubMenuName, [objPickSub.strPickMenuId intValue], [objPickSub.strPickSubMenuFlag intValue]];
            
            NSLog(@"Insert picklistsubmenu Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Insertion successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                else
                {
                    int affectedRows = sqlite3_changes(database);
                    NSLog(@"affectedRows: %d",affectedRows);
                    
                    lastInsertedId=sqlite3_last_insert_rowid(database);
                    
                    NSLog(@"lastInsertedId: %lld",lastInsertedId);
                    
                    [DBManager updatePickSubMenuWithPickId:[NSString stringWithFormat:@"%lld",lastInsertedId] withTableColoum:@"pickOrder" withColoumValue:[NSString stringWithFormat:@"%lld",lastInsertedId]];
                }
                sqlite3_reset(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_reset(querryStatement);
            sqlite3_close(database);
        }
    }
    return lastInsertedId;
}

+(BOOL) deletePickTextWithSubPickId:(NSString *)subPickId
{
    BOOL isDeleted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from pickFromListSubMenu where pickId='%d'",[subPickId intValue]];
            
            NSLog(@"PickText Delete QueryString: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"PickText Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while deleting PickText....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}


#pragma mark
#pragma mark UserProfile
#pragma mark

+(BOOL) addProfile:(NSMutableArray *)profileArray
{
    BOOL isInserted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
        
        userObj=[profileArray objectAtIndex:0];
        
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"INSERT INTO userProfile(firstName,lastName,heyName,phoneNo,deviceUDID,profileImage,currentTimeStamp,accountCreated) values(\"%@\", \"%@\", \"%@\", \"%@\",  \"%@\", \"%@\", \"%@\", \"%@\")", userObj.strFirstName,userObj.strLastName, userObj.strHeyName, userObj.strPhoneNo, userObj.strDeviceUDID, userObj.strProfileImage, userObj.strCurrentTimeStamp, userObj.strAccountCreated];
            
            NSLog(@"Profile Insertion Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                
                NSLog(@"UserProfile Inserted....");
                isInserted=YES;

                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                    isInserted=NO;
                }
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while inserting profile....");
            }
            
            sqlite3_close(database);
        }
    }
    
    return isInserted;
}

+(BOOL) updateProfile:(NSMutableArray *)profileArray
{
    BOOL isUpdated=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
        
        userObj=[profileArray objectAtIndex:0];
        
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm;
            if (userObj.strHeyName.length>0)
            {
                stm = [NSString stringWithFormat:@"UPDATE userProfile Set firstName ='%@', lastName ='%@', heyName='%@' ,phoneNo ='%@', profileImage ='%@', currentTimeStamp='%@', isSendToServer=%d",userObj.strFirstName, userObj.strLastName, userObj.strHeyName,  userObj.strPhoneNo, userObj.strProfileImage,userObj.strCurrentTimeStamp,0];
            }
            else
            {
                stm = [NSString stringWithFormat:@"UPDATE userProfile Set firstName ='%@', lastName ='%@', phoneNo ='%@', profileImage ='%@', currentTimeStamp='%@', isSendToServer=%d",userObj.strFirstName,userObj.strLastName,  userObj.strPhoneNo, userObj.strProfileImage,userObj.strCurrentTimeStamp,0];
            }
            
            //NSLog(@"Profile Updation Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"UserProfile Updated....");
                isUpdated=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
            }
            else
            {
                NSLog(@"error while inserting profile....");
            }
            
            sqlite3_close(database);
        }
    }
    
    return isUpdated;
}

+(BOOL) updatedToServerForUserWithFlag:(int)isSendToServer
{
    BOOL isUpdated=NO;
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE userProfile Set isSendToServer =%d",isSendToServer];
            
            NSLog(@"Profile isSendToServer Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"UserProfile Updated....");
                isUpdated=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
            }
            else
            {
                NSLog(@"error while updating profile....");
            }
            
            sqlite3_close(database);
        }
    }
    
    return isUpdated;
}

+(BOOL) isRegistrationSuccessful:(int)flag
{
    BOOL isUpdated=NO;
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE userProfile Set isRegistrationSuccessful =%d",flag];
            
            NSLog(@"Profile isRegistrationSuccessful Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"UserProfile Updated....");
                isUpdated=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                }
                //sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                
            }
            else
            {
                NSLog(@"error while updating profile....");
            }
            
            sqlite3_close(database);
        }
    }
    
    return isUpdated;
}


+ (NSMutableArray*) fetchUserProfile
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = @"SELECT * FROM userProfile limit 0,1";
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelUserProfile *userObj=[[ModelUserProfile alloc] init];
                    
                    userObj.strProfileId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    userObj.strFirstName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)];
                    userObj.strLastName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    userObj.strHeyName=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    userObj.strPhoneNo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 4)];
                    userObj.strDeviceUDID=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 5)];
                    userObj.strProfileImage=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 6)];
                    userObj.strCurrentTimeStamp=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 7)];
                    userObj.strAccountCreated=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text (querryStatement, 8)];
                    
                    userObj.isSendToServer=sqlite3_column_int(querryStatement, 9);
                    userObj.isRegistered=sqlite3_column_int(querryStatement, 10);
                    
                    [arr addObject:userObj];
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

#pragma mark
#pragma mark Message Send
#pragma mark

+(long long) insertMessageDetails:(NSMutableArray *)msgArray
{
    long long lastInsertedId=0;
    ModelMessageSend *msgObj=[msgArray objectAtIndex:0];
    
    if([msgObj.strMessageText containsString:@"'"])
        msgObj.strMessageText= [msgObj.strMessageText stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"INSERT INTO messageCounter(templateId,deviceId,usedMsgText, strFrom, strTo, sendDate) values(\"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\") ",msgObj.strtemplateId,msgObj.strDeviceId,msgObj.strMessageText,msgObj.strFrom,msgObj.strTo,msgObj.strSendDate];
            
            NSLog(@"MessageCounter Insertion Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"MessageDetails Insertion successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                else
                {
                    lastInsertedId=sqlite3_last_insert_rowid(database);
                    NSLog(@"MessageDetails lastInsertedId: %lld",lastInsertedId);
                }
                sqlite3_reset(querryStatement);
            }
            else
            {
                NSLog(@"error while inserting MessageDetails....");
            }
            sqlite3_close(database);
        }
    }
    
    return lastInsertedId;
}


+(BOOL) updateMessageDetailsIsPushedToServer:(int)flag withMessageId:(NSString*) strMessageId
{
    BOOL isUpdated=NO;
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE messageCounter Set isPushedToServer =%d where  messageInsertId ='%@'",flag,strMessageId];
            NSLog(@"Update Message Details Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"MessageCounter Updation successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isUpdated=NO;
                }
                else
                    isUpdated=YES;
                
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                {
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                }
            }
            else
            {
                NSLog(@"error while MessageCounter updation....");
            }
            sqlite3_close(database);
        }
    }
    return  isUpdated;
    
}


+(BOOL) deleteMessageWithDate:(NSString *)strDate
{
    BOOL isDeleted=NO;
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =[NSString stringWithFormat:@"Delete from messageCounter where sendDate<'%@'",strDate];
            
            NSLog(@"messageCounter Delete Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"messageCounter Details deleted....");
                isDeleted=YES;
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
                    isDeleted=NO;
                }
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"error while deleting messageCounter....");
            }
            
            sqlite3_close(database);
        }
    }
    return isDeleted;
}

+(NSMutableArray*)fetchUnSyncMessageDetailsWithisPushedToServer:(int)flag
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"SELECT * FROM messageCounter where isPushedToServer= %d",flag];
            
            NSLog(@"Select MessageDetails Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelMessageSend *objSend = [[ModelMessageSend alloc]init];
                    objSend.strMessageInsertId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    objSend.strtemplateId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] ;
                    objSend.strDeviceId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    objSend.strMessageText=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 3)];
                    
                    objSend.strFrom=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    objSend.strTo=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 5)];
                    objSend.strSendDate=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 7)];
                    
                    [arr addObject:objSend];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}

+ (long)fetchMessageDetailsWithTodayDate
{
    int count=0;
    
    NSDate *currentDate = [NSDate date];
    
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *strTodayDate=[format stringFromDate:currentDate];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"Select COUNT(*) from messageCounter where sendDate='%@'",strTodayDate];
            
            NSLog(@"FetchYestarday Count Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    count = sqlite3_column_int(querryStatement, 0);
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return count;
}


+ (long)fetchMessageDetailsWithYestadayDate
{
    int count=0;
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-1];
    NSDate *yesterdayDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate options:0];
    NSLog(@"CurrentDate: %@\nOne days ago: %@", currentDate, yesterdayDate);

    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *strYestardayDate=[format stringFromDate:yesterdayDate];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"Select COUNT(*) from messageCounter where sendDate='%@'",strYestardayDate];
            
            NSLog(@"FetchYestarday Count Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    count = sqlite3_column_int(querryStatement, 0);
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return count;
}

+ (long)fetchMessageDetailsWithCurrentMonth
{
    int count=0;
    
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM"];
    NSString *strCurrentMonth=[format stringFromDate:currentDate];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm =
            [NSString stringWithFormat:@"Select COUNT(*) from messageCounter where strftime('%%Y-%%m',sendDate) = '%@'",strCurrentMonth];
            
            NSLog(@"FetchYestarday Count Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    count = sqlite3_column_int(querryStatement, 0);
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return count;
}


+ (long)fetchMessageDetailsWithCurrentYear
{
    int count=0;
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy"];
    NSString *strCurrentYear=[format stringFromDate:currentDate];
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"Select COUNT(*) from messageCounter where strftime('%%Y',sendDate) = '%@'",strCurrentYear];
            
            NSLog(@"CurrentYear Count Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    count = sqlite3_column_int(querryStatement, 0);
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return count;
}

+ (long)fetchMessageDetailsWithLifeTime
{
    int count=0;
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate=[format stringFromDate:currentDate];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"Select COUNT(*) from messageCounter where sendDate BETWEEN '1970-01-01' AND '%@' ",strDate];
            
            NSLog(@"LifeTime Count Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    count = sqlite3_column_int(querryStatement, 0);
                    
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    
    return count;
}


#pragma mark
#pragma mark Subscription
#pragma mark

+(long long) insertSubscriptionDetails:(NSMutableArray *)msgArray
{
    long long lastInsertedId=0;
    ModelSubscription *subObj=[msgArray objectAtIndex:0];
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"INSERT INTO subscription(deviceUDID,purchaseTime,purchaseState, purchaseToken) values(\"%@\", \"%@\", \"%d\",\"%@\") ",subObj.strDeviceUDID,subObj.strPurchaseTime,subObj.purchaseState,subObj.strPurchaseToken];
            
            NSLog(@"Subscription Insertion Querystring: %@", stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"Subscription Insertion successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while inserting. '%s'", sqlite3_errmsg(database));
                }
                else
                {
                    lastInsertedId=sqlite3_last_insert_rowid(database);
                    NSLog(@"Subscription lastInsertedId: %lld",lastInsertedId);
                }
                sqlite3_reset(querryStatement);
            }
            else
            {
                NSLog(@"error while inserting Subscription....");
            }
            sqlite3_close(database);
        }
    }
    
    return lastInsertedId;
}


+(BOOL) updateSubscriptionDetailsWithPurchaseTime:(NSString*)strPurchaseTime PurchaseState:(int)purchaseState UDID: (NSString*)strUDID
{
    BOOL isUpdated=NO;
    
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = [NSString stringWithFormat:@"UPDATE subscription Set purchaseTime ='%@', purchaseState=%d where  deviceUDID ='%@'",strPurchaseTime,purchaseState, strUDID];
            NSLog(@"Update Message Details Querystring: %@", stm);
            
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"subscription Updation successful....");
                
                bool executeQueryResults = sqlite3_step(querryStatement) == SQLITE_DONE;
                
                if(!executeQueryResults)
                {
                    NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
                    isUpdated=NO;
                }
                else
                    isUpdated=YES;
                
                sqlite3_reset(querryStatement);
                
                if (sqlite3_finalize(querryStatement) != SQLITE_OK)
                {
                    NSLog(@"SQL Error: %s",sqlite3_errmsg(database));
                }
            }
            else
            {
                NSLog(@"error while subscription updation....");
            }
            sqlite3_close(database);
        }
    }
    return  isUpdated;
    
}

+(NSMutableArray*)fetchSubscriptionDetails
{
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    FMDatabase *database=[DBManager getDatabase];
    if(database)
    {
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        const char* dbPath=[dbpath UTF8String];
        
        if(sqlite3_open(dbPath, &database)==SQLITE_OK)
        {
            NSString *stm = @"SELECT * FROM subscription ORDER BY DESC LIMIT 0,1";
            
            NSLog(@"Select subscription Query: %@",stm);
            const char *sqlQuerry= [stm UTF8String];
            sqlite3_stmt *querryStatement;
            if(sqlite3_prepare_v2(database, sqlQuerry, -1, &querryStatement, NULL)==SQLITE_OK)
            {
                NSLog(@"conversion successful....");
                while (sqlite3_step(querryStatement)==SQLITE_ROW)
                {
                    ModelSubscription *objSub = [[ModelSubscription alloc]init];
                    
                    objSub.strSubscriptionId=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 0)];
                    objSub.strDeviceUDID=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 1)] ;
                    objSub.strPurchaseTime=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 2)];
                    objSub.purchaseState=sqlite3_column_int(querryStatement, 3);
                    objSub.strPurchaseToken=[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(querryStatement, 4)];
                    
                    [arr addObject:objSub];
                }
                sqlite3_finalize(querryStatement);
            }
            else {
                NSLog(@"error while conversion....");
            }
            sqlite3_close(database);
        }
    }
    return arr;
}


#pragma mark
#pragma mark Other Helper Methods
#pragma mark

+(BOOL)recordExistOrNot:(NSString *)query
{
    BOOL recordExist=NO;
    FMDatabase *database=[DBManager getDatabase];
    
    if(database){
        sqlite3 *database;
        NSString *dbpath = [DBManager getDBPath];
        
        if(sqlite3_open([dbpath UTF8String], &database) == SQLITE_OK)
        {
            sqlite3_stmt *statement;
            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
            {
                if (sqlite3_step(statement)==SQLITE_ROW)
                {
                    recordExist=YES;
                }
                else
                {
                    //////NSLog(@"%s,",sqlite3_errmsg(database));
                }
                sqlite3_finalize(statement);
                sqlite3_close(database);
            }
        }
        
    }
    
    return recordExist;
}
@end
