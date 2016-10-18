//
//  BaiduService.m
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BaiduService.h"
#import <BaiduMapKit/BaiduMapAPI_Search/BMKPoiSearch.h>
#import <BaiduMapKit/BaiduMapAPI_Search/BMKSuggestionSearch.h>

@interface BaiduService()<BMKPoiSearchDelegate, BMKSuggestionSearchDelegate>
{
    //BOOL _registed;
}
@property (strong, nonatomic) BMKPoiSearch *poiSearcher;
@property (strong, nonatomic) BMKSuggestionSearch *suggestionSearcher;
@property (nonatomic, copy) ArrayBlock searchNearestStationSuccessBlock;
@property (nonatomic, copy) FailureBlock searchNearestStationFailureBlock;
@property (nonatomic, copy) ArrayBlock searchStationByNameSuccessBlock;
@property (nonatomic, copy) FailureBlock searchStationByNameFailureBlock;
@property (nonatomic, copy) ArrayBlock searchSuggestionsSuccessBlock;
@property (nonatomic, copy) FailureBlock searchSuggestionsFailureBlock;
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
//        _registed = NO;
//        _locationGetted = NO;
//        self.mapManager = [[BMKMapManager alloc]init];

    }
    return self;
}


#pragma mark - getter setter

-(BMKPoiSearch *)poiSearcher
{
    if(!_poiSearcher)
    {
        _poiSearcher =[[BMKPoiSearch alloc]init];
        _poiSearcher.delegate = self;
    }
    return _poiSearcher;
}

-(BMKSuggestionSearch *)suggestionSearcher
{
    if(!_suggestionSearcher)
    {
        _suggestionSearcher = [[BMKSuggestionSearch alloc] init];
        _suggestionSearcher.delegate = self;
    }
    return _suggestionSearcher;
}

-(BMKLocationService *)locService
{
    if(!_locService)
    {
        _locService = [[BMKLocationService alloc] init];
    }
    return _locService;
}

#pragma mark - private method

-(NSMutableArray *)distinctByName:(NSArray *)array
{
    NSMutableArray *result= [NSMutableArray array];
    for (int i= 0; i < array.count; i++)
    {
        BMKPoiInfo *info = array[i];
        if(![result containsObject:info.name] && info.epoitype == 1)
        {
            [result addObject:info.name];
        }
    }
    return result;
}
//-(void)regist:(RegistedBlock)registed
//{
//    self.registedBlock = registed;
//    if(!_registed)
//        [self.mapManager start:@"yYZuIH7pkU0GtiO5pfDDI0in" generalDelegate:self];
//    else
//        self.registedBlock(YES);
//}
//
//-(void)startUserLocationService:(LocateBlock)located
//{
//    self.locateBlock = located;
//    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
//    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
//    [BMKLocationService setLocationDistanceFilter:100.f];
//    //初始化检索对象
//    self.poiSearcher =[[BMKPoiSearch alloc]init];
//    self.poiSearcher.delegate = self;
//    
//    //初始化BMKLocationService
//    self.locService = [[BMKLocationService alloc]init];
//    self.locService.delegate = self;
//    //启动LocationService
//    [self.locService startUserLocationService];
//    
//}
//-(void)registerBaiduService
//{
//    _mapManager = [[BMKMapManager alloc]init];
//    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
//    _registed = [_mapManager start:@"8KZEMXKZuWcwBpGNsxs2Tywc"  generalDelegate:self];
//}
-(void)searchSuggestionsByName:(NSString *)name Success:(ArrayBlock)success Failure:(FailureBlock)failure
{
    BMKSuggestionSearchOption* option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = @"苏州";
    option.keyword  = name;
    self.searchSuggestionsSuccessBlock = success;
    self.searchSuggestionsFailureBlock = failure;
    BOOL flag = [self.suggestionSearcher suggestionSearch:option];
    if(flag)
    {
        NSLog(@"建议检索发送成功");
    }
    else
    {
        NSLog(@"建议检索发送失败");
    }
}

