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
#import "FavoriteBusLine.h"
#import "AppDelegate.h"
static CGFloat const kBounceValue = 60.0f;
static CGFloat const kIgnoreValue = 0.0f;

@interface NearbyBusCell()<UIGestureRecognizerDelegate>
{
    int _busIndex;
}
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightLayoutConstraintConstant;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@end

@implementation NearbyBusCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RandomColor" object:nil queue:nil usingBlock:^(NSNotification *note) {
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"RandomColor"])
        {
            [self.topContentView setBackgroundColor:[UIColor randomColor]];
            [self.seperatorView setHidden:YES];
        }
        else
        {
            [self.topContentView setBackgroundColor:[UIColor darkGrayColor]];
            [self.seperatorView setHidden:NO];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"Shake" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self shake];
    }];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.topContentView addGestureRecognizer:self.panRecognizer];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"RandomColor"])
    {
        [self.topContentView setBackgroundColor:[UIColor randomColor]];
        [self.seperatorView setHidden:YES];
    }
    else
    {
        [self.topContentView setBackgroundColor:[UIColor darkGrayColor]];
        [self.seperatorView setHidden:NO];
    }
    _busIndex = 0;
}

-(void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self.topContentView setBackgroundColor:self.tintColor];
}

-(void)setEnableGesture:(BOOL)enableGesture
{
    _enableGesture = enableGesture;
    self.topContentView.userInteractionEnabled = _enableGesture;
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.topContentView];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.topContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            if((ABS([recognizer velocityInView:self.topContentView].x) > 240 && ABS([recognizer velocityInView:self.topContentView].y) < 200)
               || self.topContentLeftConstraint.constant != 0)
            {
                if(deltaX > 0)
                {
                    deltaX -= kIgnoreValue;
                }
                else
                {
                    deltaX += kIgnoreValue;
                }
                
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
    if(self.topContentLeftConstraint.constant > kIgnoreValue)
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
    else if(self.topContentLeftConstraint.constant < -kIgnoreValue)
    {
        [self addToFavorite:self.buses[_busIndex]];
        panLeft = NO;
    }
    
    self.topContentLeftConstraint.constant = 0;
    self.topContentRightConstraint.constant = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)addToFavorite:(Bus *)bus
{
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busCode==%@", bus.code];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count == 0)
    {
        FavoriteBusLine *newModel = [[FavoriteBusLine alloc] initWithEntity:[NSEntityDescription entityForName:@"FavoriteBusLine" inManagedObjectContext:SharedAppDelegate.managedObjectContext] insertIntoManagedObjectContext:SharedAppDelegate.managedObjectContext];
        newModel.busCode = bus.code;
        newModel.busName = bus.bus;
        newModel.direction = bus.FromTo;
        [SharedAppDelegate.managedObjectContext insertObject:newModel];
        
    }
    else
    {
        [SharedAppDelegate.managedObjectContext deleteObject:[result firstObject]];
    }
    [SharedAppDelegate saveContext];
    [self bindData];
}

-(void)bindData
{
    Bus *bus = self.buses[_busIndex];
    self.lineLabel.text = bus.bus;
    
    self.fromToLabel.text = [NSString stringWithFormat:@"开往 %@ 方向", [bus.FromTo componentsSeparatedByString:@">"].lastObject ];
    self.distanceLabel.text = bus.distance;
    if([bus.distance isEqualToString:@"进站"] || [bus.distance isEqualToString:@"无车"] || self.distanceLabel.text.length == 0)
    {
        self.distanceLabel.hidden = YES;
        self.zhanLabel.text = bus.distance;
    }
    else
    {
        self.distanceLabel.hidden = NO;
        self.zhanLabel.text = @"站";
    }
    
    [self.fromToLabel setAlpha:0];
    
    NSFetchRequest *search = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"busCode==%@", bus.code];
    [search setPredicate:predicate];
    NSArray *result = [SharedAppDelegate.managedObjectContext executeFetchRequest:search error:nil];
    if(result.count > 0)
    {
        [self.favoriteStarImageView setHidden:NO];
    }
    else
    {
        [self.favoriteStarImageView setHidden:YES];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.fromToLabel setAlpha:1];
    } completion:^(BOOL finished) {
        [self.fromToLabel setAlpha:1];
    }];
}

-(void)shake
{
    [UIView animateKeyframesWithDuration:10.0 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/3.0 animations:^{
            self.topContentLeftConstraint.constant = 60;
            self.topContentRightConstraint.constant = -60;
        }];
        [UIView addKeyframeWithRelativeStartTime:1/3.0 relativeDuration:1/3.0 animations:^{
            self.topContentLeftConstraint.constant = -60;
            self.topContentRightConstraint.constant = 60;
        }];
        [UIView addKeyframeWithRelativeStartTime:2/3.0 relativeDuration:1/3.0 animations:^{
            self.topContentLeftConstraint.constant = 0;
            self.topContentRightConstraint.constant = 0;
        }];
        
    } completion:^(BOOL finished) {
        
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //[otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
    if(self.topContentLeftConstraint.constant != 0)
        return NO;
    else
        return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
