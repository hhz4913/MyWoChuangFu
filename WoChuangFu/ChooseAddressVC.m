//
//  ChooseAddressVC.m
//  WoChuangFu
//
//  Created by 李新新 on 14-12-29.
//  Copyright (c) 2014年 asiainfo-linkage. All rights reserved.
//

#define PHONE_WIDTH [AppDelegate sharePhoneWidth] //手机宽度
#define PHONE_HEIGHT [AppDelegate sharePhoneHeight] //手机高度

#import "ChooseAddressVC.h"
#import "TitleBar.h"
#import "UIImage+LXX.h"
#import "ComBoxView.h"
#import "ZSYCommonPickerView.h"
#import "DataDictionary_back_cart_item.h"
#import "passParams.h"

@interface ChooseAddressVC ()<TitleBarDelegate,UITextFieldDelegate,ComBoxViewDelegate,HttpBackDelegate>
{
    UIButton *submitBtn;
}

@property(nonatomic,weak) UITextField *cityInput;
@property(nonatomic,weak) UITextField *addressInput;
@property(nonatomic,weak) UILabel *packageLabel;
@property(nonatomic,strong) NSMutableDictionary *addressRequest;
@property(nonatomic,strong) NSMutableDictionary *packageRequest;
@property(nonatomic,copy) NSString *lastRequest;//最后访问
@property(nonatomic,strong) NSMutableDictionary *returnDict;
@property(nonatomic,strong)  NSMutableArray *broadBandPkg;
@property(nonatomic,strong)  NSMutableArray *addrs;

@property(nonatomic,strong) NSString *resAreaCode;

@end

@implementation ChooseAddressVC

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self LayoutV];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    submitBtn.enabled = NO;
}

- (void)LayoutV
{
    //导航条
    TitleBar *titleBar = [[TitleBar alloc] initWithFramShowHome:YES ShowSearch:NO TitlePos:middle_position];
    if (IOS7) {
        titleBar.frame = CGRectMake(0, 20, PHONE_WIDTH, 44);
    }
    titleBar.target = self;
    titleBar.title= @"地址和套餐";
    [self.view addSubview:titleBar];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, PHONE_WIDTH, PHONE_HEIGHT)];
    contentView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:contentView];
    contentView.backgroundColor = [ComponentsFactory createColorByHex:@"#f0eff4"];
    
    //城市
    
    //背景
    UIView *cityBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, PHONE_WIDTH, 40)];
    cityBgView.backgroundColor = [UIColor whiteColor];
    //标签
    UILabel *citylabel = [[UILabel alloc] init];
    citylabel.text = @"城市:";
    citylabel.frame = CGRectMake(35, 37, 50, 25);

    ComBoxView *comBox = [[ComBoxView alloc] initWithFrame:CGRectMake(80,30, 235,40)];
    comBox.backgroundColor = [UIColor whiteColor];
    comBox.arrowImgName = @"down_dark0.png";

    comBox.titlesList = self.cardOrderKeyValuelist;
    comBox.delegate = self;
    comBox.supView = contentView;
    [comBox defaultSettings];
    
    [contentView addSubview:cityBgView];
    [contentView addSubview:citylabel];
    [contentView addSubview:comBox];
    
    //地址
    
    //背景
    UIView *addressBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, PHONE_WIDTH, 40)];
    addressBgView.backgroundColor = [UIColor whiteColor];
    
    //标签
    UILabel *addresslabel = [[UILabel alloc] init];
    addresslabel.text = @"地址:";
    addresslabel.frame = CGRectMake(35, 82, 50, 25);
    
    //输入
    UITextField *addressInput = [[UITextField alloc] initWithFrame:CGRectMake(85, 82, 200, 25)];
    addressInput.placeholder = @"请输入您的地址(模糊匹配)";
    addressInput.delegate = self;
    addressInput.tag = 1024;
    [addressInput setFont:[UIFont systemFontOfSize:14.0]];
    self.addressInput = addressInput;
    
    [contentView addSubview:addressBgView];
    [contentView addSubview:addresslabel];
    [contentView addSubview:addressInput];

    //套餐
    //背景
    UIView *packageBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, PHONE_WIDTH, 40)];
    packageBgView.backgroundColor = [UIColor whiteColor];
    
     //标签
    UILabel *packagelabel = [[UILabel alloc] init];
    packagelabel.text = @"套餐:";
    packagelabel.frame = CGRectMake(35, 127, 50, 25);
    
    //输入
    UILabel *packageLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 127, 220, 25)];

    [packageLabel setFont:[UIFont systemFontOfSize:14.0]];
    self.packageLabel = packageLabel;
    [contentView addSubview:packageBgView];
    [contentView addSubview:packagelabel];
    [contentView addSubview:packageLabel];
    
    [self.view addSubview:contentView];
    
    submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setTitle:@"确认选择" forState:UIControlStateNormal];
    submitBtn.frame = CGRectMake(10,180,PHONE_WIDTH - 20, 33);
    [submitBtn setBackgroundImage:[UIImage resizedImage:@"bnt_content_primary_n.png"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:submitBtn];
    
}

