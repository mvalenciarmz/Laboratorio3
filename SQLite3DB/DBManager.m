//
//  DBManager.m
//  Laboratorio3
//
//  Created by Eleazar Garcia on 03/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>

@interface DBManager()

@property (nonatomic, strong) NSString *documentsDirectory;
@property (nonatomic, strong) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableArray *arrResults;   // Para almacenar los resultados de las consultas


-(void)copyDatabaseIntoDocumentsDirectory;

// Este mètodo es privado porque será llamado por dos métodos públicos: el primero cargara datos desde la base de dato y el segundo ejecutara consultas.   Ambos llamaran a éste, proveyendo sus propios argumentos
// El parametro es const char y no NSString * porque las funciones de SQLite no saben nada acerca de NSStrings... sólo saben manejar cadenas de C
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable;


@end






// --------------------------------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------------------------------
@implementation DBManager


// Como la base de datos forma parte del paquete, ésto se supone que hace una copia de dicha base de datos al directorio documentos de la aplicaciòn... porque no debemos trabajar con el archivo que forma parte del paquete.
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if (self) {
        // Ponemos la ruta del directorio documents en la propiedad documentsDirectory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        
        // Mantenemos el mismo nombre de la base de datos
        self.databaseFilename = dbFilename;

        // Copiamos el archivo de base de datos en el directorio documents si es necesario
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

// Basàndonos en la clase NSFileManager checamos si existe un archivo, y si no lo copiamos
// Esto se ejecuta cada que la clase DBManager es inicializada, y en teoria deberìa ser solo al instalar la app... una vez que detecta que ya existe el archivo, esta parte del còdigo se salta
-(void)copyDatabaseIntoDocumentsDirectory {

    // Checamos si el archivo de BD existe en el directorio documents
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        
        // Si el archivo no existe, lo copiamos del paquete (bundle) al que pertenece
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        // Si ocurriera algùn error, lo mandamos a la consola de errores
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        
    }
    
}




-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable {
    
    // Creamos un objeto sqlite
    sqlite3 *sqlite3Database;
    
    // Determinamos la ruta del archivo de BD
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Inicializamos el array del resultado
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Inicializamos el array de nombres de columnas
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    // Abrimos la BD
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    
    if(openDatabaseResult == SQLITE_OK) {
        
        // Declaramos un objeto sqlite3_stmt (statement) en el cual almacenaremos la consulta despues de ser compilada
        sqlite3_stmt *compiledStatement;
        
        // Cargamos todos los datos de la BD a memoria
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        
        //NSLog(@"%s", query);
        
        if (prepareStatementResult == SQLITE_OK) {
            
            // Checamos si es una consulta no-ejecutable (select)
            if (!queryExecutable) {
                
                // En èste caso, los datos deben ser cargados de la BD al array
                
                // Declaramos un array para cada linea de datos
                NSMutableArray *arrDataRow;
                
                // Recorremos el resultado y cada linea la ponemos en el array
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    
                    // Inicializamos el array que contendra los datos de cada linea
                    arrDataRow = [[NSMutableArray alloc] init];
                    
                    // Obtenemos el total de columnas
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    
                    //NSLog(@"El total de columnas es : %i", totalColumns);
                    
                    // Columna por columna obtenemos los datos
                    // La ultima SIEMPRE sera la foto en el select, por lo que aqui recorremos totalColumns -1 para que NO incluya la foto en esta seccion
                    for (int i=0; i<totalColumns -1; i++) {
                        
                        // Obtenemos el valor de la columna (campo)
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        //NSLog(@"El valor de la columna %i es : %s", i, dbDataAsChars);
                        
                        // Si existe informaciòn en el campo lo adicionamos en el array actual
                        if (dbDataAsChars != NULL) {
                            
                            // Convertimos los caracteres a string
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                            
                        }
                        
                        // Guardamos tambien el nombre de la columna
                        if (self.arrColumnNames.count != totalColumns) {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            //NSLog(@"El nombre de la columna %i es : %s", i, dbDataAsChars);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    // Ahora cargamos la foto, que SIEMPRE sera la ultima columna del SELECT
                    totalColumns = totalColumns-1;
                    // 1. Grabamos en el array de datos la imagen
                    if (sqlite3_column_blob(compiledStatement, totalColumns) != NULL) {
                        NSData *dataimg = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, totalColumns) length:sqlite3_column_bytes(compiledStatement, totalColumns)];
                        [arrDataRow addObject:dataimg];
                    } else {
                        [arrDataRow addObject:@""];
                        //(@"el campo %i de FOTO no trae nada", totalColumns);
                    }
                    
                    // 2. Y obviamente, guardamos tambien el nombre de la columna
                    char *dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, totalColumns);
                    //NSLog(@"el campo para la foto se llama : %s", dbDataAsChars);
                    [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                    
                    
                    // Guardamos cada registro en el array... siempre y cuando exista información
                    if (arrDataRow.count > 0) {
                        [self.arrResults addObject:arrDataRow];
                    }
                }
            
            // Si es una consulta ejecutable ( insert, update, delete, ...)
            } else {
                
                // Ejecutamos la consulta
                int executeQueryResults = sqlite3_step(compiledStatement);
                
                // El codigo del ejemplo lo tiene como BOOl, pero regresa un nùmero y la comparacion de la siguiente lìnea marca error porque siempre serà falso el resultado de dicha comparacion
                //BOOL executeQueryResults = sqlite3_step(compiledStatement);
                
                if (executeQueryResults == SQLITE_DONE) {
                    
                    // Obtenemos las lìneas que se afectaron al ejecutar la consutla
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    
                    // Obtenemos el ùltimo ID insertado
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                
                // Si ocurriò un error al intentar ejecutar la consulta ...
                } else {
                    
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                
                }
                
            }
            
        // Si no se pudo abrir la base de datos, mostramos un error en la consola
        } else {
            
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
        
        }
        
        // Liberamos la memoria del comando actual
        sqlite3_finalize(compiledStatement);
        
    }
    
    // Cerramos la base de datos
    sqlite3_close(sqlite3Database);
}



