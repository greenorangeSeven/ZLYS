//
//  FeeTableView.h
//  WHDLife
//
//  Created by Seven on 15-1-21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeeTableView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>
{
    NSMutableArray *bills;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@property (copy, nonatomic) NSString *titleStr;
@property (copy, nonatomic) NSString *typeId;

@property (weak, nonatomic) IBOutlet UILabel *facebgLb;
@property (weak, nonatomic) IBOutlet UIImageView *faceIv;
@property (weak, nonatomic) IBOutlet UILabel *addressLb;
@property (weak, nonatomic) IBOutlet UILabel *noPayTotalLb;
@property (weak, nonatomic) IBOutlet UILabel *nopayMoneyLb;
@property (weak, nonatomic) IBOutlet UISegmentedControl *stateSegmented;

- (IBAction)stateChangedAction:(id)sender;

@end
