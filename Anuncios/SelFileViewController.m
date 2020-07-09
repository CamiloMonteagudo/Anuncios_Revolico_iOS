//========================================================================================================================================================
//  SelFileViewController.m
//  Anuncios
//
//  Created by Admin on 23/10/19.
//  Copyright © 2019 BigXSoft. All rights reserved.
//========================================================================================================================================================

#import "SelFileViewController.h"

@interface SelFileViewController ()
  {
  NSMutableArray<NSString *> *DefFiles;
  NSIndexPath *SelectIdxPath;
  }

@property (weak, nonatomic) IBOutlet UITableView *FilesTable;

@end

//========================================================================================================================================================
@implementation SelFileViewController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  NSBundle *Bundle = [NSBundle mainBundle];
  NSArray<NSString *> *Files = [Bundle pathsForResourcesOfType:@"txt" inDirectory:nil];
  
  DefFiles = [NSMutableArray<NSString *> new];
  for( NSString* file in Files)
    {
    NSString *Name = [file lastPathComponent];
    NSArray<NSString*>* NameExt = [Name componentsSeparatedByString:@"."];
    [DefFiles addObject:NameExt[0]];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuado la vista se termina de mostrar
- (void)viewDidAppear:(BOOL)animated
  {
  [_FilesTable selectRowAtIndexPath:SelectIdxPath animated:TRUE scrollPosition: UITableViewScrollPositionTop];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para saber el número de datos de palabras o frases que se van a mostrar
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  return DefFiles.count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conocer la palabra que se corresponde con la fila 'row'
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  int row = (int)[indexPath row];
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Row"];
  
  NSString* AnuncFile = DefFiles[row];
  cell.textLabel.text = AnuncFile;
  
  if( [AnuncFile isEqualToString:_SelectedFile ] )
    SelectIdxPath = indexPath;
//    {
//    [tableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition: UITableViewScrollPositionTop];
//    }
  
  return cell;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al seleccionar una de las opciones de la lista
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  int row = (int)[indexPath row];

  self.SelectedFile = DefFiles[row];
  [self performSegueWithIdentifier: @"Back" sender: self];  // Retorna a la vista anterior
  }


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
//========================================================================================================================================================
