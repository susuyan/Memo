//
//  MemoModel.h
//  MemoObj
//
//  Created by Sanmy on 15/5/2.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface MemoModel : NSObject

/**
 *  ID
 */
@property (nonatomic,strong) NSNumber *memoID;

/**
 *  文本内容
 */
@property (nonatomic, copy) NSString *content;

/**
 *  创建时间
 */
@property (nonatomic, strong) NSDate *create_at;

/**
 *  显示时间
 */
@property (nonatomic, strong) NSString *timeAgo;

/**
 *  二进制图片
 */
@property (nonatomic, strong) NSData  *imageData;

/**
 *  录音文件
 */
@property (nonatomic, strong) NSData *recordData;

- (instancetype)initMemoModel:(NSDictionary *) memoInfo;
@end
