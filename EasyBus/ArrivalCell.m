//
//  ArrivalCell.m
//  EasyBus
//
//  Created by pengsy on 15/7/21.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "ArrivalCell.h"

@implementation ArrivalCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.busIconImageView.image = [self.busIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.busIconImageView.image = [self.busIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    return self;
}
@end
