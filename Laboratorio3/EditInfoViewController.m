//
//  EditInfoViewController.m
//  Laboratorio3
//
//  Created by Eleazar Garcia on 04/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import "EditInfoViewController.h"

#import "DBManager.h"

@interface EditInfoViewController ()

// Como ya incluimos DBManager.h podemos usar sus metodos... asì que declaramos unas propiedades para usarla
@property (nonatomic, strong) DBManager *dbManager;


// Declaramos el mètido que cargará la información a editar ... de un registro existente claro
-(void)loadInfoToEdit;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Delegamos el comportamiento de los campos de texto
    self.txtNombre.delegate = self;
    self.txtAnimo.delegate = self;
    self.txtLink.delegate = self;

    
    // Igualamos el color de los botones regresar, con el save (que es el de màs a la derecha)
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
    // Inicializamos el objeto DBManager que definimos
    // Tal y como esta definido en la clase DBManager, checara si existe en el directorio documents y si no, lo copiara ahì
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"DBLaboratorio3.sqlite"];
    
    // Si la propiedad tiene un valor asignado como ID, entonces es un cambio/visualizaciòn y hay que cargar la info
    if (self.recordIDToEdit != -1) {
        // Lo cargamos desde la BD
        [self loadInfoToEdit];
    }

    // Si es un alta, ocultamos el botòn de ver video ... si no lo es lo mostramos
    if (self.recordIDToEdit == -1) {
        self.btnMostrarVideo.hidden = YES;
    } else {
        self.btnMostrarVideo.hidden = NO;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


// Para que desaparezca el teclado del campo de texto cuando se presione el botòn done
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)saveInfo:(id)sender {
    
    // Verificamos que todos los campos tengan informaciòn:
    if ( self.txtNombre.text.length == 0 || self.txtAnimo.text.length == 0 || self.txtLink.text.length == 0 ) {
        
        // Avisamos que falta informaciòn
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING"
                                                        message:@"All the fields are mandatory"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        
   
        // 1. Preparamos la consulta
        // Como esta pantalla se usarà para dar de alta y modificar, usaremos una propiedad para saber si ya existe un ID
        // Si la propiedad recordIDToEdit tiene un valor diferente de -1, entonces es un cambio y la consulta debe ser un update.   De otra forma es una alta y la consulta debe ser un insert
        NSString *query;
        
        if (self.recordIDToEdit == -1) {
            query = [NSString stringWithFormat:@"insert into datos( id, nombre, animo, link, foto ) values(null, '%@', '%@', '%@', nil)", self.txtNombre.text, self.txtAnimo.text, self.txtLink.text ];
            
        } else {
            query = [NSString stringWithFormat:@"update datos set nombre='%@', animo='%@', link='%@' where id=%d", self.txtNombre.text, self.txtAnimo.text, self.txtLink.text, self.recordIDToEdit ];
        }
    
        //NSLog(@"%@", query );
    
    
        // Ejecutamos la consulta
        [self.dbManager executeQuery:query];
    
    
        // Como no encontrè como grabar dentro del mismo insert o update usando executeQuery, lo hacemos por separado usando prepared statements solo para la imagen
    
    
    
        // Si la consulta fué exitosa, regresamos al view controller principal
        if (self.dbManager.affectedRows != 0) {
            NSLog(@"Consulta exitosa. Affected rows = %d", self.dbManager.affectedRows);
        
            // Informa al "delegate" que la ediciòn ha terminado
            [self.delegate editingInfoWasFinished];
        
        // Regresamos al view controller
            [self.navigationController popViewControllerAnimated:YES];
        // Si no fué exitosa, avisamos que hubo un error
        } else {
            NSLog(@"No pudo ejecutarse la consulta.");
        }

    }
}

// Cuando modifiquemos/visualicemos informaciòn, la cargamos desde la BD a los campos de texto
-(void)loadInfoToEdit{
    
    // Armamos la consulta para extraer la informacion
    NSString *query = [NSString stringWithFormat:@"select * from datos where id = %d", self.recordIDToEdit];
    
    // Cargamos los datos a un array
    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Y los asignamos a los campos de texto
    self.txtNombre.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"nombre"]];
    self.txtAnimo.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"animo"]];
    self.txtLink.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"link"]];
    
    // Para la variable
    strLink = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"link"]];
    
}


// Tomamos una foto desde la camara del celular y la ponemos en el ImageView
- (IBAction)btnTomarFoto:(id)sender {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    // image picker needs a delegate, o sease que la funciòn que toma el control esta abajo de ésta
    [imagePickerController setDelegate:self];
    
    // Colocamos la imagen en la pantalla
    [self presentViewController: imagePickerController animated:YES completion:nil];
    
}


//delegate methode will be called after picking photo either from camera or library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self.imgFoto setImage:image];    // "myImageView" name of any UIImageView.
}



- (IBAction)btnCargarImagen:(id)sender {
    
    UIImagePickerController *imagePickerController= [[UIImagePickerController alloc] init];
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // image picker needs a delegate, o sease que la función que toma el control está arriba de ésta
    [imagePickerController setDelegate:self];
    
    // Colocamos la imagen en la pantalla
    [self presentViewController: imagePickerController animated:YES completion:nil];
    
}


@end
