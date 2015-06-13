//
//  PayFeeView.m
//  WHDLife
//
//  Created by Seven on 15-1-21.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "PayFeeView.h"
#import "FeeTableView.h"
#import "CommDetailView.h"
//#import "MyPayBillView.h"
//#import "ErrorView.h"

@interface PayFeeView ()

@end

@implementation PayFeeView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"生活缴费";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 19)];
    [rBtn addTarget:self action:@selector(myPayAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"header_my"] forState:UIControlStateNormal];
    UIBarButtonItem *btnMy = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnMy;
}

- (void)myPayAction:(id)sender
{
//    MyPayBillView *payBillView = [[MyPayBillView alloc] init];
//    payBillView.frameView = self.view;
//    [self.navigationController pushViewController:payBillView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTintColor:[Tool getColorForMain]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)parkFeeAction:(id)sender {
    
//    FeeTableView *feeTableView = [[FeeTableView alloc] init];
//    feeTableView.titleStr = @"停车费账单";
//    feeTableView.typeId = @"1";
//    [self.navigationController pushViewController:feeTableView animated:YES];
    //封板保留
//    ErrorView *errorView = [[ErrorView alloc] init];
//    errorView.titleStr = @"停车费账单";
//    [self.navigationController pushViewController:errorView animated:YES];
}

- (IBAction)wuyeFeeAction:(id)sender {
    FeeTableView *feeTableView = [[FeeTableView alloc] init];
    feeTableView.titleStr = @"物业费账单";
    feeTableView.typeId = @"0";
    [self.navigationController pushViewController:feeTableView animated:YES];
}

- (IBAction)ranqiFeeAction:(id)sender {
//    FeeTableView *feeTableView = [[FeeTableView alloc] init];
//    feeTableView.titleStr = @"燃气费账单";
//    feeTableView.typeId = @"2";
//    [self.navigationController pushViewController:feeTableView animated:YES];
    //封板保留
//    ErrorView *errorView = [[ErrorView alloc] init];
//    errorView.titleStr = @"燃气费账单";
//    [self.navigationController pushViewController:errorView animated:YES];
}

- (IBAction)ydFeeAction:(id)sender {
    NSString *detailHtm = @"http://wap.10086.cn/czjf/czjf.jsp";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"移动缴费";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)ltFeeAction:(id)sender {
    NSString *detailHtm = @"http://wap.10010.com/t/home.htm";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"联通缴费";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)dxFeeAction:(id)sender {
    NSString *detailHtm = @"http://wapzt.189.cn";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"电信缴费";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)szdsFeeAction:(id)sender {
    NSString *detailHtm = @"https://jiaofei.alipay.com/jiaofei.htm";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"数字电视";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)ycsfFeeAction:(id)sender {
    NSString *detailHtm = @"https://jiaofei.alipay.com/jiaofei.htm";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"预存水费";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)ycwfFeeAction:(id)sender {
    NSString *detailHtm = @"https://jiaofei.alipay.com/jiaofei.htm";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"预存网费";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (IBAction)ycdfFeeAction:(id)sender {
    NSString *detailHtm = @"https://jiaofei.alipay.com/jiaofei.htm";
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"预存电费";
    detailView.urlStr = detailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}
@end
