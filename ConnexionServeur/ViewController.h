//
//  ViewController.h
//  ConnexionServeur
//
//  Created by vdemolombe on 05/02/2016.
//  Copyright © 2016 vdemolombe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
UISearchBarDelegate>

@property NSMutableData *receiveData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray* foTitre;
@property NSMutableArray* foSmall;
@property NSMutableArray* foUrl;
@property  NSMutableDictionary *cacheImages;

@property (weak, nonatomic) IBOutlet UISearchBar *maSearchBarre;

@property (weak, nonatomic) IBOutlet UIImageView *testImage;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *maBlurView;

@property (weak, nonatomic) IBOutlet UIImageView *maBlurImage;

- (IBAction)tapped:(UITapGestureRecognizer *)sender;
- (IBAction)rotateMoi:(UIRotationGestureRecognizer *)sender;
- (IBAction)panneMoi:(UIPanGestureRecognizer *)sender;

@end

