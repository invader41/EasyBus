//
//  NearbyBusStationCell.m
//  EasyBus
//
//  Created by pengsy on 15/6/25.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "NearbyBusStationCell.h"
#import <Masonry.h>
#import "BusService.h"
#import "BaiduService.h"
#import "NearbyStationsPageViewController.h"
#import "NearbyStationViewController.h"


@interface NearbyBusStationCell()
{
    UIActivityIndicatorView *_indicator;
}
@end


@implementation NearbyBusStationCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicator setHidesWhenStopped:YES];
        [_indicator stopAnimating];
        [self.contentView addSubview:_indicator];
        
        [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

-(void)refreshData
{
    [_indicator startAnimating];
    [[BaiduService SharedInstance] searchNearestStationSuccess:^(NSString *text) {
        [[BusService SharedInstance] searchStationsByName:text Success:^(NSArray *stations) {
            NSMutableArray *titles = [NSMutableArray array];
            NSMutableArray *views = [NSMutableArray array];
            for(Station *station in stations)
            {
                NearbyStationViewController *vc = [[NearbyStationViewController alloc] initWithStationCode:station.stationCode];
                [views addObject:vc.view];
                
                UILabel *navTitleLabel = [UILabel new];
                navTitleLabel.text = station.station;
                navTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
                navTitleLabel.textColor = [UIColor whiteColor];
                [titles addObject:navTitleLabel];
            }
            NearbyStationsPageViewController *pageView = [[NearbyStationsPageViewController alloc] initWithNavBarItems:titles
                                                                                                      navBarBackground:[UIColor colorWithRed:0.33 green:0.68 blue:0.91 alpha:1.000]
                                                                                                                 views:views
                                                                                                       showPageControl:YES];
            
            //[self.contentView addSubview:pageView.view];
            [_indicator stopAnimating];
            
        } Failure:^(NSError *error) {
            [_indicator stopAnimating];
        }];
    } Failure:^(NSError *error) {
        [_indicator stopAnimating];
    }];
}

@end
