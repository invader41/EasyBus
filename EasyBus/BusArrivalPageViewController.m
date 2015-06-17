//
//  BusArrivalViewController.m
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "BusArrivalPageViewController.h"
#import <Masonry.h>

@interface BusArrivalPageViewController ()

@end

@implementation BusArrivalPageViewController

-(instancetype)initWithNavBarItems:(NSArray*)items navBarBackground:(UIColor*)background views:(NSArray*)views showPageControl:(BOOL)addPageControl
{
    self = [super initWithNavBarItems:items
                     navBarBackground:background 
                                views:views
                      showPageControl:addPageControl];
    if(self)
    {
        [self setCurrentPageControlColor:[UIColor whiteColor]];
        [self setTintPageControlColor:[UIColor colorWithWhite:0.799 alpha:1.000]];
        [self updateUserInteractionOnNavigation:NO];
        
        // Twitter Like
        self.pagingViewMovingRedefine = ^(UIScrollView *scrollView, NSArray *subviews){
            float mid   = [UIScreen mainScreen].bounds.size.width/2 - 45.0;
            float width = [UIScreen mainScreen].bounds.size.width;
            CGFloat xOffset = scrollView.contentOffset.x;
            int i = 0;
            for(UILabel *v in subviews){
                CGFloat alpha = 0.0;
                if(v.frame.origin.x < mid)
                    alpha = 1 - (xOffset - i*width) / width;
                else if(v.frame.origin.x >mid)
                    alpha=(xOffset - i*width) / width + 1;
                else if(v.frame.origin.x == mid-5)
                    alpha = 1.0;
                i++;
                v.alpha = alpha;
            }
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"dismissNav" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions



#pragma mark - Sizing utils

- (CGFloat)statusBarHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
