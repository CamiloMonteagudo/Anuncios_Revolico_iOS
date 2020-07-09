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
  
  PanelRigthView* PopUp;                                  // Vista que muestra el menú con las opciones adicionales
  }

@property (weak, nonatomic) IBOutlet UILabel *lbFilename;
@property (weak, nonatomic) IBOutlet UITextView *txtEditFile;

- (IBAction)OnGuardar:(id)sender;

@end

//========================================================================================================================================================
@implementation EditFileViewController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  nowFile = DefFiles.ActualFile;
  
  _Saved = FALSE;
  _lbFilename.text = nowFile;
  _txtEditFile.text = [DefFiles LoadText:nowFile];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnGuardar:(id)sender
  {
  //HideKeyboard( self.view );
  
  NSMutableArray* ItemIDs = [NSMutableArray new];
  [ItemIDs addObject: @"Salir"     ];
  [ItemIDs addObject: @"Guardar"   ];
  [ItemIDs addObject: @"Nuevo"     ];
  [ItemIDs addObject: @"Restaurar" ];
  [ItemIDs addObject: @"Borrar"    ];
  [ItemIDs addObject: @"SaveAs"    ];

  PopUp = [[PanelRigthView alloc] initInView:sender ItemIDs:ItemIDs];             // Crea un popup menú con items adicionales
  
  [PopUp OnHidePopUp:@selector(OnHidePopUp:) Target:self];                          // Pone metodo de notificación del mené

//  [DefFiles SaveText:_txtEditFile.text InFile:nowFile];
//
//  _Saved = TRUE;
//  [self performSegueWithIdentifier: @"BackFromEdit" sender: self];  // Retorna a la vista anterior
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra el menú con las opciones adicionales
- (void)OnHidePopUp:(PanelRigthView*) view
  {
  PopUp = nil;                                                                     // Indica que no hay menú a partir de este momento
  
  switch( view.SelectedItem )
    {
    case 0: [self OnSalir];     break;
    case 1: [self OnGuardar];   break;
    case 2: [self OnNuevo];     break;
    case 3: [self OnRestaurar]; break;
    case 4: [self OnBorrar];    break;
    case 5: [self OnSaveAs];    break;
    }
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
  [self MsgTitle:@"Mensaje" Text:@"La opción 'Nuevo' no se ha implementado"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnRestaurar
  {
  [self MsgTitle:@"Mensaje" Text:@"La opción 'Restaurar' no se ha implementado"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnBorrar
  {
  [self MsgTitle:@"Mensaje" Text:@"La opción 'Borrar' no se ha implementado"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnSaveAs
  {
  [self MsgTitle:@"Mensaje" Text:@"La opción 'Guardar Como' no se ha implementado"];
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
