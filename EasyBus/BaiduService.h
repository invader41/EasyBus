//
//  BaiduService.h
//  EasyBus
//
//  Created by pengsy on 15/6/8.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>

@interface BaiduService : NSObject
-(void)registerBaiduService;
-(void)busLineSearch:(NSString *)busline;
+(instancetype)SharedInstance;
@end
