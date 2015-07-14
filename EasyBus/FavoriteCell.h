//
//  FavoriteCell.h
//  EasyBus
//
//  Created by pengsy on 15/6/24.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol favoriteCellDelegate;

@interface FavoriteCell : UICollectionViewCell
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<favoriteCellDelegate> delegate;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
-(void)refreshData;
@end

@protocol favoriteCellDelegate <NSObject>

-(void)deleteButtonClickedAt:(NSIndexPath *)indexPath;

@end