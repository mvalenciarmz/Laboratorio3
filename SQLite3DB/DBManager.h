//
//  DBManager.m
//  Laboratorio3
//
//  Created by Eleazar Garcia on 03/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface DBManager : NSObject

@property (nonatomic, strong) NSMutableArray *arrColumnNames;

@property (nonatomic) int affectedRows;

@property (nonatomic) long long lastInsertedRowID;


-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;

-(NSArray *)loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;

// Para grabar la imagen, tomado del còdigo de gosh
-(BOOL)guardaFoto:(NSData*)foto id:(NSString *) id;


@end
