//
//  JHService.m
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "JHService.h"
#import <MJExtension.h>

@implementation JHService

static JHService* _sharedInstance;

+(instancetype)SharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[JHService alloc] init];
    });
    return _sharedInstance;
}

-(void)registerJHService
{
     [[JHOpenidSupplier shareSupplier] registerJuheAPIByOpenId:OPENID];
}

-(void)searchStationsByName:(NSString *)stationName Success:(void (^)(NSArray *))success Failure:(void (^)(NSError *))failure
{
    NSString *path = @"http://apis.juhe.cn/szbusline/bus";
    NSString *api_id = @"31";
    NSString *method = @"GET";
    NSDictionary *param = @{@"station":stationName, @"dtype":@"json", @"key":APPKEY};
    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
    
    [juheapi executeWorkWithAPI:path
                          APIID:api_id
                     Parameters:param
                         Method:method
                        Success:^(id responseObject) {
                            CommonModel *model = [CommonModel objectWithKeyValues:responseObject];
                            NSArray *stations = [Station objectArrayWithKeyValuesArray:model.result];
                            success(stations);
                        }
                        Failure:^(NSError *error) {
                            failure(error);
                        }];
}

-(void)searchBusStateByStation:(NSString *)stationCode
                       Success:(void (^)(NSArray *buses))success
                       Failure:(void (^)(NSError *error))failure
{
    
}

-(void)searchBuslines:(NSString *)bus
              Success:(void (^)(NSArray *lines))success
              Failure:(void (^)(NSError *error))failure
{
    NSString *path = @"http://apis.juhe.cn/szbusline/bus";
    NSString *api_id = @"31";
    NSString *method = @"GET";
    NSDictionary *param = @{@"bus":bus, @"dtype":@"json", @"key":APPKEY};
    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
    
    [juheapi executeWorkWithAPI:path
                          APIID:api_id
                     Parameters:param
                         Method:method
                        Success:^(id responseObject) {
                            CommonModel *model = [CommonModel objectWithKeyValues:responseObject];
                            NSArray *buses = [Bus objectArrayWithKeyValuesArray:model.result];
                            success(buses);
                        }
                        Failure:^(NSError *error) {
                            failure(error);
                        }];
}

-(void)searchBuslineArrivals:(NSString *)buslineCode
                     Success:(void (^)(NSArray *arrivals))success
                     Failure:(void (^)(NSError *error))failure
{
    NSString *path = @"http://apis.juhe.cn/szbusline/bus";
    NSString *api_id = @"31";
    NSString *method = @"GET";
    NSDictionary *param = @{@"busline":buslineCode, @"dtype":@"json", @"key":APPKEY};
    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
    
    [juheapi executeWorkWithAPI:path
                          APIID:api_id
                     Parameters:param
                         Method:method
                        Success:^(id responseObject) {
                            CommonModel *model = [CommonModel objectWithKeyValues:responseObject];
                            NSArray *arrivals = [Arrival objectArrayWithKeyValuesArray:model.result];
                            success(arrivals);
                        }
                        Failure:^(NSError *error) {
                            failure(error);
                        }];
}

@end
