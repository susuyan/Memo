//
//  MemoEditController.m
//  MemoObj
//
//  Created by Sanmy on 15-4-18.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoEditController.h"
#import <AVFoundation/AVFoundation.h>
#import <UPStackMenu.h>
#import "MemoModel.h"
#import "MemoDatabase.h"
#import "MemoListController.h"
#import "MemoRecordSuperView.h"

#define kRecordAudioFile @"RecordAudioFile.caf"

@interface MemoEditController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UINavigationBarDelegate,AVAudioRecorderDelegate,UPStackMenuDelegate,UPStackMenuItemDelegate>

@property (nonatomic, strong) NSMutableDictionary *memoDic;

@property (nonatomic) BOOL   isAddMemo;

@property (nonatomic, strong) MemoModel *memo;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UPStackMenu *stack;

@property (nonatomic, strong) MemoRecordSuperView *recordSuperView;
//录音操作的属性
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@property (nonatomic,strong) NSTimer *timer;//录音声波监控（注意这里暂时不对播放进行监控）

@end

@implementation MemoEditController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    [self setUpView];
    
    [self setAudioSession];
    
    self.navigationController.delegate = self;
    
    //注册键盘通知
    [self setKeyboardNotification];
 
    self.music.hidden = YES;
}

- (void)setKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - load view
- (void)setUpView
{
    if (self.isAddMemo) {
        self.textview.text = nil;
    }
    self.textview.text = self.memo.content;
    
    if (![self.memo.imageData isKindOfClass:[NSNull class]]) {
       self.imageview.image = [UIImage imageWithData:self.memo.imageData];
    }
    if (![self.memo.recordData isKindOfClass:[NSNull class]]) {
        self.music.hidden = NO;
    }
    
    [self setupStackmenu];
}

#pragma mark - event Action
/**
 *  将一条数据保存到本地数据库
 */
- (IBAction)saveMemo:(id)sender {
    
    if ([self.textview.text  isEqual: @""]) {
        return;
    }
    if (self.isAddMemo) {
        //执行插入数据操作
        NSDate *date = [NSDate date];
        NSData *dateData = [NSKeyedArchiver archivedDataWithRootObject:date];
        
        _memoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.textview.text,kContent,dateData ,kCreate_at,UIImagePNGRepresentation(self.imageview.image),kImageData, nil];
        //添加到数据库
        [MemoDatabase saveMemoToDatabase:_memoDic];
        
        //保存完数据发送一个通知到上一个界面,更新数据源
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiUpdateData object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } else{
        //执行修改的操作
        _memoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.textview.text,kContent,UIImagePNGRepresentation(self.imageview.image),kImageData, nil];
        [MemoDatabase memoModifyFromDatabase:_memoDic];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiUpdateData object:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

#pragma mark - View lifeCercle
/**
 *  初始化 stackmenu
 */

- (void)setupStackmenu
{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _contentView.backgroundColor = [UIColor purpleColor];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cross"]];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    [icon setFrame:CGRectInset(_contentView.frame, 10, 10)];
    [_contentView addSubview:icon];
    
    _stack = [[UPStackMenu alloc] initWithContentView:_contentView];
    [_stack setCenter:CGPointMake(self.view.frame.size.width/2 + 100 , self.view.frame.size.height/2 - 40) ];
    [_stack setDelegate:self];
    
    UPStackMenuItem *cameraItem = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"camera"] highlightedImage:nil title:@"Camera"];
   
    UPStackMenuItem *voiceItem = [[UPStackMenuItem alloc] initWithImage:[UIImage imageNamed:@"Voice"]];
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:cameraItem,voiceItem, nil];
    [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitleColor:[UIColor yellowColor]];
    }];
    
    
    [_stack setAnimationType:UPStackMenuAnimationType_progressive];
    [_stack setStackPosition:UPStackMenuStackPosition_up];
    [_stack setOpenAnimationDuration:.4];
    [_stack setCloseAnimationDuration:.4];
    [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setLabelPosition:UPStackMenuItemLabelPosition_right];
        [item setLabelPosition:UPStackMenuItemLabelPosition_left];
    }];
    
    [_stack addItems:items];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_stack];
    
    [self setStackIconClosed:YES];
}
- (void)setStackIconClosed:(BOOL)closed
{
    UIImageView *icon = [[_contentView subviews] objectAtIndex:0];
    float angle = closed ? 0 : (M_PI * (135) / 180.0);
    [UIView animateWithDuration:0.3 animations:^{
        [icon.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
    }];
}

- (void)stackMenu:(UPStackMenu *)menu didTouchItem:(UPStackMenuItem *)item atIndex:(NSUInteger)index
{
    UIImagePickerController *imageCtrl = [[UIImagePickerController alloc] init];
    imageCtrl.delegate = self;
    [self.textview resignFirstResponder];
    switch (index) {
        case 0:
            [self presentViewController:imageCtrl animated:YES completion:^{
                NSLog(@"添加图片");
            }];
            [_stack closeStack];
            break;
        case 1:
            //[self setUpRecordView];
            _recordSuperView = [[[NSBundle mainBundle] loadNibNamed:@"MemoRecordSuperView" owner:nil options:nil] firstObject];
            [self.textview addSubview:_recordSuperView];
            [self setRecordAction];
            NSLog(@"添加音频");
            
            [_stack closeStack];
            break;
        default:
            break;
    }
}
#pragma mark - imagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageview.image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - navigation delegate
//获取 navigation 的返回时机
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isMemberOfClass:[MemoListController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiUpdateData object:nil];
    }
    
}
#pragma mark - stack view move

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_stack.frame, location)) {
        _stack.center = location;
        
    }

}
- (IBAction)hideKeyboard:(id)sender {
    
    [self.textview resignFirstResponder];
}


