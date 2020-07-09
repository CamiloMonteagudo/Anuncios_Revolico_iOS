//========================================================================================================================================================
//  DataAnuncios.m
//  Anuncios
//
//  Created by Admin on 22/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "DataAnuncios.h"

//========================================================================================================================================================
/// Datos información que hay que colocar en la pagina web
@implementation HtmlInfo

//--------------------------------------------------------------------------------------------------------------------------------------------------------
/// Crea un objeto con el nombre de la información que se va a manejar
+(HtmlInfo*) HtmlInfoWithName:(NSString*) infoName
  {
  HtmlInfo* info = [HtmlInfo new];
  info.InfoName = infoName;

  return info;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
/// Crea una copia del objeto y la retorna
-(HtmlInfo*) GetCopy
  {
  HtmlInfo* CpyInfo = [HtmlInfo HtmlInfoWithName:_InfoName];
  
  CpyInfo.TagName  = _TagName;
  CpyInfo.AttrName = _AttrName;
  
  if( [_InfoName isEqualToString:@"Titulo"] ||
      [_InfoName isEqualToString:@"Descripción"] ) CpyInfo.Txt = @"";
  else                                             CpyInfo.Txt = _Txt;
  
  return CpyInfo;
  }

@end

//========================================================================================================================================================
/// Datos de toda la información relacionada con un anuncio
@implementation AnuncioInfo

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Construye un nuevo anuncio con todos los datos del anucio anterior
+(AnuncioInfo*) AnuncioFrom:(AnuncioInfo*) Last
  {
  AnuncioInfo* Anunc = [AnuncioInfo new];
  Anunc.FillInfo = [NSMutableArray<HtmlInfo*> new];
  
  if( Last!=nil )
    {
    Anunc.ID  = Last.ID;
    Anunc.Url = Last.Url;
    
    for( HtmlInfo* item in Last.FillInfo)
      [Anunc.FillInfo addObject:[item GetCopy] ];
    }
  
  return Anunc;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el titulo del anuncio
-(NSString*) GetTitle
  {
  for( HtmlInfo* item in _FillInfo)
    if( [item.InfoName isEqualToString:@"Titulo"] )
      return item.Txt;
    
  return @"";
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el titulo del anuncio
-(void) SetTitle:(NSString*) title
  {
  for( HtmlInfo* item in _FillInfo)
    if( [item.InfoName isEqualToString:@"Titulo"] )
      item.Txt = title;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el titulo del anuncio
-(NSString*) GetDesc
  {
  for( HtmlInfo* item in _FillInfo)
    if( [item.InfoName isEqualToString:@"Descripción"] )
      return item.Txt;
  
  return @"";
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Analiza toda la información de un anuncio a partir de la linea actual
+(AnuncioInfo*) AnuncioFromLines:(NSArray<NSString*>*) lines Index:(NSInteger*) i Last:(AnuncioInfo*) LastAnuncio
  {
  AnuncioInfo* Info = [AnuncioInfo AnuncioFrom:LastAnuncio];
  
  NSInteger Idx = *i;
  for( ; Idx<lines.count; )
    {
    NSString* line = [lines[Idx] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet ];
    if( line.length==0 ) { ++Idx; continue; }
    
    bool GetAnucio = [Info ParseLine:line];
    ++Idx;
    
    if( GetAnucio )
      {
      if( [Info GetTitleAndDescription: lines Index: &Idx] )
        {
        *i = Idx;
        return Info;
        }
      }
    }
  
  *i = Idx;
  return nil;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Analiza la informacion de una linea en el fichero informacion de los anuncios
-(bool) ParseLine:(NSString*) line
  {
  NSString* ItemName;
  NSString* ItemInfo;
  NSString* ItemVal;
  if( ![self TokeingLine:line ItemName: &ItemName ItemInfo: &ItemInfo ItemVal: &ItemVal] )
    {
    NSLog( @"\r\nLA SIGUIENTE LINEA FUE IGNORADA ...\r\n%@\r\n", line );
    return false;
    }
  
  if( [ItemName isEqualToString:@"Url"] )
    {
    _Url = ItemVal;
    return false;
    }
  
  if( [ItemName isEqualToString:@"Anuncio"] )
    {
    _ID = [self GetID:ItemVal];
    return true;
    }
  
  [self AddHtmlItemName:ItemName ItemInfo:ItemInfo ItemVal:ItemVal];
  return false;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Separa las partes de informacion contenida en una linea de texto
-(bool) TokeingLine:(NSString*) line ItemName:(NSString**) ItemName ItemInfo:(NSString**) ItemInfo ItemVal:(NSString**) ItemVal
  {
  if( ![line hasPrefix:@"// "] ) return false;
  line = [line substringFromIndex:3];
  
  NSArray<NSString*>* CmdVal = [line componentsSeparatedByString:@"="];
  if( CmdVal.count < 2) return false;
  
  NSArray<NSString*>* NameInfo = [CmdVal[0] componentsSeparatedByString:@"-"];
  if( NameInfo.count < 2) return false;
  
  *ItemName = [NameInfo[0] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  *ItemInfo = [NameInfo[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  *ItemVal  = [CmdVal[1] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  
  return true;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un objeto con informacion para poner en la pagina web
-(void) AddHtmlItemName:(NSString*) ItemName ItemInfo:(NSString*) ItemInfo ItemVal:(NSString*) ItemVal
  {
  HtmlInfo *item = nil;
  
  for( HtmlInfo *itm in _FillInfo )
    if( [itm.InfoName isEqualToString: ItemName] )
      { item = itm; break; }
  
  if( item == nil )
    {
    item = [HtmlInfo HtmlInfoWithName:ItemName];
    [_FillInfo addObject:item];
    }
  
       if( [ItemInfo isEqualToString:@"TagName"]  ) item.TagName  = ItemVal;
  else if( [ItemInfo isEqualToString:@"AttrName"] ) item.AttrName = ItemVal;
  else if( [ItemInfo isEqualToString:@"Txt"]      ) item.Txt      = ItemVal;
  else NSLog( @"La información '%@-%@' fue ignorada", ItemName, ItemInfo );
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el titulo y la descripción del anuncio
-(bool) GetTitleAndDescription:(NSArray<NSString*>*) lines Index:(NSInteger *) i
  {
  NSUInteger idx = *i;
  
  if( idx >= lines.count ) return false;
    
  NSString*       Title = lines[idx++];
  NSMutableString* Desc = [NSMutableString stringWithCapacity:1500];
  
  for( ;idx < lines.count; )
    {
    NSString* line = lines[idx];
    if( [line hasPrefix:@"//"] ) break;
    
    [Desc appendFormat:@"%@\n", line];
    ++idx;
    }
  
  if( Desc.length == 0 ) {*i=idx; return false;}
  
  [self AddHtmlItemName:@"Titulo"      ItemInfo:@"Txt" ItemVal:Title];
  [self AddHtmlItemName:@"Descripción" ItemInfo:@"Txt" ItemVal:Desc ];
  
  *i=idx; return true;
  }
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene las parte de la cadena que representa el identificador del anuncio
-(NSString*) GetID:(NSString*) itemVal
  {
  NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:@" -"];
  return [itemVal stringByTrimmingCharactersInSet:set];
  }
  
@end

//========================================================================================================================================================
/// Datos de toda la información de todos los anuncios
@implementation DataAnuncios
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene los datos de los anuncios desde un fichero
+(DataAnuncios*) LoadFromFile:(NSString*) fileName
  {
  NSArray<NSString*> * Lines = [DataAnuncios ReadLinesOfFile:fileName];
  if( Lines==nil ) return nil;
  
  DataAnuncios* Datos = [DataAnuncios new];
  Datos.Items = [NSMutableArray<AnuncioInfo*> new];
  
  [Datos ParseLines: Lines ];

  return Datos;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene las parte de la cadena que representa el identificador del anuncio
+(NSArray<NSString*> *) ReadLinesOfFile:(NSString*) fileName
  {
  NSStringEncoding Enc;
  NSError          *Err;

  NSString *Txt = [NSString stringWithContentsOfFile:fileName usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return nil;

  Txt = [Txt stringByReplacingOccurrencesOfString:@"\r" withString:@""];

  NSCharacterSet* sep = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
  return [Txt componentsSeparatedByCharactersInSet: sep ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Analiza todas las lineas del fichero con los dato de los anuncios
-(void) ParseLines:(NSArray<NSString*> *) lines
  {
  NSInteger idx = 0;
  AnuncioInfo *LastAnuncio = nil;
  for ( ;idx<lines.count; )
    {
    AnuncioInfo* anuncio = [AnuncioInfo AnuncioFromLines:lines Index:&idx Last:LastAnuncio];
   
    if( anuncio != nil )
      {
      [_Items addObject:anuncio];
      LastAnuncio = anuncio;
      }
    }
  }

@end
//========================================================================================================================================================
