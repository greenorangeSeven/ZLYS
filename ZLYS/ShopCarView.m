//
//  ShopCarView.m
//  WHDLife
//
//  Created by Seven on 15-1-18.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "ShopCarView.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "ShopCar.h"
#import "ShopCarItem.h"
#import "ShopCarCell.h"
#import "SSCheckBoxView.h"
#import "ConfirmationView.h"
#import "MyOrderView.h"

@interface ShopCarView ()
{
    UserInfo *userInfo;
    SSCheckBoxView *checkAllCb;
}

//@property (copy, nonatomic) SSCheckBoxView *checkAllCb;

@end

@implementation ShopCarView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"购物车";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    shopData = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    checkAllCb = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(0, 0, 100, 20) style:kSSCheckBoxViewStyleGlossy checked:NO];
    [checkAllCb setText:@"全选"];
    [checkAllCb setStateChangedBlock:^(SSCheckBoxView *cbv) {
        if (cbv.checked) {
            FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
            if (![database open]) {
                NSLog(@"Open database failed");
                return;
            }
            if (![database tableExists:@"shoppingcar"]) {
                [database executeUpdate:createshoppingcar];
            }
            for (ShopCar *shopcar in shopData) {
                for(ShopCarItem *item in shopcar.commodityList)
                {
                    [database executeUpdate:@"update shoppingcar set ischeck = '1' where id= ?", [NSNumber numberWithInt:item.dbid]];
                    item.ischeck = @"1";
                }
                shopcar.shopIsCheck = YES;
            }
            [database close];
            [self.tableView reloadData];
        }
        else
        {
            FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
            if (![database open]) {
                NSLog(@"Open database failed");
                return;
            }
            if (![database tableExists:@"shoppingcar"]) {
                [database executeUpdate:createshoppingcar];
            }
            for (ShopCar *shopcar in shopData) {
                for(ShopCarItem *item in shopcar.commodityList)
                {
                    [database executeUpdate:@"update shoppingcar set ischeck = '0' where id= ?", [NSNumber numberWithInt:item.dbid]];
                    item.ischeck = @"0";
                }
                shopcar.shopIsCheck = NO;
            }
            [database close];
            [self.tableView reloadData];
        }
        [self totalCarMoney];
    }];
    [self.checkAllView addSubview:checkAllCb];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_RefreshShopCarTable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoOrder) name:Notification_ShopCarGotoOrder object:nil];
}

- (void)gotoOrder
{
    MyOrderView *myOrder = [[MyOrderView alloc] init];
    [self.navigationController pushViewController:myOrder animated:YES];
}

- (void)refreshed:(NSNotification *)notification
{
    if(notification.object)
    {
        int row = [(NSString *)notification.object intValue];
        if ([shopData count]>row) {
            [shopData removeObjectAtIndex:row];
        }
    }
    //没有商品则不能结算
    if([shopData count] == 0)
    {
        self.balanceBtn.enabled = NO;
    }
    [self.tableView reloadData];
    [self totalCarMoney];
}

