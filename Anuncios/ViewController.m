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
#import "PanelRigthView.h"
#import "EditFileViewController.h"
#import "DefFiles.h"

//========================================================================================================================================================
@interface ViewController ()
{
  DataAnuncios*   Anuncios;
  NSInteger       nowAnunc;
  
  PanelRigthView* PopUp;                                  // Vista que muestra el menú con las opciones adicionales
  
  int Modo;                                               // Mode de trabajo
  BOOL showTitle;                                         // Muestra el titulo del anuncio en la parte de arriba o no
  UIFont* InfoFont;
}

@property (weak, nonatomic) IBOutlet UIWebView *webPage;
@property (weak, nonatomic) IBOutlet UILabel *lbInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtDesc;

@property (weak, nonatomic) IBOutlet UIButton *btnPrevio;
@property (weak, nonatomic) IBOutlet UIButton *btnPublicar;
@property (weak, nonatomic) IBOutlet UIButton *btnProximo;
@property (weak, nonatomic) IBOutlet UIButton *btnDetener;
@property (weak, nonatomic) IBOutlet UIButton *btnLlenar;
@property (weak, nonatomic) IBOutlet UIButton *btnPublicado;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnMark;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *curWait;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BottomSep;
@property (weak, nonatomic) IBOutlet UIView *InfoAnuc;

- (IBAction)OnPrev:(id)sender;
- (IBAction)OnPublicar:(id)sender;
- (IBAction)OnProximo:(id)sender;
- (IBAction)OnDetener:(id)sender;
- (IBAction)OnLlenar:(id)sender;
- (IBAction)OnPublicado:(id)sender;
- (IBAction)OnShowMenu:(id)sender;
- (IBAction)OnBack:(id)sender;
- (IBAction)OnNext:(id)sender;
- (IBAction)OnClickTitle:(id)sender;
- (IBAction)OnMarcar:(id)sender;

@end

//========================================================================================================================================================
@implementation ViewController

