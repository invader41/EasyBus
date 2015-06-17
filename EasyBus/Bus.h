//
//  Bus.h
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bus : NSObject
@property (strong, nonatomic) NSString *bus;           	              /*线路号*/
@property (strong, nonatomic) NSString *FromTo; /*线路方向*/
@property (strong, nonatomic) NSString *code; /*线路编码，用于该线路详细信息查询*/
@property (strong, nonatomic) NSString *carCode;                        /*车辆车牌号*/
@property (strong, nonatomic) NSString *time;		              /*更新时间*/
@property (strong, nonatomic) NSString *distance;	 /*站距*/
@end
