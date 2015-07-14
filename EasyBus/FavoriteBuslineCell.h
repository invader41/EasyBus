//
//  FavoriteBuslineCell.h
//  EasyBus
//
//  Created by pengsy on 15/6/17.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteBusLine.h"
#import "FavoriteCell.h"

@interface FavoriteBuslineCell : FavoriteCell<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) FavoriteBusLine *favoriteBusLine;

@end

