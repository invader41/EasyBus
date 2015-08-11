//
//  RoutingViewController.m
//  EasyBus
//
//  Created by pengsy on 15/8/3.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "RoutingViewController.h"
#import "LocationsViewController.h"
#import "BusService.h"
#import <Masonry.h>
#import "BaiduService.h"

@interface RoutingViewController () <UISearchBarDelegate, UIWebViewDelegate, UIPopoverPresentationControllerDelegate, locationsViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UILabel *_locationLabel;
    NSArray *_stationsSearchResult;
    BaiduService *_baiduService;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *indicatorLabel;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UISearchBar *destinationSearchBar;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *anchor;
@property (weak, nonatomic) IBOutlet UITableView *stationsTableView;
@property (strong, nonatomic) NSString *locationName;
@end

@implementation RoutingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableViewHeight.constant = 0;
    _baiduService = [BaiduService SharedInstance];
    //titleview
    
    UIButton *titleView = [UIButton buttonWithType:UIButtonTypeCustom];
    titleView.backgroundColor = [UIColor blackColor];
    
    _locationLabel = [UILabel new];
    _locationLabel.userInteractionEnabled = YES;
    [_locationLabel setTextColor:[UIColor whiteColor]];
    _locationLabel.text = @"正在定位";
    UIImageView *titleicon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"07-map-marker"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    titleicon.tintColor = [UIColor whiteColor];
    
    [titleView addSubview:titleicon];
    [titleView addSubview:_locationLabel];
    
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(titleView);
        //make.left.equalTo(titleView).offset(20);
    }];
    [titleicon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@20);
        make.width.equalTo(@12);
        make.left.equalTo(_locationLabel).offset(-18);
        make.centerY.equalTo(titleView);
    }];
    
    [titleView addTarget:self action:@selector(selectLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = titleView;
    
    
    [_baiduService searchNearestStationAt:[BaiduService SharedInstance].locService.userLocation.location.coordinate
     Success:^(NSArray *pois) {
        if(pois.count > 0)
        {
            self.locationName  = pois[0];
        }
    } Failure:^(NSError *error) {
        
    }];

    _stationsSearchResult = [NSArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter setter

-(void)setLocationName:(NSString *)locationName
{
    _locationName = locationName;
    _locationLabel.text = _locationName;
}

#pragma mark - private method

- (void)selectLocation:(id)sender
{
    LocationsViewController *locationsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LocationsViewController"];
    locationsVC.delegate = self;
    locationsVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = locationsVC.popoverPresentationController;
    popover.backgroundColor = [UIColor darkGrayColor];
    popover.sourceView = self.anchor;
    popover.delegate = self;
    [self presentViewController:locationsVC animated:YES completion:^{
        
    }];
}

-(void)searchRout:(NSString *)origin destination:(NSString *)destination
{
//    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><meta name=\"viewport\" content=\"initial-scale=1.0,user-scalable=no\" /><script src=\"http://api.map.baidu.com/components?ak=yYZuIH7pkU0GtiO5pfDDI0in&v=1.0\"></script><style type=\"text/css\">body, html,#allmap {width: 100%%;height: 100%%;overflow: hidden;margin:0;}#golist {display: none;}@media (max-device-width: 800px){#golist{display: block!important;}}</style></head><body><lbs-transit strategy-index=\"1\" enable-strategy=\"true\" city=\"苏州\" origin=\"%@\" destination=\"%@\"></lbs-transit></body></html>",origin,destination];
//    [self.webView loadHTMLString:html baseURL:nil];
    

    NSString *urlString= [NSString stringWithFormat:@"http://api.map.baidu.com/direction?origin=%@&destination=%@&mode=transit&region=苏州&output=html&src=EasyBus", origin,destination];
    
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlString, NULL, NULL,  kCFStringEncodingUTF8 ));
                          
    NSURL *url =[NSURL URLWithString:encodedString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}

#pragma mark - web delegate

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.indicatorView startAnimating];
    self.indicatorLabel.text = @"正在查询路线";
    self.maskView.hidden = NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.maskView.hidden = YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicatorView stopAnimating];
    self.indicatorLabel.text = @"网络连接错误，请重试";
    self.maskView.hidden = NO;
}

#pragma mark - pop

-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}

#pragma mark - locationView

-(void)selectedLocation:(NSString *)location
{
    self.locationName = location;
}

-(void)selectedOtherLocation
{
    [self performSegueWithIdentifier:@"SearchLocations" sender:self];
}


#pragma mark - search view delegate

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.tableViewHeight.constant = 0;
    [searchBar resignFirstResponder];
    [self searchRout:self.locationName destination:searchBar.text];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [[BaiduService SharedInstance] searchSuggestionsByName:searchText Success:^(NSArray *pois) {
        _stationsSearchResult = pois;
        if(_stationsSearchResult.count > 0)
        {
            [self.stationsTableView reloadData];
            self.tableViewHeight.constant = 216;
        }
        else
        {
            self.tableViewHeight.constant = 0;
        }
    } Failure:^(NSError *error) {
        self.tableViewHeight.constant = 0;
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.tableViewHeight.constant = 0;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

#pragma mark - table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _stationsSearchResult.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = _stationsSearchResult[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.destinationSearchBar.text = _stationsSearchResult[indexPath.row];
    self.tableViewHeight.constant = 0;
    [self.destinationSearchBar resignFirstResponder];
    [self searchRout:self.locationName destination:_stationsSearchResult[indexPath.row]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SearchLocations"])
    {
        id vc = [segue destinationViewController];
        [vc setValue:self forKey:@"delegate"];
        [vc setValue:@1 forKey:@"type"];
    }
}


@end
