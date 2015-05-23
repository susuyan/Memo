//
//  MemoCell.m
//  MemoObj
//
//  Created by Sanmy on 15-4-18.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoCell.h"
#import <NSDate+TimeAgo.h>
@interface MemoCell()
{
	CGFloat _shadowWidth;
}
@end
@implementation MemoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)layoutSubviews
{
	[super layoutSubviews];
    
	CGRect bounds = self.bounds;
	if (_shadowWidth != bounds.size.width)
	{
		if (_shadowWidth == 0)
		{
			[self.layer setMasksToBounds:NO ];
			[self.layer setShadowColor:[[UIColor blackColor ] CGColor ] ];
			[self.layer setShadowOpacity:0.5 ];
			[self.layer setShadowRadius:5.0 ];
			[self.layer setShadowOffset:CGSizeMake( 0 , 0 ) ];
			self.layer.cornerRadius = 5.0;
		}
		[self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:bounds ] CGPath ] ];
		_shadowWidth = bounds.size.width;
	}
}
/**
 *  绑定 cell 的内容
 *
 *  @param memoModel 一条数据
 */
- (void)setCellFromModel:(MemoModel *)memoModel
{
    self.memoContent.text = memoModel.content;
    
    //因为数据库中得时间,没有进行格式化,所以这里需要做一个转换
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    self.memoTimeAgo.text = [[formatter dateFromString:memoModel.timeAgo] timeAgo];
    
    self.memoTimeAgo.text = [memoModel.create_at timeAgo];
}

@end
