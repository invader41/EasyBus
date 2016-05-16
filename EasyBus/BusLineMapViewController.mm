//
//  BusLineMapViewController.m
//  EasyBus
//
//  Created by pengsy on 15/7/20.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BusLineMapViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import <MJRefresh.h>
#import "UIImage+Rotate.h"
#import "BusService.h"
#import "BaiduService.h"
#import "ArrivalCell.h"
#import "HorizontalCell.h"
#import <Masonry.h>
#import "TemplatedTintColorButton.h"
#import "AppDelegate.h"
#import "FavoriteBusLine.h"
#import "BusLineAnnotation.h"
#import "IndexAnnotationView.h"
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]


@interface BusLineMapViewController ()<BMKMapViewDelegate, BMKBusLineSearchDelegate,BMKPoiSearchDelegate,UICollectionViewDelegate,UICollectionViewDataSource, UITableViewDataSource, BMKLocationServiceDelegate>
{
    NSMutableArray* _busPoiArray;
    NSArray *_arrivals;
    //int currentIndex;
    int currentBusIndex;
    int currentStationIndex;
    BMKPoiSearch* _poisearch;
    BMKBusLineSearch* _buslinesearch;
    BMKPointAnnotation* _annotation;
    UICollectionView *_arrivalCollectionView;
    //BMKLocationService* _locService;
}
@property (weak, nonatomic) IBOutlet UILabel *formToLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *sheetView;
@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet TemplatedTintColorButton *favoriteButton;
@property (strong, nonatomic) BMKBusLineSearch* busLineSearcher;
- (IBAction)back:(id)sender;
- (IBAction)favoriteClicked:(TemplatedTintColorButton *)sender;
- (IBAction)switchDirection:(id)sender;

@end

@implementation BusLineMapViewController

#pragma mark - life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mapView.delegate = self;
    _mapView.showMapScaleBar = YES;
    [_mapView setZoomLevel:15];
    
//    _locService = [[BMKLocationService alloc]init];
//    _locService.delegate = self;
//    [_locService startUserLocationService];
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
    
    _buslinesearch = [[BMKBusLineSearch alloc]init];
    _buslinesearch.delegate = self;
    _poisearch = [[BMKPoiSearch alloc]init];
    _poisearch.delegate = self;
    
    currentBusIndex = 0;
    currentStationIndex = 0;
    //currentIndex = -1;
    _busPoiArray = [[NSMutableArray alloc]init];
    
    [self refreshFavoriteState];
////    [self.toolView.layer setCornerRadius:6];
//    [self.toolView.layer setOpacity:0.8];
//    
////    [self.sheetView.layer setCornerRadius:6];
//    [self.sheetView.layer setOpacity:0.8];
    
    
    //[vc refreshData];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshArrivals:self.buses[currentBusIndex]];
    }];
    
    header.stateLabel.textColor = [UIColor whiteColor];
    header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
    self.tableView.header = header;
//    if(self.buses.count > 1)
//    {
//        [self.tableView addLegendFooterWithRefreshingBlock:^{
//            if(currentBusIndex +1 > self.buses.count -1)
//            {
//                currentBusIndex = 0;
//            }
//            else
//            {
//                currentBusIndex ++;
//            }
//            [self refreshArrivals:self.buses[currentBusIndex]];
//        }];
//        [self.tableView.footer setTitle:@"上拉切换线路方向" forState:MJRefreshFooterStateIdle];
//        [self.tableView.footer setTitle:@"正在切换线路方向" forState:MJRefreshFooterStateRefreshing];
//        [self.tableView.footer setTextColor:[UIColor whiteColor]];
//    }
    [self.tableView.header beginRefreshing];
    //[self refreshArrivals:self.buses[currentBusIndex]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    [BaiduService SharedInstance].locService.delegate = self;
    [[BaiduService SharedInstance].locService startUserLocationService];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    [BaiduService SharedInstance].locService.delegate = nil;
    _mapView.delegate = nil; // 不用时，置nil
    _buslinesearch.delegate = nil; // 不用时，置nil
    //_locService.delegate = nil;
}


