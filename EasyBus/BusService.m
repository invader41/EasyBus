//
//  JHService.m
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BusService.h"
#import <GDataXML-HTML/GDataXMLNode.h>
#import <AFNetworking.h>
#import <MJExtension.h>

@implementation BusService

static BusService* _sharedInstance;

+(instancetype)SharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[BusService alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


//-(void)registerJHService
//{
//     [[JHOpenidSupplier shareSupplier] registerJuheAPIByOpenId:OPENID];
//}


-(void)searchStationsByName:(NSString *)stationName Success:(void (^)(NSArray *))success Failure:(void (^)(NSError *))failure
{
//    NSString *path = @"http://apis.juhe.cn/szbusline/bus";
//    NSString *api_id = @"31";
//    NSString *method = @"GET";
//    NSDictionary *param = @{@"station":stationName, @"dtype":@"json", @"key":APPKEY};
//    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
//    
//    [juheapi executeWorkWithAPI:path
//                          APIID:api_id
//                     Parameters:param
//                         Method:method
//                        Success:^(id responseObject) {
//                            CommonModel *model = [CommonModel objectWithKeyValues:responseObject];
//                            NSArray *stations = [Station objectArrayWithKeyValuesArray:model.result];
//                            success(stations);
//                        }
//                        Failure:^(NSError *error) {
//                            failure(error);
//                        }];

    

    NSDictionary *parameters = @{@"__VIEWSTATE":@"/wEPDwULLTE5ODM5MjcxNzlkZJjyY5yRvvioUwya4OEEvzuY1eO2+x5v1FdJc7CCQmFT",
                                 @"__VIEWSTATEGENERATOR":@"7BCA6D38",
                                 @"__EVENTVALIDATION":@"/wEWBQL6h4/dDQLq+uyKCAKkmJj/DwL0+sTIDgLl5vKEDqsVOHq8YTmi6g8ib2Iu2KAp+9fekWJmmAKeMsAka2pX",
                                 @"ctl00$MainContent$StandName":stationName,
                                 @"ctl00$MainContent$SearchCode":@"搜索"};
    
    NSMutableURLRequest *request =  [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:@"http://www.szjt.gov.cn/apts/default.aspx" parameters:parameters error:NULL];
    
    AFHTTPRequestOperationManager *manager=[[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithHTMLData:responseObject error:&error];
        NSLog(@"%@", [[doc rootElement] XMLString]);
        if (doc) {
            NSMutableArray *stations = [NSMutableArray array];
            NSArray *table = [doc nodesForXPath:@"//span[@id='MainContent_DATA']/table" error:NULL];
            if(table.count > 0)
            {
                for (GDataXMLElement *node in [table[0] children])
                {
                    if(node == [table[0] children][0])
                        continue;
                    else
                    {
                        Station *station = [Station new];
                        GDataXMLElement *_station = node.children[0];
                        if(_station.children.count > 0)
                        {
                            station.station = [_station.children[0] stringValue] ;
                        }
                        station.stationCode = [node.children[1] stringValue];
                        station.local = [node.children[2] stringValue];
                        station.street = [node.children[3] stringValue];
                        station.Sections = [node.children[4] stringValue];
                        station.point = [node.children[5] stringValue];
                        [stations addObject:station];
                        
                    }
                }
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"station = %@",stationName];
                success([stations filteredArrayUsingPredicate:predicate]);
            }
            else
                failure(error);
        }
        else
            failure(error);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [manager.operationQueue addOperation:operation];
    
}


-(void)searchBusStateByStationCode:(NSString *)stationCode Success:(void (^)(NSArray *))success Failure:(void (^)(NSError *))failure
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.szjt.gov.cn/apts/default.aspx"];
    
    //设置和加入头信息
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"My Browser"}];
    AFHTTPSessionManager *manager=[[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //设置GET请求的参数
    NSDictionary *params=@{@"StandCode":stationCode};
    //发起GET请求
    [manager GET:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithHTMLData:responseObject error:&error];
        if (doc) {
            NSMutableArray *buses = [NSMutableArray array];
            NSArray *table = [doc nodesForXPath:@"//span[@id='MainContent_DATA']/table" error:&error];
            if(table.count > 0)
            {
                for (GDataXMLElement *node in [table[0] children])
                {
                    if(node == [table[0] children][0])
                        continue;
                    else
                    {
                        Bus *bus = [Bus new];
                        GDataXMLElement *_bus = node.children[0];
                        if(_bus.children.count > 0)
                        {
                            bus.bus = [_bus.children[0] stringValue] ;
                            bus.code = [[_bus.children[0] attributeForName:@"href"].stringValue substringWithRange:NSMakeRange (23, 36)];
                        }
                        bus.FromTo = [node.children[1] stringValue];
                        bus.carCode = [node.children[2] stringValue];
                        bus.time = [node.children[3] stringValue];
                        bus.distance = [node.children[4] stringValue];
                        [buses addObject:bus];
                    }
                }
                success(buses);
            }
            else
                failure(error);
        }
        else
            failure(error);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

-(void)searchBuslines:(NSString *)bus
              Success:(void (^)(NSArray *lines))success
              Failure:(void (^)(NSError *error))failure
{
//    NSString *path = @"http://apis.juhe.cn/szbusline/bus";
//    NSString *api_id = @"31";
//    NSString *method = @"GET";
//    NSDictionary *param = @{@"bus":bus, @"dtype":@"json", @"key":APPKEY};
//    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
//    
//    [juheapi executeWorkWithAPI:path
//                          APIID:api_id
//                     Parameters:param
//                         Method:method
//                        Success:^(id responseObject) {
//                            CommonModel *model = [CommonModel objectWithKeyValues:responseObject];
//                            NSArray *buses = [Bus objectArrayWithKeyValuesArray:model.result];
//                            success(buses);
//                        }
//                        Failure:^(NSError *error) {
//                            failure(error);
//                        }];
//    
//    
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.szjt.gov.cn/apts/APTSLine.aspx"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:baseURL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *bodystring = [NSString stringWithFormat:@"__VIEWSTATE=/wEPDwUJNDk3MjU2MjgyD2QWAmYPZBYCAgMPZBYCAgEPZBYCAgYPDxYCHgdWaXNpYmxlaGRkZJjIjf9wec64bUk0awl8Fmu9ZpeMHtOkmveJctfcLWzs&__VIEWSTATEGENERATOR=964EC381&__EVENTVALIDATION=/wEWAwLC6/qEDgL88Oh8AqX89aoKYSqjSGRgG6uatob0mRtv8UxGdjgHvVdIogSh29pwM0M=&ctl00$MainContent$LineName=%@&ctl00$MainContent$SearchLine=搜索",bus];
    [request setHTTPBody:[bodystring dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperationManager *manager=[[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithHTMLData:responseObject error:&error];
        NSLog(@"%@", [[doc rootElement] XMLString]);
        if (doc) {
            NSMutableArray *buses = [NSMutableArray array];
            NSArray *table = [doc nodesForXPath:@"//span[@id='MainContent_DATA']/table" error:NULL];
            if(table.count > 0)
            {
                for (GDataXMLElement *node in [table[0] children])
                {
                    if(node == [table[0] children][0])
                        continue;
                    else
                    {
                        Bus *bus = [Bus new];
                        GDataXMLElement *_bus = node.children[0];
                        if(_bus.children.count > 0)
                        {
                            bus.bus = [_bus.children[0] stringValue] ;
                            bus.code = [[_bus.children[0] attributeForName:@"href"].stringValue substringWithRange:NSMakeRange (23, 36)];
                        }
                        bus.FromTo = [node.children[1] stringValue];
                        [buses addObject:bus];
                    }
                }
                success(buses);
            }
            else
                failure(error);
        }
        else
            failure(error);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [manager.operationQueue addOperation:operation];
    
//    __VIEWSTATE=%2FwEPDwUJNDk3MjU2MjgyD2QWAmYPZBYCAgMPZBYCAgEPZBYCAgYPDxYCHgdWaXNpYmxlaGRkZJjIjf9wec64bUk0awl8Fmu9ZpeMHtOkmveJctfcLWzs&__VIEWSTATEGENERATOR=964EC381&__EVENTVALIDATION=%2FwEWAwLC6%2FqEDgL88Oh8AqX89aoKYSqjSGRgG6uatob0mRtv8UxGdjgHvVdIogSh29pwM0M%3D&ctl00%24MainContent%24LineName=11&ctl00%24MainContent%24SearchLine=%E6%90%9C%E7%B4%A2
}

-(void)searchBuslineArrivals:(NSString *)buslineCode
                     Success:(void (^)(NSArray *arrivals))success
                     Failure:(void (^)(NSError *error))failure
{
//    NSString *path = @"http://apis.juhe.cn/szbusline/bus";
//    NSString *api_id = @"31";
//    NSString *method = @"GET";
//    NSDictionary *param = @{@"busline":buslineCode, @"dtype":@"json", @"key":APPKEY};
//    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
//    
//    [juheapi executeWorkWithAPI:path
//                          APIID:api_id
//                     Parameters:param
//                         Method:method
//                        Success:^(id responseObject) {
//                            CommonModel *model = [CommonModel objectWithKeyValues:responseObject];
//                            NSArray *arrivals = [Arrival objectArrayWithKeyValuesArray:model.result];
//                            success(arrivals);
//                        }
//                        Failure:^(NSError *error) {
//                            failure(error);
//                        }];
//    
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.szjt.gov.cn/apts/APTSLine.aspx"];
    
    //设置和加入头信息
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setHTTPAdditionalHeaders:@{ @"User-Agent" : @"My Browser"}];
    AFHTTPSessionManager *manager=[[AFHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:config];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //设置GET请求的参数
    NSDictionary *params=@{@"LineGuid":buslineCode};
    //发起GET请求
    [manager GET:@"" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc]initWithHTMLData:responseObject error:&error];
        if (doc) {
            NSMutableArray *arrivals = [NSMutableArray array];
            NSArray *table = [doc nodesForXPath:@"//span[@id='MainContent_DATA']/table" error:NULL];
            if(table.count > 0)
            {
                for (GDataXMLElement *node in [table[0] children])
                {
                    if(node == [table[0] children][0])
                        continue;
                    else
                    {
                        Arrival *arrival = [Arrival new];
                        GDataXMLElement *stationName = node.children[0];
                        if(stationName.children.count > 0)
                            arrival.stationName = [stationName.children[0] stringValue] ;
                        arrival.stationCode = [node.children[1] stringValue];
                        arrival.carCode = [node.children[2] stringValue];
                        arrival.ArrivalTime = [node.children[3] stringValue];
                        [arrivals addObject:arrival];
                    }
                    
                }
                success(arrivals);
            }
            else
            {
                failure(error);
            }
        }
        else
            failure(error);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

@end
