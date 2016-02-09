//
//  ViewController.m
//  ConnexionServeur
//
//  Created by vdemolombe on 05/02/2016.
//  Copyright © 2016 vdemolombe. All rights reserved.
//

#import "ViewController.h"
#import "MonImageViewController.h"

@interface ViewController () <NSURLConnectionDelegate>
{
    NSURLConnection *con;
    UIActivityIndicatorView *av;
   
}
@end

@implementation ViewController

-(id)init {
    if( self == [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.foTitre=    [NSMutableArray new];
    self.foSmall=    [NSMutableArray new];
    self.foUrl=    [NSMutableArray new];
    self.cacheImages=    [NSMutableDictionary new];


    [self getPhotos:@"football"];
    [self.tableView reloadData];
//    [av stopAnimating];
    
}

-(void)connection:(NSConnection*)con didReceiveResponse:(NSURLResponse *)response {
    if(!self.receiveData) {
        self.receiveData=   [NSMutableData new];
    }
    [self.receiveData setLength:0];
    NSLog(@"didrec response");
}

-(void)connection:(NSConnection*)connection didReceiveData:(NSData *)data {
    [self.receiveData appendData:data];
    NSLog(@"didrec DATA");
}

-(void)connection:(NSConnection*)connection didFailWithError:(nonnull NSError *)error {
    NSLog(@"erreur connexion");
}

-(void)connectionDidFinishLoading:(NSConnection*)connection {
    NSLog(@"succes: recu %lu bytes", (unsigned long)[self.receiveData length]);
    NSString *str=  [[NSString alloc] initWithData:self.receiveData encoding:NSUTF8StringEncoding];
    NSLog(@"on a recu: %@", str);
    
    NSError *error;
    
    NSDictionary *json= [NSJSONSerialization JSONObjectWithData:self.receiveData  options:0 error:&error];
    if(json==nil) {
        NSLog(@"ECHEC");
    } else {
        NSArray *photos =   json[@"photos"][@"photo"];
        
        for(NSDictionary *photo in photos) {
            
            NSString *titre= photo[@"title"];
            [self.foTitre addObject:(titre.length>0 ? titre : @"sans titre")];
            
            NSString *founeURL=
            [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
             [photo objectForKey:@"farm"],
             [photo objectForKey:@"server"],
             [photo objectForKey:@"id"],
             [photo objectForKey:@"secret"]];
            [self.foUrl addObject:founeURL];
 
        }
        
    }
    NSLog(@"foTitre count : %lul", (unsigned long)[self.foTitre count]);
        [av stopAnimating];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.foTitre count];
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellFlikr" forIndexPath:indexPath];
    
    cell.textLabel.text= self.foTitre[indexPath.row];
    
    cell.detailTextLabel.text= self.foUrl[indexPath.row];
    
    NSString *localPath = [[NSBundle mainBundle]bundlePath];
    NSString *imageName = [localPath stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"rien.png"]];
    cell.imageView.image=  [UIImage imageWithContentsOfFile:imageName];

    NSData *data=nil ;

    UIActivityIndicatorView *av2 =   [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    av2.color=   [UIColor blueColor];
    [av2 startAnimating];
    [cell.imageView addSubview:av2];
    
    //  si image dans le cache
    if( [self.cacheImages objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]] )   {
        data= [self.cacheImages objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        cell.imageView.image=  [UIImage imageWithData:data];
    
    } else {
        // sinon chercher image sur web
        #pragma mark - threader un bout de code
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
            NSLog(@"CHERCER WEB %lu ", indexPath.row);
            NSData *data=nil ;
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.foUrl[indexPath.row]]];
            // sauver dans cache
            [self.cacheImages setObject:data forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:indexPath];
                if (cell2) {
                    cell2.imageView.image=  [UIImage imageWithData:data];
                }
                    [av2 stopAnimating];
                [cell2 setNeedsLayout];
            });
        });
    
    }

    return cell;
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"search cancel");
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [self getPhotos:searchBar.text];
    [self.tableView reloadData];
    
}

-(void)getPhotos:(NSString*)texte {
    av =   [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    av.center=self.view.center;
    av.color=   [UIColor blueColor];
    [av startAnimating];
    [self.view addSubview:av];
    
    [self.foTitre   removeAllObjects];
    [self.foSmall   removeAllObjects ];
    [self.foUrl     removeAllObjects ];
    [self.cacheImages removeAllObjects];
    [con cancel];
    
    NSString *maS=[NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.search&tags=%@&safe_search=1&per_page=200&format=json&nojsoncallback=1&api_key=efb4fd5e04fb8f0726fbb75c02782023", texte]; //self.maSearchBarre.text];
    
    
    NSURL   *flickrGetURL =[NSURL URLWithString:maS];
    
    NSURLRequest *theRequest=[NSURLRequest
                              requestWithURL:flickrGetURL
                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                              timeoutInterval:60.0];
    
    con = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    [av stopAnimating];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        if( [segue.identifier isEqualToString:@"segueImage" ]) {
            
            NSIndexPath *ip=    [self.tableView indexPathForSelectedRow];
            
            //Destination du segue
            MonImageViewController *detailVC= segue.destinationViewController;
            UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:ip];
            detailVC.leTitre=  cell.textLabel.text;
            detailVC.leDetail=cell.detailTextLabel.text;
            detailVC.uneIUmage=   cell.imageView.image;
            
        }
  

}

@end

