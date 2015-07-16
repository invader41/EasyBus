//
//  BaiduService.m
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BaiduService.h"
#import <CoreLocation/CoreLocation.h>

@interface BaiduService()<BMKGeneralDelegate, BMKPoiSearchDelegate, BMKLocationServiceDelegate>
{
    BOOL _registed;
}
@property (strong, nonatomic) BMKMapManager* mapManager;
@property (strong, nonatomic) BMKLocationService *locService;
@property (strong, nonatomic) BMKBusLineSearch* busLineSearcher;
@property (strong, nonatomic) BMKPoiSearch *poiSearcher;
@property (nonatomic, copy) StringBlock searchNearestStationSuccessBlock;
@property (nonatomic, copy) FailureBlock searchNearestStationFailureBlock;
@property (nonatomic, copy) RegistedBlock registedBlock;
@property (nonatomic, copy) LocateBlock locateBlock;
@end
@implementation BaiduService

#pragma mark - lifecircle

static BaiduService* _sharedInstance;

+(instancetype)SharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BaiduService alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registed = NO;
        _locationGetted = NO;
        self.mapManager = [[BMKMapManager alloc]init];
    }
    return self;
}


#pragma mark - getter setter


#pragma mark - private method
-(void)regist:(RegistedBlock)registed
{
    self.registedBlock = registed;
    if(!_registed)
        [self.mapManager start:@"yYZuIH7pkU0GtiO5pfDDI0in" generalDelegate:self];
    else
        self.registedBlock(YES);
}

-(void)startUserLocationService:(LocateBlock)located
{
    self.locateBlock = located;
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    //初始化检索对象
    self.poiSearcher =[[BMKPoiSearch alloc]init];
    self.poiSearcher.delegate = self;
    //初始化BMKLocationService
    self.locService = [[BMKLocationService alloc]init];
    self.locService.delegate = self;
    //启动LocationService
    [self.locService startUserLocationService];
    
}
//-(void)registerBaiduService
//{
//    _mapManager = [[BMKMapManager alloc]init];
//    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
//    _registed = [_mapManager start:@"8KZEMXKZuWcwBpGNsxs2Tywc"  generalDelegate:self];
//}

-(void)searchNearestStationSuccess:(StringBlock)success Failure:(FailureBlock)failure
{
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.location = self.locService.userLocation.location.coordinate;
    option.radius = 500;
    option.sortType = BMK_POI_SORT_BY_DISTANCE;
    option.keyword = @"公交站";
    self.searchNearestStationSuccessBlock = success;
    self.searchNearestStationFailureBlock = failure;
    BOOL flag = [self.poiSearcher poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"周边检索发送成功");
    }
    else
    {
        failure(nil);
        NSLog(@"周边检索发送失败");
    }
    
}

#pragma mark - BMKPoiSearchDelegate

-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        //BMKPoiInfo *poiInfo;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"epoitype = 1"];
        self.searchNearestStationSuccessBlock([[[poiResult.poiInfoList filteredArrayUsingPredicate:predicate] valueForKeyPath:@"@distinctUnionOfObjects.name"] reverseObjectEnumerator].allObjects);
        
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        self.searchNearestStationFailureBlock(nil);
        NSLog(@"起始点有歧义");
    } else {
        self.searchNearestStationFailureBlock(nil);
        NSLog(@"抱歉，未找到结果");
    }
}


#pragma mark - BMKLocationServiceDelegate

- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //NSLog(@"heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if(!self.locationGetted)
    {
        self.locationGetted = YES;
        self.locateBlock(YES);
    }
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

-(void)didFailToLocateUserWithError:(NSError *)error
{
    self.locateBlock(NO);
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
         NSLog(@"联网成功");
    }
    else{
        NSLog(@"联网失败");
        self.registedBlock(NO);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
        _registed = YES;
        //设置定位精确度，默认：kCLLocationAccuracyBest

        self.registedBlock(YES);
    }
    else {
        NSLog(@"授权失败");
        self.registedBlock(NO);
    }
}
@end
