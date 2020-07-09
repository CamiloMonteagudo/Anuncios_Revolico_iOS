//========================================================================================================================================================
//  TextEval.m
//  Anuncios
//
//  Created by Admin on 24/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "TextEval.h"

//========================================================================================================================================================
@interface TextEval()
  {
  AnuncioInfo* Anuncio;
  
  NSDate* Now;
  NSCalendar* Cldr;
  }

@end

//========================================================================================================================================================
// Maneja los comodines que puedan aparecen en el texto de llenado de un elemento HTML
@implementation TextEval

//--------------------------------------------------------------------------------------------------------------------------------------
//Crea el objeto con la informción del anuncio
+(TextEval*) TextEvalWithAnucio:(AnuncioInfo*) Anuncio
  {
  TextEval* obj = [TextEval new];

  obj->Anuncio = Anuncio;
  obj->Now     = NSDate.date;
  obj->Cldr    = NSCalendar.currentCalendar;
  obj.Escape   = TRUE;
  
  return obj;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Escapa los caracteres que pueden ser conflictivo en las cadenas Javascript
-(NSString*) EscapeText:(NSMutableString*) sVal
  {
  [sVal replaceOccurrencesOfString:@"\r\n" withString:@"\\n" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  [sVal replaceOccurrencesOfString:@"\r"   withString:@"\\n" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  [sVal replaceOccurrencesOfString:@"\n"   withString:@"\\n" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];

  [sVal replaceOccurrencesOfString:@"\""   withString:@"\\\"" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  [sVal replaceOccurrencesOfString:@"\'"   withString:@"\\\'" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  
  return sVal;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Si hay alguna marca de sustitución en texto de llenado lo resuelve en otro caso retorna la misma cadena
-(NSString*) ParseValue:(NSString*) sVal1
  {
  NSMutableString* str = [NSMutableString stringWithString:sVal1];
  for(;;)
    {
    NSRange ini = [str rangeOfString:@"{"];
    if( ini.length == 0 ) break;
    
    ini.length = str.length - ini.location;
    NSRange fin = [str rangeOfString:@"}" options:NSLiteralSearch range:ini];
    if( fin.length == 0) break;
    
    NSRange rg = NSMakeRange(ini.location, fin.location-ini.location+1);
    NSString* cmd = [[str substringWithRange:rg] uppercaseString];
    
    NSString* ret = cmd;
         if( [cmd isEqualToString:@"{ID}"    ] ) ret = [self GetAnuncioID];
    else if( [cmd isEqualToString:@"{DIA}"   ] ) ret = [self GetDia];
    else if( [cmd isEqualToString:@"{MES}"   ] ) ret = [self GetMes];
    else if( [cmd isEqualToString:@"{H}"     ] ) ret = [self GetTitleHeader];
    else if( [cmd isEqualToString:@"{DIASEM}"] ) ret = [self GetSemanaDia];
    else if( [cmd isEqualToString:@"{DIASTR}"] ) ret = [self GetStringDia];
    
    [str replaceOccurrencesOfString:cmd   withString:ret options:NSLiteralSearch range:NSMakeRange(0, str.length)];
    }
  
  if(_Escape ) [self EscapeText:str];
  return str;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
/// Obtiene el dia en forma de una palabra
-(NSString*) GetStringDia
 {
  NSString* Dias[] = { @"Uno"      , @"Dos"     , @"Tres"     , @"Cuatro"     , @"Cinco"     , @"Seis"     , @"Siete"     , @"Ocho"     , @"Nueve"     , @"Dies"  ,
                       @"Once"     , @"Doce"    , @"Trece"    , @"Catorce"    , @"Quince"    , @"DiesiSeis", @"DiesiSiete", @"DiesiOcho", @"DiesiNueve", @"Vente" ,
                       @"VentiUno" , @"VentiDos", @"VentiTres", @"VentiCuatro", @"VentiCinco", @"VentiSeis", @"VentiSiete", @"VentiOcho", @"VentiNueve", @"Trenta",
                       @"TrentiUno" };
 
 NSInteger dia = [Cldr component:NSCalendarUnitDay fromDate:Now] - 1;
 return Dias[ dia ];
 }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre del dia de la semana
-(NSString*) GetSemanaDia
  {
  NSString* Dias[] = { @"Domingo", @"Lunes", @"Martes", @"Miercoles", @"Jueves", @"Viernes", @"Sabado" };
  
  NSInteger dia = [Cldr component:NSCalendarUnitWeekday fromDate:Now] - 1;
  return Dias[ dia ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene un emcabezamiento unico de 2 letras para el titulo
-(NSString*) GetTitleHeader
  {
  NSString* Meses = @"ZYXWVUTSRQPOMNLKJIHGFEDCBA0987654321Ñ";
  NSString* Dias  = @"0123456789ABCDEFGHIJKLNMOPQRSTUVWXYZ";
  
  NSInteger dia  = [Cldr component:NSCalendarUnitDay   fromDate:Now] - 1;
  NSInteger mes  = [Cldr component:NSCalendarUnitMonth fromDate:Now] - 1;
  NSInteger hora = [Cldr component:NSCalendarUnitHour  fromDate:Now];

  if( hora>12 ) mes += 12;
  if( hora>16 ) mes += 12;

  char c1 = [Meses characterAtIndex:mes];
  char c2 = [Dias characterAtIndex:dia];
  
  return [NSString stringWithFormat:@"%c%c", c1, c2];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre del mes actual
-(NSString*) GetMes
  {
  NSString* Meses[] = {@"Enero",@"Febrero",@"Marzo",@"Abrir", @"Mayo", @"Junio", @"Julio", @"Agosto", @"Septiembre", @"Octubre", @"Noviembre", @"Diciembre" };
  
  NSInteger mes  = [Cldr component:NSCalendarUnitMonth fromDate:Now] - 1;
  
  return Meses[ mes ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el dia actual en el formato de dos letras
-(NSString*) GetDia
  {
  NSInteger dia = [Cldr component:NSCalendarUnitDay fromDate:Now];
  
  return [NSString stringWithFormat:@"%2ld", dia];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el identificador del anuncio actual
-(NSString*) GetAnuncioID
  {
  return Anuncio.ID;
  }

@end
//========================================================================================================================================================
