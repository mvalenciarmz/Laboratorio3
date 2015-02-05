//
//  ViewController.h
//  Laboratorio3
//
//  Created by Eleazar Garcia on 03/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditInfoViewController.h"

@interface ViewController : UIViewController

// Propiedades
@property (weak, nonatomic) IBOutlet UITableView *tblDatos;


// Acciones
- (IBAction)addNewRecord:(id)sender;

@end

