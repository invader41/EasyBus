//
//  NearbyStationsPageViewController.m
//  EasyBus
//
//  Created by pengsy on 15/6/26.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import "NearbyStationsPageViewController.h"

@interface NearbyStationsPageViewController ()

@end

@implementation NearbyStationsPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
