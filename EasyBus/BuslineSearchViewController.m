//
//  BuslineSearchViewController.m
//  EasyBus
//
//  Created by pengsy on 15/6/5.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BuslineSearchViewController.h"
#import "BusArrivalPageViewController.h"
#import <AFSwipeToHide/AFSwipeToHide.h>
#import "BusService.h"
#import "BusArrivalViewController.h"
#import <DBGHTMLEntities/DBGHTMLEntityDecoder.h>

@interface BuslineSearchViewController ()<UITableViewDataSource, AFSwipeToHideDelegate, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>
{
    CGFloat _headerHeight;
    NSMutableDictionary *_busSearchResults;
    DBGHTMLEntityDecoder *_decoder;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AFSwipeToHide *swipeToHide;
@property (weak, nonatomic) IBOutlet UIButton *searchTipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipBottom;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeight;
@end

@implementation BuslineSearchViewController


#pragma mark - LifeCircle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _headerHeight = self.searchViewHeight.constant;
    _busSearchResults = [NSMutableDictionary dictionary];
    _decoder = [DBGHTMLEntityDecoder new];
    
    self.searchBar.delegate = self;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(_headerHeight , 0.0, 0.0, 0.0);
    
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [self updateElements];
    

    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    labelView.text = @"公交线路";
    [labelView setFont:[UIFont boldSystemFontOfSize:17]];
    labelView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = labelView;
    
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma mark - Sizing utils

- (CGFloat)statusBarHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

#pragma mark - Private Method

- (void)updateElements {
    CGFloat percentHidden = self.swipeToHide.percentHidden;
    
    self.searchViewHeight.constant = (1.0 - percentHidden) * _headerHeight;
    self.searchBar.layer.opacity = (1.0 - percentHidden);
}

- (void)keyboardWillShow:(NSNotification *)notif {
    self.tipBottom.constant = -53;
    self.tipRight.constant = -72;
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0 initialSpringVelocity:0.0 options:0 animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished)
     {
     }];
}

- (void)keyboardHide:(NSNotification *)notif {
    
    self.tipBottom.constant = 9;
    self.tipRight.constant = -9;
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished)
     {
     }];
}

#pragma mark - Getter Setter

-(AFSwipeToHide *)swipeToHide
{
    if(!_swipeToHide)
    {
        _swipeToHide = [[AFSwipeToHide alloc] init];
        _swipeToHide.scrollDistance = _headerHeight;
        _swipeToHide.delegate = self;
    }
    return _swipeToHide;
}

#pragma mark - searchbar delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [[BusService SharedInstance] searchBuslines:searchBar.text Success:^(NSArray *lines) {
        [_busSearchResults removeAllObjects];
        for(Bus *bus in lines)
        {
            if(![_busSearchResults.allKeys containsObject:bus.bus])
            {
                [_busSearchResults setObject:[NSMutableArray array] forKey:bus.bus];
            }
            [_busSearchResults[bus.bus] addObject:bus];
        }
        
        [self.tableView reloadData];
    } Failure:^(NSError *error) {
        
    }];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}



#pragma mark - AFUSwipeToHide delegate

- (void)swipeToHide:(AFSwipeToHide *)swipeToHide didUpdatePercentHiddenInteractively:(BOOL)interactive {
    [self updateElements];
    
    if (!interactive) {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.45 initialSpringVelocity:0.0 options:0 animations:^{
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark - actions

- (IBAction)tipTouched:(id)sender {
    self.searchViewHeight.constant = _headerHeight;
    self.searchBar.layer.opacity = 1.0;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0 initialSpringVelocity:0.0 options:0 animations:^{
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished)
     {
     }];
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.swipeToHide scrollViewWillBeginDragging:scrollView];
    

}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self.swipeToHide scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.swipeToHide scrollViewDidScroll:scrollView];
    [self.searchBar resignFirstResponder];
}


#pragma mark - table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSArray *buses = _busSearchResults[_busSearchResults.allKeys[indexPath.row]];
    NSMutableArray *titles = [NSMutableArray array];
    NSMutableArray *views = [NSMutableArray array];
    for(Bus *bus in buses)
    {
        BusArrivalViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BusArrivalViewController"];
        vc.bus = bus;
        [views addObject:vc.view];
        
        UILabel *navTitleLabel = [UILabel new];
        navTitleLabel.text = [_decoder decodeString:bus.FromTo];
        navTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
        navTitleLabel.textColor = [UIColor whiteColor];
        [titles addObject:navTitleLabel];
    }
    BusArrivalPageViewController *pagerController = [[BusArrivalPageViewController alloc] initWithNavBarItems:titles
                                                                                             navBarBackground:[UIColor colorWithRed:0.33 green:0.68 blue:0.91 alpha:1.000]
                                                                                                        views:views
                                                                                              showPageControl:YES];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pagerController];
    [self presentViewController:nav  animated:YES completion:NULL];
}

#pragma mark - table view source delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _busSearchResults.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = _busSearchResults.allKeys[indexPath.row];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
