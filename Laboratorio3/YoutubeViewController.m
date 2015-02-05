//
//  YoutubeViewController.m
//  Laboratorio3
//
//  Created by Eleazar Garcia on 04/02/15.
//  Copyright (c) 2015 Marcos. All rights reserved.
//

#import "YoutubeViewController.h"

NSString *strLink;

@interface YoutubeViewController ()

@end

@implementation YoutubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url= [NSURL URLWithString:strLink];
    
    NSLog(@"%@", strLink);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
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

@end