- (NSDictionary *)addressRequest
{
    if (nil == _addressRequest)
    {
        _addressRequest = [NSMutableDictionary dictionary];
        [_addressRequest setObject:@"10" forKey:@"maxRows"];
    }
    return _addressRequest;
}
- (NSMutableDictionary *)returnDict
{
    if (_returnDict == nil)
    {
        _returnDict = [NSMutableDictionary dictionary];
    }
    return _returnDict;
}

- (NSDictionary *)packageRequest
{
    if (nil == _packageRequest)
    {
        _packageRequest = [NSMutableDictionary dictionary];
        [_packageRequest setObject:[NSNull null] forKey:@"bandAddress"];
        [_packageRequest setObject:self.moduleId forKey:@"moduleId"];
    }
    return _packageRequest;
}

#pragma mark 
#pragma mark - 提交
- (void)submit:(UIButton *)sender
{
    [self resignAllFirstResponder];
    if (self.block)
    {
        self.block(self.returnDict);
    }
    
    [self backAction];
}

- (void)resignAllFirstResponder
{
    [self.cityInput resignFirstResponder];
    [self.addressInput resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.tag == 1024 &&textField.text.length <2)
    {
        [self ShowProgressHUDwithMessage:@"请至少输入两个字符"];
        return NO;
    }
    else if (textField.tag == 1024 && textField.text.length >= 2)
    {
        bussineDataService *bus = [bussineDataService sharedDataService];
        bus.target = self;
        [self.addressRequest setObject:textField.text forKey:@"addrInfo"];
        
        NSString *city = [self.addressRequest objectForKey:@"city"];
        if (city == nil)
        {
            [self ShowProgressHUDwithMessage:@"请先选择城市"];
            return NO;
        }
        
        [bus filterAddress:self.addressRequest];
    }
    return YES;
}
- (void)ShowProgressHUDwithMessage:(NSString *)msg
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.dimBackground = NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - HttpBackDelegate
- (void)requestDidFinished:(NSDictionary*)info
{
    NSString* oKCode = @"0000";
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* errCode = [info objectForKey:@"errorCode"];
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    if ([[filterAddressMessage getBizCode] isEqualToString:bizCode])
    {
        if ([oKCode isEqualToString:errCode])
        {
            bussineDataService *bus=[bussineDataService sharedDataService];
            NSDictionary *dict = bus.rspInfo;
            
            if (dict[@"addrs"] != [NSNull null])
            {
                self.addrs = dict[@"addrs"];
                if (self.addrs.count >0)
                {
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.addrs.count];
                    for (int i = 0; i < self.addrs.count; i++)
                    {
                        DataDictionary_back_cart_item *item = [[DataDictionary_back_cart_item alloc] init];
                        item.ITEM_NAME = self.addrs[i][@"areaName"];
                        item.ITEM_CODE = self.addrs[i][@"areaCode"];
                        [array addObject:item];
                    }
                    self.lastRequest = [filterAddressMessage getBizCode];
                    [self showDataPickerWithArray:array];
                }
                else
                {
                    [self ShowProgressHUDwithMessage:@"没有搜索结果"];
                }
            }
            else
            {
                [self ShowProgressHUDwithMessage:@"没有搜索结果"];
            }
        }
    }
    else if([[FilterAddressPackageMessage getBizCode] isEqualToString:bizCode])
    {
        if ([oKCode isEqualToString:errCode])
        {
            bussineDataService *bus=[bussineDataService sharedDataService];
            NSDictionary *dict = bus.rspInfo;
            if (dict[@"broadbandPackage"] != [NSNull null])
            {
                NSDictionary *broadbandPackage = dict[@"broadbandPackage"];
                if (broadbandPackage[@"broadBandPkg"]!=[NSNull null])
                {
                    self.broadBandPkg = broadbandPackage[@"broadBandPkg"];
                    NSMutableDictionary *broadbrandDict = [NSMutableDictionary dictionary];
                    [broadbrandDict setObject:broadbandPackage[@"addrId"] forKey:@"bssAddr_Id"];
                    [broadbrandDict setObject:broadbandPackage[@"usertypeId"] forKey:@"usertype_Id"];
                    [broadbrandDict setObject:broadbandPackage[@"bssProductId"] forKey:@"bssproduct_Id"];
                    [broadbrandDict setObject:broadbandPackage[@"alTypeId"] forKey:@"aLType_Id"];
                    [broadbrandDict setObject:@"1" forKey:@"bssBandFlag"];
                    [self.returnDict setObject:broadbrandDict forKey:@"broadbrand"];
    
                    if (self.broadBandPkg.count >0)
                    {
                        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.broadBandPkg.count];
                        for (int i = 0; i < self.broadBandPkg.count; i++)
                        {
                            DataDictionary_back_cart_item *item = [[DataDictionary_back_cart_item alloc] init];
                            item.ITEM_NAME = self.broadBandPkg[i][@"packDesc"];
                            item.ITEM_CODE = self.broadBandPkg[i][@"packCode"];
                            [array addObject:item];
                        }
                        self.lastRequest = [FilterAddressPackageMessage getBizCode];
                        [self showDataPickerWithArray:array];
                    }
                    else
                    {
                        [self ShowProgressHUDwithMessage:@"没有匹配套餐"];
                    }
                }
                else
                {
                    [self ShowProgressHUDwithMessage:@"没有匹配套餐"];
                }
            }
        }
    }
}

