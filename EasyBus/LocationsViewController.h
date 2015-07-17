//
//  LocationsViewController.h
//  EasyBus
//
//  Created by pengsy on 15/7/15.
//  Copyright (c) 2015年 PSY. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol locationsViewDelegate;

@interface LocationsViewController : UIViewController
@property (nonatomic, weak) id <locationsViewDelegate> delegate;
@end

@protocol locationsViewDelegate <NSObject>

-(void)selectedLocation:(NSString *)location;

@end