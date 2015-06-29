//
//  CommodityDetailView.m
//  WHDLife
//
//  Created by Seven on 15-1-16.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "CommodityDetailView.h"
#import "Community.h"
#import "CommodityPropery.h"
#import "StrikeThroughLabel.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabaseQueue.h"
#import "ShopCarView.h"
#import "ConfirmationView.h"
#import "ShopCarItem.h"
#import "MWPhotoBrowser.h"
#import "MyOrderView.h"

@interface CommodityDetailView ()<UIWebViewDelegate, SGFocusImageFrameDelegate, MWPhotoBrowserDelegate>
{
    UserInfo *userInfo;
    Commodity *commodityDetail;
    SGFocusImageFrame *bannerView;
    NSMutableArray *imageDatas;
    
    NSMutableArray *properyKeyArray;
    NSMutableArray *properyValArray;
    float webViewY;
    
    int advIndex;
    NSMutableArray *_photos;
}

@property (nonatomic, retain) NSMutableArray *photos;

@end

@implementation CommodityDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = @"商品详情";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rBtn addTarget:self action:@selector(addShopCarAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"shopcar2"] forState:UIControlStateNormal];
    UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = btnTel;
    
    //button长按事件
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shopCarLong:)];
//    longPress.minimumPressDuration = 0.8; //定义按的时间
//    [rBtn addGestureRecognizer:longPress];
    
    userInfo = [[UserModel Instance] getUserInfo];
    [self getDetailData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoOrder) name:Notification_CommodityDetailGotoOrder object:nil];
}

- (void)gotoOrder
{
    MyOrderView *myOrder = [[MyOrderView alloc] init];
    [self.navigationController pushViewController:myOrder animated:YES];
}

-(void)addShopCarAction:(id)sender{
    ShopCarView *carView = [[ShopCarView alloc] init];
    [self.navigationController pushViewController:carView animated:YES];
}

//-(void)shopCarLong:(UILongPressGestureRecognizer *)gestureRecognizer{
//    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
//        ShopCarView *carView = [[ShopCarView alloc] init];
//        [self.navigationController pushViewController:carView animated:YES];
//    }
//}

- (void)getDetailData
{
    //生成获取商品信息URL
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.commodityId forKey:@"commodityId"];
//    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    
    NSString *findCommodityInfoByIdUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findCommodityInfoById] params:param];
    [[AFOSCClient sharedClient]getPath:findCommodityInfoByIdUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   
                                   @try {
                                       commodityDetail = [Tool readJsonStrToCommodityDetail:operation.responseString];
                                       if (commodityDetail) {
                                           [self initDetailView];
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
                                       [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                   }
                               }];
}

- (void)initDetailView
{
    [self initShopImage];
    [self initCommodityPropery];
    self.nameLb.text = commodityDetail.commodityName;
    self.shopNameLb.text = commodityDetail.shopName;
    self.priceLb.text = [NSString stringWithFormat:@"￥%0.2f", commodityDetail.price];
    StrikeThroughLabel *slabel = [[StrikeThroughLabel alloc] initWithFrame:CGRectMake(0, 0, 59, 21)];
    slabel.text = [NSString stringWithFormat:@"￥%0.2f", commodityDetail.marketPrice];
    slabel.font = [UIFont italicSystemFontOfSize:12.0f];
    slabel.strikeThroughEnabled = YES;
    [self.marketPriceLb addSubview:slabel];
    
    if (commodityDetail.isCollection == 0) {
        [self.collectionBtn setImage:[UIImage imageNamed:@"star_nor"] forState:UIControlStateNormal];
        self.collectionLb.text = @"收藏";
        self.collectionLb.textColor = [UIColor blackColor];
    }
    else
    {
        [self.collectionBtn setImage:[UIImage imageNamed:@"star_pro"] forState:UIControlStateNormal];
        self.collectionLb.text = @"已收藏";
        self.collectionLb.textColor = [Tool getColorForMain];
    }
}

