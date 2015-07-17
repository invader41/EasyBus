//
//  NearbyBusCell.m
//  EasyBus
//
//  Created by pengsy on 15/7/14.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "NearbyBusCell.h"
#import "Bus.h"
#import "UIColor+RandomColor.h"
static CGFloat const kBounceValue = 60.0f;

@interface NearbyBusCell()<UIGestureRecognizerDelegate>
{
    int _busIndex;
}
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@end

@implementation NearbyBusCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.topContentView addGestureRecognizer:self.panRecognizer];
    [self.topContentView setBackgroundColor:[UIColor randomColor]];
    _busIndex = 0;
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.topContentView];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.topContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            if(ABS(deltaX)<=kBounceValue)
            {
                self.topContentLeftConstraint.constant = deltaX;
                self.topContentRightConstraint.constant = -deltaX;
            }
            else
            {
                CGFloat constraint = kBounceValue + (ABS(deltaX)-kBounceValue)/10;
                self.topContentLeftConstraint.constant = deltaX > 0? constraint:-constraint;
                self.topContentRightConstraint.constant = deltaX > 0? -constraint:constraint;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded];
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"Pan Cancelled");
            break;
        default:
            break;
    }
}

-(void)panEnded
{
    BOOL panLeft = NO;
    if(self.topContentLeftConstraint.constant > 0)
    {
        panLeft = YES;
        if(_busIndex == self.buses.count - 1)
        {
            _busIndex = 0;
        }
        else
        {
            _busIndex ++;
        }
        [self bindData];
    }
    else
    {
    
        panLeft = NO;
    }
    
    self.topContentLeftConstraint.constant = 0;
    self.topContentRightConstraint.constant = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)bindData
{
    Bus *bus = self.buses[_busIndex];
    self.lineLabel.text = bus.bus;
    self.fromToLabel.text = bus.FromTo;
    self.distanceLabel.text = bus.distance;
    
    [self.fromToLabel setAlpha:0];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.fromToLabel setAlpha:1];
    } completion:^(BOOL finished) {
        [self.fromToLabel setAlpha:1];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
