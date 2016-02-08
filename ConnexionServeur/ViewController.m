//
//  ViewController.m
//  ConnexionServeur
//
//  Created by vdemolombe on 05/02/2016.
//  Copyright © 2016 vdemolombe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSURLConnectionDelegate>
{
    NSURLConnection *con;
   
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
    
//    NSURL   *flickrGetURL =[NSURL URLWithString:@"https://www.flickr.com/services/rest/?method=flickr.photos.search&tags=football&safe_search=1&per_page=20&format=json&nojsoncallback=1&api_key=efb4fd5e04fb8f0726fbb75c02782023"];
//    
//    
//    NSURLRequest *theRequest=[NSURLRequest
//                              requestWithURL:flickrGetURL
//                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                              timeoutInterval:60.0];
//    
//    NSLog(@"avant");
//    con = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
//    NSLog(@"apres");

    [self getPhotos:@"football"];
    [self.tableView reloadData];


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
    NSString *imageName = [localPath stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"rss.png"]];
    cell.imageView.image=  [UIImage imageWithContentsOfFile:imageName];

    NSData *data=nil ;

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
    [self.foTitre   removeAllObjects];
    [self.foSmall   removeAllObjects ];
    [self.foUrl     removeAllObjects ];
    [self.cacheImages removeAllObjects];
    [con cancel];
    
    NSString *maS=[NSString stringWithFormat:@"https://www.flickr.com/services/rest/?method=flickr.photos.search&tags=%@&safe_search=1&per_page=20&format=json&nojsoncallback=1&api_key=efb4fd5e04fb8f0726fbb75c02782023", texte]; //self.maSearchBarre.text];
    
    
    NSURL   *flickrGetURL =[NSURL URLWithString:maS];
    
    NSURLRequest *theRequest=[NSURLRequest
                              requestWithURL:flickrGetURL
                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                              timeoutInterval:60.0];
    
    con = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
}

@end

