
//
//  MemoSearchController.h
//  MemoObj
//
//  Created by Sanmy on 15-4-18.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemoSearchController;
@protocol SearchViewControllerDelegate <NSObject>
- (void)searchControllerWillBeginSearch:(MemoSearchController *)controller;
- (void)searchControllerWillEndSearch:(MemoSearchController *)controller;
@end
@interface MemoSearchController : UIViewController

@property (nonatomic, weak) id<SearchViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
