//========================================================================================================================================================
//  TextEval.h
//  Anuncios
//
//  Created by Admin on 24/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import <Foundation/Foundation.h>
#import "DataAnuncios.h"

@interface TextEval : NSObject

+(TextEval*) TextEvalWithAnucio:(AnuncioInfo*) Anuncio;
-(NSString*) ParseValue:(NSString*) sVal;

@property (nonatomic) BOOL Escape;                   // Escapa los caracteres conflictivos para Javascript

@end
//========================================================================================================================================================
