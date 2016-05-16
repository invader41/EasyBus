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
#import "BusLineMapViewController.h"
#import "AppDelegate.h"
#import "FavoriteBusLine.h"
#import "UIColor+RandomColor.h"
//#import "BusStationSearchViewController.h"
//#import "BusStationSearchNavigationViewController.h"

@interface NearbyBusesViewController ()<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, locationsViewDelegate>
{
    UILabel *_locationLabel;
    UITapGestureRecognizer *_singleTapGestureRecognizer;
    NSMutableArray *_unfiltedBuses;
    NSMutableDictionary *_filtedBusesDic;
    NSMutableDictionary *_favoriteBusesDic;
    BOOL _displayFavorite;
}
- (IBAction)switchDisplayFavorite:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *anchor;
- (IBAction)randomColor:(UIBarButtonItem *)sender;
@property (strong, nonatomic) NSString *locationName;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelBottom;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favoriteBarbutton;
@end

@implementation NearbyBusesViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipLabelBottom.constant = -44;
    

    _unfiltedBuses = [NSMutableArray array];
    _filtedBusesDic = [NSMutableDictionary dictionary];
    _displayFavorite = NO;
    
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
    
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                if(!_displayFavorite)
        {
            if(self.locationName  == nil)
            {
                
                [[BaiduService SharedInstance] searchNearestStationAt:[BaiduService SharedInstance].locService.userLocation.location.coordinate
                                                              Success:^(NSArray *pois) {
                    if(pois.count > 0)
                    {
                        self.locationName  = pois[0];
                        [self refreshData:self.locationName];
                    }
                    else
                        [self.tableView.header endRefreshing];
                } Failure:^(NSError *error) {
                    [self.tableView.header endRefreshing];
                }];
            }
            else
                [self refreshData:self.locationName];
        }
        else
        {
            [self.tableView.header endRefreshing];
        }
    }];
    
    header.stateLabel.textColor = [UIColor whiteColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
    self.tableView.header = header;
    [self.tableView.header beginRefreshing];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[BaiduService SharedInstance].locService startUserLocationService];
    if(!_displayFavorite)
    {
        //[self.tableView.header beginRefreshing];
//        [[BaiduService SharedInstance] searchNearestStationSuccess:^(NSArray *pois) {
//            if(pois.count > 0)
//            {
//                self.locationName  = pois[0];
//                [self refreshData:self.locationName];
//            }
//        } Failure:^(NSError *error) {
//            [self.tableView.header endRefreshing];
//        }];
    }
    else
    {
        NSFetchRequest *search1 = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
        NSArray *favoriteBuses =  [NSMutableArray arrayWithArray:[SharedAppDelegate.managedObjectContext executeFetchRequest:search1 error:nil]];
        _favoriteBusesDic = [NSMutableDictionary dictionary];
        for(FavoriteBusLine *bus in favoriteBuses)
        {
            if(![_favoriteBusesDic.allKeys containsObject:bus.busName])
            {
                [_favoriteBusesDic setObject:[NSMutableArray array] forKey:bus.busName];
            }
            [_favoriteBusesDic[bus.busName] addObject:bus];
        }
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter setter

-(void)setLocationName:(NSString *)locationName
{
    _locationName = locationName;
    _locationLabel.text = locationName;
}

#pragma mark - private method

-(void)showTips
{
    [UIView animateWithDuration:1.5 delay:1 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{

        self.tipLabelBottom.constant = 4;
        [self.tipLabel setNeedsLayout];
        [self.tipLabel layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.tipLabelBottom.constant = 4;
        [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissTips) userInfo:nil repeats:NO];
        
    }];
    //透明度变化
//    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//    opacityAnim.duration = 2.0;
//    opacityAnim.fromValue = [NSNumber numberWithFloat:0];
//    opacityAnim.toValue = [NSNumber numberWithFloat:1];
//    opacityAnim.removedOnCompletion = YES;
//    
//    [self.tipLabel.layer addAnimation:opacityAnim forKey:nil];
    
    //[[NSTimer timerWithTimeInterval:3 target:self selector:@selector(dismissTips) userInfo:nil repeats:NO] fire];

}

-(void)dismissTips
{
    //旋转变化
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.duration = 0.5;
    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    //x，y轴缩小到0.1,Z 轴不变
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 0, 1)];
    scaleAnim.removedOnCompletion = YES;
    scaleAnim.delegate = self;
    
    [self.tipLabel.layer setTransform:CATransform3DMakeScale(1, 0, 1)];
    
    [self.tipLabel.layer addAnimation:scaleAnim forKey:@"transform"];
    
    //[self.tipLabel setHidden:YES];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.tipLabel setHidden:YES];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NearbyGuide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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

            if(_filtedBusesDic.count > 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"NearbyGuide"])
            {
                [self showTips];
            }
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
    if(!_displayFavorite)
        [self.tableView.header beginRefreshing];
}

