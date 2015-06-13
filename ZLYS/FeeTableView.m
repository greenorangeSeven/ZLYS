//
//  FeeTableView.m
//  WHDLife
//
//  Created by Seven on 15-1-21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "FeeTableView.h"
#import "BillCell.h"
#import "Bill.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UIImageView+WebCache.h"

@interface FeeTableView ()<UIAlertViewDelegate>
{
    UserInfo *userInfo;
    NSString *stateIdStr;
    int currentIndex;
}

@end

@implementation FeeTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = self.titleStr;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    self.addressLb.text = [NSString stringWithFormat:@"%@%@%@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName];
    
    //图片圆形处理
    self.faceIv.layer.masksToBounds=YES;
    self.faceIv.layer.cornerRadius=self.faceIv.frame.size.width/2;    //最重要的是这个地方要设成imgview高的一半
    self.faceIv.backgroundColor = [UIColor whiteColor];
    
    self.facebgLb.layer.masksToBounds=YES;
    self.facebgLb.layer.cornerRadius=self.facebgLb.frame.size.width/2;    //最重要的是这个地方要设成view高的一半
    [self.faceIv sd_setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
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
    bills = [[NSMutableArray alloc] initWithCapacity:20];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePayedTable) name:ORDER_PAY_NOTIC object:nil];
    [self reload:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    _refreshHeaderView = nil;
    [bills removeAllObjects];
    bills = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [bills removeAllObjects];
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
        
        //生成获取账单列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.defaultUserHouse.numberId forKey:@"numberId"];
        [param setValue:[NSString stringWithFormat:@"%d", pageIndex] forKey:@"pageNumbers"];
        [param setValue:@"20" forKey:@"countPerPages"];
        if (stateIdStr != nil && [stateIdStr length] > 0) {
            [param setValue:@"0" forKey:@"stateId"];
        }
        [param setValue:self.typeId forKey:@"typeId"];
        NSString *findBillUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findBillDetailsByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:findBillUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       
                                       NSMutableArray *billNews = [Tool readJsonStrToBillArray:operation.responseString];
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *billJsonDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           NSDictionary *totalMap = [[billJsonDic objectForKey:@"data"] objectForKey:@"totalMap"];
                                           int nopaycount = [[totalMap objectForKey:@"nopaycount"] intValue];
                                           double totalnopay = 0.00;
                                           if (nopaycount > 0) {
                                               totalnopay = [[totalMap objectForKey:@"totalnopay"] doubleValue];
                                           }
                                           self.noPayTotalLb.text = [NSString stringWithFormat:@"%d", nopaycount];
                                           self.nopayMoneyLb.text = [NSString stringWithFormat:@"￥%0.2f", totalnopay];
                                           
                                           int count = [billNews count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [bills addObjectsFromArray:billNews];
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

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return bills.count == 0 ? 1 : bills.count;
        }
        else
            return bills.count + 1;
    }
    else
        return bills.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    if (row < bills.count)
    {
        return 77.0;
    }
    else
    {
        return 47.0;
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
    if ([bills count] > 0) {
        if (row < [bills count])
        {
            BillCell *cell = [tableView dequeueReusableCellWithIdentifier:BillCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BillCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[BillCell class]]) {
                        cell = (BillCell *)o;
                        break;
                    }
                }
            }
            Bill *bill = [bills objectAtIndex:row];
            cell.billNameLb.text = bill.billName;
            cell.totalMoneyLb.text = [NSString stringWithFormat:@"￥%0.2f", bill.totalMoney];
            cell.totalFeeLb.text = [NSString stringWithFormat:@"￥%0.2f", bill.totalFee];
            if (bill.stateId == 0) {
                cell.totalFeeLb.textColor = [Tool getColorForMain];
                cell.nofeeIv.hidden = NO;
            }
            else if(bill.stateId == 1)
            {
                cell.totalFeeLb.textColor = [UIColor blackColor];
                cell.nofeeIv.hidden = YES;
            }
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
    if (row >= [bills count]) {
        //启动刷新
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else
    {
        Bill *bill = [bills objectAtIndex:currentIndex];
        if(bill.stateId == 0)
        {
            currentIndex = row;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示:" message:@"是否缴费" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去缴费", nil];
            [alertView show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1)
    {
        Bill *bill = [bills objectAtIndex:currentIndex];
        [self doPay:bill];
    }
    else
    {
        currentIndex = 0;
    }
}

- (void)doPay:(Bill *)bill
{
    
    //生成支付宝订单URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createAlipayParams];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:bill.detailsId forKey:@"billDetailsId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
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
    currentIndex = 0;
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
    Bill *bill = [bills objectAtIndex:currentIndex];
    bill.stateId = 1;
    [self.tableView reloadData];
    currentIndex = 0;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stateChangedAction:(id)sender {
    switch (self.stateSegmented.selectedSegmentIndex) {
        case 0:
            stateIdStr = @"";
            break;
        case 1:
            stateIdStr = @"0";
            break;
    }
    isLoadOver = NO;
    [self reload:NO];
}
@end
