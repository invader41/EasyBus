//
//  LocationsViewController.m
//  EasyBus
//
//  Created by pengsy on 15/7/15.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "LocationsViewController.h"
#import "BaiduService.h"
#import "BusService.h"
#import <MJRefresh.h>
#import "NearbyStationCell.h"

@interface LocationsViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_stations;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation LocationsViewController

#pragma mark - life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _stations = [NSArray array];
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView.header beginRefreshing];
}

#pragma mark - private method

-(void)refreshData
{

    [[BaiduService SharedInstance] searchNearestStationSuccess:^(NSArray *pois) {
        if(pois .count > 0)
        {
            NSString *locationName = pois[0];
            [[BusService SharedInstance] searchStationsByName:locationName Success:^(NSArray *stations) {
                _stations = stations;
                [self.tableView reloadData];
                [self.tableView.header endRefreshing];
            } Failure:^(NSError *error) {
                
            }];
        }
    } Failure:^(NSError *error) {
        [self.tableView.header endRefreshing];
    }];

}

#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _stations.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NearbyStationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if(indexPath.row== 0)
    {
        cell.iconImageView.image = [[UIImage imageNamed:@"06-magnify"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.nameLabel.text = @"搜索地址";
    }
    else
    {
        Station *station = _stations[indexPath.row - 1];
        cell.iconImageView.image = [[UIImage imageNamed:@"07-map-marker"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ | %@", station.station, station.point];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row== 0)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
        [self.delegate selectedLocation:_stations[indexPath.row - 1]];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
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