- (void)viewDidLoad
  {
  [super viewDidLoad];
  InfoFont = _lbInfo.font;
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  
  NSString* lastFile = [UserDef objectForKey:@"lastAnuncFile"];
  [self LoadAnunciosFromFile: lastFile ];
  
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  
  // Notificaciones para cuando se muestra/oculta el teclado
  [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Evento que se produce cuando se va ha mostrar el teclado
- (void)keyboardWillShow:(NSNotification *)notification
  {
  CGFloat Bottom = 0;
  
  if( @available(iOS 11.0, *) )
    Bottom = [self.view safeAreaInsets].bottom;
  
  NSDictionary *userInfo = [notification userInfo];
  
  NSValue *KbSz = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect rcKb = [self.view convertRect:[KbSz CGRectValue] fromView:nil];
  NSTimeInterval tm = ((NSNumber*)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
  
  [UIView animateWithDuration:tm animations:^{
    self.BottomSep.constant = rcKb.size.height - Bottom;
    [self.view layoutIfNeeded];
  }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Evento que se produce cuando se va a esaconder el teclado
- (void)keyboardWillHide:(NSNotification *)notification
  {
  NSDictionary *userInfo = [notification userInfo];
  NSTimeInterval tm = ((NSNumber*)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
  
  [UIView animateWithDuration:tm animations:^{
    self.BottomSep.constant = 0;
    [self.view layoutIfNeeded];
  }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
  {
  //  NSString* msg = [NSString stringWithFormat:@"Cargando:'%@'\r\nTipo de navegación:'%d'",request.URL.absoluteString,(int)navigationType];
  
  //  [self MsgTitle:@"Va a cargar la Página" Text: msg ];
  //  NSLog( @"Va a cargar la Página: %@", msg );
  
  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
-(void)webViewDidStartLoad:(UIWebView *)webView
  {
  //  NSString* msg = [NSString stringWithFormat:@"Termino de Cargar:'%@'",webView.request.URL.path];
  
  //  [self MsgTitle:@"Carga Iniciada" Text: msg ];
  //  NSLog( @"Carga Iniciada: %@", msg );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hubo un error al cargar la página
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
  {
  //  NSString* msg = [NSString stringWithFormat:@"ERROR:%@",error.description];
  
  //  [self MsgTitle:@"Error cargando la Página" Text: msg ];
  //  NSLog( @"Error cargando la Página: %@",msg );
  
  _curWait.hidden = true;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se cargo la página sin problemas
- (void)webViewDidFinishLoad:(UIWebView *)webView
  {
  //  NSString* msg = [NSString stringWithFormat:@"Termino de Cargar:'%@'",webView.request.URL.path];
  
  //  [self MsgTitle:@"Carga finalizada" Text: msg ];
  //  NSLog( @"Carga finalizada: %@", msg );
  
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
  
  _curWait.hidden = false;
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
  
  [self getFechaforTitle:[self GetNowTitle] Check:TRUE];
  
  AnuncioInfo* nowItem = Anuncios.Items[nowAnunc];
  
  NSURL *url = [NSURL URLWithString: nowItem.Url];
  
//  NSBundle *Bundle = [NSBundle mainBundle];
//  NSString* file = [Bundle pathForResource:@"PageTest" ofType:@"html" ];
//  url = [NSURL URLWithString: file];
  
  [_webPage loadRequest:[NSURLRequest requestWithURL:url]];
  
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
// Encuentra la vista que tiene el teclado y lo esconde
UIView* HideKeyboard( UIView* view )
  {
  if( [view isFirstResponder] )
    {
    [view resignFirstResponder];
    return view;
    }
  
  for( UIView *subView in view.subviews )
    {
    if( HideKeyboard(subView) ) return subView;
    }
  
  return nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el contenido del anuncio actual dentro de la pagina Web
- (IBAction)OnLlenar:(id)sender
  {
  [self FillDatos];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Marca el anuncio como publicado y pasa al siguiente
- (IBAction)OnPublicado:(id)sender
  {
  _curWait.hidden = false;
  [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate: [NSDate date] ];   // Procesa los mensajes
  
  [self SetFechaforTitle: [self GetNowTitle]];
  
  [self OnProximo:sender];
  [self OnPublicar:sender];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando marca o desmarca un anuncio
- (IBAction)OnMarcar:(id)sender
  {
  NSString* AnuncKey = [NSString stringWithFormat:@">>>%@", [self GetNowTitle] ];

  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  NSString* sMark = [UserDef objectForKey:AnuncKey];
  
  if( sMark==nil )  [UserDef setObject:NSDate.date forKey:AnuncKey];
  else              [UserDef removeObjectForKey:AnuncKey];
  
  [self ShowNowAnuncioInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el titulo del anuncio actual
- (NSString *) GetNowTitle
  {
  NSInteger num = Anuncios.Items.count;
  if( nowAnunc >= 0 && nowAnunc < num )
    {
    AnuncioInfo* nowItem = Anuncios.Items[nowAnunc];
    return nowItem.GetTitle;
    }
  
  return @"";
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia las palabras del titulo
- (void) ChangeTitle
  {
  if( nowAnunc<0 || nowAnunc>=Anuncios.Items.count ) return;
  
  NSString* title = Anuncios.Items[nowAnunc].GetTitle;
  
  NSArray<NSString*>* Prods = [title componentsSeparatedByString:@"✅"];
  NSString* newTitle = [self ChangeWordsList:Prods];

  [Anuncios.Items[nowAnunc] SetTitle:newTitle];
  [self ShowNowAnuncioInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una cadena con las palabras de la lista ordenadas aleatoriamente
-(NSString*) ChangeWordsList:(NSArray<NSString*>*) Prods
  {
  // Obtiene una lista con todas las palabras claves
  NSMutableArray<NSString*>* words = [NSMutableArray arrayWithArray:Prods];
  
  NSMutableString* List = [NSMutableString stringWithString:@""];       // Crea cadena vacia
  if( words[0].length>0 )
    {
    NSString* wrd = [words[0] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
    
    [List appendString:wrd];
    [words removeObjectAtIndex:0];
    }
  
  while( words.count>0 )                                                // Mientras haya palabras en la lista
    {
    int idx = rand() % words.count;                                     // Obtiene indice a una palabra aleatoriamente
    
    NSString* wrd = [words[idx] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
    
    if( wrd.length>0 )
      {
      if( List.length>0 ) [List appendString:@" "];                     // Si no es la primera palabra adiciona espacio separador
      [List appendString:@"✅"];                                        // Adiciona un check mark
      [List appendString:wrd];                                          // Adiciona la palabra a la cadena
      }
    
    [words removeObjectAtIndex:idx];                                    // Borra la palabra de la lista
    }
  
  return List;                                                          // Retorna cadena con lista de palabras
}



//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el fichero de definición de los anuncios desde un fichero
- (void) LoadAnunciosFromFile:(NSString*) fName
  {
  Anuncios = [DefFiles LoadDatos:fName];
  
  _curWait.hidden = true;
  
  [self GetNowAnunc];
  if( nowAnunc<0 || nowAnunc>=Anuncios.Items.count ) nowAnunc = 0;
  
  [self ShowNowAnuncioInfo];
  [self ShowButtonsMode:0];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarde en los datos del usuario la fecha de publicación del articulo
- (void) SetFechaforTitle:(NSString*) title
  {
  NSString* AnuncKey = [title substringFromIndex:3];
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  [UserDef setObject:NSDate.date forKey:AnuncKey];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la última fecha que fue publicado el anuncio, si 'msg' es verdadero se chequea que no se haya publicado recientemente
- (NSString*) getFechaforTitle:(NSString*) title Check:(BOOL) msg
  {
  NSString* AnuncKey = [title substringFromIndex:3];
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  NSDate* fPublic = [UserDef objectForKey:AnuncKey];
  if( fPublic==nil ) return @"";
  
  NSTimeInterval tm = -[fPublic timeIntervalSinceNow];
  NSString* strTm = [self StrFromTime:tm];
  
  if( msg )
    {
    double Hour6 = 60*60*6;
    if( tm < Hour6 )
      {
      NSString* msg = [NSString stringWithFormat:@"El anuncio solo hace %@ que se publico.", strTm ];
      [self MsgTitle:@"Publicación muy frecuente" Text: msg ];
      }
    }
  
  return strTm;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una cadena con la descripción del tiempo transcurrido
- (NSString*) StrFromTime:(NSTimeInterval) tm
  {
  float Count;
  NSString* Unidad;
  
  if( tm<60       ) { Count = tm;          Unidad = @"segundos"; }
  else if( tm<60*60    ) { Count = tm/60;       Unidad = @"minutos"; }
  else if( tm<60*60*24 ) { Count = tm/60/60;    Unidad = @"horas"; }
  else                   { Count = tm/60/60/24; Unidad = @"días"; }
  
  return [NSString stringWithFormat:@"%2.2f %@", Count, Unidad ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Guarda el ultimo anuncio que se esta trabajando
- (void) SaveLastAnunc
  {
  if( DefFiles.ActualFile==nil ) return;
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  
  NSNumber* lastAnunc = [NSNumber numberWithInteger:nowAnunc];
  
  [UserDef setObject:lastAnunc forKey:DefFiles.ActualFile];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene cual fue el ultimo anuncio que se trabajo en el fichero actual
- (void) GetNowAnunc
  {
  if( DefFiles.ActualFile!=nil )
    {
    NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
    
    NSNumber* lastAnunc = [UserDef objectForKey:DefFiles.ActualFile];
    nowAnunc = (lastAnunc != nil)? lastAnunc.intValue : 0;
    
    [UserDef setObject:DefFiles.ActualFile forKey:@"lastAnuncFile"];
    }
  else
    nowAnunc = 0;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Oculta los botones de acuerdo al modo de trabajo elegido
- (void) ShowButtonsMode:(int) mode
  {
  HideKeyboard( self.view );
  
  _btnPrevio.hidden = _btnPublicar.hidden  = _btnProximo.hidden = true;
  _btnLlenar.hidden = _btnPublicado.hidden = _btnDetener.hidden = true;
  _btnMark.hidden   = true;

       if( mode == 0 ) _btnPrevio.hidden = _btnPublicar.hidden = _btnProximo.hidden = false;    // Modo Anuncios
  else if( mode == 1 ) _btnLlenar.hidden = _btnDetener.hidden  = false;                         // Modo Publicar
  else if( mode == 3 ) _btnPrevio.hidden = _btnMark.hidden     = _btnProximo.hidden  = false;   // Modo Revisar

  _InfoAnuc.hidden = (mode!=0);
  
  Modo = mode;
  
  [self ShowWebNavigate];
  [self ShowNowAnuncioInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra/Oculata los botones navegación según el modo y el contenido de la historia del navegador
- (void) ShowWebNavigate
  {
  if( Modo == 2 )
    {
    _btnBack.hidden = !_webPage.canGoBack;
    _btnNext.hidden = !_webPage.canGoForward;
    }
  else
    _btnBack.hidden = _btnNext.hidden = true;
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
 //@"  if( elem.onchange ) elem.onchange( this );"
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

//--------------------------------------------------------------------------------------------------------------------------------------------------------
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
    
    if( info.Txt==nil || info.AttrName==nil || info.TagName==nil )
      {
      //      NSLog(@"El dato '%@' fue ignorado", info.InfoName );
      continue;
      }
    
    NSString* sVal = [eVal ParseValue:info.Txt];
    NSString* sRet = [self FillTag:info.TagName Name:info.AttrName With:sVal];
    
    if( ![sRet isEqualToString:@"0"] )
      {
      NSString* Msg = [NSString stringWithFormat:@"TagName:%@ AttrName:%@ Value:%@", info.TagName, info.AttrName, info.Txt ];
      [self MsgTitle:@"Error llenando un campo" Text:Msg];
      AllOk = false;
      }
    }
  
  _btnPublicado.hidden = false;
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

//--------------------------------------------------------------------------------------------------------------------------------------------------------
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
  eVal.Escape = false;
  
  NSString* strTime =  [self getFechaforTitle:[self GetNowTitle] Check:FALSE];
  if( strTime.length > 0 )
    strTime = [NSString stringWithFormat:@"hace %@", strTime];
  
  NSString* AnuncKey = [NSString stringWithFormat:@">>>%@", [self GetNowTitle] ];
  
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  NSString* sMark = [UserDef objectForKey:AnuncKey];
  sMark = sMark==nil? @"" : @" ***";
  
  _txtDesc.contentOffset = CGPointMake(0, 0);
  
  NSString* info  = [NSString stringWithFormat:@"%d de %d  %@  %@", (int)nowAnunc+1, (int)num, strTime, sMark];
  NSString* title = [eVal ParseValue:nowItem.GetTitle];
  
  if( Modo != 0 && showTitle )
    {
    info = [NSString stringWithFormat:@"%@\r\n%@", info, title ];
    _lbInfo.font = [UIFont systemFontOfSize:10];
    }
  else
    _lbInfo.font = InfoFont;

  _lbInfo.text  = info;
  _lbTitle.text = title;
  _txtDesc.text = [eVal ParseValue:nowItem.GetDesc ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  //  UIViewController* Ctrller = segue.destinationViewController;
  //  NSString* ID = segue.identifier;
  //
  //  if( [ID isEqualToString:@"SelectFile"] )
  //    ((SelFileViewController*) Ctrller).SelectedFile = AnuncFile;
  //
  //  if( [ID isEqualToString:@"EditFile"] )
  //    ((EditFileViewController*) Ctrller).EditFile = AnuncFile;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se retorna desde otra pantalla
- (IBAction)ReturnFromUnwind:(UIStoryboardSegue *)unWindSegue
  {
  UIViewController* Ctrller = unWindSegue.sourceViewController;
  NSString* ID = unWindSegue.identifier;
  
  if( [ID isEqualToString:@"BackFormSelFile"] )
    {
    NSString* file = ((SelFileViewController*) Ctrller).SelectedFile;
    [self LoadAnunciosFromFile: file ];
    }
  
  if( [ID isEqualToString:@"BackFromEdit"] )
    {
    BOOL Saved = ((EditFileViewController*) Ctrller).Saved;
    
    if( Saved )  [self LoadAnunciosFromFile: DefFiles.ActualFile ];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir el botón para mostrar el menú
- (IBAction)OnShowMenu:(id)sender
  {
  HideKeyboard( self.view );
  
  NSMutableArray<NSString*>* ItemIDs = [NSMutableArray new];
  [ItemIDs addObject: @"File"   ];
  [ItemIDs addObject: @"Editar" ];
  
  if( Modo!=0 ) [ItemIDs addObject: @"Auncios"];
  if( Modo!=1 ) [ItemIDs addObject: @"Pubicar"];
  if( Modo!=2 ) [ItemIDs addObject: @"Navegar"];
  
  if( Modo!=3 ) [ItemIDs addObject: @"Revisar"];

  if( Modo!=0 && !showTitle ) [ItemIDs addObject: @"ShowTitle"];
  if( Modo!=0 &&  showTitle ) [ItemIDs addObject: @"HideTitle"];
  
  if( Modo<=1 ) [ItemIDs addObject: @"ChgTitle"];

  PopUp = [[PanelRigthView alloc] initInView:sender ItemIDs:ItemIDs];             // Crea un popup menú con items adicionales
  
  [PopUp OnHidePopUp:@selector(OnHidePopUp:) Target:self];                          // Pone metodo de notificación del mené
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra el menú con las opciones adicionales
- (void)OnHidePopUp:(PanelRigthView*) view
  {
  PopUp = nil;                                                                     // Indica que no hay menú a partir de este momento
  NSString* mnu = view.SelectedID;
  
       if( [mnu isEqualToString:@"File"     ] ) [self performSegueWithIdentifier: @"SelectFile" sender: self];
  else if( [mnu isEqualToString:@"Auncios"  ] ) [self ShowButtonsMode:0];
  else if( [mnu isEqualToString:@"Pubicar"  ] ) [self ShowButtonsMode:1];
  else if( [mnu isEqualToString:@"Navegar"  ] ) [self ShowButtonsMode:2];
  else if( [mnu isEqualToString:@"Revisar"  ] ) {showTitle=TRUE; [self ShowButtonsMode:3];}
  else if( [mnu isEqualToString:@"Editar"   ] ) [self performSegueWithIdentifier: @"EditFile" sender: self];
  else if( [mnu isEqualToString:@"ShowTitle"] ) {showTitle=TRUE;  [self ShowNowAnuncioInfo]; }
  else if( [mnu isEqualToString:@"HideTitle"] ) {showTitle=FALSE; [self ShowNowAnuncioInfo]; }
  else if( [mnu isEqualToString:@"ChgTitle"]  ) { [self ChangeTitle]; }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Navega a la pagina web anterior en el navegador
- (IBAction)OnBack:(id)sender
  {
  [_webPage goBack];
  
  [self ShowWebNavigate];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Navega a la pagina web siguiente en el navegador
- (IBAction)OnNext:(id)sender
  {
  [_webPage goForward];
  
  [self ShowWebNavigate];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se da click sobre el titulo del anuncio
- (IBAction)OnClickTitle:(id)sender
  {
  if( Modo==0 ) return;
  
  showTitle = !showTitle;
  [self ShowNowAnuncioInfo];
  }

@end

//========================================================================================================================================================
