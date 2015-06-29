//
//  GrouponInfoView.h
//  ZLYS
//
//  Created by Seven on 15/6/29.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommodityClass.h"
#import "ShopType.h"

@interface GrouponInfoView : UIViewController<EGORefreshTableHeaderDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *commoditys;
    
    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
}

@property (copy, nonatomic) ShopType *shopType;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
