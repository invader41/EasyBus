//
//  NearbyStationViewController.h
//  EasyBus
//
//  Created by pengsy on 15/6/26.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearbyStationViewController : UIViewController
@property (nonatomic, strong) NSString *stationCode;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
-(instancetype)initWithStationCode:(NSString *)stationCode;
@end
