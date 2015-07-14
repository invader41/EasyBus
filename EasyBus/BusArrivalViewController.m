//
//  BusArrivalViewController.m
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BusArrivalViewController.h"
#import "BusAndFavoriteCell.h"
#import <Masonry/Masonry.h>
#import <MJRefresh.h>
#import "AppDelegate.h"
#import "FavoriteCarCode.h"
#import "FavoriteBusLine.h"


@interface BusArrivalViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_busArrivalsResult;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)dismissNav:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoriteButton;
- (IBAction)addToFavorite:(id)sender;

@end

@implementation BusArrivalViewController

#pragma mark - lifecircle
- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _busArrivalsResult = [NSArray array];
    
    
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busLine==%@", self.bus.code];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count > 0)
    {
        [self.favoriteButton setTintColor:[UIColor yellowColor]];
    }
    else
    {
        [self.favoriteButton setTintColor:nil];
    }
    
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        [self fetchData];
    }];
    [_tableView.header beginRefreshing];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter setter



#pragma mark - private methods

-(void)fetchData
{
    [[BusService SharedInstance] searchBuslineArrivals:self.bus.code Success:^(NSArray *arrivals) {
        _busArrivalsResult = arrivals;
        [_tableView reloadData];
        [_tableView.header endRefreshing];
        
    } Failure:^(NSError *error) {
        
    }];
}

- (IBAction)addLPNToFavorite:(UIButton *)sender
{
    Arrival *arrival = _busArrivalsResult[self.tableView.indexPathForSelectedRow.row];
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteCarCode"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carCode==%@", arrival.carCode];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count == 0)
    {
        FavoriteCarCode *newModel = [[FavoriteCarCode alloc] initWithEntity:[NSEntityDescription entityForName:@"FavoriteCarCode" inManagedObjectContext:SharedAppDelegate.managedObjectContext] insertIntoManagedObjectContext:SharedAppDelegate.managedObjectContext];
        newModel.carCode = arrival.carCode;
        newModel.busLine = self.bus.code;
        newModel.lineName = self.bus.bus;
        [SharedAppDelegate.managedObjectContext insertObject:newModel];
        
        [sender.imageView setTintColor:[UIColor yellowColor]];
        [sender setNeedsDisplay];
    }
    else
    {
        [SharedAppDelegate.managedObjectContext deleteObject:[result firstObject]];
        [sender.imageView setTintColor:[UIColor blackColor]];
        [sender setNeedsDisplay];
    }
    [SharedAppDelegate saveContext];
}

#pragma mark - tableview source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _busArrivalsResult.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BusAndFavoriteCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BusAndFavoriteCell" owner:self options:nil] firstObject];
    
    Arrival *arrival = _busArrivalsResult[indexPath.row];
    cell.busTitleLabel.text = arrival.stationName;
    if(arrival.ArrivalTime.length > 0)
    {
        cell.backgroundColor = [UIColor greenColor];
        cell.arrivalTimeLabel.text = arrival.ArrivalTime;
        cell.LPNLabel.text = arrival.carCode;
        cell.indexPath = indexPath;
        //
        NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteCarCode"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carCode==%@", arrival.carCode];
        [search setPredicate:predicate];
        NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
        //
        if(result.count > 0)
           [cell.favoriteButton.imageView setTintColor:[UIColor yellowColor]];
        else
           [cell.favoriteButton.imageView setTintColor:[UIColor blackColor]];
        [cell.favoriteButton addTarget:self action:@selector(addLPNToFavorite:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
        cell.arrivalTimeLabel.text = @"";
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:tableView.indexPathForSelectedRow] && [(Arrival *)_busArrivalsResult[indexPath.row] ArrivalTime].length > 0) {
        return 88;
    }
    else
        return 44;
}

#pragma mark - tableview delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView beginUpdates];
    
    [tableView endUpdates];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - actions

- (IBAction)dismissNav:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissNav" object:nil];
}
- (IBAction)addToFavorite:(UIBarButtonItem*)sender
{
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busLine==%@", self.bus.code];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count == 0)
    {
        FavoriteBusLine *newModel = [[FavoriteBusLine alloc] initWithEntity:[NSEntityDescription entityForName:@"FavoriteBusLine" inManagedObjectContext:SharedAppDelegate.managedObjectContext] insertIntoManagedObjectContext:SharedAppDelegate.managedObjectContext];
        newModel.busLine = self.bus.code;
        newModel.lineName = self.bus.bus;
        [SharedAppDelegate.managedObjectContext insertObject:newModel];
        
        [sender setTintColor:[UIColor yellowColor]];
    }
    else
    {
        [SharedAppDelegate.managedObjectContext deleteObject:[result firstObject]];
        [sender setTintColor:nil];
    }
    [SharedAppDelegate saveContext];
}
@end
