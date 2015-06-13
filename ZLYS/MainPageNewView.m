//
//  MainPageNewView.m
//  LinJu
//
//  Created by Seven on 15/6/6.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "MainPageNewView.h"
#import "NoticeTableView.h"
#import "Notice.h"
#import "CallServiceView.h"
#import "GoodBorrowView.h"
#import "ExpressView.h"
#import "AddRepairView.h"
#import "ADInfo.h"
#import "AddSuitWorkView.h"
#import "CommDetailView.h"
#import "PushGatePassView.h"
#import "PaymentListView.h"
#import "TradeFrameView.h"
#import "SignInView.h"
#import "FeeTableView.h"
#import "ShopTypeView.h"
#import "ActivityCollectionView.h"
#import "CommodityClassView.h"

@interface MainPageNewView ()
{
    UIWebView *phoneWebView;
    UserInfo *userInfo;
}

@end

@implementation MainPageNewView

#define KSCROLLVIEW_WIDTH [UIScreen mainScreen].applicationFrame.size.width

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"左邻优社";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(telAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"head_tel"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    [self getADVData];
    
    self.scrollView.contentSize=CGSizeMake(KSCROLLVIEW_WIDTH*2, 92);
    self.scrollView.delegate=self;
}

- (void)getADVData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1141788149430600" forKey:@"typeId"];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:@"1" forKey:@"timeCon"];
        NSString *getADDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAdInfoList] params:param];
        
        [[AFOSCClient sharedClient]getPath:getADDataUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           advDatas = [Tool readJsonStrToAdinfoArray:operation.responseString];
                                           int length = [advDatas count];
                                           
                                           NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
                                           if (length > 1)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:length-1];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:length-1];
                                               [itemArray addObject:item];
                                           }
                                           for (int i = 0; i < length; i++)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:i];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:i];
                                               [itemArray addObject:item];
                                               
                                           }
                                           //添加第一张图 用于循环
                                           if (length >1)
                                           {
                                               ADInfo *adv = [advDatas objectAtIndex:0];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:adv.adName image:adv.imgUrlFull tag:0];
                                               [itemArray addObject:item];
                                           }
                                           bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, 320, 155) delegate:self imageItems:itemArray isAuto:YES];
                                           [bannerView scrollToIndex:0];
                                           [self.advIv addSubview:bannerView];
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
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
    }
}

//顶部图片滑动点击委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    ADInfo *adv = (ADInfo *)[advDatas objectAtIndex:advIndex];
    if (adv)
    {
        NSString *adDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_adDetail ,adv.adId];
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = @"详情";
        detailView.urlStr = adDetailHtm;
        detailView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
    advIndex = index;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    bannerView.delegate = self;
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
    if ([[[UserModel Instance] getUserInfo].defaultUserHouse.userTypeId intValue] == 0) {
        self.gatePassBtn.hidden = NO;
        self.gatePassLb.hidden = NO;
    }
    else
    {
        self.gatePassBtn.hidden = YES;
        self.gatePassLb.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    bannerView.delegate = nil;
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

- (IBAction)telAction:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", userInfo.defaultUserHouse.phone]];
    if (!phoneWebView) {
        phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

//物业通知
- (IBAction)noticesAction:(id)sender {
    NoticeTableView *noticeView = [[NoticeTableView alloc] init];
    noticeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:noticeView animated:YES];
}

//物业呼叫
- (IBAction)callServiceAction:(id)sender {
    CallServiceView *callServiceView = [[CallServiceView alloc] init];
    callServiceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:callServiceView animated:YES];
}

//物品借用
- (IBAction)goodBorrowAction:(id)sender {
    GoodBorrowView *borrowView = [[GoodBorrowView alloc] init];
    borrowView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:borrowView animated:YES];
}

//快递收发
- (IBAction)expressAction:(id)sender {
    ExpressView *expressView = [[ExpressView alloc] init];
    expressView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:expressView animated:YES];
}

//物业报修
- (IBAction)addRepairAction:(id)sender {
    AddRepairView *addRepairView = [[AddRepairView alloc] init];
    addRepairView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addRepairView animated:YES];
}

//投诉建议
- (IBAction)addSuitWorkAction:(id)sender {
    AddSuitWorkView *addSuitView = [[AddSuitWorkView alloc] init];
    addSuitView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addSuitView animated:YES];
}

//访客通行证
- (IBAction)pushGatePassAction:(id)sender {
    PushGatePassView *gatePassView = [[PushGatePassView alloc] init];
    gatePassView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gatePassView animated:YES];
}

//账单推送
- (IBAction)pushPaymentListView:(id)sender {
    //    PaymentListView *paymentListView = [[PaymentListView alloc] init];
    //    paymentListView.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:paymentListView animated:YES];
    FeeTableView *feeTableView = [[FeeTableView alloc] init];
    feeTableView.titleStr = @"物业费账单";
    feeTableView.typeId = @"0";
    feeTableView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feeTableView animated:YES];
}

//交易买卖
- (IBAction)pushTradeViewAction:(id)sender {
    TradeFrameView *tradeView = [[TradeFrameView alloc] init];
    tradeView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:tradeView animated:YES];
}

//积分兑奖
- (IBAction)signInAction:(id *)sender
{
    SignInView *signInView = [[SignInView alloc] init];
    signInView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:signInView animated:YES];
}

//周边商家
- (IBAction)ShopTypeAction:(id)sender {
    //    ShopTypeView *shopTypeView = [[ShopTypeView alloc] init];
    //    shopTypeView.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:shopTypeView animated:YES];
    CommodityClassView *commodityView = [[CommodityClassView alloc] init];
    commodityView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commodityView animated:YES];
}

//社区活动
- (IBAction)activityViewAction:(id)sender {
    ActivityCollectionView *activityView = [[ActivityCollectionView alloc] init];
    activityView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityView animated:YES];
}

@end
