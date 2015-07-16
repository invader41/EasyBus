//
//  BusFavoritesViewController.m
//  EasyBus
//
//  Created by pengsy on 15/6/17.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BusFavoritesViewController.h"
#import <RACollectionViewReorderableTripletLayout.h>
#import <MJRefresh.h>
#import "BusService.h"
#import "BaiduService.h"
#import "AppDelegate.h"
#import "FavoriteBuslineCell.h"
#import "FavoriteCarCodeCell.h"
#import "NearbyBusStationCell.h"
#define BuslineCellReuseIdentifier @"BuslineCell"
#define CarCodeCellReuseIdentifier @"CarCodeCell"
#define NearbyBusStationReuseIdentifier @"NearbyBusStationCell"

@interface BusFavoritesViewController () <RACollectionViewDelegateReorderableTripletLayout, RACollectionViewReorderableTripletLayoutDataSource, favoriteCellDelegate>
{
    NSMutableArray *_favoriteBusLines;
    NSMutableArray *_favoriteCarCodes;
    BOOL _isEditing;
}
- (IBAction)deleteItems:(id)sender;
@end

@implementation BusFavoritesViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - lifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    _favoriteBusLines = [NSMutableArray array];
    _favoriteCarCodes = [NSMutableArray array];
    _isEditing= NO;
    // Register cell classes
    //[self.collectionView registerNib:[[NSBundle mainBundle] loadNibNamed:@"FavoriteBuslineCell" owner:self options:nil].firstObject forCellWithReuseIdentifier:BuslineCellReuseIdentifier];
    [self.collectionView registerClass:[FavoriteBuslineCell class] forCellWithReuseIdentifier:BuslineCellReuseIdentifier];
    //[self.collectionView registerNib:[[NSBundle mainBundle] loadNibNamed:@"FavoriteCarCodeCell" owner:self options:nil].firstObject forCellWithReuseIdentifier:CarCodeCellReuseIdentifier];
    [self.collectionView registerClass:[FavoriteCarCodeCell class] forCellWithReuseIdentifier:CarCodeCellReuseIdentifier];
    
    // Do any additional setup after loading the view.
    [self.collectionView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    labelView.text = @"我的收藏";
    [labelView setFont:[UIFont boldSystemFontOfSize:17]];
    labelView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = labelView;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView.header beginRefreshing];
    [self.navigationItem.titleView setAlpha:0];
    [self.navigationController.navigationItem.titleView setAlpha:0.8];
    [UIView animateWithDuration:1 animations:^{
        [self.navigationItem.titleView setAlpha:1];
        [self.navigationItem.titleView setNeedsLayout];
        [self.navigationItem.titleView layoutIfNeeded];
    } completion:^(BOOL finished)
     {
         [self.navigationItem.titleView setAlpha:1];
     }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method

-(void)refreshData
{
    NSFetchRequest *search1 = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteBusLine"];
    _favoriteBusLines =  [NSMutableArray arrayWithArray:[SharedAppDelegate.managedObjectContext executeFetchRequest:search1 error:nil]];
    
    NSFetchRequest *search2 = [NSFetchRequest fetchRequestWithEntityName:@"FavoriteCarCode"];
    _favoriteCarCodes = [NSMutableArray arrayWithArray:[SharedAppDelegate.managedObjectContext executeFetchRequest:search2 error:nil]];
    
    [self.collectionView reloadData];
    [self.collectionView.header endRefreshing];
}

-(void)deleteButtonClickedAt:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        FavoriteBusLine *object = _favoriteBusLines[indexPath.row];
        [SharedAppDelegate.managedObjectContext deleteObject:object];
        [_favoriteBusLines removeObjectAtIndex:indexPath.row];
    }
    if(indexPath.section == 1)
    {
        FavoriteCarCode *object = _favoriteCarCodes[indexPath.row];
        [SharedAppDelegate.managedObjectContext deleteObject:object];
        [_favoriteCarCodes removeObjectAtIndex:indexPath.row];
    }
    [SharedAppDelegate saveContext];
    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 0)
    {
        return _favoriteBusLines.count;
    }
    if(section == 1)
    {
        return _favoriteCarCodes.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
    {
        FavoriteBuslineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BuslineCellReuseIdentifier forIndexPath:indexPath];
        //FavoriteBuslineCell *cell = [[FavoriteBuslineCell alloc] initWithFrame:CGRectZero];
        cell.favoriteBusLine = (FavoriteBusLine *)_favoriteBusLines[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        [cell refreshData];
        return cell;
    }
    if(indexPath.section == 1)
    {
        FavoriteCarCodeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CarCodeCellReuseIdentifier forIndexPath:indexPath];
        cell.favoriteCarCode = (FavoriteCarCode *)_favoriteCarCodes[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        [cell refreshData];
        return cell;
    }
    return nil;
}

#pragma mark - RACollectionViewDelegateReorderableTripletLayout

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(self.view.bounds.size.width, 200);
    }
    return RACollectionViewTripletLayoutStyleSquare;
}//Default to automaticaly grow square !
- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    if(_isEditing)
        return UIEdgeInsetsMake(15.f, 15.f, 15.f, 15.f);
    else
        return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
}
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    if(_isEditing)
        return 15.f;
    else
        return 5.f;
}
- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    if(_isEditing)
        return 15.f;
    else
        return 5.f;
}
- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    if(_isEditing)
        return 15.f;
    else
        return 5.f;
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0); //Sorry, horizontal scroll is not supported now.
}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}


- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{

}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if(fromIndexPath.section == toIndexPath.section)
        return YES;
    else
        return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - actions

- (IBAction)deleteItems:(id)sender
{
    [self.collectionView performBatchUpdates:^{
        if(_isEditing)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoriteCellEndEditing" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoriteCellBeginEditing" object:self];
        }
        _isEditing = !_isEditing;
    } completion:^(BOOL finished) {
        
    }];
    

}
@end
