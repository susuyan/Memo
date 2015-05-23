//
//  MemoListController.m
//  MemoObj
//
//  Created by Sanmy on 15-4-18.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoListController.h"
#import "MemoCell.h"
#import <MTCardLayout.h>
#import <UICollectionView+CardLayout.h>
#import <LSCollectionViewLayoutHelper.h>
#import <UICollectionView+Draggable.h>
#import "MemoSearchController.h"
#import "UIViewController+ScrollingNavbar.h"
#import "MemoModel.h"
#import <NSDate+TimeAgo.h>
#import <FMDB.h>
#import "MemoDatabase.h"
#import "MemoEditController.h"
#import <ENSDK.h>
#import "MemoEvernoteHelper.h"

@interface MemoListController ()<SearchViewControllerDelegate,UICollectionViewDataSource_Draggable,UINavigationBarDelegate>

typedef NSComparisonResult (^NSComparator)(id obj1,id obj2);


@property (nonatomic, strong) MemoSearchController *searchViewController;

@property (nonatomic, strong) FMDatabase    *databaseManager;

@property (nonatomic, strong) NSMutableArray *memoArr;

@end

@implementation MemoListController

/**
 *  懒加载
 */
-(FMDatabase *)databaseManager
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    if (_databaseManager == nil) {
        _databaseManager = [FMDatabase databaseWithPath:[path stringByAppendingPathComponent:@"memo.db"]];
    }
    
    return _databaseManager;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // 设置删除的图标和 searchCtrl
    [self setImageViewAndSearchCtrl];
    
    //导航栏的隐藏
     
    [self followScrollView:self.collectionView];
    [self setUseSuperview:YES];
    
    [self setMemoFromDatabase];
    
    //接受通知并更新数据源
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMemoFromDatabase) name:kNotiUpdateData object:nil];
}


#pragma mark - Sync Action

- (IBAction)syncMemo:(id)sender {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
       //请求授权
        ENSession *session = [ENSession sharedSession];
        [session authenticateWithViewController:self preferRegistration:NO completion:^(NSError *error) {
            if (error) {
                // authentication failed
                // show an alert, etc
                // ...
                
                                
            } else {
                // authentication succeeded
                // do something now that we're authenticated
                // ...
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogin"];
                [self uploadMemo];
            }
        }];
        
    }
    
}
- (void)uploadMemo
{
    [MemoEvernoteHelper updateMemo:self.memoArr];
}


#pragma mark - View Lifecycle

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView setPresenting:YES animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.memoArr.count;
}

- (void)setImageViewAndSearchCtrl
{
    /**
     *  background controller
     */
    self.searchViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchViewController"];
    self.searchViewController.delegate = self;
	self.collectionView.backgroundView = self.searchViewController.view;

	/**
	 *  delete image icon
	 */
	UIImageView *dropOnToDeleteView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trashcan"] highlightedImage:[UIImage imageNamed:@"trashcan_red"]];
	dropOnToDeleteView.center = CGPointMake(50, 300);
	self.collectionView.dropOnToDeleteView = dropOnToDeleteView;
	
	UIImageView *dragUpToDeleteConfirmView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trashcan"] highlightedImage:[UIImage imageNamed:@"trashcan_red"]];
	self.collectionView.dragUpToDeleteConfirmView = dragUpToDeleteConfirmView;
}

#pragma mark - Memo datasource
- (void)setMemoFromDatabase
{
    //[self.memoArr removeAllObjects];
    //将数据库中得数据取到数据源
   self.memoArr = [MemoDatabase memoArrFromDatabase];
    //时间排序
    NSMutableArray *arr = [MemoDatabase memoArrFromDatabase];
    NSArray *memos = [arr sortedArrayUsingComparator:^NSComparisonResult(MemoModel *obj1, MemoModel *obj2) {
        return [obj2.create_at compare:obj1.create_at];
    }];
    self.memoArr = [NSMutableArray arrayWithArray:memos];
    [self.collectionView reloadData];
    self.collectionView.presenting = NO;
}
#pragma mark - CollectionView delegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	MemoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"memoCell" forIndexPath:indexPath];
    [cell setCellFromModel:self.memoArr[indexPath.item]];
	return cell;
}

- (UIImage *)collectionView:(UICollectionView *)collectionView imageForDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
	CGSize size = cell.bounds.size;
	size.height = 72.0;
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[cell.layer renderInContext:context];
	
	UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

- (CGAffineTransform)collectionView:(UICollectionView *)collectionView transformForDraggingItemAtIndexPath:(NSIndexPath *)indexPath duration:(NSTimeInterval *)duration
{
	return CGAffineTransformMakeScale(1.05f, 1.05f);
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString * item = self.memoArr[fromIndexPath.item];
    [self.memoArr removeObjectAtIndex:fromIndexPath.item];
    [self.memoArr insertObject:item atIndex:toIndexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

- (BOOL)collectionView:(UICollectionView *)collectionView canDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView deleteItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    MemoModel *model = [self.memoArr objectAtIndex:indexPath.item];
    [MemoDatabase memoDeleteFromDatabase:model.content];
    [self.memoArr removeObjectAtIndex:indexPath.item];
   
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeleteItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark SearchCell

- (void)searchControllerWillBeginSearch:(MemoSearchController *)controller
{
    if (!self.collectionView.presenting)
    {
        [self.collectionView setPresenting:YES animated:YES completion:nil];
    }
}

- (void)searchControllerWillEndSearch:(MemoSearchController *)controller
{
    if (self.collectionView.presenting)
    {
        [self.collectionView setPresenting:NO animated:YES completion:nil];
    }
}

#pragma mark - NavigationBar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self showNavBarAnimated:NO];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // This enables the user to scroll down the navbar by tapping the status bar.
    [self showNavbar];
    
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    MemoEditController *desti = (MemoEditController *)segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"addmemo"]) {
        [desti setValue:@(YES) forKey:@"isAddMemo"];
    }else {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:(MemoCell *)sender];
        MemoModel *memo = self.memoArr[indexPath.item];
        
        [desti setValue:memo forKeyPath:@"memo"];

    }
    
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    return YES;
    
}

@end
