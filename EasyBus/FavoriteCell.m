//
//  FavoriteCell.m
//  EasyBus
//
//  Created by pengsy on 15/6/24.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "FavoriteCell.h"
#import <Masonry.h>

@interface FavoriteCell()
@end
@implementation FavoriteCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
  
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.deleteButton setTintColor:[UIColor blackColor]];
        [self.deleteButton addTarget:self action:@selector(deleteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteButton setAlpha:0];
        //[_deleteButton setHidden:YES];
        [self.contentView addSubview:self.deleteButton];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_indicator setHidesWhenStopped:YES];
        [_indicator stopAnimating];
        [self.contentView addSubview:_indicator];
        
        [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@20);
            make.height.equalTo(@20);
            make.top.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.contentView).offset(-10);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"FavoriteCellBeginEditing" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [UIView animateWithDuration:0.5 animations:^{
                [self.deleteButton setAlpha:1];
                [self setNeedsDisplay];
            } completion:^(BOOL finished) {
                [self.deleteButton setAlpha:1];
                [self setNeedsDisplay];
            }];

        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:@"FavoriteCellEndEditing" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.deleteButton setAlpha:0];
                [self setNeedsDisplay];
            } completion:^(BOOL finished) {
                [self.deleteButton setAlpha:0];
                [self setNeedsDisplay];
            }];
        }];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.alpha = .7f;
    }else {
        self.alpha = 1.f;
    }
}

-(void)deleteButtonClicked
{
    [self.delegate deleteButtonClickedAt:self.indexPath];
}

-(void)refreshData
{
    
}
@end
