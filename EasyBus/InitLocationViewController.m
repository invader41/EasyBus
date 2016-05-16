//
//  InitLocationViewController.m
//  EasyBus
//
//  Created by pengsy on 15/7/16.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "InitLocationViewController.h"
#import "BaiduService.h"
#import <BaiduMapAPI/BMapKit.h>
#import "NearbyBusesViewController.h"

@interface InitLocationViewController ()<BMKGeneralDelegate,BMKLocationServiceDelegate>
{
    BOOL _located;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation InitLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _located = NO;
    self.titleLabel.text = @"正在注册服务";
    
    
    BMKMapManager* mapManager = [[BMKMapManager alloc]init];
    if([mapManager start:@"yYZuIH7pkU0GtiO5pfDDI0in" generalDelegate:self])
    {
       
    }
    else
    {
        
    }
    
//    [[BaiduService SharedInstance] regist:^(BOOL successd) {
//        if(successd)
//        {
//            self.titleLabel.text = @"正在定位";
//            [[BaiduService SharedInstance] startUserLocationService:^(BOOL successd) {
//                [self performSegueWithIdentifier:@"Start" sender:self];
//            }];
//        }
//        else
//        {
//            self.titleLabel.text = @"注册服务失败";
//        }
//    }];
}

#pragma mark - BMKLocationServiceDelegate

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if(!_located)
    {
        _located = YES;
        [[BaiduService SharedInstance].locService setDelegate:nil];
        [self performSegueWithIdentifier:@"Start" sender:self];
    }
}

-(void)didFailToLocateUserWithError:(NSError *)error
{
    self.titleLabel.text = @"定位失败";
    [[BaiduService SharedInstance].locService setDelegate:nil];
    [self performSegueWithIdentifier:@"Start" sender:self];
}

//#pragma mark - CLLocationManagerDelegate
//
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    if(!_located)
//    {
//        _located = YES;
//        [[BaiduService SharedInstance].locService setDelegate:nil];
//        [self performSegueWithIdentifier:@"Start" sender:self];
//    }
//}
//
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    self.titleLabel.text = @"定位失败";
//    [[BaiduService SharedInstance].locService setDelegate:nil];
//    [self performSegueWithIdentifier:@"Start" sender:self];
//}


#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"联网失败");
        self.titleLabel.text = @"网络连接错误";
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
        //设置定位精确度，默认：kCLLocationAccuracyBest
        [BaiduService SharedInstance].locService.delegate = self;
         [[BaiduService SharedInstance].locService startUserLocationService];
    }
    else {
        NSLog(@"授权失败");
        self.titleLabel.text = @"注册服务失败";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    NearbyBusesViewController *vc = [segue destinationViewController];
//    vc.initLocation = _locationManager.location.coordinate;
//}


@end
