//
//  BaiduService.h
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>
typedef void (^StringBlock)(NSString *text);
typedef void (^FailureBlock)(NSError *error);

@interface BaiduService : NSObject
//-(void)registerBaiduService;
-(void)searchNearestStationSuccess:(StringBlock)success Failure:(FailureBlock)failure;
+(instancetype)SharedInstance;
@end
