//
//  GrouponInfoView.m
//  ZLYS
//
//  Created by Seven on 15/6/29.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "GrouponInfoView.h"
#import "GrouponCell.h"
#import "Commodity.h"
#import "CommodityDetailView.h"
#import "UIImageView+WebCache.h"
#import "Groupon.h"
#import "GrouponShopView.h"
#import "GrouponInfoCell.h"

@interface GrouponInfoView ()

@end

@implementation GrouponInfoView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = self.shopType.shopTypeName;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    commoditys = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [commoditys removeAllObjects];
    commoditys = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [commoditys removeAllObjects];
    isLoadOver = NO;
}

- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        //生成获取商品分类URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        [param setValue:@"0" forKey:@"stateId"];
        [param setValue:@"0" forKey:@"classType"];
        [param setValue:self.shopType.shopTypeId forKey:@"shopTypeId"];
        
        NSString *findCommodityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findShopInfoByPage] params:param];
        [[AFOSCClient sharedClient] getPath:findCommodityUrl parameters:Nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                        NSError *error;
                                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                        
                                        NSDictionary *datas = [json objectForKey:@"data"];
                                        NSArray *array = [datas objectForKey:@"resultsList"];
                                        
                                        NSMutableArray *commNews = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[Groupon class]]];
                                        isLoading = NO;
                                        if (!noRefresh) {
                                            [self clear];
                                        }
                                        
                                        @try {
                                            int count = [commNews count];
                                            allCount += count;
                                            if (count < 20)
                                            {
                                                isLoadOver = YES;
                                            }
                                            [commoditys addObjectsFromArray:commNews];
                                            [self.tableView reloadData];
                                            [self doneLoadingTableViewData];
                                        }
                                        @catch (NSException *exception) {
                                            [NdUncaughtExceptionHandler TakeException:exception];
                                        }
                                        @finally {
                                            [self doneLoadingTableViewData];
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        //如果是刷新
                                        [self doneLoadingTableViewData];
                                        
                                        if ([UserModel Instance].isNetworkRunning == NO) {
                                            return;
                                        }
                                        isLoading = NO;
                                        if ([UserModel Instance].isNetworkRunning) {
                                            [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                        }
                                    }];
        isLoading = YES;
        //        [self.newsTable reloadData];
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return commoditys.count == 0 ? 1 : commoditys.count;
        }
        else
            return commoditys.count + 1;
    }
    else
        return commoditys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < [commoditys count])
    {
        return 87.0;
    }
    else
    {
        return 47.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if ([commoditys count] > 0) {
        if (row < [commoditys count])
        {
            GrouponInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:GrouponInfoCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"GrouponInfoCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[GrouponInfoCell class]]) {
                        cell = (GrouponInfoCell *)o;
                        break;
                    }
                }
            }
            Groupon *shop = [commoditys objectAtIndex:row];
            NSString *imageUrl = [NSString stringWithFormat:@"%@_200",shop.imgUrlFull];
            [cell.picIV sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
            cell.shopNameLb.text = shop.shopName;
            cell.addressLb.text = [NSString stringWithFormat:@"地址:%@", shop.shopAddress];
            cell.telLb.text = [NSString stringWithFormat:@"电话:%@", shop.phone];
//            
//            if(shop.distance > 0)
//            {
//                cell.distanceView.hidden = NO;
//                cell.distanceLb.text = [NSString stringWithFormat:@"%.2f千米", shop.distance];
//            }
//            else
//            {
//                cell.distanceView.hidden = YES;
//            }
            
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"暂无数据" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    //点击“下面20条”
    if (row >= [commoditys count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Groupon *groupon = [commoditys objectAtIndex:row];
        if (groupon) {
            GrouponShopView *detailView = [[GrouponShopView alloc] init];
            detailView.groupon = groupon;
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}

- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}

// tableView添加拉更新
- (void)egoRefreshTableHeaderDidTriggerToBottom
{
    if (!isLoading) {
        [self performSelector:@selector(reload:)];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}
- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
}

- (void)dealloc
{
    [self.tableView setDelegate:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
