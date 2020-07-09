//========================================================================================================================================================
//  FilesAnuncios.h
//  Anuncios
//
//  Created by Admin on 08/11/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import <Foundation/Foundation.h>
#import "DataAnuncios.h"

//========================================================================================================================================================
@interface DefFiles : NSObject

+(NSString*) ActualFile;

+ (NSString*) AppPathForFile:(NSString*) fName;
+ (NSString*) UserPathForFile:(NSString*) fName;

+ (DataAnuncios*) LoadDatos:(NSString*) fName;
+ (NSString*) LoadText:(NSString*) fName;
+ (BOOL) SaveText:(NSString*) Text InFile:(NSString*) fName;

+ (NSArray<NSString *>*) FindFiles;

@end
//========================================================================================================================================================