- (void)initShopImage
{
    imageDatas = commodityDetail.imgStrList;
    int length = [imageDatas count];
    
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
    if (length > 1)
    {
        NSString *imageStr = [imageDatas objectAtIndex:length-1];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:nil image:imageStr tag:length-1];
        [itemArray addObject:item];
    }
    for (int i = 0; i < length; i++)
    {
        NSString *imageStr = [imageDatas objectAtIndex:i];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:nil image:imageStr tag:i];
        [itemArray addObject:item];
        
    }
    //添加第一张图 用于循环
    if (length >1)
    {
        NSString *imageStr = [imageDatas objectAtIndex:0];
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:nil image:imageStr tag:0];
        [itemArray addObject:item];
    }
    bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, 320, 150) delegate:self imageItems:itemArray isAuto:YES];
    [bannerView scrollToIndex:0];
    [self.shopImageIv addSubview:bannerView];
}

//顶部图片滑动点击委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    if ([self.photos count] == 0) {
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (NSString *d in imageDatas) {
            MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:d]];
            [photos addObject:photo];
        }
        self.photos = photos;
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;//左右分页切换,默认否
    browser.displaySelectionButtons = NO;//是否显示选择按钮在图片上,默认否
    browser.alwaysShowControls = YES;//控制条件控件 是否显示,默认否
    browser.zoomPhotosToFill = NO;//是否全屏,默认是
    //    browser.wantsFullScreenLayout = YES;//是否全屏
    [browser setCurrentPhotoIndex:advIndex];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:browser animated:YES];
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
    advIndex = index;
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)initCommodityPropery
{
    properyKeyArray = [[NSMutableArray alloc] init];
    properyValArray = [[NSMutableArray alloc] init];
    int currentY = 5;
    if (commodityDetail.properyStrList != nil && [commodityDetail.properyStrList count] > 0) {
        UILabel *linkTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1.0)];
        linkTop.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
        [self.properyView addSubview:linkTop];
        
        for (int i = 0; i < [commodityDetail.properyStrList count]; i++) {
            self.properyView.hidden = NO;
            CommodityPropery *propery = [commodityDetail.properyStrList objectAtIndex:i];
            
            //属性标题
            UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, currentY, 180, 20)];
            keyLabel.backgroundColor = [UIColor clearColor];
            keyLabel.font = [UIFont boldSystemFontOfSize:14.0];
            keyLabel.textColor = [UIColor blackColor];
            keyLabel.text = propery.properyName;
            [self.properyView addSubview:keyLabel];
            [properyKeyArray addObject:propery.properyName];
            
            currentY = currentY + 15;
            
            UIView *properyValView = [[UIView alloc] initWithFrame:CGRectMake(5, currentY, 310, 20)];
            properyValView.tag = i;
            [self.properyView addSubview:properyValView];
            
            int attrValViewY = 0;
            for (int l = 0; l < [propery.valueNameList count]; l++) {
                NSString *properyVal = (NSString *)[propery.valueNameList objectAtIndex:l];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(10 + l % 3 * 100 , 10 + l / 3 * 32, 90, 22);
                button.titleLabel.font = [UIFont systemFontOfSize:14];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [button setTitle:properyVal forState:UIControlStateNormal];
                if (l == 0) {
                    [button setBackgroundImage:[UIImage imageNamed:@"propery_r"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [properyValArray addObject:properyVal];
                }
                else
                {
                    [button setBackgroundImage:[UIImage imageNamed:@"propery_w"] forState:UIControlStateNormal];
                    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
                button.tag = l;
                [button addTarget:self action:@selector(properySelectAction:) forControlEvents:UIControlEventTouchUpInside];
                [properyValView addSubview:button];
                attrValViewY = button.frame.origin.y;
            }
            properyValView.frame = CGRectMake(properyValView.frame.origin.x, properyValView.frame.origin.y, properyValView.frame.size.width, attrValViewY + 22 + 5);
            currentY = currentY + attrValViewY + 22 + 5;
        }
        
        UILabel *linkbottom = [[UILabel alloc] initWithFrame:CGRectMake(0, currentY + 9, self.view.frame.size.width, 1.0)];
        linkbottom.backgroundColor = [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0];
        [self.properyView addSubview:linkbottom];
        
        self.properyView.frame = CGRectMake(self.properyView.frame.origin.x, self.properyView.frame.origin.y, self.properyView.frame.size.width, currentY + 10);
    }
    //初始化属性后再加载详情
    [self initCommodityDetail];
}

