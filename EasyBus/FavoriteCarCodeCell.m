//
//  FavoriteCarCodeCell.m
//  EasyBus
//
//  Created by pengsy on 15/6/17.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "FavoriteCarCodeCell.h"
#import "BusService.h"
#import <Masonry.h>

@interface FavoriteCarCodeCell()
{
    UITextView *_textView;
    UILabel *_titleLabel1;
}
@end
@implementation FavoriteCarCodeCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _textView = [[UITextView alloc] init];
        [_textView setEditable:NO];
        [_textView setSelectable:NO];
        [self.contentView insertSubview:_textView atIndex:0];
        
        _titleLabel1 = [[UILabel alloc] init];
        _titleLabel1.backgroundColor = [UIColor whiteColor];
        [_titleLabel1 setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel1 setFont:[UIFont fontWithName:@"HelveticaBold" size:14]];
        [self.contentView insertSubview:_titleLabel1 atIndex:0];
        
        
        [_titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.height.equalTo(@20);
            make.bottom.equalTo(_textView.mas_top);
        }];
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel1.mas_bottom);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

    }
    return self;
}


-(void)refreshData
{
    [self.indicator startAnimating];
    _titleLabel1.text = [NSString stringWithFormat:@"%@路，%@", self.favoriteCarCode.lineName, self.favoriteCarCode.carCode];;
    [[BusService SharedInstance] searchBuslineArrivals:self.favoriteCarCode.busLine Success:^(NSArray *arrivals) {
        for(Arrival *arrival in arrivals)
        {
            if([arrival.carCode isEqualToString:self.favoriteCarCode.carCode])
            {
                _textView.text = [NSString stringWithFormat:@"本班车于%@到达%@",arrival.ArrivalTime, arrival.stationName];
                break;
            }
        }
        [self.indicator stopAnimating];
        [self setNeedsDisplay];

    } Failure:^(NSError *error) {
        
    }];
}



@end
