//========================================================================================================================================================
//  ViewController.m
//  Anuncios
//
//  Created by Admin on 19/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "ViewController.h"
#import "DataAnuncios.h"

//========================================================================================================================================================
@interface ViewController ()
  {
  DataAnuncios* Anuncios;
  NSInteger     nowAnunc;
  }

@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *curWait;

- (IBAction)OnShowMore:(id)sender;
- (IBAction)OnPrev:(id)sender;
- (IBAction)OnPublicar:(id)sender;
- (IBAction)OnProximo:(id)sender;

@end

//========================================================================================================================================================
@implementation ViewController

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  [self LoadAnunciosFromFile: @"Revolico Medicinas 1.txt"];
  [self ShowNowAnuncioInfo];
  
  _curWait.hidden = true;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el fichero de definición de los anuncios desde un fichero
- (void) LoadAnunciosFromFile:(NSString*) file
  {
  NSBundle *Bundle = [NSBundle mainBundle];
  file = [Bundle.bundlePath stringByAppendingPathComponent:file];
  
  Anuncios = [DataAnuncios LoadFromFile:file];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se cargo la página sin problemas
- (void)webViewDidFinishLoad:(UIWebView *)webView
  {
  NSString* jsSet = @"function FillInput( Name, Val )"
  @"  {"
  @"  var elem = document.all( Name );"
  @"  if( !elem ) return '1';"
  
  @"  elem.value = Val;"
  @"  return '0';"
  @"  }"
  
  @"function FillSelect( Name, OptText )"
  @"  {"
  @"  var elem = document.all( Name );"
  @"  if( !elem ) return '1';"
  
  @"  var sOpt    = OptText.toLowerCase();"
  @"  var Options = elem.getElementsByTagName(\"option\");"
    
  @"  for( var j=0; j<Options.length; ++j )"
  @"    {"
  @"    var opt = Options[j];"
      
  @"    if( opt.innerText.toLowerCase() == sOpt )"
  @"      {"
  @"      opt.selected = true;"
  @"      elem.onchange( this );"
  @"      return '0'"
  @"      }"
  @"    }"
  
  @"  return '2';"
  @"  }" ;
  
  [_webPage stringByEvaluatingJavaScriptFromString: jsSet ];
  _curWait.hidden = false;
  
  [self FillDatos];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone en la entrada 'Name' de la página la cadena 'Value'
- (NSString*) FillInput:(NSString*) Name With:(NSString*) Value
  {
  NSString* jsSet = @"FillInput('nombre','%Val%')";
  
  jsSet = [jsSet stringByReplacingOccurrencesOfString:@"%Val%"  withString:Value ];
  
  return [_webPage stringByEvaluatingJavaScriptFromString: jsSet ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone en el campo de selección 'Name' de la página la opción 'Value'
- (NSString*) FillSelect:(NSString*) Name With:(NSString*) Value
  {
  NSString* jsSet = @"FillSelect('seleccion','%Val%')";
  
  jsSet = [jsSet stringByReplacingOccurrencesOfString:@"%Val%"  withString:Value ];
  
  return [_webPage stringByEvaluatingJavaScriptFromString: jsSet ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
/// Pone todos los datos definidos en el anuncio en la pagina actual
-(void) FillDatos
  {
  AnuncioInfo* Anuncio = Anuncios.Items[nowAnunc];
  
  for( NSInteger i=0; i<Anuncio.FillInfo.count; i++)
    {
    HtmlInfo* info = Anuncio.FillInfo[i];
    
    if( [info.TagName isEqualToString:@"select"] )
      [self FillSelect:info.AttrName With:info.Txt];
    else
      {
      [self FillInput:info.AttrName With:info.Txt];
//      var val = new TextEval( IdxFill, Anuncio );
//      [self FillInput:info.AttrName With:val.Txt];
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra un mensaje de alerta, con el titulo y el texto suministado
- (void) MsgTitle:(NSString*) title Text:(NSString*) Text
  {
  UIAlertController* alert = [UIAlertController alertControllerWithTitle: title
                                                                 message: Text
                                                          preferredStyle: UIAlertControllerStyleAlert];
  
  UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil];
  
  [alert addAction:defaultAction];
  [self presentViewController:alert animated:YES completion:nil];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hubo un error al cargar la página
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
  {
  [self MsgTitle:@"Error cargando la Página" Text: Anuncios.Items[nowAnunc].Url ];
//  NSLog(@"%@", error.description);
  _curWait.hidden = true;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Selecciona opciones adicionales para llenar las páginas
- (IBAction)OnShowMore:(id)sender
  {
  [self MsgTitle:@"Alerta" Text:@"Ir a mostrar más información"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se mueve al anuncio anterior
- (IBAction)OnPrev:(id)sender
  {
  --nowAnunc;
  [self ShowNowAnuncioInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Publica el anuncio actual
- (IBAction)OnPublicar:(id)sender
  {
  NSInteger num = Anuncios.Items.count;
  if( nowAnunc >= num || nowAnunc < 0 ) return;
  
  AnuncioInfo* nowItem = Anuncios.Items[nowAnunc];

  NSURL *url = [NSURL URLWithString: nowItem.Url];
  
  [_webPage loadRequest:[NSURLRequest requestWithURL:url]];
  _curWait.hidden = false;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se mueve al proximo anuncio
- (IBAction)OnProximo:(id)sender
  {
  ++nowAnunc;
  [self ShowNowAnuncioInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Actualiza los datos del anuncio actual en la pantalla
-(void) ShowNowAnuncioInfo
  {
  NSInteger num = Anuncios.Items.count;
  if( num==0 )
    {
    _lbInfo.text  = @"";
    _lbTitle.text = @"";
    return;
    }
  
  if( nowAnunc >= num ) nowAnunc = 0;
  if( nowAnunc < 0    ) nowAnunc = num-1;

  AnuncioInfo* nowItem = Anuncios.Items[nowAnunc];
  
  _lbInfo.text = [NSString stringWithFormat:@"%ld de %ld  Identif: %@", nowAnunc+1, num, nowItem.ID ];
  _lbTitle.text = nowItem.GetTitle;
  }

@end

//========================================================================================================================================================