#pragma mark - private method

-(void)refreshArrivals:(Bus *)bus
{
    [[BusService SharedInstance] searchBuslineArrivals:bus.code Success:^(NSArray *arrivals) {
        _arrivals = arrivals;
        for (int i =0; i < _arrivals.count; i++) {
            if([[_arrivals[i] stationName] isEqualToString:self.currentStation])
            {
                currentStationIndex = i;
                break;
            }
        }
        [_arrivalCollectionView reloadData];
        [self.formToLabel setAlpha:0];
        self.formToLabel.text = [NSString stringWithFormat:@"%@路 开往 %@", bus.bus, [bus.FromTo componentsSeparatedByString:@">"].lastObject];
        [UIView animateWithDuration:0.5 animations:^{
            [self.formToLabel setAlpha:1];
        } completion:^(BOOL finished) {
            [self.formToLabel setAlpha:1];
        }];
        [self loadMap];
        [self.tableView.header endRefreshing];
        //[self.tableView.footer endRefreshing];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [_arrivalCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:currentStationIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];

    } Failure:^(NSError *error)
    {
        [self.tableView.header endRefreshing];
        //[self.tableView.footer endRefreshing];
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
}

-(void)refreshFavoriteState
{
    Bus *bus = self.buses[currentBusIndex];
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busCode==%@", bus.code];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count == 0)
    {
        [self.favoriteButton setTintColor:[UIColor blackColor]];
        [self.favoriteButton setNeedsDisplay];
    }
    else
    {
        [self.favoriteButton setTintColor:[UIColor whiteColor]];
        [self.favoriteButton setNeedsDisplay];
    }
}

-(void)loadMap
{
    [_busPoiArray removeAllObjects];
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = 0;
    citySearchOption.pageCapacity = 10;
    citySearchOption.city= @"苏州";
    citySearchOption.keyword = [self.buses[0] bus];
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }
}

- (NSString*)getMyBundlePath1:(NSString *)filename
{
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ){
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent : filename];
        return s;
    }
    return nil ;
}


- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(BusLineAnnotation*)routeAnnotation
{
    BMKAnnotationView* view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end.png"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 2:
        {
            view = nil;
//            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_node"];
//            if (view == nil) {
                view = [[IndexAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:nil];
                //view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
//            }
            view.annotation = routeAnnotation;
        }
            break;
        case 3:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"rail_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"rail_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_rail.png"]];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = TRUE;
            } else {
                [view setNeedsDisplay];
            }
            
            UIImage* image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction.png"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
            
        }
            break;
        case 5:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_arrival"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_arrival"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_bus.png"]];
                //view.image = [UIImage imageNamed:@"bus-2"];
                view.canShowCallout = TRUE;
                [view setBounds:CGRectMake(0, 0, 17, 17)];
//                [view mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.width.equalTo(@20);
//                    make.height.equalTo(@20);
//                }];
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 6:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"bus_center"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc]initWithAnnotation:routeAnnotation reuseIdentifier:@"bus_center"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_center_point.png"]];
                //[view setBounds:CGRectMake(0, 0, 16, 16)];
                //view.backgroundColor = [UIColor blueColor];
                view.canShowCallout = TRUE;
            }
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    return view;
}