// Funcion para ejecutar una consulta tipo SELECT y regresar un array con la información
-(NSArray *)loadDataFromDB:(NSString *)query {
    
    // Ejecutamos la consulta e indicamos que es de tipo no-ejecutable
    // La consulta string es convertida a un objeto char*
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    
    // Regresamos en un array los resultados
    return (NSArray *)self.arrResults;
    
}


// Función para ejecutar una consulta de tipo INSERT, UPDATE, DELETE
// Aunque no regresa ningùn valor, las funciones de SQLite grabadas en propiedades, como affectedRows, proporcionan la informaciòn que haga falta
-(void)executeQuery:(NSString *)query {
    
    // Ejecutamos la consulta indicando que es de tipo ejecutable
    [self runQuery:[query UTF8String] isQueryExecutable:YES];

}


-(instancetype)initWithDatabaseFileName:(NSString *)dbFilename {
    self = [super init];
    if (self) {
        
    }
    return self;
}


// Para la imagen

// Para grabarla en la base de datos ( ya tiene que existir el registro, asi que es un update siempre, aun cuando estemos dando de alta, ya que los datos se insertaron anteriormene :(    )
- (BOOL) guardaFoto:(NSData*)foto id:(NSString *) id {

    //NSLog(@"foto vale : %@", foto);
    
    // Creamos un objeto sqlite
    sqlite3 *sqlite3Database;
    
    // Determinamos la ruta del archivo de BD
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    // Abrimos la BD
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    
    if(openDatabaseResult == SQLITE_OK) {
        
        const char* sqliteQuery = "UPDATE datos SET foto = ? WHERE id = ?";
        sqlite3_stmt* statement;
            
        if( sqlite3_prepare_v2(sqlite3Database, sqliteQuery, -1, &statement, NULL) == SQLITE_OK ){

            sqlite3_bind_blob(statement, 1, [foto bytes], (int) [foto length], SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [id UTF8String], -1, SQLITE_TRANSIENT);
            
            if (sqlite3_step(statement) == SQLITE_DONE){
            
                sqlite3_reset(statement);
                NSLog(@"La imagen ha sido guardada");
                return YES;
                
            }else{
                
                // Si hubo un error lo mostramos
                NSLog(@"El Error al guardar la imagen : %s", sqlite3_errmsg(sqlite3Database));
                return NO;
            }
            
        } else {
            
            NSLog(@"Registro FALLO (%s)", sqlite3_errmsg(sqlite3Database));
            sqlite3_reset(statement);
            return NO;
        
        }
    }
    return NO;
}


@end
