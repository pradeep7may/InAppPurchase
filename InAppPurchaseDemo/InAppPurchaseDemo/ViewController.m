//
//  ViewController.m
//  InAppPurchaseDemo
//
//  Created by Pradeep Kumar Yadav on 27/05/15.
//  Copyright (c) 2015 Pradeep Kumar Yadav. All rights reserved.
//

#import "ViewController.h"
#import "InAppPurchaseHelper.h"

#define IN_APP_PRODUCT_ID   @"place your in app product id here"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)purchaseBtnTapped:(id)sender
{
  [[InAppPurchaseHelper sharedManager]requestForProduct:IN_APP_PRODUCT_ID callback:^(NSDictionary *responseDic) {
    if([[responseDic valueForKey:@"Success"] boolValue])
    {
      UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"InAPP" message:@"You have successfully purchase bundle." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alert show];
    }
    else
    {
      UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"InAPP failed" message:[responseDic valueForKey:@"Message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
      [alert show];
    }
  } ];
  

}
@end
