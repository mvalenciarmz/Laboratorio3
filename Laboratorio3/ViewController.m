//
//  ViewController.m
//  Laboratorio3
//
//  Created by Eleazar Garcia on 03/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"


// Para saber la lìnea actualmente seleccionada, y compartir en twitter o facebook los datos de dicha linea
NSIndexPath * currentRow;

@interface ViewController ()

@property (nonatomic, strong) DBManager *dbManager;

// Para guardar el ID del registro a consultar/modificar
@property (nonatomic) int recordIDToEdit;

@property (nonatomic, strong) NSArray *arrDatos;

// Para preguntar primero antes de borrar un registro
@property (nonatomic) int recordIDToDelete;

-(void)loadData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    // Esto es para mostrar los datos de la BD en el tableview
    self.tblDatos.delegate = self;
    self.tblDatos.dataSource = self;
    
    // Inicializamos la propiedad dbManager
    self.dbManager = [[DBManager alloc] initWithDatabaseFilename:@"DBLaboratorio3.sqlite"];
    
    // Cargamos los datos en el tableView
    [self loadData];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// Para que cuando presionen alta/cambio ... se deleguen correctamente los metodos y trabaje bien
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    EditInfoViewController *editInfoViewController = [segue destinationViewController];
    editInfoViewController.delegate = self;
    editInfoViewController.recordIDToEdit = self.recordIDToEdit;
}



// Cuando presionen el botón para adicionar un nuevo registro
- (IBAction)addNewRecord:(id)sender {
    
    // Asignamos -1 a la propiedad recordIDToEdit para indicar que es un alta
    self.recordIDToEdit = -1;    
    
    // mostramos la pantalla desde donde podremos dar de alta/ver/editar un registro
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
    
}

- (IBAction)btnCompartir:(id)sender {
    
    /*
     
    UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"COMPARTIR"
                                 message:[[self.arrDatos objectAtIndex:currentRow.row] objectAtIndex:1]
                                 delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];
    */
    
    
    NSString *strMsg;
    NSArray *activityItems;
    UIImage *imgShare;
    UIActivityViewController *actVC;
    imgShare = [UIImage imageWithData:[[self.arrDatos objectAtIndex:currentRow.row] objectAtIndex:4]];
    strMsg = @"Hola desde mi clase de iOS de la UAG en Oaxaca =)";
    activityItems = @[imgShare, strMsg];
    //Init activity view controller
    actVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    actVC.excludedActivityTypes = [NSArray arrayWithObjects:UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypeAirDrop, nil];
    [self presentViewController:actVC animated:YES completion:nil];
    
    
}


// Para cargar los datos de la BD al tableview
-(void)loadData{
    
    // Armamos la consulta
    NSString *query = @"select id, nombre, animo, link, foto from datos order by nombre";
    
    // Limpiamos el array y cargamos los datos
    if (self.arrDatos != nil) {
        self.arrDatos = nil;
    }
    self.arrDatos = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    // Recargamos el tableview
    [self.tblDatos reloadData];
}



// De la configuracion y carga de informaciòn en el tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;   // Una secciòn para ésta tabla
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrDatos.count;   // Todos los registros de la tabla se mostraran
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;   // Definimos el alto de las celdas a 60 puntos
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Dequeue the cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellRecord" forIndexPath:indexPath];
    
    // Apuntadores de cada campo, para no hacernos pelotas adelante y clarificar el codigo cuando dibujamos en la celda cada campo
    NSInteger indexOfNombre = [self.dbManager.arrColumnNames indexOfObject:@"nombre"];
    NSInteger indexOfAnimo = [self.dbManager.arrColumnNames indexOfObject:@"animo"];
//    NSInteger indexOfLink = [self.dbManager.arrColumnNames indexOfObject:@"link"];
    NSInteger indexOfFoto = [self.dbManager.arrColumnNames indexOfObject:@"foto"];
    
    // ponemos cada dato cargado en la etiqueta apropiada dentro de la celda
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:indexOfNombre]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Se siente: %@", [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:indexOfAnimo]];
    
    // Por si no trae foto, para que no truene ...
    if ( [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:indexOfFoto] != @"" ) {
        cell.imageView.image = [UIImage imageWithData:[[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:indexOfFoto] ];
    }
    
    
    return cell;
}


// Cuando presionen el boton dentro del row del tableView ... aquì lo detectamos y controlamos
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    // Obtenemos el id del registro seleccionado y lo asignamos a la propiedad recordIDToEdit
    self.recordIDToEdit = [[[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
    
    // Lanzamos la saga para que nos lleve a la pantalla de ediciòn/alta
    [self performSegueWithIdentifier:@"idSegueEditInfo" sender:self];
}


// Cuando deslicen a la izquierda una linea de la tabla, aparecerá el boton de borrar.   Si presionan cuando el estilo de edicion (edition style) sea delete, borraremos el registro y recargamos los datos
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Si tiene el estilo de edicion
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // guardamos el ID del registro para su posterior borrado
        self.recordIDToDelete = [[[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
        
 
        // Para probar cómo obtener cada uno de los datos del registro actual
        //NSLog(@"%@", [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:1] );
        //NSLog(@"%@", [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:2] );
        //NSLog(@"%@", [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:3] );
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DELETE"
                                                        message:[NSString stringWithFormat:@"%@ will be deleted, are yo sure ?", [[self.arrDatos objectAtIndex:indexPath.row] objectAtIndex:1] ]
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        [alert show];
        
    }
    
}


// Cuando seleccionen una linea, guardamos la linea seleccionada
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    currentRow = indexPath;
    
}

// En esta seccion confirmaremos que quieren borrar el registro y aqui en donde realmente se realiza el borrado
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Mantengo el comentario del autor para futuras referencias:
    // This method is invoked in response to the user's action. The altert view is about to disappear (or has been disappeard already - I am not sure)
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"NO"]) {
        // No hacemos nada
    
    } else if([title isEqualToString:@"YES"]) {
        
        // Preparamos la consulta
        NSString *query = [NSString stringWithFormat:@"delete from datos where id = %d", self.recordIDToDelete];
        
        // Ejecutamos la consulta
        [self.dbManager executeQuery:query];
        
        // Y recargamos la información
        [self loadData];
        
    }
    
}



// Para activar la recarga de info cuando graben informaciòn y regresen a la pantalla principal
-(void)editingInfoWasFinished{
    // Volvemos a cargar los datos
    [self loadData];
}

@end