#pragma mark -
#pragma mark imeplement BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BusLineAnnotation class]]) {
        return [self getRouteAnnotationView:view viewForAnnotation:(BusLineAnnotation*)annotation];
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{	
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        UIColor *color = [UIColor colorWithRed:23./255. green:175./255. blue:136./255. alpha:1];
        polylineView.fillColor = [color colorWithAlphaComponent:1];
        polylineView.strokeColor = [color colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}


#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKPoiInfo* poi = nil;
        BOOL findBusline = NO;
        for (int i = 0; i < result.poiInfoList.count; i++) {
            poi = [result.poiInfoList objectAtIndex:i];
            if (poi.epoitype == 2 || poi.epoitype == 4) {
                findBusline = YES;
                [_busPoiArray addObject:poi];
            }
        }
        //开始bueline详情搜索
        if(findBusline)
        {
            NSString* strKey = ((BMKPoiInfo*) [_busPoiArray objectAtIndex:currentBusIndex]).uid;
            BMKBusLineSearchOption *buslineSearchOption = [[BMKBusLineSearchOption alloc]init];
            buslineSearchOption.city= @"苏州";
            buslineSearchOption.busLineUid= strKey;
            BOOL flag = [_buslinesearch busLineSearch:buslineSearchOption];
            if(flag)
            {
                NSLog(@"busline检索发送成功");
            }
            else
            {
                NSLog(@"busline检索发送失败");
            }
            
        }
    }
}

- (void)onGetBusDetailResult:(BMKBusLineSearch*)searcher result:(BMKBusLineResult*)busLineResult errorCode:(BMKSearchErrorCode)error
{
    int _currentStationIndex = 0;
    
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        
        BusLineAnnotation* item = [[BusLineAnnotation alloc]init];
        //判断是否正向
        BOOL zhengxiang = NO;
        if([[busLineResult.busStations[0] title] isEqualToString:[[self.buses[currentBusIndex] FromTo] componentsSeparatedByString:@">"].lastObject])
        {
            zhengxiang = NO;
        }
        else
        {
            zhengxiang = YES;
        }
        
        //站点信息
        int size = 0;
        size = busLineResult.busStations.count;
        for (int j = 0; j < size; j++) {
            BMKBusStation* station = [busLineResult.busStations objectAtIndex:j];
            item = [[BusLineAnnotation alloc]init];
            item.coordinate = station.location;
            item.title = station.title;
            item.stationName = station.title;
            item.type = 2;
            if(zhengxiang)
                item.index = j + 1;
            else
                item.index = size - j;
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationName=%@",station.title];
            NSArray *_temp = [_arrivals filteredArrayUsingPredicate:predicate];
            if(_temp.count > 0)
            {
                Arrival *arrival = _temp.firstObject;
                if(arrival.ArrivalTime.length > 0)
                {
                    item.type = 5;
                    item.title = [NSString stringWithFormat:@"%@ %@",station.title,arrival.ArrivalTime];
                }
            }
            
            if([station.title isEqualToString:self.currentStation])
            {
                //item.type = 6;
                _currentStationIndex = j;
            }
            
//            if(j == 0)
//                item.type = 0;
//            
//            if(j == size - 1)
//                item.type = 1;
            
            [_mapView addAnnotation:item];
        }
        
        
        //路段信息
        int index = 0;
        //累加index为下面声明数组temppoints时用
        for (int j = 0; j < busLineResult.busSteps.count; j++) {
            BMKBusStep* step = [busLineResult.busSteps objectAtIndex:j];
            index += step.pointsCount;
        }
        //直角坐标划线
        BMKMapPoint * temppoints = new BMKMapPoint[index];
        int k=0;
        for (int i = 0; i < busLineResult.busSteps.count; i++) {
            BMKBusStep* step = [busLineResult.busSteps objectAtIndex:i];
            for (int j = 0; j < step.pointsCount; j++) {
                BMKMapPoint pointarray;
                pointarray.x = step.points[j].x;
                pointarray.y = step.points[j].y;
                temppoints[k] = pointarray;
                k++;
            }
        }
        
        
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:index];
        [_mapView addOverlay:polyLine];
        delete temppoints;
        
        BMKBusStation* start = [busLineResult.busStations objectAtIndex:_currentStationIndex];
        [_mapView setCenterCoordinate:start.location animated:NO];
        
    }
}

