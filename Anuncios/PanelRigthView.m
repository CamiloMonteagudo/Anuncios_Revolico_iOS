//=========================================================================================================================================================
//  PopUpView.m
//  TrdSuite
//
//  Created by Camilo on 28/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "PanelRigthView.h"
//#import "AppData.h"
//#import "ColAndFont.h"

#define SEP_HOZ        6
#define SEP_VERT       2

#define ICON_WIDTH     50
#define ICON_HEIGHT    50

#define ROUND  8                 // Radio de redondeo de las esquinas
#define BRD_W  1                 // Ancho del borde de las zonas redondeadas
#define STUS_H 20                // Altura de la barra de estado del telefono

static float RowHeight;          // Altura de las filas del menú
static float PopUpWidth;         // Ancho del mené

UIColor* ColPanelBck;            // Color de fondo para el menú lateral
UIColor* ColItemBck;             // Color de fondo para los items del menu
UIColor* ColItemSel;             // Color de fondo para item seleccionado
UIColor* ColItemBorde;           // Color del borde de los Items
UIColor* ColItemTxt;             // Color de los textos del menú lateral
UIFont*  fontTitle;              // Fuente para los titulos de los modulos
CGFloat  FontSize;               // Tamaño de la letras estandard del sistema
UIFont*  fontEdit;               // Fuente para los textos editados

//=========================================================================================================================================================
@interface PanelRigthView ()
  {
  NSArray<NSString*>* ItemsID;   // Identificadores del los items del menú
  NSMutableArray * Rows;         // Filas o Item que conforman el menú
  UIView* UpView;                // Ventana superior en la jerarquia de la ventana de referencia
  UIView* Panel;                 // Vista que contiene el contenido del menú
  
  SEL OnSelAction;               // Acción que se ejecuta cuando se selecciona un item en el menu
  id  OnTarget;                  // Objeto donde se va a ejecutar la accion
  
  BOOL inClose;                  // Bandera que indica que se esta cerrando el panel
  }

@end

//=========================================================================================================================================================
@implementation PanelRigthView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un PopUp Menu, debajo de la vista view, con las listas de Iconos de cada uno de los items del menú
- (id)initInView:(UIView*)view ItemIDs:(NSArray<NSString*>*) Items
  {
  ItemsID = Items;
  
  ColPanelBck  = [UIColor colorWithRed:0.23 green:0.60 blue:0.98 alpha:0.95];   // Color de fondo para el menú lateral
  ColItemBck   = [UIColor colorWithRed:0.23 green:0.60 blue:0.98 alpha:1.00];   // Color de fondo para los items del menu
  ColItemSel   = [UIColor colorWithRed:0.50 green:0.70 blue:0.95 alpha:1.00];   // Color del item seleccionado y de los bordes
  ColItemBorde = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.00];   // Color del borde de los Items
  ColItemTxt   = [UIColor whiteColor];                                          // Color de los textos del menú lateral
  
  FontSize  = [UIFont systemFontSize];                                          // Tamaño de la letras estandard del sistema
  
  fontTitle = [UIFont boldSystemFontOfSize:1.2*FontSize];                       // Fuente para los titulos de los modulos
  fontEdit  = [UIFont systemFontOfSize:FontSize];                               // Fuente para los textos editados

  inClose = FALSE;
  
  [self PopUpWidthForItems:Items];
  
  UpView  = FindTopView( view );
  if( !UpView ) return nil;
  
  UpView.clipsToBounds = FALSE;
  
