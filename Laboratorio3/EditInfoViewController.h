//
//  EditInfoViewController.h
//  Laboratorio3
//
//  Created by Eleazar Garcia on 04/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *strLink;

// Para delegar y avisar que se modifico / adiciono un registro y que debe regrescarse la tabla al volver a la pantalla principal
@protocol EditInfoViewControllerDelegate

-(void)editingInfoWasFinished;

@end


// Al adicionar <UITextFieldDelegate> esta clase es donde delegaran los textfield
// Lo usaremos para -por ejemplo- esconder el teclado al presionar el boton DONE
@interface EditInfoViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) id<EditInfoViewControllerDelegate> delegate;

// Propiedades
@property (weak, nonatomic) IBOutlet UITextField *txtNombre;
@property (weak, nonatomic) IBOutlet UITextField *animo;
@property (weak, nonatomic) IBOutlet UITextField *link;
@property (weak, nonatomic) IBOutlet UITextField *txtAnimo;
@property (weak, nonatomic) IBOutlet UITextField *txtLink;

// Para la foto
@property (weak, nonatomic) IBOutlet UIImageView *imgFoto;

// para poder ocultarlo cuando se trate de un alta
@property (weak, nonatomic) IBOutlet UIButton *btnMostrarVideo;


// Como usaremos la misma pantalla para dar de alta que para editar, en ésta variable guardaremos el ID de un registro ya existente
@property (nonatomic) int recordIDToEdit;



// acciones
- (IBAction)saveInfo:(id)sender;

// Para la foto
- (IBAction)btnTomarFoto:(id)sender;

- (IBAction)btnCargarImagen:(id)sender;



@end
