//
//  MemoEvernoteHelper.m
//  MemoObj
//
//  Created by Sanmy on 15/5/8.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoEvernoteHelper.h"
#import <ENSDK.h>
@implementation MemoEvernoteHelper

/**
 *  从服务器上更新数据
 *
 *  @return 返回一组 memoModel 对象
 */
+ (NSMutableArray *)downloadMemo
{
    return nil;
}
/**
 *  上传到服务器
 */
+ (void)updateMemo:(NSMutableArray *)memoArr
{
    for (int i = 0; i < memoArr.count; i++) {
        MemoModel *memo = [memoArr objectAtIndex:i];
        [MemoEvernoteHelper memoToEverNote:memo];
    }
}
+ (void)memoToEverNote:(MemoModel *)memo
{
    ENNote *note = [[ENNote alloc] init];
    note.content = [ENNoteContent noteContentWithString:memo.content];
    
    if (memo.imageData) {
        ENResource *resImg = [[ENResource alloc] initWithData:memo.imageData mimeType:@"image/png"];
        [note addResource:resImg];
    }
//    if (memo.recordData) {
//        ENResource *record = [[ENResource alloc] initWithData:memo.recordData mimeType:@"media/caf"];
//        [note addResource:record];
//    }
    
    [[ENSession sharedSession] uploadNote:note notebook:nil completion:^(ENNoteRef *noteRef, NSError *uploadNoteError) {
        
    }];
    
    
}
@end
