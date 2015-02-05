//
//  ViewController.h
//  Laboratorio3
//
//  Created by Eleazar Garcia on 03/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditInfoViewController.h"

// Para compartir socialmente en facebook, twitter y lo que se acumule en la semana
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h> 


@interface ViewController : UIViewController

// Propiedades
@property (weak, nonatomic) IBOutlet UITableView *tblDatos;
@property (weak, nonatomic) IBOutlet UIImageView *imgFotoEnTabla;


// Acciones
- (IBAction)addNewRecord:(id)sender;
- (IBAction)btnCompartir:(id)sender;

@end

