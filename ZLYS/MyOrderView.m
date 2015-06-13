//
//  MyOrderView.m
//  WHDLife
//
//  Created by Seven on 15-1-28.
//  Copyright (c) 2015年 Seven. All rights reserved.
//  {"header":{"state":"0000"},"data":[{"stateId":0,"stateName":"等待付款"},{"stateId":1,"stateName":"已付款"},{"stateId":2,"stateName":"已发货"},{"stateId":3,"stateName":"交易成功"},{"stateId":4,"stateName":"交易关闭"}]}
//

#import "MyOrderView.h"
#import "MyOrderCell.h"
#import <AlipaySDK/AlipaySDK.h>

@interface MyOrderView ()
{
    UserInfo *userInfo;
    NSString *stateId;
    int currentIndex;
}

@end

@implementation MyOrderView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"我的订单";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    if (self.fromBuy) {
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle: @"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePayedTable) name:ORDER_PAY_NOTIC object:nil];
    
    orders = [[NSMutableArray alloc] initWithCapacity:20];
    [self getUrl];
    [self reload:YES];
}

- (void)backAction
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [arr removeObjectAtIndex:arr.count - 2];
    self.navigationController.viewControllers = arr;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getUrl
{
    NSString *getOrderListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAllOrderState] params:nil];
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
        
        //生成获取订单列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.regUserId forKey:@"regUserId"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        if ([stateId length] > 0) {
            [param setValue:stateId forKey:@"stateId"];
        }
        NSString *getOrderListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findOrderByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:getOrderListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSMutableArray *orderNews = [Tool readJsonStrToOrderArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           int count = [orderNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [orders addObjectsFromArray:orderNews];
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
                                       NSLog(@"列表获取出错");
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
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [orders removeAllObjects];
    orders = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [orders removeAllObjects];
    isLoadOver = NO;
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return orders.count == 0 ? 1 : orders.count;
        }
        else
            return orders.count + 1;
    }
    else
        return orders.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < orders.count)
    {
        MyOrder *shopcar = [orders objectAtIndex:row];
        return 221 + (([shopcar.commodityObjectList count] -1) * 85);
    }
    else
    {
        return 40.0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if ([orders count] > 0) {
        if (row < [orders count])
        {
            MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:MyOrderCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyOrderCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[MyOrderCell class]]) {
                        cell = (MyOrderCell *)o;
                        break;
                    }
                }
            }
            int indexRow = [indexPath row];
            
            MyOrder *order = [orders objectAtIndex:indexRow];
            
            cell.orderNumberLb.text = [NSString stringWithFormat:@"订单号:%@", order.orderId];
            cell.stateNameLb.text = order.stateName;
            cell.receivingInfoLb.text = [NSString stringWithFormat:@"联系人:%@(%@)", order.receivingUserName, order.phone];
            cell.receivingAddressLb.text = order.receivingAddress;
            
            cell.shopName.text = order.shopName;
            cell.subTotalLb.text = [NSString stringWithFormat:@"合计:￥%0.2f", order.totalPrice];
            
            cell.subTotalView.frame = CGRectMake(cell.subTotalView.frame.origin.x, cell.subTotalView.frame.origin.y + ([order.commodityList count] - 1) * 85, cell.subTotalView.frame.size.width, cell.subTotalView.frame.size.height);
            
            cell.navigationController = self.navigationController;
            //初始化商品
            [cell loadShopCommoditys:order andRow:indexRow];
            
            cell.commodityTable.frame = CGRectMake(cell.commodityTable.frame.origin.x, cell.commodityTable.frame.origin.y, cell.commodityTable.frame.size.width, [order.commodityList count] * 85);
            
            if (order.stateId == 0) {
                cell.payOrderBtn.hidden = NO;
                cell.payOrderBtn.tag = indexRow;
                cell.closeOrderBtn.hidden = NO;
                [cell.payOrderBtn addTarget:self action:@selector(doPay:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.payOrderBtn.hidden = YES;
                cell.closeOrderBtn.hidden = YES;
            }
            
            cell.closeOrderBtn.tag = indexRow;
            [cell.closeOrderBtn addTarget:self action:@selector(doClose:) forControlEvents:UIControlEventTouchUpInside];
            
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
    if (row >= [orders count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)item1Action:(id)sender {
    [self.item1Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item1Btn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.item2Btn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.item3btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.item3btn setBackgroundImage:nil forState:UIControlStateNormal];
    stateId = @"";
    isLoadOver = NO;
    [self reload:NO];
}

- (IBAction)item2Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.item1Btn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item2Btn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    [self.item3btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.item3btn setBackgroundImage:nil forState:UIControlStateNormal];
    stateId = @"0";
    isLoadOver = NO;
    [self reload:NO];
}

- (IBAction)item3Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.item1Btn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.item2Btn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.item3btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item3btn setBackgroundImage:[UIImage imageNamed:@"activity_tab_bg"] forState:UIControlStateNormal];
    stateId = @"1,2,3";
    isLoadOver = NO;
    [self reload:NO];
}

- (void)doPay:(UIButton *)sender
{
    MyOrder *order = [orders objectAtIndex:sender.tag];
    
    //生成支付宝订单URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createAlipayParams];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:order.orderId forKey:@"orderId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
    currentIndex = sender.tag;
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在支付..." andView:self.view andHUD:request.hud];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestCreate:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [json objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        NSString *orderStr = [json objectForKey:@"msg"];
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:@"ZLYSAlipay" callback:^(NSDictionary *resultDic)
         {
             NSString *resultState = resultDic[@"resultStatus"];
             if([resultState isEqualToString:ORDER_PAY_OK])
             {
                 [self updatePayedTable];
             }
         }];
    }
}

#pragma mark 刷新列表(当程序支付时在后台被kill掉时供appdelegate调用)
- (void)updatePayedTable
{
    [Tool showCustomHUD:@"支付成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
    MyOrder *order = [orders objectAtIndex:currentIndex];
    order.stateId = 1;
    order.stateName = @"已付款";
    [self.tableView reloadData];
    currentIndex = 0;
}

- (void)doClose:(UIButton *)sender
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        int row = sender.tag;
        MyOrder *order = [orders objectAtIndex:sender.tag];
        //关闭交易
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:order.orderId forKey:@"orderId"];
        NSString *updateOrderCloseUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, updateOrderClose] params:param];
        [[AFOSCClient sharedClient]getPath:updateOrderCloseUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           
                                           NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                           if ([state isEqualToString:@"0000"] == NO) {
                                               UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                                                            message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"确定"
                                                                                  otherButtonTitles:nil];
                                               [av show];
                                               return;
                                           }
                                           else
                                           {
                                               [orders removeObjectAtIndex:row];
                                               [self.tableView reloadData];
                                               [Tool showCustomHUD:@"交易取消" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

@end
