//
//  MainPageNewView.h
//  LinJu
//
//  Created by Seven on 15/6/6.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface MainPageNewView : UIViewController<UIScrollViewDelegate, SGFocusImageFrameDelegate>
{
    Notice *notice;
    
    NSMutableArray *advDatas;
    SGFocusImageFrame *bannerView;
    int advIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *advIv;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *gatePassBtn;
@property (weak, nonatomic) IBOutlet UILabel *gatePassLb;

@property (weak, nonatomic) IBOutlet UILabel *noticeTitleLb;
- (IBAction)noticeDetailAction:(id)sender;

//物业通知
- (IBAction)noticesAction:(id)sender;
//物业呼叫
- (IBAction)callServiceAction:(id)sender;
//物品借用
- (IBAction)goodBorrowAction:(id)sender;
//快递收发
- (IBAction)expressAction:(id)sender;
//物业报修
- (IBAction)addRepairAction:(id)sender;
//投诉建议
- (IBAction)addSuitWorkAction:(id)sender;
//访客通行证
- (IBAction)pushGatePassAction:(id)sender;
//账单推送
- (IBAction)pushPaymentListView:(id)sender;
//交易买卖
- (IBAction)pushTradeViewAction:(id)sender;
//积分兑奖
- (IBAction)signInAction:(id)sender;
//周边商家
- (IBAction)ShopTypeAction:(id)sender;
//社区活动
- (IBAction)activityViewAction:(id)sender;


@end
