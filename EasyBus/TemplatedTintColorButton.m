//
//  TemplatedTintColorButton.m
//  EasyBus
//
//  Created by pengsy on 15/6/16.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "TemplatedTintColorButton.h"

@implementation TemplatedTintColorButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.imageView.image  = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}


@end