-(void)searchNearestStationAt:(CLLocationCoordinate2D)location Success:(ArrayBlock)success Failure:(FailureBlock)failure
{
    //发起检索
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
    option.location = location;
    option.radius = 1000;
    option.sortType = BMK_POI_SORT_BY_DISTANCE;
    option.keyword = @"公交站";
    option.pageCapacity = 50;
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

-(void)searchStationsByName:(NSString *)name Success:(ArrayBlock)success Failure:(FailureBlock)failure
{
    BMKCitySearchOption *option = [[BMKCitySearchOption alloc] init];
    option.city = @"苏州";
    option.keyword = name;
    self.searchStationByNameSuccessBlock = success;
    self.searchStationByNameFailureBlock = failure;
    
    BOOL flag = [self.poiSearcher poiSearchInCity:option];
    if(flag)
    {
        NSLog(@"城市检索发送成功");
    }
    else
    {
        failure(nil);
        NSLog(@"城市检索发送失败");
    }
    
}

#pragma mark - BMKSuggestionDelegate

//实现Delegate处理回调结果
- (void)onGetSuggestionResult:(BMKSuggestionSearch*)searcher result:(BMKSuggestionResult*)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        self.searchSuggestionsSuccessBlock(result.keyList);
    }
    else {
        self.searchSuggestionsFailureBlock(nil);
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark - BMKPoiSearchDelegate

-(void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        //BMKPoiInfo *poiInfo;
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"epoitype = 1"];
        if(self.searchNearestStationSuccessBlock)
        {
            self.searchNearestStationSuccessBlock([self distinctByName:poiResult.poiInfoList]);
            self.searchNearestStationSuccessBlock = nil;
            self.searchNearestStationFailureBlock = nil;
        }
        if(self.searchStationByNameSuccessBlock)
        {
            self.searchStationByNameSuccessBlock([self distinctByName:poiResult.poiInfoList]);
            self.searchStationByNameSuccessBlock = nil;
            self.searchStationByNameFailureBlock = nil;
        }
    }
    else if (errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        if(self.searchNearestStationSuccessBlock)
        {
            self.searchNearestStationFailureBlock(nil);
            self.searchNearestStationSuccessBlock = nil;
            self.searchNearestStationFailureBlock = nil;
        }
        if(self.searchStationByNameSuccessBlock)
        {
            self.searchStationByNameFailureBlock(nil);
            self.searchStationByNameSuccessBlock = nil;
            self.searchStationByNameFailureBlock = nil;
        }
        NSLog(@"起始点有歧义");
    } else {
        if(self.searchNearestStationSuccessBlock)
        {
            self.searchNearestStationSuccessBlock(nil);
            self.searchNearestStationSuccessBlock = nil;
            self.searchNearestStationFailureBlock = nil;
        }
        if(self.searchStationByNameSuccessBlock)
        {
            self.searchStationByNameSuccessBlock(nil);
            self.searchStationByNameSuccessBlock = nil;
            self.searchStationByNameFailureBlock = nil;
        }
        NSLog(@"抱歉，未找到结果");
    }
}


//#pragma mark - BMKLocationServiceDelegate
//
//- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
//{
//    //NSLog(@"heading is %@",userLocation.heading);
//}
////处理位置坐标更新
//- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
//{
//
//}
//
//-(void)didFailToLocateUserWithError:(NSError *)error
//{
//
//}

//#pragma mark - BMKGeneralDelegate
//- (void)onGetNetworkState:(int)iError
//{
//    if (0 == iError) {
//         NSLog(@"联网成功");
//    }
//    else{
//        NSLog(@"联网失败");
//        self.registedBlock(NO);
//    }
//    
//}
//
//- (void)onGetPermissionState:(int)iError
//{
//    if (0 == iError) {
//        NSLog(@"授权成功");
//        _registed = YES;
//        //设置定位精确度，默认：kCLLocationAccuracyBest
//
//        self.registedBlock(YES);
//    }
//    else {
//        NSLog(@"授权失败");
//        self.registedBlock(NO);
//    }
//}
@end
