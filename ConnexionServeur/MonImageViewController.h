//
//  MonImageViewController.h
//  ConnexionServeur
//
//  Created by vdemolombe on 08/02/2016.
//  Copyright © 2016 vdemolombe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *refImage;
@property NSString *leTitre;
@property NSString *leDetail;
@property UIImage *uneIUmage;


@property (weak, nonatomic) IBOutlet UILabel *lesDetails;


@property (weak, nonatomic) IBOutlet UIImageView *limageIMG;

@end

