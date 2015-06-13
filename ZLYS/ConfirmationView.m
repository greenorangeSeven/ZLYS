//
//  ConfirmationView.m
//  WHDLife
//
//  Created by Seven on 15-1-20.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "ConfirmationView.h"
#import "ConfirmationCell.h"
#import "ShopCarItem.h"
#import "OderSubmitVO.h"
#import "OrderShopVO.h"
#import "OrderCommodityVO.h"
#import "NSString+STRegex.h"
#import "MyOrderView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "UIImageView+WebCache.h"

@interface ConfirmationView ()
{
    UserInfo *userInfo;
    int count;
    double total;
}

@end

@implementation ConfirmationView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"订单确认";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    userInfo = [[UserModel Instance] getUserInfo];
    self.recipientsTf.text = userInfo.regUserName;
    self.telphoneTf.text = userInfo.mobileNo;
    self.addressTv.text = [NSString stringWithFormat:@"%@%@%@%@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.unitName,userInfo.defaultUserHouse.numberName];
    [self refreshTotal];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)refreshTotal
{
    count = 0;
    total = 0.00;
    for (ShopCarItem *item in self.commodityItems) {
        count += item.number;
        total += item.number * item.price;
    }
    self.totalLb.text = [NSString stringWithFormat:@"共 %d 件商品    合计:￥%0.2f", count, total];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commodityItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfirmationCell *cell = [tableView dequeueReusableCellWithIdentifier:ConfirmationCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ConfirmationCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ConfirmationCell class]]) {
                cell = (ConfirmationCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    ShopCarItem *item = [self.commodityItems objectAtIndex:row];
    cell.priceLb.text = [NSString stringWithFormat:@"￥%0.2f", item.price];
    cell.nameLb.text = item.name;
    cell.properyLb.text = item.properyStr;
    cell.numberTf.text = [NSString stringWithFormat:@"%d", item.number];
    NSString *imageUrl = [NSString stringWithFormat:@"%@_200",item.imagefull];
    [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
    
    if (item.number <= 1) {
        cell.minBtn.enabled = NO;
    }
    else
    {
        cell.minBtn.enabled = YES;
    }
    [cell.minBtn addTarget:self action:@selector(minusAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.minBtn.tag = row;
    
    [cell.addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.addBtn.tag = row;
    
    return cell;
}

- (IBAction)minusAction:(id)sender {
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        ShopCarItem *item = [self.commodityItems objectAtIndex:tap.tag];
        item.number -= 1;
        [self.tableView reloadData];
        [self refreshTotal];
    }
}

- (IBAction)addAction:(id)sender {
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        ShopCarItem *item = [self.commodityItems objectAtIndex:tap.tag];
        item.number += 1;
        [self.tableView reloadData];
        [self refreshTotal];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)doOrder:(id)sender
{
    NSString *nameStr = self.recipientsTf.text;
    NSString *telStr = self.telphoneTf.text;
    NSString *addressStr = self.addressTv.text;
    NSString *ramarkStr = self.remarkTv.text;
    
    if(nameStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入收件人姓名" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:1.2f];
        return;
    }
    if(![telStr isValidPhoneNum])
    {
        [Tool showCustomHUD:@"请检查手机号码" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:1.2f];
        return;
    }
    if(addressStr.length == 0)
    {
        [Tool showCustomHUD:@"请输入收件地址" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:1.2f];
        return;
    }
    
    OderSubmitVO *submitVO = [[OderSubmitVO alloc] init];
    submitVO.regUserId = userInfo.regUserId;
    if(ramarkStr.length > 0)
       submitVO.remark = ramarkStr;
    submitVO.receivingUserName = nameStr;
    submitVO.receivingAddress = addressStr;
    submitVO.phone = telStr;
    
    submitVO.shopList = [[NSMutableArray alloc] initWithCapacity:self.commodityItems.count];
    NSMutableDictionary *shopDic = [[NSMutableDictionary alloc] init];
    for(ShopCarItem *item in self.commodityItems)
    {
        OrderShopVO *shop = nil;
        shop = [shopDic objectForKey:item.shopId];
        if(!shop)
        {
            shop = [[OrderShopVO alloc] init];
            shop.shopId = item.shopId;
            shop.commodityList = [[NSMutableArray alloc] initWithCapacity:10];
            [shopDic setValue:shop forKey:item.shopId];
        }
        
        OrderCommodityVO *commodity = [[OrderCommodityVO alloc] init];
        commodity.commodityId = item.commodityid;
        commodity.num = item.number;
        commodity.skuName = item.properyStr;
        [shop.commodityList addObject:commodity];
        
        if(![submitVO.shopList containsObject:shop])
        {
            [submitVO.shopList addObject:shop];
        }
    }
    
    NSString *json = [Tool readOderSubmitVOToJson:submitVO];
    [self orderAction:json];
}

- (void)orderAction:(NSString *)orderStr
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:orderStr forKey:@"orderJson"];
    NSString *createOrderSign = [Tool serializeSign:[NSString stringWithFormat:@"%@%@", api_base_url, api_orderSubmit] params:param];
    
    //生成创建帖子URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_orderSubmit];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    
    [request setPostValue:Appkey forKey:@"accessId"];
    [request setPostValue:createOrderSign forKey:@"sign"];
    [request setPostValue:orderStr forKey:@"orderJson"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在下单..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
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
        //删除购入车已选商品
        FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
        if (![database open]) {
            NSLog(@"Open database failed");
            return;
        }
        if (![database tableExists:@"shoppingcar"]) {
            [database executeUpdate:createshoppingcar];
        }
        BOOL detele = [database executeUpdate:@"delete from shoppingcar where ischeck = '1'"];
        [database close];
        [Tool showCustomHUD:@"下单成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
//        [self.navigationController popViewControllerAnimated:YES];
//        if (self.fromShopCar) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_ShopCarGotoOrder object:nil];
//        }
//        else
//        {
//            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_CommodityDetailGotoOrder object:nil];
//        }
        MyOrderView *myOrder = [[MyOrderView alloc] init];
        myOrder.fromBuy = YES;
        [self.navigationController pushViewController:myOrder animated:YES];
    }
}

@end
