//
//  BusStationSearchViewController.h
//  EasyBus
//
//  Created by pengsy on 15/8/3.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationsViewController.h"

@interface BusStationSearchViewController : UIViewController
@property (nonatomic) NSNumber *type;
@property (nonatomic, weak) id <locationsViewDelegate> delegate;
@end
