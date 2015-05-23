//
//  MemoSearchController.m
//  MemoObj
//
//  Created by Sanmy on 15-4-18.
//  Copyright (c) 2015年 susuyan. All rights reserved.
//

#import "MemoSearchController.h"

@interface MemoSearchController ()

@end

@implementation MemoSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    id<SearchViewControllerDelegate> delegate = self.delegate;
    if (delegate)
    {
        [delegate searchControllerWillBeginSearch:self];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    id<SearchViewControllerDelegate> delegate = self.delegate;
    if (delegate)
    {
        [delegate searchControllerWillEndSearch:self];
    }
}



@end
