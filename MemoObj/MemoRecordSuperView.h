//
//  MemoRecordSuperView.h
//  MemoObj
//
//  Created by Sanmy on 15/5/15.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemoRecordSuperView : UIView
@property (weak, nonatomic) IBOutlet UIButton *recordPause;
@property (weak, nonatomic) IBOutlet UIButton *recordPlay;
@property (weak, nonatomic) IBOutlet UIButton *recordStop;

@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@end
