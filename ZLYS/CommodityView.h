//
//  CommodityView.h
//  WHDLife
//
//  Created by Seven on 15-1-16.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommodityClass.h"

@interface CommodityView : UIViewController<EGORefreshTableHeaderDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *commoditys;

    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
}

@property (copy, nonatomic) CommodityClass *classOb;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
