//========================================================================================================================================================
//  DataAnuncios.h
//  Anuncios
//
//  Created by Admin on 22/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import <Foundation/Foundation.h>

//========================================================================================================================================================
/// Datos información que hay que colocar en la pagina web
@interface HtmlInfo : NSObject

 @property (nonatomic) NSString *InfoName;              // Nombre de la información que se va a poner en la pagina web
 @property (nonatomic) NSString *TagName;               // Nombre del tag donde hay que poner la información
 @property (nonatomic) NSString *AttrName;              // Nombre del atributo name que identifica al tag
 @property (nonatomic) NSString *Txt;                   // Texto que hay que colocar en la página web

@end

//========================================================================================================================================================
/// Datos de toda la información relacionada con un anuncio
@interface AnuncioInfo : NSObject

 @property (nonatomic) NSString *ID;                   // Identificador del anuncio
 @property (nonatomic) NSString *Url;                  // Url de la pagina para publecar el anuncio

 @property (nonatomic) NSMutableArray<HtmlInfo*> *FillInfo;     // Lista de todas las modificaciones que hay que hacer en la pagina

-(NSString*) GetTitle;
-(NSString*) GetDesc;

@end

//========================================================================================================================================================
@interface DataAnuncios : NSObject

@property (nonatomic) NSMutableArray<AnuncioInfo*> *Items;     // Lista de todas las modificaciones que hay que hacer en la pagina

+(DataAnuncios*) LoadFromFile:(NSString*) fileName;

@end
