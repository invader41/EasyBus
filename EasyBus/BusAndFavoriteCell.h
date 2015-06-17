//
//  BusAndFavoriteCell.h
//  EasyBus
//
//  Created by pengsy on 15/6/12.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusAndFavoriteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *busTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *LPNLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (strong, nonatomic) NSIndexPath *indexPath;
@end
