//
//  LineInfo.h
//  EasyBus
//
//  Created by pengsy on 15/6/4.
//  Copyright (c) 2015年 PSY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineInfo : NSObject
@property (strong, nonatomic) NSString *LPGUID;
@property (strong, nonatomic) NSString *LPLineName;
@property (strong, nonatomic) NSString *LPFStdName;
@property (strong, nonatomic) NSString *LPEStdName;
@property (strong, nonatomic) NSString *LPIntervalH;
@property (strong, nonatomic) NSString *LPIntervalN;
@property (strong, nonatomic) NSString *LPDirection;
@property (strong, nonatomic) NSString *LPCompGUID;
@property (strong, nonatomic) NSString *LPRunBusNum;
@property (strong, nonatomic) NSString *LPRunShiftNum;
@property (strong, nonatomic) NSString *LPRunYear;
@property (strong, nonatomic) NSString *LPLineDirect;
@property (strong, nonatomic) NSString *LPStandName;
@end
