//
//  MemoModel.m
//  MemoObj
//
//  Created by Sanmy on 15/5/2.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoModel.h"
#import <NSDate+TimeAgo.h>



@implementation MemoModel

- (instancetype)initMemoModel:(NSDictionary *)memoInfo
{
    self = [super init];
    if (self) {
        
        if ([memoInfo[kCreate_at] isKindOfClass:[NSData class]]) {
         self.create_at =  [NSKeyedUnarchiver unarchiveObjectWithData: memoInfo[kCreate_at]];
        }
        self.content = memoInfo[kContent];
        self.imageData = memoInfo[kImageData];
        self.recordData = memoInfo[kRecordData];
        if (memoInfo[kmemoID]) {
            self.memoID = memoInfo[kmemoID];
        }
    }
    
    return self;
}


@end
