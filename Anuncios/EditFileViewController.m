//========================================================================================================================================================
//  EditFileViewController.m
//  Anuncios
//
//  Created by Admin on 08/11/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "EditFileViewController.h"
#import "DefFiles.h"
#import "PanelRigthView.h"

@interface EditFileViewController ()
  {
  NSString* nowFile;
  BOOL SaveAs;
  
  PanelRigthView* PopUp;                                  // Vista que muestra el menú con las opciones adicionales
  }

@property (weak, nonatomic) IBOutlet UILabel *lbFilename;
@property (weak, nonatomic) IBOutlet UITextView *txtEditFile;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hBottom;
@property (weak, nonatomic) IBOutlet UITextField *txtFileName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *xFileName;

- (IBAction)OnSelOptions:(id)sender;
- (IBAction)OnNewName:(id)sender;
- (IBAction)OnCancelName:(id)sender;

@end

//========================================================================================================================================================
@implementation EditFileViewController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  [self IniEdition];
  
  NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
  
  // Notificaciones para cuando se muestra/oculta el teclado
  [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los datos de la edición de un fichero de anuncios
- (void)IniEdition
  {
  nowFile = DefFiles.ActualFile;
  
  _Saved = FALSE;
  _lbFilename.text = nowFile;
  _txtEditFile.text = [DefFiles LoadText:nowFile];
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
    self.hBottom.constant = rcKb.size.height - Bottom;
    [self.view layoutIfNeeded]; }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Evento que se produce cuando se va a esaconder el teclado
- (void)keyboardWillHide:(NSNotification *)notification
  {
  NSDictionary *userInfo = [notification userInfo];
  NSTimeInterval tm = ((NSNumber*)[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]).doubleValue;
  
  [UIView animateWithDuration:tm animations:^{
    self.hBottom.constant = 0;
    [self.view layoutIfNeeded]; }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra la vista que tiene el teclado y lo esconde
- (UIView*) HideKeyboard:(UIView*) view
  {
  if( [view isFirstResponder] )
    {
    [view resignFirstResponder];
    return view;
    }
  
  for( UIView *subView in view.subviews )
    {
    if( [self HideKeyboard:subView] ) return subView;
    }
  
  return nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el botón para mostrar el menú de opciones
- (IBAction)OnSelOptions:(id)sender
  {
  [self HideKeyboard:self.view];
  
  int Loc = [DefFiles GetLocOfFile:nowFile];
  
  NSMutableArray* ItemIDs = [NSMutableArray new];
  [ItemIDs addObject: @"Salir"     ];
  [ItemIDs addObject: @"Guardar"   ];
  [ItemIDs addObject: @"Nuevo"     ];
  [ItemIDs addObject: @"SaveAs"    ];
  
  if( Loc==3 ) [ItemIDs addObject: @"Restaurar" ];
  if( Loc==2 ) [ItemIDs addObject: @"Borrar"    ];
  
  PopUp = [[PanelRigthView alloc] initInView:sender ItemIDs:ItemIDs];             // Crea un popup menú con items adicionales
  
  [PopUp OnHidePopUp:@selector(OnHidePopUp:) Target:self];                          // Pone metodo de notificación del mené
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra el menú con las opciones adicionales
- (void)OnHidePopUp:(PanelRigthView*) view
  {
  PopUp = nil;                                                                     // Indica que no hay menú a partir de este momento
  
  NSString* mnu = view.SelectedID;
  
       if( [mnu isEqualToString:@"Salir"    ] ) [self OnSalir];
  else if( [mnu isEqualToString:@"Guardar"  ] ) [self OnGuardar];
  else if( [mnu isEqualToString:@"Nuevo"    ] ) [self OnNuevo];
  else if( [mnu isEqualToString:@"Restaurar"] ) [self OnRestaurar];
  else if( [mnu isEqualToString:@"Borrar"   ] ) [self OnBorrar];
  else if( [mnu isEqualToString:@"SaveAs"   ] ) [self OnSaveAs];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnSalir
  {
  _Saved = FALSE;
  
  [self performSegueWithIdentifier: @"BackFromEdit" sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnGuardar
  {
   _Saved = [DefFiles SaveText:_txtEditFile.text InFile:nowFile];
  
  [self performSegueWithIdentifier: @"BackFromEdit" sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnNuevo
  {
  SaveAs = FALSE;
  
  [UIView animateWithDuration:0.6 animations:^{
    self.xFileName.constant = 0;
    [self.view layoutIfNeeded]; }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnSaveAs
  {
  SaveAs = TRUE;
  
  [UIView animateWithDuration:0.6 animations:^{
    self.xFileName.constant = 0;
    [self.view layoutIfNeeded]; }];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnRestaurar
  {
  [DefFiles DeleteFile:nowFile];
  [self IniEdition];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnBorrar
  {
  [DefFiles DeleteFile:nowFile];
  
  [self performSegueWithIdentifier: @"SelectFile" sender: self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Optiene un nuevo nombre para el fichero
- (IBAction)OnNewName:(id)sender
  {
  NSString* fName = _txtFileName.text;
  
  NSString* Text = @"";
  if( SaveAs ) Text = _txtEditFile.text;
  
  [DefFiles SaveText:Text InFile:fName];
  [DefFiles LoadDatos:fName];
  
  [self IniEdition];
  [self OnCancelName:sender];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Oculta la vista de optener el nombre del fichero
- (IBAction)OnCancelName:(id)sender
  {
  [self HideKeyboard:self.view];
  
  CGFloat w = self.view.bounds.size.width;
  
  [UIView animateWithDuration:0.6 animations:^{
    self.xFileName.constant = -w;
    [self.view layoutIfNeeded]; }];
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



@end
//========================================================================================================================================================
