//
//  PaymentListView.h
//  BBK
//
//  Created by Seven on 14-12-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentListView : UIViewController<UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *payments;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIImageView *userFaceIv;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *userAddressLb;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
