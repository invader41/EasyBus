//
//  ArrivalCell.h
//  EasyBus
//
//  Created by pengsy on 15/7/21.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrivalCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *busIconImageView;
@property (weak, nonatomic) IBOutlet UITextView *stationTextView;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