#pragma mark - keyboard
- (void)willShowKeyboard:(NSNotification *)noti
{
    CGRect frame = self.imageview.frame;
    CGRect fr    = self.music.frame;
    //获取键盘高度
    NSDictionary *info = [noti userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSNumber *duration = [noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    frame.origin.y = keyboardSize.height + 3;
    fr.origin.y = keyboardSize.height + 3;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        self.imageview.frame = frame;
        self.music.frame = fr;
    }];
    
}
- (void)willHideKeyboard:(NSNotification *)noti
{

    NSNumber *duration = [noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect frame = self.imageview.frame;
    CGRect fr = self.music.frame;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - 150;
    fr.origin.y = [UIScreen mainScreen].bounds.size.height - 150;
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        self.imageview.frame = frame;
        self.music.frame = fr;
    }];
}

/**
 *  录音功能
 */
- (void)setAudioSession
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置为播放和录音状态,以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
/**
 *  取得录音文件保存路径
 */
- (NSURL *)getSavePath
{
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path :%@",urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    return url;
}
/**
 *  取得录音文件设置
 *
 */
- (NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    
    
    return dicM;
}
/**
 *  获得录音机对象
 */

- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder) {
        //创建录音文件保存对象
        NSURL *url = [self getSavePath];
        //创建录音格式设置
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        if (error) {
            NSLog(@"创建录音机对象是发生错误,错误信息 %@",error);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  录音声波监控定制器
 *
 *  @return 定时器
 */
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
/**
 *  录音声波状态设置
 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    CGFloat progress=(1.0/160.0)*(power+160.0);
    [self.recordSuperView.progress setProgress:progress];
}

#pragma mark - setup Record View
- (void)setUpRecordView
{
    [self setRecordAction];
}
- (void)setRecordAction
{
    [self.recordSuperView.recordPause addTarget:self action:@selector(recordPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordSuperView.recordPlay addTarget:self action:@selector(recordPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordSuperView.recordStop addTarget:self action:@selector(recordStopAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)recordPauseAction:(id)sender
{
    NSLog(@"暂停录音");
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate=[NSDate distantFuture];
    }
}
- (void)recordPlayAction:(id)sender
{
    NSLog(@"开始录音");
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate=[NSDate distantPast];
    }else {
        [self.audioRecorder record];
        self.timer.fireDate = [NSDate distantPast];
    }
}
- (void)recordStopAction:(id)sender
{
    NSLog(@"退出录音");
    [self.audioRecorder stop];
    self.timer.fireDate=[NSDate distantFuture];
    self.recordSuperView.progress.progress=0.0;
    NSArray *views = [_recordSuperView subviews];
    for (UIView *view in views) {
        [view removeFromSuperview];
    }
    _recordSuperView.hidden = YES;
    self.music.hidden = NO;
}

-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}
- (IBAction)playRecord:(id)sender {
    if ([self getSavePath]) {
        return;
    }
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer pause];
    }else {
        [_audioPlayer play];
    }
}

@end
