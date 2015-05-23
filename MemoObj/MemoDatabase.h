//
//  MemoDatabase.h
//  MemoObj
//
//  Created by Sanmy on 15/5/4.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemoDatabase : NSObject

/**
 *  插入一条记录
 *
 *  @param memoInfo 一条记录的字典
 */
+ (void)saveMemoToDatabase:(NSDictionary *)memoInfo;

/**
 *  查询所有记录
 *
 *  @return  model 数组
 */
+ (NSMutableArray *)memoArrFromDatabase;


/**
 *  删除一条记录
 */
+ (void)memoDeleteFromDatabase:(NSString *)memoContent;

/**
 *  修改一条记录
 */
+ (void)memoModifyFromDatabase:(NSDictionary *)memoInfo;
@end