//取数方法
- (void)reloadData
{
    //    self.totalLb.text = @"0.00";
    [shopData removeAllObjects];
    total = 0.00;
    FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
    if (![database open]) {
        NSLog(@"Open database failed");
        return;
    }
    if (![database tableExists:@"shoppingcar"]) {
        [database executeUpdate:createshoppingcar];
    }
    FMResultSet* resultSet=[database executeQuery:@"select shopname, shopid, sum(number) commodityCount  from shoppingcar where user_id = ? group by shopid order by shopid", userInfo.regUserId];
    while ([resultSet next]) {
        ShopCar *shopCar = [[ShopCar alloc] init];
        shopCar.shopName = [resultSet stringForColumn:@"shopname"];
        shopCar.shopId = [resultSet stringForColumn:@"shopid"];
        shopCar.commodityCount = [resultSet intForColumn:@"commodityCount"];
        shopCar.commodityList = [[NSMutableArray alloc] init];
        shopCar.total = 0.00;
        shopCar.shopIsCheck = NO;
        FMResultSet* resultItemSet = [database executeQuery:@"select id, commodityid, name, properyStr, imagefull, price, number, ischeck, price*number subtotal, shopid, shopname from shoppingcar where user_id = ? and shopid = ? order by commodityid", userInfo.regUserId, shopCar.shopId];
        while ([resultItemSet next]) {
            ShopCarItem *item = [[ShopCarItem alloc] init];
            item.dbid = [resultItemSet intForColumn:@"id"];
            item.commodityid = [resultItemSet stringForColumn:@"commodityid"];
            item.name = [resultItemSet stringForColumn:@"name"];
            item.properyStr = [resultItemSet stringForColumn:@"properyStr"];
            item.imagefull = [resultItemSet stringForColumn:@"imagefull"];
            item.price = [resultItemSet doubleForColumn:@"price"];
            item.number = [resultItemSet intForColumn:@"number"];
            item.ischeck = [resultItemSet stringForColumn:@"ischeck"];
            item.subtotal = [resultItemSet doubleForColumn:@"subtotal"];
            item.shopId = [resultItemSet stringForColumn:@"shopid"];
            item.shopName = [resultItemSet stringForColumn:@"shopname"];
            [shopCar.commodityList addObject:item];
            shopCar.total += item.subtotal;
        }
        [shopData addObject:shopCar];
    }
    [database close];
    //没有商品则不能结算
    if([shopData count] == 0)
    {
        self.balanceBtn.enabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void)totalCarMoney
{
    FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
    if (![database open]) {
        NSLog(@"Open database failed");
        return;
    }
    if (![database tableExists:@"shoppingcar"]) {
        [database executeUpdate:createshoppingcar];
    }
    FMResultSet* amountSet=[database executeQuery:@"select sum(price * number) amount from shoppingcar where user_id = ? and ischeck = '1'", userInfo.regUserId];
    if ([amountSet next]) {
        self.totalLb.text = [NSString stringWithFormat:@"合计:%0.2f", [amountSet doubleForColumn:@"amount"]];
    }
    else
    {
        self.totalLb.text = @"合计:0.00";
    }
    [database close];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([shopData count] == 0)
    {
        return 1;
    }
    else
    {
        return [shopData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([shopData count] > 0) {
        ShopCarCell *cell = [tableView dequeueReusableCellWithIdentifier:ShopCarCellIdentifier];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ShopCarCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[ShopCarCell class]]) {
                    cell = (ShopCarCell *)o;
                    break;
                }
            }
        }
        int indexRow = [indexPath row];
        
        ShopCar *shopcar = [shopData objectAtIndex:indexRow];
        cell.shopName.text = shopcar.shopName;
        cell.subTotalLb.text = [NSString stringWithFormat:@"共 %d 件商品    合计:￥%0.2f", shopcar.commodityCount, shopcar.total];
        
        cell.subTotalView.frame = CGRectMake(cell.subTotalView.frame.origin.x, cell.subTotalView.frame.origin.y + ([shopcar.commodityList count] - 1) * 85, cell.subTotalView.frame.size.width, cell.subTotalView.frame.size.height);
        
        //初始化商品
        [cell loadShopCommoditys:shopcar andRow:indexRow];
        cell.commodityTable.frame = CGRectMake(cell.commodityTable.frame.origin.x, cell.commodityTable.frame.origin.y, cell.commodityTable.frame.size.width, [shopcar.commodityList count] * 85);
        
        SSCheckBoxView *cb = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(2, 0, 30, 30) style:kSSCheckBoxViewStyleGlossy checked:shopcar.shopIsCheck];
        [cb setStateChangedBlock:^(SSCheckBoxView *cbv) {
            if (cbv.checked) {
                FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
                if (![database open]) {
                    NSLog(@"Open database failed");
                    return;
                }
                if (![database tableExists:@"shoppingcar"]) {
                    [database executeUpdate:createshoppingcar];
                }
                for(ShopCarItem *item in shopcar.commodityList)
                {
                    [database executeUpdate:@"update shoppingcar set ischeck = '1' where id= ?", [NSNumber numberWithInt:item.dbid]];
                    item.ischeck = @"1";
                }
                shopcar.shopIsCheck = YES;
                [database close];
                [self.tableView reloadData];
            }
            else
            {
                FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
                if (![database open]) {
                    NSLog(@"Open database failed");
                    return;
                }
                if (![database tableExists:@"shoppingcar"]) {
                    [database executeUpdate:createshoppingcar];
                }
                for(ShopCarItem *item in shopcar.commodityList)
                {
                    [database executeUpdate:@"update shoppingcar set ischeck = '0' where id= ?", [NSNumber numberWithInt:item.dbid]];
                    item.ischeck = @"0";
                }
                shopcar.shopIsCheck = NO;
                [database close];
                [self.tableView reloadData];
            }
            [self totalCarMoney];
        }];
        
        [cell addSubview:cb];
        
        return cell;
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:NO andLoadOverString:@"暂无商品" andLoadingString:@"暂无商品" andIsLoading:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([shopData count] == 0)
    {
        return 40;
    }
    else
    {
        int indexRow = [indexPath row];
        ShopCar *shopcar = [shopData objectAtIndex:indexRow];
        return 152 + (([shopcar.commodityList count] -1) * 85);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning {
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
    
    FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
    if (![database open]) {
        NSLog(@"Open database failed");
        return;
    }
    if (![database tableExists:@"shoppingcar"]) {
        [database executeUpdate:createshoppingcar];
    }
    [database executeUpdate:@"update shoppingcar set ischeck = '0'"];
    [database close];
    
    [self reloadData];
    if (checkAllCb) {
        checkAllCb.checked = NO;
    }
    
    self.totalLb.text = @"合计:0.00";
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)balanceAction:(id)sender {
    NSMutableArray *commodityArray = [[NSMutableArray alloc] init];
    for (ShopCar *shop in shopData) {
        for (ShopCarItem *item in shop.commodityList) {
            if ([item.ischeck isEqualToString:@"1"] == YES) {
                [commodityArray addObject:item];
            }
        }
    }
    if ([commodityArray count] == 0) {
        [Tool showCustomHUD:@"请选择商品结算" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
        return;
    }
    
    ConfirmationView *confirmationView = [[ConfirmationView alloc] init];
    confirmationView.commodityItems = commodityArray;
    confirmationView.fromShopCar = YES;
    [self.navigationController pushViewController:confirmationView animated:YES];
}
@end
