//
//  BaiduService.m
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BaiduService.h"

@interface BaiduService()<BMKGeneralDelegate, BMKBusLineSearchDelegate>
{
    BMKMapManager* _mapManager;
    BOOL _registed;
}
@property (strong, nonatomic) BMKBusLineSearch* busLineSearcher;
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

#pragma mark - getter setter

-(BMKBusLineSearch *)busLineSearcher
{
    if(!_busLineSearcher)
    {
        _busLineSearcher = [[BMKBusLineSearch alloc]init];
        _busLineSearcher.delegate = self;
    }
    return _busLineSearcher;
}

#pragma mark - private method

-(void)registerBaiduService
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    _registed = [_mapManager start:@"8KZEMXKZuWcwBpGNsxs2Tywc"  generalDelegate:self];
}

-(void)busLineSearch:(NSString *)busline
{
    //发起检索
    BMKBusLineSearchOption *buslineSearchOption = [[BMKBusLineSearchOption alloc]init];
    buslineSearchOption.city= @"苏州";
    buslineSearchOption.busLineUid= busline;
    BOOL flag = [self.busLineSearcher busLineSearch:buslineSearchOption];
    if(flag)
    {
        NSLog(@"busline检索发送成功");
    }
    else
    {
        NSLog(@"busline检索");
    }
}

-(void)onGetBusDetailResult:(BMKBusLineSearch *)searcher result:(BMKBusLineResult *)busLineResult errorCode:(BMKSearchErrorCode)error
{
    
}

#pragma mark - BMKGeneralDelegate

-(void)onGetNetworkState:(int)iError
{
    NSAssert(iError >= 0, @"error");
}

-(void)onGetPermissionState:(int)iError
{
    NSAssert(iError >= 0, @"error");
}
@end
