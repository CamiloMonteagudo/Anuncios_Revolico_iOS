//========================================================================================================================================================
//  DefFiles.m
//  Maneja todo los relacionado con los ficheros de de definición de los anuncios
//
//  Created by Admin on 08/11/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "DefFiles.h"

NSString* nowFile;

//========================================================================================================================================================
@implementation DefFiles

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(NSString*) ActualFile
  {
  return nowFile;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino del fichero para el directorio de la aplicación
+ (NSString*) AppPathForFile:(NSString*) fName
  {
  NSString* file  = [fName stringByAppendingString:@".txt"];            // Le agrega la extensión
  NSBundle *Bundle = [NSBundle mainBundle];                             // Obtiene la localización de la aplicación
  
  return [Bundle.bundlePath stringByAppendingPathComponent:file];       // Une camino a la aplicación y nombre del ficherp
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el camino del fichero para el directorio de documentos del usuario
+ (NSString*) UserPathForFile:(NSString*) fName
  {
  NSString* file  = [fName stringByAppendingString:@".txt"];            // Le agrega la extensión
  
  NSFileManager *fMng = [[NSFileManager alloc] init];                   // Crea objeto para manejo de ficheros
  
  NSURL *url =[fMng URLForDirectory:NSDocumentDirectory                 // Le pide el directorio de los documentos
                           inDomain:NSUserDomainMask
                  appropriateForURL:nil
                             create:YES
                              error:nil];
  
  return [[url path] stringByAppendingPathComponent:file];              // Le adiciona el nombre del fichero para los datos
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de los anuncios contenidos en el fichero 'fName'
+ (DataAnuncios*) LoadDatos:(NSString*) fName
  {
  NSString* file = [DefFiles UserPathForFile:fName];                    // Camino para el directorio de usuario
  
  DataAnuncios* Anuncios = [DataAnuncios LoadFromFile: file ];          // Trata de cargar los anuncios desde el directorio de usuario
  if( Anuncios == nil )                                                 // No los pudo cargar
    {
    file     = [DefFiles AppPathForFile:fName];                         // Camino para el directorio de la aplicación
    Anuncios = [DataAnuncios LoadFromFile: file ];                      // Trata de cargar los anuncios desde el directorio de la aplicación
    }
    
  if( Anuncios != nil ) nowFile = fName;                                // Si lo cargo, guarda el ficero actual
  
  return Anuncios;                                                      // Retorna los datos de los anucios en el fichero
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene del fichero de definición de anuncios 'fName' en forma de una cadena de texto
+ (NSString*) LoadText:(NSString*) fName
  {
  NSString* file = [DefFiles UserPathForFile:fName];                    // Camino para el directorio de usuario
  
  NSString* Text = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
  
  if( Text == nil )                                                     // No los pudo cargar
    {
    file = [DefFiles AppPathForFile:fName];                             // Camino para el directorio de la aplicación
    Text = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
    }
  
  return Text;                                                          // Retorna los datos de los anucios en el fichero
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda la cadena 'Text' en el fichero 'fName'
+ (BOOL) SaveText:(NSString*) Text InFile:(NSString*) fName
  {
  NSString* file = [DefFiles UserPathForFile:fName];                    // Camino para el directorio de usuario
  
  return [Text writeToFile:file atomically:NO encoding:NSUTF8StringEncoding error:NULL];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene todos los archivos de definición de fichero que existan
+ (NSArray<NSString *>*) FindFiles
  {
  NSMutableSet<NSString *>* FoundFiles = [NSMutableSet<NSString *> new];  // Crea un conjunto vacio
  
  NSString* AppDir = [NSBundle mainBundle].bundlePath;                    // Obtiene directorio de la aplicación
  
  [DefFiles GetFilesFromDir:AppDir InSet:FoundFiles];                     // Suma ficeheros en el directorio de la aplicación
  
  // Obtiene el fichero de documentos del usuario
  NSFileManager *fMng = [[NSFileManager alloc] init];
  NSString* UserDir = [fMng URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil].path;

  [DefFiles GetFilesFromDir:UserDir InSet:FoundFiles];                     // Suma ficheros en el directorio de usuario

  NSMutableArray<NSString *>* ListFiles = [NSMutableArray new];            // Crea un arreglo vacio
  for( NSString* file in FoundFiles )                                      // Copia todos los fichero para el arreglo
    [ListFiles addObject:file];
    
  return ListFiles;                                                        // Retorna la lista de ficheros
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene todos los archivos de definición de fichero que existan
+ (void) GetFilesFromDir:(NSString*) Dir InSet:(NSMutableSet<NSString *>*) FoundFiles
  {
  NSFileManager *fMng = [[NSFileManager alloc] init];                   // Crea objeto para manejo de ficheros
  
  NSError* err;
  NSArray<NSString *> *Files = [fMng contentsOfDirectoryAtPath:Dir error:&err ];
  
  for( NSString* file in Files)
    {
    NSString *Ext  = [file pathExtension];
    if( ![[Ext lowercaseString] isEqualToString:@"txt"] ) continue;
    
    NSString *Name = [file lastPathComponent];
    NSArray<NSString*>* NameExt = [Name componentsSeparatedByString:@"."];
    
    [FoundFiles addObject:NameExt[0]];
    }
  }

@end
//========================================================================================================================================================