- (void)properySelectAction:(id)sender
{
    UIButton *selectBtn = (UIButton *)sender;
    
    UIView *parentView = [selectBtn superview];
    int viewIndex = parentView.tag;
    
    NSArray * btnArray = [parentView subviews];
    for (int i = 0; i < [btnArray count]; i++) {
        
        UIButton *btn = (UIButton *)[btnArray objectAtIndex:i];
        if (selectBtn.tag == i) {
            [btn setBackgroundImage:[UIImage imageNamed:@"propery_r"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [properyValArray replaceObjectAtIndex:viewIndex withObject:btn.titleLabel.text];
        }
        else
        {
            [btn setBackgroundImage:[UIImage imageNamed:@"propery_w"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void)initCommodityDetail
{
    webViewY = self.properyView.frame.origin.y+ self.properyView.frame.size.height;
    self.detailWebView.frame = CGRectMake(self.detailWebView.frame.origin.x, webViewY, self.detailWebView.frame.size.width, 0);
    
    if(commodityDetail.details == nil )
    {
        commodityDetail.details = @"暂无详情";
    }
    
    NSString *html = [NSString stringWithFormat:@"<body>%@<div id='web_body'>%@</div></body>", HTML_Style, commodityDetail.details];
    NSString *result = [Tool getHTMLString:html];
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.detailWebView];
    [self.detailWebView sizeToFit];
    [self.detailWebView loadHTMLString:result baseURL:nil];
    self.detailWebView.delegate = self;
    
    self.detailWebView.opaque = YES;
    for (UIView *subView in [self.detailWebView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            //            ((UIScrollView *)subView).bounces = YES;
            ((UIScrollView *)subView).scrollEnabled = NO;
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    NSArray *arr = [webViewP subviews];
    UIScrollView *webViewScroll = [arr objectAtIndex:0];
    [webViewP setFrame:CGRectMake(self.detailWebView.frame.origin.x, webViewY, self.detailWebView.frame.size.width, [webViewScroll contentSize].height)];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.detailWebView.frame.origin.y + self.detailWebView.frame.size.height);
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

- (IBAction)addOrDelCollectionAction:(id)sender {
    if (commodityDetail.isCollection == 0) {
        [self addCollectionBtn];
    }
    else
    {
        [self delCollectionBtn];
    }
}

- (IBAction)confirmationAction:(id)sender {
    ShopCarItem *item = [[ShopCarItem alloc] init];
    item.dbid = -1;
    item.commodityid = commodityDetail.commodityId;
    item.name = commodityDetail.commodityName;
    //商品属性
    NSMutableString *properysMuStr = [[NSMutableString alloc] init];
    for (int i = 0; i < [properyKeyArray count]; i++) {
        [properysMuStr appendString:[NSString stringWithFormat:@"%@:%@  ", [properyKeyArray objectAtIndex:i], [properyValArray objectAtIndex:i]]];
    }
    NSString *properysStr = [NSString stringWithString:properysMuStr];
    item.properyStr = properysStr;
    item.imagefull = [commodityDetail.imgStrList objectAtIndex:0];
    item.price = commodityDetail.price;
    item.number = 1;
    item.ischeck = @"1";
    item.subtotal = commodityDetail.price;
    item.shopId = commodityDetail.shopId;
    item.shopName = commodityDetail.shopName;
    NSMutableArray *commodityArray = [[NSMutableArray alloc] init];
    [commodityArray addObject:item];
    
    ConfirmationView *confirmationView = [[ConfirmationView alloc] init];
    confirmationView.commodityItems = commodityArray;
    [self.navigationController pushViewController:confirmationView animated:YES];
}

- (void)addCollectionBtn
{
    //收藏
    self.collectionBtn.enabled = NO;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.commodityId forKey:@"commodityId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    NSString *addCollectionUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCollection] params:param];
    [[AFOSCClient sharedClient]getPath:addCollectionUrl parameters:Nil
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
                                           commodityDetail.isCollection = 1;
                                           [self.collectionBtn setImage:[UIImage imageNamed:@"star_pro"] forState:UIControlStateNormal];
                                           self.collectionLb.text = @"已收藏";
                                           self.collectionLb.textColor = [Tool getColorForMain];
                                           [Tool showCustomHUD:@"已收藏" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                       }
                                       self.collectionBtn.enabled = YES;
                                   }
                                   @catch (NSException *exception) {
                                       [NdUncaughtExceptionHandler TakeException:exception];
                                   }
                                   @finally {
                                       self.collectionBtn.enabled = YES;
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

- (void)delCollectionBtn
{
    //取消收藏
    self.collectionBtn.enabled = NO;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:self.commodityId forKey:@"commodityId"];
    [param setValue:userInfo.regUserId forKey:@"regUserId"];
    NSString *delCollectionUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_delCollection] params:param];
    [[AFOSCClient sharedClient]getPath:delCollectionUrl parameters:Nil
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
                                           commodityDetail.isCollection = 0;
                                           [self.collectionBtn setImage:[UIImage imageNamed:@"star_nor"] forState:UIControlStateNormal];
                                           self.collectionLb.text = @"收藏";
                                           self.collectionLb.textColor = [UIColor blackColor];
                                           [Tool showCustomHUD:@"取消收藏" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                       }
                                       self.collectionBtn.enabled = YES;
                                   }
                                   @catch (NSException *exception) {
                                       [NdUncaughtExceptionHandler TakeException:exception];
                                   }
                                   @finally {
                                       self.collectionBtn.enabled = YES;
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

- (IBAction)addToShopCarAction:(id)sender {
    FMDatabase* database=[FMDatabase databaseWithPath:[Tool databasePath]];
    if (![database open]) {
        NSLog(@"Open database failed");
        return;
    }
    if (![database tableExists:@"shoppingcar"]) {
        [database executeUpdate:createshoppingcar];
    }
    
    NSMutableString *properysMuStr = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [properyKeyArray count]; i++) {
        [properysMuStr appendString:[NSString stringWithFormat:@"%@:%@  ", [properyKeyArray objectAtIndex:i], [properyValArray objectAtIndex:i]]];
    }
    NSString *properysStr = [NSString stringWithString:properysMuStr];
    
    BOOL addGood;
    FMResultSet* resultSet=[database executeQuery:@"select * from shoppingcar where commodityid = ? and user_id = ? and properyStr = ?", commodityDetail.commodityId, userInfo.regUserId, properysStr];
    if ([resultSet next]) {
        addGood = [database executeUpdate:@"update shoppingcar set number = number + 1 where id= ?", [resultSet stringForColumn:@"id"]];
    }
    else
    {
        addGood = [database executeUpdate:@"insert into shoppingcar (commodityid, name, properyStr, imagefull, price, shopid, shopname, number, user_id, ischeck) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", commodityDetail.commodityId, commodityDetail.commodityName, properysStr, [commodityDetail.imgStrList objectAtIndex:0], [NSString stringWithFormat:@"%0.2f", commodityDetail.price], commodityDetail.shopId, commodityDetail.shopName, [NSNumber numberWithInt:1], userInfo.regUserId, @"0"];
    }
    if (addGood) {
        [Tool showCustomHUD:@"已添加至购物车" andView:self.view andImage:@"37x-Checkmark.png" andAfterDelay:2];
    }
    [database close];
}

- (IBAction)buyNowAction:(id)sender {
    ShopCarItem *item = [[ShopCarItem alloc] init];
    item.dbid = -1;
    item.commodityid = commodityDetail.commodityId;
    item.name = commodityDetail.commodityName;
    //商品属性
    NSMutableString *properysMuStr = [[NSMutableString alloc] init];
    for (int i = 0; i < [properyKeyArray count]; i++) {
        [properysMuStr appendString:[NSString stringWithFormat:@"%@:%@  ", [properyKeyArray objectAtIndex:i], [properyValArray objectAtIndex:i]]];
    }
    NSString *properysStr = [NSString stringWithString:properysMuStr];
    item.properyStr = properysStr;
    item.imagefull = [commodityDetail.imgStrList objectAtIndex:0];
    item.price = commodityDetail.price;
    item.number = 1;
    item.ischeck = @"1";
    item.subtotal = commodityDetail.price;
    item.shopId = commodityDetail.shopId;
    item.shopName = commodityDetail.shopName;
    NSMutableArray *commodityArray = [[NSMutableArray alloc] init];
    [commodityArray addObject:item];
    
    ConfirmationView *confirmationView = [[ConfirmationView alloc] init];
    confirmationView.commodityItems = commodityArray;
    [self.navigationController pushViewController:confirmationView animated:YES];
}
@end
