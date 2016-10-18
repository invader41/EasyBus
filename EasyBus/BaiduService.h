//
//  BaiduService.h
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapKit/BaiduMapAPI_Location/BMKLocationService.h>
typedef void (^ArrayBlock)(NSArray *pois);
typedef void (^FailureBlock)(NSError *error);
typedef void (^RegistedBlock)(BOOL successd);
typedef void (^LocateBlock)(BOOL successd);

@interface BaiduService : NSObject
//@property (nonatomic) BOOL locationGetted;
@property (strong, nonatomic) BMKLocationService *locService;
//-(void)registerBaiduService;
-(void)searchNearestStationAt:(CLLocationCoordinate2D)location Success:(ArrayBlock)success Failure:(FailureBlock)failure;
-(void)searchStationsByName:(NSString *)name Success:(ArrayBlock)success Failure:(FailureBlock)failure;
-(void)searchSuggestionsByName:(NSString *)name Success:(ArrayBlock)success Failure:(FailureBlock)failure;
+(instancetype)SharedInstance;
//-(void)regist:(RegistedBlock)registed;
//-(void)startUserLocationService:(LocateBlock)located;
@end