-(void)selectedOtherLocation
{
//    BusStationSearchNavigationViewController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"BusStationSearchNavigationViewController"];
//    BusStationSearchViewController *vc = nav.viewControllers.firstObject;
//    vc.delegate = self;
//    [self presentViewController:nav animated:YES completion:NULL];
    
    [self performSegueWithIdentifier:@"SearchStations" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SearchStations"])
    {
        id vc = [segue destinationViewController];
        [vc setValue:self forKey:@"delegate"];
        [vc setValue:@0 forKey:@"type"];
    }
}


#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_displayFavorite)
        return _favoriteBusesDic.allKeys.count;
    else
        return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_displayFavorite)
        return [_favoriteBusesDic[_favoriteBusesDic.allKeys[section]] count];
    else
        return _filtedBusesDic.allKeys.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NearbyBusCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"NearbyBusCell" owner:self options:nil] firstObject];
    if(_displayFavorite)
    {
        FavoriteBusLine *bus = [_favoriteBusesDic[_favoriteBusesDic.allKeys[indexPath.section]] objectAtIndex:indexPath.row];
        cell.lineLabel.text = [NSString stringWithFormat:@"%@路",bus.busName ];
        cell.fromToLabel.text = [NSString stringWithFormat:@"开往 %@ 方向", [bus.direction componentsSeparatedByString:@">"].lastObject];
        //cell.tintColor = [UIColor darkGrayColor];
        cell.zhanLabel.hidden = YES;
        cell.favoriteStarImageView.hidden = NO;
        cell.enableGesture = NO;
    }
    else
    {
        cell.buses = _filtedBusesDic[_filtedBusesDic.allKeys[indexPath.row]];
        cell.stationLabel.text = [NSString stringWithFormat:@"距离 %@", self.locationName];
        //cell.tintColor = [UIColor darkGrayColor];
        cell.enableGesture = YES;
        [cell bindData];
    }
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    BusLineMapViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BusLineMapViewController"];
    if(!_displayFavorite)
    {
        vc.buses = _filtedBusesDic[_filtedBusesDic.allKeys[indexPath.row]];
    }
    else
    {
        FavoriteBusLine *favoriteBusLine = [_favoriteBusesDic[_favoriteBusesDic.allKeys[indexPath.section]] objectAtIndex:indexPath.row];
        Bus *bus = [Bus new];
        bus.code = favoriteBusLine.busCode;
        bus.bus = favoriteBusLine.busName;
        bus.FromTo = favoriteBusLine.direction;
        vc.buses = @[bus];
    }
    vc.currentStation = self.locationName;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:NULL];
    
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _displayFavorite;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        FavoriteBusLine *bus = [_favoriteBusesDic[_favoriteBusesDic.allKeys[indexPath.section]] objectAtIndex:indexPath.row];
        [_favoriteBusesDic[_favoriteBusesDic.allKeys[indexPath.section]] removeObjectAtIndex:indexPath.row];
        [SharedAppDelegate.managedObjectContext deleteObject:bus];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - actions

- (IBAction)switchDisplayFavorite:(UIBarButtonItem *)sender
{
    _displayFavorite = !_displayFavorite;
    [sender setTintColor:_displayFavorite? [UIColor randomColor]: [UIColor whiteColor]];
    if(_displayFavorite)
    {
        NSFetchRequest *search1 = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
        NSArray *favoriteBuses =  [NSMutableArray arrayWithArray:[SharedAppDelegate.managedObjectContext executeFetchRequest:search1 error:nil]];
        _favoriteBusesDic = [NSMutableDictionary dictionary];
        for(FavoriteBusLine *bus in favoriteBuses)
        {
            if(![_favoriteBusesDic.allKeys containsObject:bus.busName])
            {
                [_favoriteBusesDic setObject:[NSMutableArray array] forKey:bus.busName];
            }
            [_favoriteBusesDic[bus.busName] addObject:bus];
        }
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView.header beginRefreshing];
    }
}
- (IBAction)randomColor:(UIBarButtonItem *)sender
{
    BOOL random = [[NSUserDefaults standardUserDefaults] boolForKey:@"RandomColor"];
    [[NSUserDefaults standardUserDefaults] setBool:!random forKey:@"RandomColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RandomColor" object:nil];
    
//    if(_filtedBusesDic.allValues.count > 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"NearbyGuide"])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"Shake" object:nil];
//        
//    }
}
@end
