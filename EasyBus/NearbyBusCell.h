//
//  NearbyBusCell.h
//  EasyBus
//
//  Created by pengsy on 15/7/14.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NearbyBusCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromToLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *topContentView;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteStarImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContentLeftConstraint;
@property (weak, nonatomic) IBOutlet UILabel *zhanLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContentRightConstraint;
@property (strong, nonatomic) NSArray *buses;
@property (nonatomic) BOOL enableGesture;
-(void)bindData;
-(void)shake;
@end
