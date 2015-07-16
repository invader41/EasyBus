//
//  BaiduService.h
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>
typedef void (^StringBlock)(NSArray *pois);
typedef void (^FailureBlock)(NSError *error);
typedef void (^RegistedBlock)(BOOL successd);
typedef void (^LocateBlock)(BOOL successd);
#define LOCATIONGETTED @"LocationGetted"

@interface BaiduService : NSObject
@property (nonatomic) BOOL locationGetted;
//-(void)registerBaiduService;
-(void)searchNearestStationSuccess:(StringBlock)success Failure:(FailureBlock)failure;
+(instancetype)SharedInstance;
-(void)regist:(RegistedBlock)registed;
-(void)startUserLocationService:(LocateBlock)located;
@end
