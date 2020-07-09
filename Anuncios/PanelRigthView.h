//=========================================================================================================================================================
//  PopUpView.h
//  TrdSuite
//
//  Created by Camilo on 28/04/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <UIKit/UIKit.h>

//=========================================================================================================================================================
@interface PanelRigthView : UIView

- (id)initInView:(UIView*)view ItemIDs:(NSArray<NSString*>*) Items;
- (void) OnHidePopUp:(SEL)action Target:(id)target;

@property(nonatomic,readonly)       int SelectedIdx;        // Indice de la selección
@property(nonatomic,readonly) NSString* SelectedID;         // Identificador de la selección

@end

//=========================================================================================================================================================
@interface PanelItemView : UIView

- (id)initWithItem:(NSString*)sItem YPos:(float) yPos;

@property(nonatomic) BOOL Selected;

@end

//=========================================================================================================================================================