//  CGRect rc = UpView.bounds;
//  rc.origin.y = 150;
//  rc.size.width = rc.size.width + PopUpWidth;
  
  self = [super initWithFrame: UpView.bounds ];                                   // Crea una vista, con la dimensiones la de mayor jerarquia
  if( !self ) return self;                                                        // Si no la puede crear termina
  
  self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  [UpView.superview addSubview:self];                                             // Adiciona esta vista a de mayor jerarquia (La cubre de forna trasparente)
  
  [self CreatePanelWithItems:Items];                                              // Crea el panel en la parte derecha de la vista
  
  [UpView addSubview:Panel];                                                      // Adiciona el menú a la vista de fondo
  
  CGPoint pnt = Panel.center;
  pnt.x = pnt.x - Panel.frame.size.width;
    
  [UIView animateWithDuration: 0.6 animations:^{  self->Panel.center = pnt;}];    // Muestra menú animado, con la altura final

  _SelectedIdx = -1;                                                              // Por defecto no se selecciono ningun item
  _SelectedID  = @"";                                                             // Por defecto no se selecciono ningun item
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra la vista definida como el tope superior
UIView* FindTopView( UIView* FromView )
  {
  for( ; FromView!=nil; )                                                                     // Itera para encontrar la vista de mayor jerarquia
    {
    UIView* next = FromView.superview;
    if( next==nil || [next isKindOfClass: UIWindow.class ] )
      return FromView;
    
    FromView = next;
    if( next.tag == 999999)
      return FromView;
    }
  
  NSLog(@"Top view no found");
  return nil;
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Calcula el ancho del menú según el tamaño de la fuente actual
- (void) PopUpWidthForItems:(NSArray*) ItemsId
  {
//  float wTxt = 0;
//  CGSize  sz = CGSizeMake( 5000, 5000);
//  
//  for( int i=0; i<ItemsId.count; ++i )                                          // Recorre todo los nombres de los items
//    {
//    NSString* sItem = ItemsId[i];
//    
//    NSString* IdTitle = [@"Mnu" stringByAppendingString:sItem];                 // Obtiene identificador del titulo
//    NSString* strTitle = NSLocalizedString( IdTitle, nil);                      // Obtiene el titulo localizado
//    
//    CGRect rc = [strTitle boundingRectWithSize: sz
//                                       options: NSStringDrawingUsesLineFragmentOrigin
//                                    attributes: attrEdit
//                                       context: nil      ];
//    if( rc.size.width > wTxt )
//       wTxt = rc.size.width;
//    }
  
  RowHeight  = 40;
  PopUpWidth = ICON_WIDTH + SEP_HOZ + 110 + 4*SEP_HOZ;                           // Ancho del menú
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se utiliza para establecer el metodo y el objeto al que se notificará cuando se seleccione un item en el menú
- (void) OnHidePopUp:(SEL)action Target:(id)target
  {
  OnSelAction = action;                                                       // Guarda el metodo a llamar
  OnTarget    = target;                                                       // Guarda el objeto a que pertenece el metodo
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se toca en cualquier lugar de la pantalla
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
  {
  if( inClose ) return;
  inClose = TRUE;
  
  CGPoint pnt = [[touches anyObject] locationInView: self];                   // Punto de la vista en la que se produjo el toque
  [self OnToucheMenuItem:pnt];                                                // Determina si el toque se produjo sobre un item del menú
  
  CGPoint cnt = Panel.center;
  cnt.x = cnt.x + Panel.frame.size.width;

      [UIView animateWithDuration:0.6 animations:^{ self->Panel.center = cnt; }          // Anina como disminulle la altura del menú hasta desaparecer
                                  completion:^(BOOL finished)
                                    {
                                    [self removeFromSuperview];               // Quita la ventada de fondo (el menú)
                                    [self->Panel removeFromSuperview];
                                    [self NotifySelMenuItem];                 // Notifica si se toco algun item del menú
                                    }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Notifica al objeto interesado que se esta cerrando el menú de popup
- (void) NotifySelMenuItem
  {
  if( !OnSelAction || !OnTarget )                                             // Si ningún objeto se ha registrado para recivir notificación
    return;                                                                   // Termina sin hacer nada
    
  NSThread* nowThread = [NSThread currentThread];
  [OnTarget performSelector:OnSelAction onThread:nowThread withObject:self waitUntilDone:NO];       // Realiza la notificacion
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si el toque se produjo sobre uno de los items del menú
- (void) OnToucheMenuItem:(CGPoint) pnt
  {
  CGPoint pnt2 = [self convertPoint:pnt toView:Panel];                        // Refiere el punto a la vista Pop Up
    
  for( int i=0; i<Rows.count; ++i )                                           // Recorre todas las filas (Items del menú)
    {
    PanelItemView* vRow = Rows[i];                                            // Toma la vista del fila actual
    
    if( CGRectContainsPoint( vRow.frame, pnt2 ) )                             // Si el punto esta dentro de la fila actual
      {
      vRow.Selected = TRUE;                                                   // Pone la fila como seleccionada
      [vRow setNeedsDisplay];                                                 // Fuerza a que se redibuje
      
      _SelectedIdx = i;                                                       // Retorna el indice de la fila
      _SelectedID = ItemsID[i];                                               // Retorna el identificador de la fila
      return;
      }
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el panel lateral en la parte derecha de la vista con lo (oculto) items 'ItemsId'
- (void)CreatePanelWithItems:(NSArray*) ItemsId
  {
  UIEdgeInsets Mg =  [UpView layoutMargins];
  CGRect  rc = UpView.bounds;
  CGFloat w  = PopUpWidth;
  CGFloat y  = Mg.top;
  CGFloat h  = rc.size.height - Mg.top - Mg.bottom;

  CGRect  frame = CGRectMake( rc.size.width, y, w , h );                        // Crea recuadro para la vista del menú
  Panel  = [[UIView alloc] initWithFrame:frame  ];                              // Crea la vista del menú
  
  Panel.backgroundColor = ColPanelBck;                                          // Define el color de fondo del menú
  Panel.clipsToBounds   = TRUE;                                                 // Hace que se oculten las vistas fuera del recuadro del menú
  Panel.autoresizesSubviews = FALSE;
  Panel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
  
  Rows = [NSMutableArray new];                                                  // Crea arreglo vacio, para las vistas de las filas (Items del menú)
  
  float yPos = 0;                                                              // Posición inicial para el primer item del menú
  [self CreateMenuTitleInYPos:yPos];                                            // Crea un texto con el titulo del menú
  
  yPos += RowHeight;                                                            // Salta la altura del titulo
  for( int i=0; i<ItemsId.count; ++i )                                          // Recorre todo los nombres de los items
    {
    UIView* vRow = [[PanelItemView alloc] initWithItem:ItemsId[i] YPos: yPos];  // Crea la fila con el item de menu actual
    
    [Rows  addObject:vRow ];                                                    // Adiciona la fila al arreglo de filas
    [Panel addSubview:vRow];                                                    // Agrega la fila al menú
    
    yPos = yPos + RowHeight;                                                    // Calcula posición para el proximo item
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el titulo del menú
- (void)CreateMenuTitleInYPos:(CGFloat) yPos
  {
  CGRect rc = CGRectMake( 0, yPos , PopUpWidth, RowHeight);                     // Determina el recuedro para la fila
  
  UILabel* Title      = [[UILabel alloc] initWithFrame: rc];                    // Crea la vista para el titulo
  Title.text          = NSLocalizedString(@"Options", nil) ;                    // Pone el texto del titulo
  Title.textColor     = ColItemTxt;                                        // Pone el color de las letras del titulo
  Title.textAlignment = NSTextAlignmentCenter;                                  // Centra el titulo por la horizontal
  Title.font          = fontTitle;                                              // Pone el tipo de letra a utilizar
  
  //Title.shadowColor   = [UIColor blackColor];
  //Title.shadowOffset  = CGSizeMake(2, 2);
  
  [Panel addSubview: Title];                                                    // Agrega la vista del titulo a la fila
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
@implementation PanelItemView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una fila o Item del menú, con el identificador del item 'sItem' en la posición 'yPos´
- (id)initWithItem:(NSString*)sItem YPos:(float) yPos
  {
//  NSString* IdIcon  = [@"Btn" stringByAppendingString:sItem];                 // Obtiene identificador de la imagen
  NSString* IdTitle = [@"Mnu" stringByAppendingString:sItem];                 // Obtiene identificador del titulo
  
  CGRect frame = CGRectMake( 0, yPos, PopUpWidth, RowHeight);                 // Determina el recuedro para la fila
  
  self = [super initWithFrame: frame ];                                       // Crea una vista, con la dimensiones la de mayor jerarquia
  if( !self ) return self;                                                    // Si no la puede crear termina
  
  self.backgroundColor = [UIColor clearColor];
 
//  float      y = (RowHeight - ICON_HEIGHT) / 2.0;
//  CGRect rcImg = CGRectMake( SEP_HOZ, y, ICON_WIDTH, ICON_HEIGHT);            // Determina el recuadro para el icono
//
//  UIImageView* img = [[UIImageView alloc] initWithFrame: rcImg];              // Crea la vista para el icono
//  img.image         = [UIImage imageNamed: IdIcon ];                          // Carga el icono en la vista
//
//  [self addSubview: img];                                                     // Agrega la vista del icono a la fila
  
//  CGFloat xTitle  = SEP_HOZ + ICON_WIDTH;                                     // Determina la posicion donde empieza el titulo
//  CGFloat wTitle  = PopUpWidth-xTitle-SEP_HOZ-SEP_HOZ;                        // Ancho del titulo
  
  CGFloat xTitle  = 2*SEP_HOZ;                                       // Determina la posicion donde empieza el titulo
  CGFloat wTitle  = PopUpWidth-3*SEP_HOZ;                            // Ancho del titulo
  
  CGRect rcTitle  = CGRectMake( xTitle, 0, wTitle, RowHeight);                // Determina el recuadro para el titulo
  UILabel* Title  = [[UILabel alloc] initWithFrame: rcTitle];                 // Crea la vista para el titulo
  
  NSString* strTitle = NSLocalizedString( IdTitle, nil);                      // Obtiene el titulo localizado
  Title.text         = strTitle;                                              // Pone el texto del titulo
  Title.textColor    = ColItemTxt;                                       // Pone el color de las letras del titulo
  Title.font         = fontEdit;                                              // Pone el tipo de letra a utilizar
  Title.numberOfLines = 0;
  
  [self addSubview: Title];                                                   // Agrega la vista del titulo a la fila
  
  return self;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el borde de los items en el menu lateral derecho
- (void)drawRect:(CGRect)rect
  {
  CGContextRef ct = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(ct, 2);
  CGContextSetStrokeColorWithColor(ct, ColItemBorde.CGColor);
  
//  int DrawMode = kCGPathStroke;
//    DrawMode = kCGPathFillStroke;
  if( _Selected ) CGContextSetFillColorWithColor(ct, ColItemSel.CGColor);
  else            CGContextSetFillColorWithColor(ct, ColItemBck.CGColor);
  
  CGSize sz = self.frame.size;
	CGRect rc = CGRectMake( SEP_HOZ, SEP_VERT, sz.width-(2*SEP_HOZ), sz.height-(2*SEP_VERT) );
  
  float xIzq = rc.origin.x;
  float xDer = xIzq + rc.size.width;

  float ySup = rc.origin.y;
  float yInf = ySup + rc.size.height;
  
  float ycSup  = ySup + ROUND;
  float xcSupI = xIzq + ROUND;
  float xcSupD = xDer - ROUND;

  float ycInf  = yInf - ROUND;
  float xcInfI = xIzq + ROUND;
  float xcInfD = xDer - ROUND;

  CGContextBeginPath(ct);
	CGContextMoveToPoint   (ct, xcSupI, ySup  );
  CGContextAddArc        (ct, xcSupI, ycSup , ROUND, -M_PI_2, -M_PI  , 1 );
  CGContextAddLineToPoint(ct, xIzq  , ycInf );
  CGContextAddArc        (ct, xcInfI, ycInf , ROUND, -M_PI  ,  M_PI_2, 1 );
  CGContextAddLineToPoint(ct, xcInfD, yInf );
  CGContextAddArc        (ct, xcInfD, ycInf , ROUND, M_PI_2 ,  0     , 1 );
  CGContextAddLineToPoint(ct, xDer  , ycSup );
  CGContextAddArc        (ct, xcSupD, ycSup , ROUND, 0      , -M_PI_2, 1 );
  
  CGContextClosePath(ct);
    
  CGContextDrawPath( ct, kCGPathFillStroke);
  }


@end


//=========================================================================================================================================================
