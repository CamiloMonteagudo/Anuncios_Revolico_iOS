//========================================================================================================================================================
//  ViewController.m
//  Anuncios
//
//  Created by Admin on 19/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "ViewController.h"
#import "DataAnuncios.h"
#import "SelFileViewController.h"
#import "TextEval.h"

//========================================================================================================================================================
@interface ViewController ()
  {
  DataAnuncios* Anuncios;
  NSInteger     nowAnunc;
  
  NSString* AnuncFile;
  }

@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *curWait;

@property (weak, nonatomic) IBOutlet UIButton *btnPrevio;
@property (weak, nonatomic) IBOutlet UIButton *btnPublicar;
@property (weak, nonatomic) IBOutlet UIButton *btnProximo;
@property (weak, nonatomic) IBOutlet UIButton *btnDetener;
@property (weak, nonatomic) IBOutlet UIButton *btnLlenar;
@property (weak, nonatomic) IBOutlet UIButton *btnTest;

- (IBAction)OnPrev:(id)sender;
- (IBAction)OnPublicar:(id)sender;
- (IBAction)OnProximo:(id)sender;
- (IBAction)OnDetener:(id)sender;
- (IBAction)OnLlenar:(id)sender;
- (IBAction)OnTest:(id)sender;

@end

//========================================================================================================================================================
@implementation ViewController

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  
  NSString* lastFile = [UserDef objectForKey:@"lastAnuncFile"];
  [self LoadAnunciosFromFile: lastFile ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
  {
  NSString* msg = [NSString stringWithFormat:@"Cargando:'%@'\r\nTipo de navegación:'%d'",request.URL.absoluteString,(int)navigationType];
  
//  [self MsgTitle:@"Va a cargar la Página" Text: msg ];
  NSLog( @"Va a cargar la Página: %@", msg );
        
  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void)webViewDidStartLoad:(UIWebView *)webView
  {
  NSString* msg = [NSString stringWithFormat:@"Termino de Cargar:'%@'",webView.request.URL.path];
  
//  [self MsgTitle:@"Carga Iniciada" Text: msg ];
  NSLog( @"Carga Iniciada: %@", msg );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hubo un error al cargar la página
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
  {
  NSString* msg = [NSString stringWithFormat:@"ERROR:%@",error.description];
  
//  [self MsgTitle:@"Error cargando la Página" Text: msg ];
  NSLog( @"Error cargando la Página: %@",msg );

  _curWait.hidden = true;
  [self ShowButtonsMode:0];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se cargo la página sin problemas
- (void)webViewDidFinishLoad:(UIWebView *)webView
  {
  NSString* msg = [NSString stringWithFormat:@"Termino de Cargar:'%@'",webView.request.URL.path];
  
//  [self MsgTitle:@"Carga finalizada" Text: msg ];
  NSLog( @"Carga finalizada: %@", msg );

  _curWait.hidden = true;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se mueve al anuncio anterior
- (IBAction)OnPrev:(id)sender
  {
  --nowAnunc;
  [self ShowNowAnuncioInfo];
  [self SaveLastAnunc];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Publica el anuncio actual
- (IBAction)OnPublicar:(id)sender
  {
  NSInteger num = Anuncios.Items.count;
  if( nowAnunc >= num || nowAnunc < 0 ) return;
  
  AnuncioInfo* nowItem = Anuncios.Items[nowAnunc];
  
  NSURL *url = [NSURL URLWithString: nowItem.Url];
  
  NSBundle *Bundle = [NSBundle mainBundle];
  NSString* file = [Bundle pathForResource:@"PageTest" ofType:@"html" ];
  url = [NSURL URLWithString: file];
  
  [_webPage loadRequest:[NSURLRequest requestWithURL:url]];
  _curWait.hidden = false;
  
  [self ShowButtonsMode:1];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se mueve al proximo anuncio
- (IBAction)OnProximo:(id)sender
  {
  ++nowAnunc;
  [self ShowNowAnuncioInfo];
  [self SaveLastAnunc];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Detiene la carga de la pagina Web
- (IBAction)OnDetener:(id)sender
  {
  [_webPage stopLoading];
  [self ShowButtonsMode:0];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el contenido del anuncio actual dentro de la pagina Web
- (IBAction)OnLlenar:(id)sender
  {
  if( [self FillDatos] )
    [self ShowButtonsMode:0];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Boton para pruebas
- (IBAction)OnTest:(id)sender
  {
  [self SetJavascriptFunctions];
  
  AnuncioInfo* Anuncio = Anuncios.Items[nowAnunc];
  
  for( NSInteger i=0; i<Anuncio.FillInfo.count; i++)
    {
    HtmlInfo* info = Anuncio.FillInfo[i];
    
    NSString* jsSet = [NSString stringWithFormat:@"ShowEventsForID('%@')", info.AttrName];
    
    [_webPage stringByEvaluatingJavaScriptFromString: jsSet ];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el fichero de definición de los anuncios desde un fichero
- (void) LoadAnunciosFromFile:(NSString*) fName
  {
  NSString* file = [fName stringByAppendingString:@".txt"];
  
  NSBundle *Bundle = [NSBundle mainBundle];
  file = [Bundle.bundlePath stringByAppendingPathComponent:file];

  Anuncios = [DataAnuncios LoadFromFile:file];
  
  _curWait.hidden = true;
  
  AnuncFile = fName;
  
  [self GetNowAnunc];
  if( nowAnunc<0 || nowAnunc>=Anuncios.Items.count ) nowAnunc = 0;
  
  [self ShowNowAnuncioInfo];
  [self ShowButtonsMode:0];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda el ultimo anuncio que se esta trabajando
- (void) SaveLastAnunc
  {
  if( AnuncFile==nil ) return;
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
    
  NSNumber* lastAnunc = [NSNumber numberWithInteger:nowAnunc];
    
  [UserDef setObject:lastAnunc forKey:AnuncFile];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene cual fue el ultimo que se trabajo en el fichero actual
- (void) GetNowAnunc
  {
  if( AnuncFile!=nil )
    {
    NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
    
    NSNumber* lastAnunc = [UserDef objectForKey:AnuncFile];
    nowAnunc = (lastAnunc != nil)? lastAnunc.intValue : 0;
    
    [UserDef setObject:AnuncFile forKey:@"lastAnuncFile"];
    }
  else
    nowAnunc = 0;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Oculta los botones de acuerdo al modo de trabajo elegido
- (void) ShowButtonsMode:(int) mode
  {
  if( mode == 0 )
    {
    _btnPrevio.hidden   = false;
    _btnPublicar.hidden = false;
    _btnProximo.hidden  = false;
    _btnDetener.hidden  = true;
    _btnLlenar.hidden   = true;
    _btnTest.hidden     = true;
    }
  else
    {
    _btnPrevio.hidden   = true;
    _btnPublicar.hidden = true;
    _btnProximo.hidden  = true;
    _btnDetener.hidden  = false;
    _btnLlenar.hidden   = false;
    _btnTest.hidden     = false;
    }
  
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se cargo la página sin problemas
- (void) SetJavascriptFunctions
  {
  NSString* jsSet = @""
  @"function FindElem( TagName, Name )"
  @"  {"
  @"  var elem = document.all( Name );"
  @"  if( !elem || !elem.length ) return elem;"
    
  @"  for( var i=0; i<elem.length; ++i )"
  @"    if( elem[i].tagName == TagName )"
  @"      return elem[i];"
  @"  }"
  
  @"function FillInput( TagName, Name, Val )"
  @"  {"
  @"  var elem = FindElem( TagName, Name );"
  @"  if( !elem ) return '1';"
    
  @"  elem.value = Val;"
  @"  if( elem.onchange ) elem.onchange( this );"
  @"  return '0';"
  @"  }"
  
  @"function SelectValue( AttrName, sVal )"
  @"  {"
  @"  var elems = document.getElementsByTagName( \"select\" );"
  @"  if( !elems ) return \"1\";"
    
  @"  for( var i=0; i<elems.length; ++i )"
  @"    {"
  @"    var elem = elems[i];"
      
  @"    if( elem.name == AttrName )"
  @"      {"
  @"      elem.value = sVal;"
  @"      if( elem.onchange ) elem.onchange( this );"
  @"      return \"0\";"
  @"      }"
      
  @"    return \"3\";"
  @"    }"
  @"  }"

  @"function FillSelect( AttrName, OptText )"
  @"  {"
  @"  var elems = document.getElementsByTagName( \"select\" );"
  @"  if( !elems ) return \"1\";"
    
  @"  for( var i=0; i<elems.length; ++i )"
  @"    {"
  @"    var elem = elems[i];"
      
  @"    if( elem.name == AttrName )"
  @"      {"
  @"      var sOpt = OptText.toLowerCase();"
  @"      var Options = elem.getElementsByTagName(\"option\");"
        
  @"      for( var j=0; j<Options.length; ++j )"
  @"        {"
  @"        var opt = Options[j];"
          
  @"        if( opt.innerText.toLowerCase().indexOf(sOpt) != -1  )"
  @"          {"
  @"          opt.selected = true;"
  @"          if( elem.onchange ) elem.onchange( this );"
  @"          return \"0\";"
  @"          }"
  @"        }"
        
  @"      return \"2\";"
  @"      }"
      
  @"    return \"3\";"
  @"    }"
  @"  }";
  
  [_webPage stringByEvaluatingJavaScriptFromString: jsSet ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Llena el un Tag en en la pagina Web de acuerdo a la información suministrada
- (NSString*) FillTag:(NSString*) Tipo Name:(NSString*) Name With:(NSString*) Value
  {
  NSString* jsSet;
  
  Tipo = [Tipo uppercaseString];
  if( [Tipo isEqualToString:@"SELECT"] )
    jsSet = [NSString stringWithFormat:@"SelectValue('%@','%@')", Name, Value];
  else
    jsSet = [NSString stringWithFormat:@"FillInput('%@','%@','%@')", Tipo, Name, Value];

  return [_webPage stringByEvaluatingJavaScriptFromString: jsSet ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
/// Pone todos los datos definidos en el anuncio en la pagina actual
-(bool) FillDatos
  {
  [self SetJavascriptFunctions];
  
  AnuncioInfo* Anuncio = Anuncios.Items[nowAnunc];
  TextEval* eVal = [TextEval TextEvalWithAnucio:Anuncio];

  bool AllOk = true;
  for( NSInteger i=0; i<Anuncio.FillInfo.count; i++)
    {
    HtmlInfo* info = Anuncio.FillInfo[i];
    
    NSString* sVal = [eVal ParseValue:info.Txt];
    NSString* sRet = [self FillTag:info.TagName Name:info.AttrName With:sVal];
    
    if( ![sRet isEqualToString:@"0"] )
      {
      NSString* Msg = [NSString stringWithFormat:@"TagName:%@ AttrName:%@ Value:%@", info.TagName, info.AttrName, info.Txt ];
      [self MsgTitle:@"Error llenando un campo" Text:Msg];
      AllOk = false;
      }
    }
  
  return AllOk;
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
  
  //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
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
  TextEval* eVal = [TextEval TextEvalWithAnucio:nowItem];
  //eVal.Escape = false;

  _lbInfo.text = [NSString stringWithFormat:@"%d de %d  Identif: %@", (int)nowAnunc+1, (int)num, nowItem.ID ];
  _lbTitle.text = [eVal ParseValue:nowItem.GetTitle];
  }

//------------------------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  UIViewController* Ctrller = segue.destinationViewController;
  NSString* ID = segue.identifier;
  
  if( [ID isEqualToString:@"SelFile"] )
    ((SelFileViewController*) Ctrller).SelectedFile = AnuncFile;
  }

//------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se retorna desde otra pantalla
- (IBAction)ReturnFromUnwind:(UIStoryboardSegue *)unWindSegue
  {
  UIViewController* Ctrller = unWindSegue.sourceViewController;
  NSString* ID = unWindSegue.identifier;
  
  if( [ID isEqualToString:@"Back"] )
    {
    NSString* file = ((SelFileViewController*) Ctrller).SelectedFile;
    [self LoadAnunciosFromFile: file ];
    }
  }

@end

//========================================================================================================================================================
