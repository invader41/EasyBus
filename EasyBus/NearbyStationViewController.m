//
//  NearbyStationViewController.m
//  EasyBus
//
//  Created by pengsy on 15/6/26.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "NearbyStationViewController.h"
#import "BusService.h"
#import "BaiduService.h"
#import <Masonry.h>
#import "BusDistanceCell.h"

@interface NearbyStationViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_searchResults;
}
@end

@implementation NearbyStationViewController

#pragma mark - lifecircle

-(instancetype)initWithStationCode:(NSString *)stationCode
{
    self = [super init];
    if (self) {
        self.stationCode = stationCode;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] init];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setHidesWhenStopped:YES];
    [_indicator stopAnimating];
    [self.view addSubview:_indicator];
    
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method

-(void)refreshData
{
    [self.indicator startAnimating];
    [[BusService SharedInstance] searchBusStateByStationCode:self.stationCode Success:^(NSArray *buses) {
        _searchResults = buses;
        [_tableView reloadData];
        [self.indicator stopAnimating];
    } Failure:^(NSError *error) {
        [self.indicator stopAnimating];
    }];
}

#pragma mark - tableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BusDistanceCell *cell =  [[[NSBundle mainBundle] loadNibNamed:@"BusDistanceCell" owner:self options:nil] firstObject];
    Bus *bus = [Bus new];
    cell.busLabel.text = [NSString stringWithFormat:@"%@路", bus.bus];
    cell.fromToLabel.text = bus.FromTo;
    cell.distanceLabel.text = [NSString stringWithFormat:@"还有%@站到达", bus.distance];
    cell.timeLabel.text = bus.time;
    return cell;
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
