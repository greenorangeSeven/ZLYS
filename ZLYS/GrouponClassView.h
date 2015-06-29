//
//  CommodityClassView.h
//  WHDLife
//
//  Created by Seven on 15-1-16.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface GrouponClassView : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate, SGFocusImageFrameDelegate>
{
    NSMutableArray *classes;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

//@property (strong, nonatomic) UIImageView *advIv;
@property (weak, nonatomic) IBOutlet UIImageView *advIv;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)refreshExpressData;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end