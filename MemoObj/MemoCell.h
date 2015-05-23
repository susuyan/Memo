//
//  MemoCell.h
//  MemoObj
//
//  Created by Sanmy on 15-4-18.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoModel.h"
@interface MemoCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UILabel *memoContent;
@property (weak, nonatomic) IBOutlet UILabel *memoTimeAgo;

/**
 *  将 model 设置到 cell 上
 */
- (void)setCellFromModel:(MemoModel *)memoModel;
@end
