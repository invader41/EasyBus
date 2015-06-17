//
//  JHService.h
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bus.h"
#import "CommonModel.h"
#import "Station.h"
#import "Arrival.h"
#import "LineInfo.h"
#import "JHAPISDK.h"
#import "JHOpenidSupplier.h"
#define OPENID @"JHb0fa603485cdfb742565d47dfddb718d"
#define APPKEY @"088fccfa30aac18c991e3c422cabc9a0"

@interface JHService : NSObject
+(instancetype)SharedInstance;
-(void)registerJHService;
-(void)searchStationsByName:(NSString *)stationName
              Success:(void (^)(NSArray *stations))success
              Failure:(void (^)(NSError *error))failure;

-(void)searchBusStateByStation:(NSString *)stationCode
                       Success:(void (^)(NSArray *buses))success
                       Failure:(void (^)(NSError *error))failure;

-(void)searchBuslines:(NSString *)bus
            Success:(void (^)(NSArray *lines))success
            Failure:(void (^)(NSError *error))failure;

-(void)searchBuslineArrivals:(NSString *)buslineCode
              Success:(void (^)(NSArray *arrivals))success
              Failure:(void (^)(NSError *error))failure;


@end
