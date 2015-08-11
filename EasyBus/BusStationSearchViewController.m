//
//  BusStationSearchViewController.m
//  EasyBus
//
//  Created by pengsy on 15/8/3.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BusStationSearchViewController.h"
#import "BaiduService.h"

@interface BusStationSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_stationsSearchResult;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)back:(id)sender;

@end

@implementation BusStationSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([self.type  isEqual: @0])
    {
        self.title = @"站台搜索";
        self.searchBar.placeholder = @"请输入站台名称";
    }
    if([self.type  isEqual: @1])
    {
        self.title = @"位置搜索";
        self.searchBar.placeholder = @"请输入位置名称";
    }
    _stationsSearchResult = [NSArray array];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

#pragma mark - private method



#pragma mark - search view delegate

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([self.type  isEqual: @0])
    {
        [[BaiduService SharedInstance] searchStationsByName:searchText Success:^(NSArray *pois) {
            _stationsSearchResult = pois;
            [self.tableView reloadData];
            
        } Failure:^(NSError *error) {
            
        }];
    }
    if([self.type  isEqual: @1])
    {
        [[BaiduService SharedInstance] searchSuggestionsByName:searchText Success:^(NSArray *pois) {
            _stationsSearchResult = pois;
            [self.tableView reloadData];
        } Failure:^(NSError *error) {
            [self.tableView reloadData];
        }];
    }
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
    [self.delegate selectedLocation:_stationsSearchResult[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
