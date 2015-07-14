//
//  FavoriteCarCode.h
//  EasyBus
//
//  Created by pengsy on 15/6/16.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FavoriteCarCode : NSManagedObject

@property (nonatomic, retain) NSString * carCode;
@property (nonatomic, retain) NSString * busLine;
@property (nonatomic, retain) NSString * lineName;

@end
