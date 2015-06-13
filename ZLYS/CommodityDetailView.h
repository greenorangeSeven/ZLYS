//
//  CommodityDetailView.h
//  WHDLife
//
//  Created by Seven on 15-1-16.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommodityDetailView : UIViewController

@property (copy, nonatomic) NSString *commodityId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
@property (weak, nonatomic) IBOutlet UILabel *marketPriceLb;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *collectionLb;
@property (weak, nonatomic) IBOutlet UIView *properyView;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLb;

- (IBAction)addOrDelCollectionAction:(id)sender;
- (IBAction)confirmationAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addToShopCarBtn;
- (IBAction)addToShopCarAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buyNowBtn;
- (IBAction)buyNowAction:(id)sender;

@end
