//
//  Arrival.h
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Arrival : NSObject
@property (strong, nonatomic) NSString *stationName;	/*站台名称*/
@property (strong, nonatomic) NSString *stationCode;			/*站台编号，用于查询经过该站台车辆信息*/
@property (strong, nonatomic) NSString *carCode;				/*车辆车牌号*/
@property (strong, nonatomic) NSString *ArrivalTime;			/*车辆到达该站点时间*/
@end