- (void)requestFailed:(NSDictionary*)info
{
    
}

#pragma mark - ComBoxViewDelegate
- (void)comBoxView:(ComBoxView *)comBoxView didSelectAtIndex:(NSInteger)index withData:(NSDictionary *)data
{
    self.resAreaCode = data[@"resAreaCode"];
//    [self.returnDict setObject:data[@"resAreaCode"] forKey:@"resAreaCode"];
    [self.addressRequest setObject:data[@"areaName"] forKey:@"city"];
    [self.packageRequest setObject:data[@"areaCode"] forKey:@"cityCode"];
}

#pragma mark - TitleBarDelegate
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)homeAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showDataPickerWithArray:(NSMutableArray *)array
{
    ZSYCommonPickerView *picker = [[ZSYCommonPickerView alloc] initWithTitle:@"地址选择"
                                                                  includeAll:NO
                                                                  dataSource:array
                                                           selectedIndexPath:0
                                                                    Firstrow:nil
                                                           cancelButtonBlock:^{
                                                                      
                                                                  }
                                                         makeSureButtonBlock:^(NSInteger indexPath) {
                                                             if ([self.lastRequest isEqualToString:[filterAddressMessage getBizCode]])
                                                             {
                                                                 self.addressInput.text = [array[indexPath] ITEM_NAME];
                                                                 [self.packageRequest setObject:[array[indexPath] ITEM_CODE] forKey:@"addrId"];
                                                                 [self.packageRequest setObject:self.moduleId forKey:@"moduleId"];
                                                                 NSDictionary *country = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                          @"",@"areaName",
                                                                                          @"",@"areaCode",
                                                                                          nil];
                                                                 NSDictionary *city = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                          self.resAreaCode == nil?@"":self.resAreaCode,@"resAreaCode",
                                                                                          self.addrs[indexPath][@"areaName"],@"areaName",
                                                                                          self.addrs[indexPath][@"areaCode"],@"areaCode",
                                                                                          nil];
                                                                 passParams *pass = [passParams sharePassParams];
                                                                 [pass.params setObject:country forKey:@"countryCode"];
                                                                 [pass.params setObject:city forKey:@"cityCode"];
                                                                 bussineDataService *bus = [bussineDataService sharedDataService];
                                                                 [self.returnDict setObject:[array[indexPath] ITEM_NAME] forKey:@"areaName"];
                                                                 bus.target = self;
                                                                 [bus filterAddressPackage:self.packageRequest];
                                                             }
                                                             else if([self.lastRequest isEqualToString:[FilterAddressPackageMessage getBizCode]])
                                                             {
                                                                 DataDictionary_back_cart_item *item = array[indexPath];
                                                                 [self.returnDict setObject:self.broadBandPkg[indexPath] forKey:@"broadBandPkg"];
                                                                 self.packageLabel.text = [item ITEM_NAME];
                                                                 submitBtn.enabled = YES;
                                                             }
                                                                  }];
    [picker show];
}

@end