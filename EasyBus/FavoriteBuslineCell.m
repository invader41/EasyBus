//
//  FavoriteBuslineCell.m
//  EasyBus
//
//  Created by pengsy on 15/6/17.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "FavoriteBuslineCell.h"
#import "BusService.h"
#import <Masonry.h>

@interface FavoriteBuslineCell()
{
    NSMutableArray *_busArrivalsResult;
    UITableView *_tableView;
    UILabel *_titleLabel1;
}
@end
@implementation FavoriteBuslineCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _busArrivalsResult = [NSMutableArray array];
        
        _titleLabel1 = [[UILabel alloc] init];
        _titleLabel1.backgroundColor = [UIColor whiteColor];
        [_titleLabel1 setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel1 setFont:[UIFont fontWithName:@"HelveticaBold" size:14]];
        [self.contentView insertSubview:_titleLabel1 atIndex:0];
        
        _tableView = [[UITableView alloc] init];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.contentView insertSubview:_tableView atIndex:0];
        
        [_titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.height.equalTo(@20);
            make.bottom.equalTo(_tableView.mas_top);
        }];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLabel1.mas_bottom);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

    }
    return self;
}

-(void)refreshData
{
    [self.indicator startAnimating];
    _titleLabel1.text = [NSString stringWithFormat:@"%@路", self.favoriteBusLine.lineName];
    [[BusService SharedInstance] searchBuslineArrivals:self.favoriteBusLine.busLine Success:^(NSArray *arrivals) {
        _busArrivalsResult = [NSMutableArray array];
//        for(Arrival *arrival in arrivals)
//        {
//            if(arrival.ArrivalTime.length > 0)
//            {
//                [_busArrivalsResult addObject:arrival];
//            }
//        }
        _busArrivalsResult = [NSMutableArray arrayWithArray:arrivals];
        [_tableView reloadData];
        [self.indicator stopAnimating];
        [self setNeedsDisplay];
    } Failure:^(NSError *error) {
        
    }];
}

#pragma mark - tableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _busArrivalsResult.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    Arrival *arrival = _busArrivalsResult[indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
//    [cell.textLabel setNumberOfLines:0];
//    [cell.textLabel setLineBreakMode:NSLineBreakByCharWrapping];
    if(arrival.ArrivalTime.length > 0)
    {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:arrival.stationName];
        NSRange contentRange = {0,[content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        [content addAttribute:NSBackgroundColorAttributeName value:[UIColor greenColor] range:contentRange];
        cell.textLabel.attributedText = content;
    }
    else
        cell.textLabel.text = arrival.stationName;
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    cell.detailTextLabel.text = arrival.ArrivalTime;

    return cell;
}
@end
