//
//  NearbyBusesViewController.m
//  EasyBus
//
//  Created by pengsy on 15/7/14.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "NearbyBusesViewController.h"
#import <MJRefresh.h>
#import "BusService.h"
#import "BaiduService.h"
#import <Masonry.h>
#import "LocationsViewController.h"
#import "NearbyBusCell.h"

@interface NearbyBusesViewController ()<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, locationsViewDelegate>
{
    UILabel *_locationLabel;
    UITapGestureRecognizer *_singleTapGestureRecognizer;
    NSMutableArray *_unfiltedBuses;
    NSMutableDictionary *_filtedBusesDic;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *anchor;
@property (strong, nonatomic) NSString *locationName;
@end

@implementation NearbyBusesViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];

    _unfiltedBuses = [NSMutableArray array];
    _filtedBusesDic = [NSMutableDictionary dictionary];
    
    //titleview
    UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    titleView.backgroundColor = [UIColor blackColor];
    
    _locationLabel = [UILabel new];
    _locationLabel.userInteractionEnabled = YES;
    [_locationLabel setTextColor:[UIColor whiteColor]];
    _locationLabel.text = @"正在定位";
    UIImageView *titleicon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"07-map-marker"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    titleicon.tintColor = [UIColor whiteColor];
    
    [titleView addSubview:titleicon];
    [titleView addSubview:_locationLabel];
    
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(titleView);
        //make.left.equalTo(titleView).offset(20);
    }];
    [titleicon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@12);
        make.left.equalTo(_locationLabel).offset(-18);
        make.centerY.equalTo(titleView);
    }];
    
    [titleView addTarget:self action:@selector(selectLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = titleView;

    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        if(self.locationName  == nil)
        {
            [[BaiduService SharedInstance] searchNearestStationSuccess:^(NSArray *pois) {
                if(pois.count > 0)
                {
                    self.locationName  = pois[0];
                    [self refreshData:self.locationName];
                }
            } Failure:^(NSError *error) {
                [self.tableView.header endRefreshing];
            }];
        }
        else
            [self refreshData:self.locationName];
    }];
    [self.tableView.header setTextColor:[UIColor whiteColor]];
    [self.tableView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter setter

-(void)setLocationName:(NSString *)locationName
{
    _locationName = locationName;
    _locationLabel.text = _locationName;
}

#pragma mark - private method

- (void)selectLocation:(id)sender
{
    LocationsViewController *locationsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
    locationsVC.delegate = self;
    locationsVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = locationsVC.popoverPresentationController;
    popover.backgroundColor = [UIColor darkGrayColor];
    popover.sourceView = self.anchor;
    popover.delegate = self;
    [self presentViewController:locationsVC animated:YES completion:^{
        
    }];
}

-(void)refreshData:(NSString *)locationName
{
    [[BusService SharedInstance] searchStationsByName:locationName Success:^(NSArray *stations) {
        [_unfiltedBuses removeAllObjects];
        [self searchBusStateInStations:stations fromIndex:0];
    } Failure:^(NSError *error) {
        [self.tableView.header endRefreshing];
    }];

}

-(void)searchBusStateInStations:(NSArray *)stations fromIndex:(int)index
{
    __block int _index = index;
    [[BusService SharedInstance] searchBusStateByStationCode:[stations[_index] stationCode] Success:^(NSArray *buses) {
        [_unfiltedBuses addObjectsFromArray:buses];
        _index ++;
        if(_index > stations.count -1 )
        {
            _filtedBusesDic = [self filterBuses:_unfiltedBuses];
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        }
        else
        {
            [self searchBusStateInStations:stations fromIndex:_index];
        }
    } Failure:^(NSError *error)
    {
        [self.tableView.header endRefreshing];
    }];
}

-(NSMutableDictionary *)filterBuses:(NSArray *)buses
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for(Bus *bus in buses)
    {
        if(![dic.allKeys containsObject:bus.bus])
        {
            [dic setObject:[NSMutableArray array] forKey:bus.bus];
        }
        [dic[bus.bus] addObject:bus];
    }
    return dic;
}

#pragma mark - pop

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - locationView

-(void)selectedLocation:(NSString *)location
{
    self.locationName = location;
    [self.tableView.header beginRefreshing];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _filtedBusesDic.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NearbyBusCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"NearbyBusCell" owner:self options:nil] firstObject];
    cell.buses = _filtedBusesDic[_filtedBusesDic.allKeys[indexPath.row]];
    cell.stationLabel.text = [NSString stringWithFormat:@"距离 %@", self.locationName];
    [cell bindData];
    return cell;
    
}
@end
