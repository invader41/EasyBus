//
//  Station.h
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Station : NSObject
@property (strong, nonatomic) NSString *station;        /*站台名称*/
@property (strong, nonatomic) NSString *stationCode;	/*站台编码,用于查询经过该站台车辆信息*/
@property (strong, nonatomic) NSString *local;      /*所属行政区*/
@property (strong, nonatomic) NSString *street;		/*所在道路路*/
@property (strong, nonatomic) NSString *Sections;	/*所在路段*/
@property (strong, nonatomic) NSString *point;		/*站台方位*/
@end
