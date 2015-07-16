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

@interface NearbyBusesViewController ()<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, lcationsViewDelegate>
{
    UILabel *_locationLabel;
    UITapGestureRecognizer *_singleTapGestureRecognizer;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *anchor;

@end

@implementation NearbyBusesViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];

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

    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private method

- (void)selectLocation:(id)sender
{
    LocationsViewController *locationsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
    locationsVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = locationsVC.popoverPresentationController;
    popover.backgroundColor = [UIColor darkGrayColor];
    popover.sourceView = self.anchor;
    popover.delegate = self;
    [self presentViewController:locationsVC animated:YES completion:^{
        
    }];
}

-(void)refreshData
{
    [[BaiduService SharedInstance] searchNearestStationSuccess:^(NSArray *pois) {
        if(pois .count > 0)
        {
            NSString *locationName = pois[0];
            [[BusService SharedInstance] searchStationsByName:locationName Success:^(NSArray *stations) {
                
            } Failure:^(NSError *error) {
                
            }];
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        }
    } Failure:^(NSError *error) {
        [self.tableView.header endRefreshing];
    }];
}

#pragma mark - pop

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - locationView

-(void)selectedLocation:(NSString *)location
{
    
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
    return 0;
}
@end
