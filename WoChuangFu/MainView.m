//
//  MainView.m
//  WoChuangFu
//
//  Created by duwl on 12/8/14.
//  Copyright (c) 2014 asiainfo-linkage. All rights reserved.
//

#import "MainView.h"
#import "MainViewModelsInit.h"
#import "MJRefresh.h"

#define MAX_MODEL_TYPE      8

@implementation MainView
@synthesize allScrollView;

#pragma mark -
#pragma mark UI
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self layoutMainView];
    }
    return self;
}

- (void)dealloc
{
    if (self.allScrollView != nil)
    {
        [self.allScrollView release];
    }
    [super dealloc];
}

- (void)layoutMainView
{
    //step 0:初始整体页面
    UIScrollView* allScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    allScroll.delegate = self;
    allScroll.tag = 10240;
    allScroll.showsVerticalScrollIndicator = NO;
    allScroll.backgroundColor = [UIColor whiteColor];
    allScroll.contentSize = CGSizeMake(self.frame.size.width,self.frame.size.height+40);
    self.allScrollView = allScroll;
    [self.allScrollView addHeaderWithTarget:self action:@selector(sendMainUIRequest)];
    [self addSubview:allScroll];
    
    UIImage *image = [UIImage imageNamed:@"has_no_content"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = CGPointMake(allScrollView.frame.size.width/2, allScrollView.frame.size.height/2);
    [allScroll addSubview:imageView];
    [imageView release];
    [allScroll release];
}

- (void)initHomeData:(NSArray*)datas
{
    float height_offset = 0;
    for(int i=0;i<datas.count;i++){
        NSInteger type = [[[datas objectAtIndex:i] objectForKey:@"type"] integerValue];
        switch (type) {
            case 0:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_0_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_0_HEIGHT;
            }break;
            case 1:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_1_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_1_HEIGHT;
            }break;
            case 2:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_2_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                height_offset += MODEL_2_HEIGHT;
            }break;
            case 3:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_3_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_3_HEIGHT;
            }break;
            case 4:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_4_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_4_HEIGHT;
            }break;
            case 5:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_5_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_5_HEIGHT;
            }break;
            case 6:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_6_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_6_HEIGHT;
            }break;
            case 7:{
                CGRect frame = CGRectMake(0,
                                          height_offset,
                                          self.frame.size.width,
                                          MODEL_7_HEIGHT);
                MainViewModelsInit* modelsInit = [[MainViewModelsInit alloc] initWithFrame:frame
                                                                                      Data:[datas objectAtIndex:i]];
                [self.allScrollView addSubview:modelsInit];
                [modelsInit release];
                
                height_offset += MODEL_7_HEIGHT;
            }break;
                
            default:
                break;
        }
    }
    self.allScrollView.contentSize=CGSizeMake(self.frame.size.width, height_offset);
}

#pragma mark -
#pragma mark UI&Http交互
//请求数据成功后，数据处理
-(void)mainPageDataProcess
{
    bussineDataService* buss = [bussineDataService sharedDataService];
    //取出http请求返回的数据
    
    //step 1:获取界面数据信息，初始界面
    if ([[buss rspInfo] objectForKey:@"datas"] != [NSNull null])
    {
        NSArray* homeDataList = [[buss rspInfo] objectForKey:@"datas"];
        [self initHomeData:homeDataList];
    }
}

//页面数据请求
-(void)sendMainUIRequest
{
    NSArray *subViews = [[self viewWithTag:10240] subviews];
    
    if (subViews.count != 0)
    {
        for(UIView *subView in subViews)
        {
            if ([subView isKindOfClass:[MainViewModelsInit class]])
            {
//                if ([(MainViewModelsInit*)subView timer]!= nil)
//                {
//                    [[(MainViewModelsInit*)subView timer] invalidate];
//                }
                [subView removeFromSuperview];
            }
        }
    }
    bussineDataService* buss = [bussineDataService sharedDataService];
    buss.target = self;
    NSDictionary *dic=[[NSDictionary alloc] initWithObjectsAndKeys:
//                       [NSNull null],@"expand",
//                       [NSNull null],@"advType",
                       nil];
    [buss mainPage:dic];
    [dic release];
}

#pragma mark -
#pragma mark HttpBackDelegate
- (void)requestDidFinished:(NSDictionary*)info
{
    NSString* oKCode = @"0000";
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* errCode = [info objectForKey:@"errorCode"];
    NSString* msg = [info objectForKey:@"MSG"];
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    
    if([[MainPageMessage getBizCode] isEqualToString:bizCode]){
        if([oKCode isEqualToString:errCode]){
            [self mainPageDataProcess];
        } else {
            if(msg == nil || msg.length <= 0){
                msg = @"获取数据失败!";
            }
            [self showAlertViewTitle:@"错误提示"
                             message:msg
                            delegate:self
                                 tag:10108
                   cancelButtonTitle:@"取消"
                   otherButtonTitles:@"重试", nil];
        }
        [(UIScrollView *)[self viewWithTag:10240] headerEndRefreshing];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView.tag==10108){
        if([buttonTitle isEqualToString:@"重试"]){
            [self sendMainUIRequest];
        }
    }
}

- (void)requestFailed:(NSDictionary*)info
{
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* msg = [info objectForKey:@"MSG"];
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    
    if([[MainPageMessage getBizCode] isEqualToString:bizCode]){
        if(msg == nil || msg.length <= 0){
            msg = @"获取数据失败!";
        }
    [self showAlertViewTitle:@"错误提示"
                     message:msg
                    delegate:self
                         tag:10108
           cancelButtonTitle:@"取消"
           otherButtonTitles:@"确定", nil];
    }
    [(UIScrollView *)[self viewWithTag:10240] headerEndRefreshing];
}

#pragma mark -
#pragma mark AlertView
-(void)showAlertViewTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate tag:(NSInteger)tag cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles,...
{
    NSMutableArray* argsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    id arg;
    va_list argList;
    if(nil != otherButtonTitles){
        va_start(argList, otherButtonTitles);
        while ((arg = va_arg(argList,id))) {
            [argsArray addObject:arg];
        }
        va_end(argList);
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitles,nil];
    alert.tag = tag;
    for(int i = 0; i < [argsArray count]; i++){
        [alert addButtonWithTitle:[argsArray objectAtIndex:i]];
    }
    [alert show];
    [alert release];
    
    [argsArray release];
}

-(void)showSimpleAlertView:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end