//
//  MemoEvernoteHelper.h
//  MemoObj
//
//  Created by Sanmy on 15/5/8.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoModel.h"


@interface MemoEvernoteHelper : NSObject

+ (void)updateMemo:(NSMutableArray *)memoArr;

+ (NSMutableArray *)downloadMemo;

@end