#pragma mark - collectionview delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrivals.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ArrivalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    Arrival *arrival = _arrivals[indexPath.row];
    cell.stationTextView.text = arrival.stationName;
    if(indexPath.row == currentStationIndex)
    {
        //cell.stationTextView.textColor = [UIColor greenColor];
        cell.stationTextView.textColor = [UIColor whiteColor];
        cell.busIconImageView.image = [UIImage imageNamed:@"mapCurrentLocation"];
    }
    else if(arrival.ArrivalTime.length > 0)
    {
        cell.stationTextView.textColor = [UIColor colorWithRed:23./255. green:175./255. blue:136./255. alpha:1];
        cell.busIconImageView.image = [UIImage imageNamed:@"myTravelBus"];
    }
    else
    {
        cell.stationTextView.textColor = [UIColor whiteColor];
        cell.busIconImageView.image = nil;
    }
        //[cell.busIconImageView setHidden:!(arrival.ArrivalTime.length > 0)];
    //[cell.lineView setBackgroundColor:(arrival.ArrivalTime.length > 0)? [UIColor blueColor]:[UIColor greenColor]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    Arrival *arrival = _arrivals[indexPath.row];
    if(arrival.ArrivalTime.length > 0)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationName=%@", arrival.stationName];
        NSArray *_temp = [_mapView.annotations filteredArrayUsingPredicate:predicate];
        if(_temp.count > 0)
        {
            BMKPointAnnotation *ann = _temp.firstObject;
            [_mapView setCenterCoordinate:ann.coordinate animated:YES];
            [_mapView selectAnnotation:ann animated:YES];
            [_mapView setZoomLevel:15];
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Arrival *arrival = _arrivals[indexPath.row];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationName=%@", arrival.stationName];
        NSArray *_temp = [_mapView.annotations filteredArrayUsingPredicate:predicate];
        if(_temp.count > 0)
        {
            BMKPointAnnotation *ann = _temp.firstObject;
            [_mapView setCenterCoordinate:ann.coordinate animated:YES];
            [_mapView selectAnnotation:ann animated:YES];
            [_mapView setZoomLevel:15];
        }
}

#pragma mark - locationDelegate

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
}

#pragma mark - tableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HorizontalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.collectionView.delegate = self;
    cell.collectionView.dataSource = self;
    _arrivalCollectionView = cell.collectionView;
    return cell;
}


- (void)dealloc {
    if (_poisearch != nil) {
        _poisearch = nil;
    }
    if (_buslinesearch != nil) {
        _buslinesearch = nil;
    }
    
    if (_mapView) {
        _mapView = nil;
    }
    if (_busPoiArray) {
        _busPoiArray = nil;
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

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)favoriteClicked:(TemplatedTintColorButton *)sender
{
    Bus *bus = self.buses[currentBusIndex];
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busCode==%@", bus.code];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count == 0)
    {
        FavoriteBusLine *newModel = [[FavoriteBusLine alloc] initWithEntity:[NSEntityDescription entityForName:@"FavoriteBusLine" inManagedObjectContext:SharedAppDelegate.managedObjectContext] insertIntoManagedObjectContext:SharedAppDelegate.managedObjectContext];
        newModel.busCode = bus.code;
        newModel.busName = bus.bus;
        newModel.direction = bus.FromTo;
        [SharedAppDelegate.managedObjectContext insertObject:newModel];
        
    }
    else
    {
        [SharedAppDelegate.managedObjectContext deleteObject:[result firstObject]];
    }
    [SharedAppDelegate saveContext];
    [self refreshFavoriteState];
}

- (IBAction)switchDirection:(id)sender
{
    if(self.buses.count > 1)
    {
        if(currentBusIndex +1 > self.buses.count -1)
        {
            currentBusIndex = 0;
        }
        else
        {
            currentBusIndex ++;
        }
        //[self refreshArrivals:self.buses[currentBusIndex]];
    }

    //[self.tableView.header setTitle:@"正在切换线路方向" forState:MJRefreshHeaderStateRefreshing];
    [self.tableView.header beginRefreshing];

}
@end
