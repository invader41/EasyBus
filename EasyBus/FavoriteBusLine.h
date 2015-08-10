//
//  FavoriteBusLine.h
//  EasyBus
//
//  Created by pengsy on 15/6/16.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoriteBusLine : NSManagedObject

@property (nonatomic, retain) NSString * busCode;
@property (nonatomic, retain) NSString * busName;
@property (nonatomic, retain) NSString * direction;
@end
