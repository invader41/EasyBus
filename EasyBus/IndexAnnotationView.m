//
//  IndexAnnotationView.m
//  EasyBus
//
//  Created by pengsy on 15/7/30.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "IndexAnnotationView.h"
#import <Masonry.h>
#import "BusLineAnnotation.h"

@implementation IndexAnnotationView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:23./255. green:175./255. blue:136./255. alpha:1];
        self.canShowCallout = YES;
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        [indexLabel setTextAlignment:NSTextAlignmentCenter];
        [indexLabel setFont:[UIFont systemFontOfSize:10]];
        [indexLabel setTextColor:[UIColor whiteColor]];
        indexLabel.text = [NSString stringWithFormat:@"%d", [(BusLineAnnotation *)annotation index]];
       
        [self setBounds:CGRectMake(0, 0, 16, 16)];
         [self addSubview:indexLabel];
        
//        [self mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.equalTo(@16);
//            make.height.equalTo(@16);
//        }];
//        [indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
        [self.layer setCornerRadius:8];
        [self setClipsToBounds:YES];
    }
    return self;
}

@end
