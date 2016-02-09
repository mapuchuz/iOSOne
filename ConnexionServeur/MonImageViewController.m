//
//  MonImageViewController.m
//  ConnexionServeur
//
//  Created by vdemolombe on 08/02/2016.
//  Copyright © 2016 vdemolombe. All rights reserved.
//

#import "MonImageViewController.h"

@interface MonImageViewController ()

@end

@implementation MonImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.refImage.text= self.leTitre;
    self.lesDetails.text=   self.leDetail;
    self.limageIMG.image=   self.uneIUmage;
    
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
