//
//  FilterAddressPackageMessage.h
//  WoChuangFu
//
//  Created by 李新新 on 14-12-30.
//  Copyright (c) 2014年 asiainfo-linkage. All rights reserved.
//

#import "message.h"

#define FILTERADDRESSPACKAGE_BIZCODE  @"cf0035"
@interface FilterAddressPackageMessage : message

+ (NSString*)getBizCode;

@end