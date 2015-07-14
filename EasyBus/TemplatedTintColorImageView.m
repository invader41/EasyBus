//
//  TemplatedTintColorImageView.m
//  EasyBus
//
//  Created by pengsy on 15/7/14.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "TemplatedTintColorImageView.h"

@implementation TemplatedTintColorImageView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.image  = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

@end
