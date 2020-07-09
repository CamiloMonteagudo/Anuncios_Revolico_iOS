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
 // [sVal replaceOccurrencesOfString:@"\\"   withString:@"\\\\" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  [sVal replaceOccurrencesOfString:@"\n"   withString:@"\\n" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];

  [sVal replaceOccurrencesOfString:@"\""   withString:@"\\\"" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  [sVal replaceOccurrencesOfString:@"\'"   withString:@"\\\'" options:NSLiteralSearch range:NSMakeRange(0, sVal.length)];
  
  return sVal;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Si hay alguna marca de sustitución en texto de llenado lo resuelve en otro caso retorna la misma cadena
-(NSString*) ParseValue:(NSString*) sVal
  {
  NSMutableString* str = [NSMutableString stringWithString:sVal];
  for(;;)
    {
    NSString* cmd = [self stringForm:str Ini:@"{" End:@"}"];
    if( cmd.length==0 ) break;

    NSString* ret = @"";
    NSString* CMD = [cmd uppercaseString];
         if( [CMD isEqualToString:@"ID"      ] ) ret = [self GetAnuncioID];
    else if( [CMD isEqualToString:@"DIA"     ] ) ret = [self GetDia];
    else if( [CMD isEqualToString:@"MES"     ] ) ret = [self GetMes];
    else if( [CMD isEqualToString:@"H"       ] ) ret = [self GetTitleHeader];
    else if( [CMD isEqualToString:@"DIASEM"  ] ) ret = [self GetSemanaDia];
    else if( [CMD isEqualToString:@"DIASTR"  ] ) ret = [self GetStringDia];
    else if( [CMD isEqualToString:@"EMAIL"   ] ) ret = [self GetRandomMail];
    else if( [CMD       hasPrefix:@"WORDSKEY"] ) ret = [self GetWordKeys:cmd];

    NSRange    all = NSMakeRange(0, str.length);
    NSString* sust = [[@"{" stringByAppendingString:cmd] stringByAppendingString:@"}"];

    [str replaceOccurrencesOfString:sust withString:ret options:NSLiteralSearch range:all];
    }
  
  if(_Escape ) [self EscapeText:str];
  return str;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cadena encerrada entre lo
-(NSString*) stringForm:(NSString*) str Ini:(NSString*) sIni End:(NSString*) sEnd
  {
  NSRange ini = [str rangeOfString:sIni];
  if( ini.length == 0 ) return @"";
    
  ini.length = str.length - ini.location;
  NSRange fin = [str rangeOfString:sEnd options:NSLiteralSearch range:ini];
  if( fin.length == 0) return @"";
    
  NSRange rg = NSMakeRange(ini.location+1, fin.location-ini.location-1);

  return [str substringWithRange:rg];
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
  NSString* Meses = @"ZYXWVUTSRQPOMNLKJIHGFEDCBAÑ©°Æ®Øß∂¶§µ";
  NSString* Dias  = @"ABCDEFGHIJKLNMOPQRSTUVWXYZÇÆµÑØß∂¶§";
  
  NSInteger dia  = [Cldr component:NSCalendarUnitDay   fromDate:Now] - 1;
  NSInteger mes  = [Cldr component:NSCalendarUnitMonth fromDate:Now] - 1;

  int mult = rand()%3;
  mes += mult*12;

  char c1 = [Meses characterAtIndex:mes];
  char c2 = [Dias characterAtIndex:dia];
  
  return [NSString stringWithFormat:@"(%c%c)", c1, c2];
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
  
  NSString* frmt = dia<10? @"0%d": @"%d";
  return [NSString stringWithFormat:frmt, (int)dia];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el identificador del anuncio actual
-(NSString*) GetAnuncioID
  {
  return Anuncio.ID;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una dirección de Correo Aleatoria
-(NSString*) GetRandomMail
  {
  NSString*   Names[] = {@"Camilo",@"Carlos", @"Pedro",@"Juan", @"David", @"Armando", @"Felix", @"Maria", @"Juana", @"Margar", @"Tere", @"Josefa", @"Fran" ,@"Pepe", @"Maira", @"Teresita", @"Josefa", @"Ana", @"Anita", @"Aida", @"Lola", @"Laura", @"Ivan", @"Manuel", @"Elvis" ,@"Eva", @"Clara" ,@"Gael", @"Joel", @"Jony", @"Joana", @"Yoan", @"Yoani", @"Lorena", @"Patricia", @"Gilda", @"Ariel" ,@"Alex", @"Ernesto", @"Jose", @"Elsa", @"Jainer", @"Julian", @"Victor", @"Eve", @"Fara", @"Jorge", @"Sivia", @"Amelia" ,@"Grettel", @"Nicolas", @"Fidel", @"Raul", @"Mariela", @"Agustin", @"Alfredo", @"Daniel", @"Fide", @"Oscar", @"Juaqin", @"Malena" ,@"Ivon", @"Agusto" ,@"Cecilia", @"Celia", @"Cesar", @"Homero", @"Ristro", @"Lazaro", @"Yeyo", @"Miguel", @"Rafael", @"Andres", @"Regla", @"Bruno", @"Elena", @"Blanca", @"Aurelio", @"Yelianis", @"Ledys", @"Monica", @"Rebeca", @"Yenifer", @"Yadira", @"Esteban", @"Sebastian", @"Alturo", @"Alejandro", @"Diosdado", @"Dematrio", @"Abel", @"Hector", @"Roberto", @"Alain", @"Alicia", @"Eduardo", @"Angel", @"Jesus", @"Hugo", @"Nestor", @"Julian", @"Armando", @"Rodolfo", @"Richar", @"Cristian", @"Alberto", @"Julio", @"Mandy", @"Dinora", @"Vivian", @"Rigo", @"Damian", @"Oriol"  };
  NSString*  Apllds[] = {@"Fdez",@"Monte" ,@"Dias" ,@"Abrir", @"Suares", @"Valdez", @"Castro", @"Gzles", @"Peres", @"Ochoa", @"Hrdez", @"Sanches", @"Tabares", @"1970", @"1980", @"1985", @"1968", @"Orosco", @"Mora", @"Garcia", @"Torres", @"Almirar", @"Enrique", @"Blanco", @"Cruz", @"Palomo", @"Caro", @"Carrazana", @"Pena", @"Orozco", @"Guevara", @"Morales", @"Piñera", @"Prieto", @"Carcaces", @"Alonso", @"Alfonso", @"Chavez", @"Dies", @"Jimenes", @"More", @"Canel", @"Ojeda", @"Leon", @"Noa", @"Moa", @"Reyes", @"Ortega" };
  NSString* Servers[] = {@"gmail.com",@"outlook.com", @"hotmail.com", @"infomed.sld.cu", @"yahoo.com", @"yahoo.ar", @"ms.net", @"amazon.com", @"cultur.cu", @"aol.com" };
  
  int iName    = rand() % ( sizeof(Names)/sizeof(Names[0]) );
  int iApllds  = rand() % ( sizeof(Apllds)/sizeof(Apllds[0]) );
  int iServers = rand() % ( sizeof(Servers)/sizeof(Servers[0]) );
  
  NSString* sMail = [NSString stringWithFormat:@"%@%@@%@", Names[iName], Apllds[iApllds], Servers[iServers] ];
  
  return sMail;
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una lista de palabras clasves ordenadas de manera aleatoria
-(NSString*) GetWordKeys:(NSString*) cmd
  {
  NSArray<NSString*>* CmdVal = [cmd componentsSeparatedByString:@"/"];    // Separa los comandos

  NSString* KeysName = CmdVal[0];                                         // Primer comando "Nombre de la lista de llaves"
  NSString*      Sep = (CmdVal.count>=2)? CmdVal[1] : @" / ";             // Segundo comando "Separador utilizado para los elementos de la lista"
  
  for( HtmlInfo* Info in Anuncio.FillInfo )                               // Recorre informacion del anuncio
    if( [KeysName isEqualToString:Info.InfoName] )                        // Si es el nombre de lista de llaves
      return [self WordsKeyList:Info ListSep:Sep];                        // Obtine una lista ordenada aleatoriamente
  
  NSLog(@"No se obtubo la lista de palabras: %@", cmd);                   // Pone cartel de advertencia
  return @"";                                                             // Obtiene una lista vacia
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una lista de palabras clasves ordenadas de manera aleatoria
-(NSString*) WordsKeyList:(HtmlInfo*) info ListSep:(NSString*) Sep
  {
  // Obtiene una lista con todas las palabras claves
  NSMutableArray<NSString*>* words = [NSMutableArray arrayWithArray:[info.Txt componentsSeparatedByString:@", "]];

  NSMutableString* List = [NSMutableString stringWithString:@""];       // Crea cadena vacia
  while( words.count>0 )                                                // Mientras haya palabras en la lista
    {
    int idx = rand() % words.count;                                     // Obtiene indice a una palabra aleatoriamente

    if( List.length>0 ) [List appendString:Sep];                        // Si no es la primera palabra adiciona un separador
    
    [List appendString:words[idx]];                                     // Adiciona la palabra a la cadena
    [words removeObjectAtIndex:idx];                                    // Borra la palabra de la lista
    }
  
  return List;                                                          // Retorna cadena con lista de palabras
  }

@end
//========================================================================================================================================================
