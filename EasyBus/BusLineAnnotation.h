//
//  BusLineAnnotation.h
//  EasyBus
//
//  Created by pengsy on 15/7/31.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>

@interface BusLineAnnotation : BMKPointAnnotation
@property (nonatomic) int type; //<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:进站 6:当前位置
@property (nonatomic) int index;
@property (nonatomic) int degree;
@property (nonatomic, strong) NSString *stationName;
@end
