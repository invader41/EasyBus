//
//  CommonModel.h
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonModel : NSObject
@property (strong, nonatomic) NSString *resultcode;
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSArray *result;
@end
