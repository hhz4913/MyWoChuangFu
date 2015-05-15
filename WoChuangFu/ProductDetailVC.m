#import "ProductDetailVC.h"
#import "UIImage+LXX.h"
#import "CrossLineLable.h"
#import "TitleBar.h"
#import "FileHelpers.h"
#import "PropertyCell.h"
#import "InsetsLabel.h"
#import "MayYouLikeView.h"
#import "ProductEvaluationVC.h"
#import "UrlParser.h"
#import "ChoosePackageVC.h"
//#import "ChooseNumVC.h"
#import "WebProductDetailVC.h"
#import "ZSYCommonPickerView.h"
#import "DataDictionary_back_cart_item.h"
#import "CommitVC.h"
#import "ChooseAddressVC.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ISSContent.h>
#import "ShowWebVC.h"
#import "ChoosePhoneNumVC.h"

#define SCROLL_CONTENT_VIEW_TAG 2000
#define PRODUCT_DETAIL_IMAGEVIEW_TAG 2001
#define MY_NAVBAR_HEIGHT IOS7?64:44
#define PRODUCT_IMAGE_HEIGHT 190           //商品图片高度
#define PRODUCT_DESC_HEIGHT 58              //商品描述高度
#define PRICE_CONTENTVIEW_HEIGHT 60         //价格标签容器视图高度
#define BTN_CONTENTVIEW_HEIGHT 50                    //按钮容器高度
enum DetailType
{
    DetailTypeContract = 1001,
    DetailTypeCard = 1002,
    DetailTypeNet = 1011,
    DetailTypePhone = 1004,
    DetailTypeParts = 1005
};

@interface ProductDetailVC ()<UITableViewDataSource,UITableViewDelegate,TitleBarDelegate,HttpBackDelegate,MayYouLikeViewDelegate,UITextFieldDelegate>
{
    BOOL               isShow;   //赠品栏是否收缩
    BOOL               isHaveMayYoulike;
    BOOL               needCheckRom;
    BOOL               needCheckColor;
    BOOL               showYiWaibao;
    ChoosePhoneNumVC   *choosePhoneNumVC;
//    ChooseNumVC        *chooseNumVc;
    ChoosePackageVC    *choosePackageVC;
    UIView             *headerView;           //section视图
    UIImageView        *headImgView;          //section收缩箭头
    UIButton           *checkDetailBtn;
    NSIndexPath        *myIndexPath;           //合约或方式所在的Indexpath
    int                propetryNum;
}
@property(nonatomic,assign)BOOL         selectedYiWaibao;
@property(nonatomic,assign)BOOL         phoneHavaChoosedPackage;
@property(nonatomic,copy) NSString       *saveProductUrl;
@property(nonatomic,copy) NSString       *yiWaiBaoLink;
@property(nonatomic,copy) NSString       *saveProductDesc;
@property(nonatomic,copy) NSString       *moduleId;
@property(nonatomic,strong) NSDictionary *requestDict;
@property(nonatomic,weak) UIImageView    *productImgView;        //产品图片
@property(nonatomic,assign)float         offsetY;
@property(nonatomic,assign)float         tableViewHeight;
@property(nonatomic,weak) InsetsLabel    *descLabel;
@property(nonatomic,copy)   NSString     *allDetailUrl;          //图文详情URL
@property(nonatomic,weak) UILabel        *discountPrice;         //原价
@property(nonatomic,weak) CrossLineLable *sailPriceLable;        //现价
@property(nonatomic,weak) UIImageView    *ifHaveView;          //存货数量图标
@property(nonatomic,weak) UITableView    *dataTable;
@property(nonatomic,strong) NSMutableArray *gifts;                //赠品
@property(nonatomic,strong)NSMutableArray *propertyDictList;
@property(nonatomic,strong)NSMutableArray *skuList;
@property(nonatomic,strong)NSMutableArray *packageTypeList;
@property(nonatomic,strong)NSMutableArray *cardOrderKeyValuelist;
@property(nonatomic,strong)NSMutableArray *evaluateInfo;
@property(nonatomic,strong) NSMutableDictionary *selectedPropetryDict;
@property(nonatomic,strong) NSMutableDictionary *sendData;         //订单报文字典
@property(nonatomic,copy)   NSString       *cardNum;
@property(nonatomic,strong) NSDictionary   *package;
@property(nonatomic,copy)   NSString       *giftOrInstruction;   // 赠品或描述
@property(nonatomic,weak)   UIButton       *submitBtn;
@property(nonatomic,strong) UIScrollView   *mayYouLikeContentView;
@property(nonatomic,strong) UIView         *mayYouLikeView;
@property(nonatomic,copy)   NSString       *style;
@property(nonatomic,assign)   float        productPrice;
@property(nonatomic,assign)  float         phoneNumPrice;
@property(nonatomic,assign)  float         ginsengPremium;
@property(nonatomic,assign) BOOL           isAlreadyHaveNum;
@property(nonatomic,strong) NSDictionary   *netInfoDict;
@property(nonatomic,copy)  NSString        *packageName;
@property(nonatomic,assign)  float        phonePriceAfterChoosepackage;
@end

@implementation ProductDetailVC

- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor blackColor];
    self.view = view;
    [self layoutSubV];
}

- (NSMutableDictionary *)selectedPropetryDict
{
    if (_selectedPropetryDict == nil)
    {
        _selectedPropetryDict = [NSMutableDictionary dictionary];
    }
    return _selectedPropetryDict;
}
- (NSMutableDictionary *)sendData
{
    if (nil == _sendData)
    {
        _sendData = [NSMutableDictionary dictionary];
    }
    return _sendData;
}
- (NSDictionary *)package
{
    if (nil == _package)
    {
        _package = [NSMutableDictionary dictionary];
    }
    return _package;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.phoneHavaChoosedPackage = NO;
    showYiWaibao = NO;
    isShow = YES;
    self.selectedYiWaibao = NO;
    needCheckRom = NO;
    needCheckColor = NO;
    self.isAlreadyHaveNum = NO;
    isHaveMayYoulike = NO;
    bussineDataService *buss = [bussineDataService sharedDataService];
    buss.target = self;
    self.requestDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        self.params[@"productId"],@"id",
                        self.params[@"developId"],@"developerId",
                        nil];
    [buss getProductDetail:self.requestDict];
}

- (void)layoutSubV
{
    [self initTitleBar];
    [self initMainContView];
    [self initBuyBtn];
}

-(void)initBuyBtn
{
    //按钮界面
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, [AppDelegate sharePhoneHeight] - BTN_CONTENTVIEW_HEIGHT, [AppDelegate sharePhoneWidth],BTN_CONTENTVIEW_HEIGHT)];
    btnView.backgroundColor = [UIColor whiteColor];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setTitle:@"立即购买" forState:UIControlStateNormal];
    submitBtn.frame = CGRectMake(7, 8, 195 + 111, 33);
    [submitBtn setBackgroundImage:[UIImage resizedImage:@"bnt_content_primary_n.png"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(BuyProduct) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:submitBtn];
    self.submitBtn = submitBtn;
    self.submitBtn.enabled = NO;
    [self.view addSubview:btnView];
}

- (void)initTitleBar
{
    TitleBar *titleBar = [[TitleBar alloc] initWithFramShowHome:YES ShowSearch:NO TitlePos:middle_position];
    titleBar.title = @"商品详情";
    titleBar.target = self;
    if (IOS7)
        titleBar.frame = CGRectMake(0, 20, [AppDelegate sharePhoneWidth], 44);
    [self.view addSubview:titleBar];
}

- (void)initMainContView
{
    //滚动视图
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                              MY_NAVBAR_HEIGHT,
                                                                              [AppDelegate sharePhoneWidth],
                                                                              [AppDelegate sharePhoneHeight])];
    scrollView.backgroundColor = [ComponentsFactory createColorByHex:@"#f0eff4"];
    scrollView.tag = SCROLL_CONTENT_VIEW_TAG;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
}

-(void)initProductImageView
{
    if (nil == self.productImgView)
    {
        UIScrollView *scrollview = (UIScrollView *)[self.view viewWithTag:SCROLL_CONTENT_VIEW_TAG];
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [AppDelegate sharePhoneWidth], PRODUCT_IMAGE_HEIGHT)];
        contentView.backgroundColor = [UIColor whiteColor];
        //商品图片
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,100,100)];
        imgView.center =contentView.center;
        self.productImgView = imgView;
        [contentView addSubview:imgView];
        [scrollview addSubview:contentView];
        self.offsetY += PRODUCT_IMAGE_HEIGHT;
    }
}

- (void)initProductDescView
{
    //商品描述
    if (nil == self.descLabel)
    {
        UIScrollView *scrollview = (UIScrollView *)[self.view viewWithTag:SCROLL_CONTENT_VIEW_TAG];
        InsetsLabel *descLabel = [[InsetsLabel alloc] initWithInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        descLabel.frame = CGRectMake(0,self.offsetY,[AppDelegate sharePhoneWidth], PRODUCT_DESC_HEIGHT);
        descLabel.numberOfLines = 0;
        descLabel.adjustsFontSizeToFitWidth = YES;
        descLabel.backgroundColor = [UIColor clearColor];
        self.descLabel = descLabel;
        [scrollview addSubview:descLabel];
        self.offsetY += PRODUCT_DESC_HEIGHT;
    }
}
- (void)initPriceViewAndShareView
{
    if (nil == self.discountPrice)
    {
        UIScrollView *scrollview = (UIScrollView *)[self.view viewWithTag:SCROLL_CONTENT_VIEW_TAG];
        //价格信息视图
        UIView *priceShowView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                         self.offsetY,
                                                                         [AppDelegate sharePhoneWidth],
                                                                         PRICE_CONTENTVIEW_HEIGHT)];
        priceShowView.backgroundColor = [UIColor whiteColor];
        [scrollview addSubview:priceShowView];
        
        //现价
        UILabel *discountPrice = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 160, 20)];
        discountPrice.font = [UIFont systemFontOfSize:16.0f];
        discountPrice.textColor = [ComponentsFactory createColorByHex:@"#d73902"];
        self.discountPrice = discountPrice;
        [priceShowView addSubview:discountPrice];
        
        //原价
        CrossLineLable *sailPriceLable = [[CrossLineLable alloc] initWithFrame:CGRectMake(10, 30, 180,20)];
        sailPriceLable.font = [UIFont systemFontOfSize:14.0f];
        sailPriceLable.textColor = [UIColor lightGrayColor];
        self.sailPriceLable = sailPriceLable;
        [priceShowView addSubview:sailPriceLable];
        
        //是否有货
        
        UIImageView *ifHaveView = [[UIImageView alloc] initWithFrame:CGRectMake(175, 13, 27, 13)];
        ifHaveView.image = [UIImage imageNamed:@"lable_content_sku_y"];
        self.ifHaveView = ifHaveView;
        [priceShowView addSubview:ifHaveView];
        
        //分割线
        UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(240, 5, 1, 50)];
        lineView.image = [UIImage imageNamed:@"list_nav_line_s"];
        [priceShowView addSubview:lineView];
        
        //分享按钮
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setFrame:CGRectMake(237, 0, 83, 60)];
        [shareBtn setImage:[UIImage imageNamed:@"btn_share_n"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"btn_share_p"] forState:UIControlStateHighlighted];
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(-10, 15, 10, -15);
        [shareBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [shareBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
        [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        shareBtn.titleEdgeInsets = UIEdgeInsetsMake(13, -18, -20, 0);
        [priceShowView addSubview:shareBtn];
        //添加事件监听
        [shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        self.offsetY += PRICE_CONTENTVIEW_HEIGHT+5;
    }
}

- (void)initDataTableView:(BOOL)HaveMayYoulike
{
    if (nil == self.dataTable)
    {
        UIScrollView *scrollview = (UIScrollView *)[self.view viewWithTag:SCROLL_CONTENT_VIEW_TAG];
        //创建表格
        UITableView *dataTable = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                               self.offsetY,
                                                                               [AppDelegate sharePhoneWidth],
                                                                               self.tableViewHeight)
                                                              style:UITableViewStylePlain];
        dataTable.delegate = self;
        dataTable.dataSource = self;
        dataTable.scrollEnabled = NO;
        dataTable.backgroundColor = [UIColor clearColor];
        dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataTable = dataTable;
        if (isHaveMayYoulike) {
            self.dataTable.tableFooterView = self.mayYouLikeView;
        }
        else
        {
            self.dataTable.tableFooterView = checkDetailBtn;
        }
        [scrollview addSubview:_dataTable];
        self.offsetY+= self.tableViewHeight;
    }
}

- (void)initDetailWithData:(NSDictionary *)dict
{
    NSDictionary *rspDict = dict;
    //step1.获取moduleId
    if (rspDict[@"moduleId"] != [NSNull null])
    {
        self.moduleId = rspDict[@"moduleId"];
    }
    //获取商品详情
    if (rspDict[@"productDetail"] != [NSNull null])
    {
        //step1.取出商品详情
        NSDictionary *productDetail = rspDict[@"productDetail"];
        self.yiWaiBaoLink = productDetail[@"yiWaiBaoLink"];
        self.saveProductUrl = [productDetail objectForKey:@"productUrl"];
        self.saveProductDesc = [productDetail objectForKey:@"desc"];
        [self.sendData setObject:[productDetail objectForKey:@"name"]forKey:@"productName"];
        
        //step2.设置图片
        if (productDetail[@"imgURL"] != [NSNull null])
        {
            NSString *imgURL = productDetail[@"imgURL"];
            
            [self initProductImageView];
            //异步加载图片
            if (hasCachedImage([NSURL URLWithString:imgURL]))
            {
                UIImage *image = [UIImage imageWithContentsOfFile:pathForURL([NSURL URLWithString:imgURL])];
                NSLog(@"%@",NSStringFromCGSize(image.size));
//                [self.productImgView setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
//                self.productImgView.center = [self.productImgView superview].center;
                [self.productImgView setImage:image];
                
            }else
            {
                NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:imgURL,@"url",self.productImgView,@"imageView",nil];
                [ComponentsFactory dispatch_process_with_thread:^{
                    UIImage* ima = [self LoadImage:dic];
                    return ima;
                } result:^(UIImage *image)
                 {
//                     [self.productImgView setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
//                     self.productImgView.center = [self.productImgView superview].center;
                     [self.productImgView setImage:image];
                 }];
            }
        }
        //step3.设置商品描述
        [self initProductDescView];
        if (productDetail[@"desc"] != [NSNull null] &&![(NSString *)productDetail[@"desc"] isEqualToString:@""])
        {
            self.descLabel.text = [NSString stringWithFormat:@"%@,%@",[productDetail objectForKey:@"name"],productDetail[@"desc"]];
        }
        else
        {
            self.descLabel.text =[productDetail objectForKey:@"name"];
        }
        //step4.获取图文详情地址
        if (productDetail[@"allDetailUrl"] != [NSNull null])
        {
            self.allDetailUrl = productDetail[@"allDetailUrl"];
        }
        
        //step5.根据moduleId显示价格
        
        [self initPriceViewAndShareView];
        switch ([self.moduleId intValue])
        {
                // 手机
            case DetailTypePhone:
            {
                self.discountPrice.text = [NSString stringWithFormat:@"裸机价:￥%@元",productDetail[@"sailPrice"]];
                self.productPrice = [productDetail[@"sailPrice"] floatValue];
                self.sailPriceLable.hidden = YES;
                break;
            }
                // 配件
            case DetailTypeParts:
                // 合约
            case DetailTypeContract:
            {
                self.discountPrice.text = [NSString stringWithFormat:@"折扣价:￥%@元",productDetail[@"discountPrice"]];
                self.productPrice = [productDetail[@"discountPrice"] floatValue];
                self.sailPriceLable.text = [NSString stringWithFormat:@"原价:￥%@元",productDetail[@"sailPrice"]];
                break;
            }
                
                // 宽带
            case DetailTypeNet:
            {
                self.discountPrice.text = [NSString stringWithFormat:@"价格:￥%@～1800元",productDetail[@"sailPrice"]];
                self.sailPriceLable.hidden = YES;
                break;
            }
                // 包卡
            case DetailTypeCard:
            {
                self.discountPrice.text = [NSString stringWithFormat:@"预存款:￥%@元",productDetail[@"sailPrice"]];
                self.productPrice = [productDetail[@"sailPrice"] floatValue];
                self.sailPriceLable.hidden = YES;
                break;
            }
            default:
                break;
        }
        //step7.设置赠品信息
        if ([productDetail[@"gifts"] count] >0)
        {
            self.gifts = productDetail[@"gifts"];
            if (self.gifts.count == 1 && [self.gifts[0][@"giftDetail"] isEqualToString:@""])
            {
                self.gifts = nil;
            }
            self.tableViewHeight += (self.gifts.count+1)*44+10;
        }
        
        //step8.根据商品类型读取不同数据
        if (rspDict[@"phoneDetail"] != [NSNull null])
        {
            NSDictionary *phoneDetail = rspDict[@"phoneDetail"];
            self.propertyDictList = phoneDetail[@"propertyList"];
            propetryNum = [self.propertyDictList count];
            switch ([self.moduleId intValue])
            {
                    //合约
                case DetailTypeContract:
                {
                    //获取SkuList
                    _skuList = phoneDetail[@"skuList"];
                    if (self.propertyDictList.count == 0)
                    {
                        NSArray *products = [self SelectProductsByPropetrys:[self.selectedPropetryDict allValues]];
                        
                        if (1 == [products count])
                        {
                            NSString *skuId = [self makeSureSkuId:[self.selectedPropetryDict allValues]];
                            if (skuId == nil)
                            {
                                [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                                [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                            }
                            else
                            {
                                [self.sendData setObject:skuId forKey:@"skuId"];
                                [self reShowViewWithProductInfo:[products firstObject]];
                            }
                        }
                        else if (0 == [products count])
                        {
                            [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                            [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                        }
                        
                        self.submitBtn.enabled = YES;
                    }
                    NSArray *array = [NSArray arrayWithObjects:@{@"propertyName":@"合约"},@{@"propertyName":@"号码"}, nil];
                    [self.propertyDictList addObjectsFromArray:array];
                    self.tableViewHeight += self.propertyDictList.count*44;
                    break;
                }
                    //手机
                case DetailTypePhone:
                {
                    _skuList = phoneDetail[@"skuList"];
                    if (self.propertyDictList.count == 0)
                    {
                        NSArray *products = [self SelectProductsByPropetrys:[self.selectedPropetryDict allValues]];
                        
                        if (1 == [products count])
                        {
                            NSString *skuId = [self makeSureSkuId:[self.selectedPropetryDict allValues]];
                            if (skuId == nil)
                            {
                                [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                                [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                            }
                            else
                            {
                                [self.sendData setObject:skuId forKey:@"skuId"];
                                [self reShowViewWithProductInfo:[products firstObject]];
                            }
                        }
                        else if (0 == [products count])
                        {
                            [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                            [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                        }
                        
                        self.submitBtn.enabled = YES;
                    }
                    NSArray *array = [NSArray arrayWithObjects:@{@"propertyName":@"方式"}, nil];
                    [self.propertyDictList addObjectsFromArray:array];
                    self.tableViewHeight += (self.propertyDictList.count+1)*44;
                    break;
                }
                case DetailTypeParts:
                {
                    _skuList = phoneDetail[@"skuList"];
                    if (self.propertyDictList.count == 0)
                    {
                        NSArray *products = [self SelectProductsByPropetrys:[self.selectedPropetryDict allValues]];
                        
                        if (1 == [products count])
                        {
                            NSString *skuId = [self makeSureSkuId:[self.selectedPropetryDict allValues]];
                            if (skuId == nil)
                            {
                                [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                                [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                            }
                            else
                            {
                                [self.sendData setObject:skuId forKey:@"skuId"];
                                [self reShowViewWithProductInfo:[products firstObject]];
                            }
                        }
                        else if (0 == [products count])
                        {
                            [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                            [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                        }
                        
                        self.submitBtn.enabled = YES;
                    }
                    self.tableViewHeight += self.propertyDictList.count*44;
                    break;
                }
                default:
                    break;
            }
        }
        else if(rspDict[@"simDetail"]!= [NSNull null])
        {
            NSDictionary *simDetail = rspDict[@"simDetail"];
            self.propertyDictList = simDetail[@"propertyList"];
            if (self.propertyDictList == nil)
            {
                self.propertyDictList = [NSMutableArray array];
            }
            NSArray *array = [NSArray arrayWithObjects:@{@"propertyName":@"套餐"},@{@"propertyName":@"号码"}/*,@{@"propertyName":@"手机串号(选填)"}*/, nil];
            [self.propertyDictList addObjectsFromArray:array];
            self.tableViewHeight+=self.propertyDictList.count*44;
            
            self.packageTypeList = simDetail[@"bsuiPkg"][@"packageType"];
        }
        else if(rspDict[@"netDetail"]!= [NSNull null])
        {
            NSDictionary *netDetail = rspDict[@"netDetail"];
            
            self.cardOrderKeyValuelist = netDetail[@"cardOrderKeyValuelist"];
            self.propertyDictList = netDetail[@"propertyList"];
            [self.sendData setObject:netDetail[@"skuId"] forKey:@"skuId"];
            if (self.propertyDictList == nil)
            {
                self.propertyDictList = [NSMutableArray array];
            }
            [self.propertyDictList addObject:@{@"propertyName":@"地址和套餐"}];
            self.tableViewHeight+=self.propertyDictList.count*44;
        }
        //step9.设置商品评价
        if (productDetail[@"evaluateResult"]!= [NSNull null])
        {
            self.evaluateInfo = [NSMutableArray arrayWithObject:productDetail[@"evaluateResult"]];
            self.tableViewHeight+=54;
        }
        //step10.猜你喜欢
        NSArray *mayYouLikeData = rspDict[@"productDetail"][@"maybeYourLiker"];
        if (mayYouLikeData != nil && mayYouLikeData.count >0)
        {
            isHaveMayYoulike = YES;
            //猜你喜欢视图
            self.mayYouLikeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [AppDelegate sharePhoneWidth], 185)];
            self.mayYouLikeView.backgroundColor = [UIColor clearColor];
            
            InsetsLabel *lable = [[InsetsLabel alloc] initWithFrame:CGRectMake(0, 10, [AppDelegate sharePhoneWidth], 20) andInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            lable.text = @"也许您还喜欢:";
            lable.font = [UIFont systemFontOfSize:14.0f];
            lable.backgroundColor = [UIColor clearColor];
            [self.mayYouLikeView addSubview:lable];
            
            _mayYouLikeContentView = [[UIScrollView alloc] init];
            _mayYouLikeContentView.backgroundColor = [UIColor whiteColor];
            _mayYouLikeContentView.showsVerticalScrollIndicator = NO;
            _mayYouLikeContentView.frame = CGRectMake(0, 35, [AppDelegate sharePhoneWidth], 100);
            [self.mayYouLikeView addSubview:_mayYouLikeContentView];
            //添加推荐商品
            [self.mayYouLikeContentView setContentSize:CGSizeMake(100 *mayYouLikeData.count, 0)];
            for (int i = 0; i < mayYouLikeData.count; i++)
            {
                MayYouLikeView *mayYouLikeView = [[MayYouLikeView alloc] initWithFrame:CGRectMake(0 + 100 *i,0, 100, 100)];
                mayYouLikeView.delegate = self;
                mayYouLikeView.dataDict = mayYouLikeData[i];
                [_mayYouLikeContentView addSubview:mayYouLikeView];
            }
            checkDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [checkDetailBtn setBackgroundColor:[UIColor whiteColor]];
            [checkDetailBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [checkDetailBtn setTitle:@"点击查看商品详情" forState:UIControlStateNormal];
            [checkDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [checkDetailBtn setFrame:CGRectMake(0, 145, [AppDelegate sharePhoneWidth], 30)];
            [checkDetailBtn addTarget:self action:@selector(checkProductDetail) forControlEvents:UIControlEventTouchUpInside];
            [self.mayYouLikeView addSubview:checkDetailBtn];
            self.tableViewHeight+=185;
        }
        else
        {
            isHaveMayYoulike = NO;
            checkDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [checkDetailBtn setBackgroundColor:[UIColor whiteColor]];
            [checkDetailBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
            [checkDetailBtn setTitle:@"点击查看商品详情" forState:UIControlStateNormal];
            [checkDetailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [checkDetailBtn setFrame:CGRectMake(0,10, [AppDelegate sharePhoneWidth], 30)];
            [checkDetailBtn addTarget:self action:@selector(checkProductDetail) forControlEvents:UIControlEventTouchUpInside];
            self.tableViewHeight += 30;
        }
        //step11.赠品或描述
        self.giftOrInstruction = rspDict[@"giftOrInstruction"];
        self.tableViewHeight +=50;
        
        [self initDataTableView:isHaveMayYoulike];
        [self.dataTable reloadData];
        UIScrollView *scrollview = (UIScrollView *)[self.view viewWithTag:SCROLL_CONTENT_VIEW_TAG];
        scrollview.contentSize = CGSizeMake(0,self.offsetY+60+BTN_CONTENTVIEW_HEIGHT);
        
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (isShow)
            return self.gifts.count;
        else
            return 0;
    }
    else if(section == 1)
        return self.propertyDictList.count;
    else if(section == 2)
    {
       return showYiWaibao?1:0;
    }
    else if(section == 3)
        return self.evaluateInfo.count;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CustomCell";
    static NSString *identifier_YWB = @"CustomCell_YiWaiBao";
    PropertyCell *cell = nil;
    if (indexPath.section == 2)
    {
        cell = (PropertyCell *)[tableView dequeueReusableCellWithIdentifier:identifier_YWB];
    }
    else
    {
        cell = (PropertyCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    if (cell == nil)
    {
        if (indexPath.section == 2)
        {
            cell = [[PropertyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier_YWB];
        }
        else
        {
            cell = [[PropertyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    if (indexPath.section == 0)
    {
        cell.textLabel.text = self.gifts[indexPath.row][@"giftDetail"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 1)
    {
        NSString *propertyName = self.propertyDictList[indexPath.row][@"propertyName"];
        if ([propertyName isEqualToString:@"合约"])
        {
            myIndexPath = indexPath;
        }
        if ([propertyName isEqualToString:@"内存"])
        {
            needCheckRom = YES;
        }
        else if([propertyName isEqualToString:@"颜色"])
        {
            needCheckColor = YES;
        }
        
        cell.detailTextLabel.text = @"未选择";
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = propertyName;
    }
    else if(indexPath.section == 2)
    {
        UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkBtn setImage:[UIImage imageNamed:@"checkbox_d"] forState:UIControlStateNormal];
        [checkBtn setImage:[UIImage imageNamed:@"checkbox_p"] forState:UIControlStateSelected];
        checkBtn.adjustsImageWhenHighlighted = NO;
        [checkBtn addTarget:self action:@selector(yiWaiBaoClicked:) forControlEvents:UIControlEventTouchDown];
        checkBtn.frame = CGRectMake(10,5, 33, 33);
        [cell.contentView addSubview:checkBtn];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(43,0,100, 21)];
        label1.font = [UIFont systemFontOfSize:15];
        label1.text=@"手机意外保";
        [cell.contentView addSubview:label1];
        UIButton *xieYiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [xieYiBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [xieYiBtn addTarget:self action:@selector(checkXieYi) forControlEvents:UIControlEventTouchUpInside];
        xieYiBtn.frame = CGRectMake(43,21,150, 21);
        [xieYiBtn setTitle:@"《中国联通手机意外保服务协议》"forState:UIControlStateNormal];
        [xieYiBtn.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [cell.contentView addSubview:xieYiBtn];
        cell.detailTextLabel.textColor = [UIColor blueColor];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"服务费%.0f元/年",self.ginsengPremium];
    }
    else if(indexPath.section == 3)
    {
        cell.textLabel.text = @"商品评价";
        NSDictionary *dict = self.evaluateInfo[0];
        int evaluateCount = [dict[@"evaluateCount"] intValue];
        if (evaluateCount >0)
        {
            int evaluateNiceCount = [dict[@"evaluateNiceCount"] intValue];
            int nice = (int)((float)evaluateNiceCount/evaluateCount*100);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d人评价,好评率%d%%",evaluateCount,nice];
        }
        else
        {
            cell.detailTextLabel.text = @"0人评价,好评率0%";
        }
        cell.detailTextLabel.textColor = [UIColor blueColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)yiWaiBaoClicked:(UIButton *)sender
{
    self.selectedYiWaibao = !self.selectedYiWaibao;
    sender.selected = self.self.selectedYiWaibao;
    float priceCount = 0;
    if (self.self.selectedYiWaibao) {
        priceCount = self.productPrice+self.phoneNumPrice+self.ginsengPremium;
    }
    else
    {
        priceCount = self.productPrice+self.phoneNumPrice;
    }
    self.discountPrice.text = [NSString stringWithFormat:@"折扣价:%.2f元",priceCount];
}
-(void)checkXieYi
{
    if (self.selectedYiWaibao)
    {
        ShowWebVC *showWebVC=  [[ShowWebVC alloc] init];
        showWebVC.urlStr = self.yiWaiBaoLink;
        [self.navigationController pushViewController:showWebVC animated:YES];
    }
    else
    {
        [self ShowProgressHUDwithMessage:@"请先勾选意外保"];
    }
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

//选中单元格时调用
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //属性section
    if (indexPath.section == 1)
    {
        NSString *propertyName = self.propertyDictList[indexPath.row][@"propertyName"];
        if ([propertyName isEqualToString:@"合约"])
        {
            NSArray *selectedPropetryArray = [self.selectedPropetryDict allValues];
            if (selectedPropetryArray.count == propetryNum)
            {
                if ([self.sendData objectForKey:@"skuId"] == [NSNull null])
                {
                    [self ShowProgressHUDwithMessage:@"暂无匹配的商品"];
                }
                else
                {
                    NSString *skuId = [self.sendData objectForKey:@"skuId"];
                    if ([skuId isEqualToString:@""]||skuId == nil)
                    {
                        [self ShowProgressHUDwithMessage:@"暂无匹配的商品"];
                    }
                    else
                    {
                        __weak ProductDetailVC *weakSelf = self;
                        choosePackageVC = [[ChoosePackageVC alloc] init];
                        choosePackageVC.block = ^(NSDictionary *package)
                        {
                            PropertyCell *cell = (PropertyCell *)[weakSelf.dataTable cellForRowAtIndexPath:indexPath];
                            [weakSelf.sendData setObject:package[@"period"] forKey:@"period"];
                            [weakSelf.sendData setObject:package[@"pkgId"] forKey:@"pkgId"];
                            [weakSelf.sendData setObject:package[@"packTypeName"] forKey:@"packageName"];
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\%@个月",package[@"packTypeName"],package[@"period"]];
                            cell.detailTextLabel.textColor = [UIColor blueColor];
                        };
                        choosePackageVC.attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.moduleId,@"moduleId",skuId,@"skuId",self.params[@"productId"],@"productId", nil];
                        [self.navigationController pushViewController:choosePackageVC animated:YES];
                    }
                }
            }
            else
            {
                [self ShowProgressHUDwithMessage:@"请先选择商品属性"];
            }
        }
        else if ([propertyName isEqualToString:@"号码"])
        {
            choosePhoneNumVC = [[ChoosePhoneNumVC alloc] init];
            __weak ProductDetailVC *weakSelf = self;
            choosePhoneNumVC.params = [NSDictionary dictionaryWithObject:self.params[@"productId"] forKey:@"productId"];
//            chooseNumVc.productID = self.params[@"productId"];
            choosePhoneNumVC.handler = ^(NSDictionary *dict)
            {
                weakSelf.cardNum = dict[@"phoneNum"];
                PropertyCell *cell = (PropertyCell *)[weakSelf.dataTable cellForRowAtIndexPath:indexPath];
                weakSelf.phoneNumPrice = [dict[@"phoneNumPrice"] floatValue];
                float priceCount = 0;
                if (weakSelf.selectedYiWaibao)
                {
                    if([weakSelf.moduleId intValue] == DetailTypeCard)
                    {
                       priceCount = weakSelf.productPrice+weakSelf.ginsengPremium;
                    }
                    else if([weakSelf.moduleId intValue] == DetailTypePhone)
                    {
                        if (weakSelf.phoneHavaChoosedPackage)
                        {
                            priceCount = weakSelf.phonePriceAfterChoosepackage+weakSelf.phoneNumPrice+weakSelf.ginsengPremium;
                        }
                        else
                        {
                            priceCount = weakSelf.productPrice+weakSelf.phoneNumPrice+weakSelf.ginsengPremium;
                        }
                    }
                    else
                    {
                       priceCount = weakSelf.phoneNumPrice+weakSelf.productPrice+weakSelf.ginsengPremium;
                    }
                }
                else
                {
                    if([weakSelf.moduleId intValue] == DetailTypeCard)
                    {
                        priceCount = weakSelf.productPrice;
                    }
                    else if([weakSelf.moduleId intValue] == DetailTypePhone)
                    {
                        if (weakSelf.phoneHavaChoosedPackage)
                        {
                            priceCount = weakSelf.phonePriceAfterChoosepackage+weakSelf.phoneNumPrice;
                        }
                        else
                        {
                            priceCount = weakSelf.productPrice+weakSelf.phoneNumPrice;
                        }
                    }
                    else
                    {
                        priceCount = weakSelf.phoneNumPrice+weakSelf.productPrice;
                    }
                }
                weakSelf.discountPrice.text = [NSString stringWithFormat:@"折扣价:%.2f元",priceCount];
                cell.detailTextLabel.text = dict[@"phoneNum"];
                cell.detailTextLabel.textColor = [UIColor blueColor];
                if ([weakSelf.moduleId intValue]== DetailTypeCard)
                {
                    weakSelf.submitBtn.enabled = YES;
                }
            };
            [self.navigationController pushViewController:choosePhoneNumVC animated:YES];
        }
        else if ([propertyName isEqualToString:@"地址和套餐"])
        {
            ChooseAddressVC *chooseAddressVC = [[ChooseAddressVC alloc] init];
            chooseAddressVC.moduleId = self.moduleId;
            __weak ProductDetailVC *weakSelf = self;
            chooseAddressVC.block = ^(NSDictionary *dict)
            {
                weakSelf.netInfoDict = dict;
                weakSelf.discountPrice.text = [NSString stringWithFormat:@"售价：%@元",dict[@"broadBandPkg"][@"packCost"]];
                [weakSelf.sendData setObject:dict[@"broadBandPkg"][@"packCode"] forKey:@"pkgId"];
                PropertyCell *cell = (PropertyCell *)[weakSelf.dataTable cellForRowAtIndexPath:indexPath];
                cell.detailTextLabel.text = dict[@"broadBandPkg"][@"packDesc"];
                cell.detailTextLabel.textColor = [UIColor blueColor];
                weakSelf.submitBtn.enabled = YES;
            };
            chooseAddressVC.cardOrderKeyValuelist = self.cardOrderKeyValuelist;
            
            [self.navigationController pushViewController:chooseAddressVC animated:YES];
        }
        else if ([propertyName isEqualToString:@"套餐"])
        {
            [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:NO];
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.packageTypeList.count];
            for (int i=0; i<self.packageTypeList.count;i++)
            {
                NSDictionary *dict = self.packageTypeList[i];
                DataDictionary_back_cart_item *item = [[DataDictionary_back_cart_item alloc] init];
                item.ITEM_NAME = [NSString stringWithFormat:@"%@,通话%@，流量%@",dict[@"packageName"],dict[@"packageInlandVoice"],dict[@"packageInlandFlow"]];
                item.ITEM_CODE = dict[@"pkgId"];
                
                [array addObject:item];
            }
            ZSYCommonPickerView *packageTypePickerView = [[ZSYCommonPickerView alloc] initWithTitle:@"套餐"
                                                                                         includeAll:NO
                                                                                         dataSource:array
                                                                                  selectedIndexPath:0
                                                                                           Firstrow:nil
                                                                                  cancelButtonBlock:^{
                                                                                      [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
                                                                                  }
                                                                                makeSureButtonBlock:^(NSInteger index) {
                                                                                    PropertyCell *cell = (PropertyCell *)[self.dataTable cellForRowAtIndexPath:indexPath];
                                                                                    cell.detailTextLabel.textColor = [UIColor blueColor];
                                                                                    cell.detailTextLabel.text = [[array[index] ITEM_NAME] substringToIndex:7];
                                                                                    cell.userInteractionEnabled = YES;
                                                                                    [self.sendData setObject:[array[index] ITEM_CODE] forKey:@"pkgId"];
                                                                                    [self.sendData setObject:self.packageTypeList[index][@"skuId"] forKey:@"skuId"];
                                                                                }];
            [packageTypePickerView show];
            
        }
        else if ([propertyName isEqualToString:@"方式"])
        {
            [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:NO];
            NSArray *selectedPropetryArray = [self.selectedPropetryDict allValues];
            if (selectedPropetryArray.count == propetryNum)
            {
                NSString *skuId = [self makeSureSkuId:selectedPropetryArray];
                if ([skuId isEqualToString:@""])
                {
                    [self ShowProgressHUDwithMessage:@"暂无匹配的商品"];
                    [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
                }
                else
                {
                    //                    [self resetProductInfo];
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
                    DataDictionary_back_cart_item *item1 = [[DataDictionary_back_cart_item alloc] init];
                    item1.ITEM_NAME = @"裸机";
                    DataDictionary_back_cart_item *item2 = [[DataDictionary_back_cart_item alloc] init];
                    item2.ITEM_NAME = @"合约机";
                    
                    [array addObject:item1];
                    [array addObject:item2];
                    ZSYCommonPickerView *buyWayPickerView = [[ZSYCommonPickerView alloc] initWithTitle:@"方式"
                                                                                            includeAll:NO
                                                                                            dataSource:array
                                                                                     selectedIndexPath:0
                                                                                              Firstrow:nil
                                                                                     cancelButtonBlock:^{
                                                                                         [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
                                                                                     }
                                                                                   makeSureButtonBlock:^(NSInteger index) {
                                                                                       __block PropertyCell *cell = (PropertyCell *)[self.dataTable cellForRowAtIndexPath:indexPath];
                                                                                       if (index == 0)
                                                                                       {
                                                                                           cell.detailTextLabel.text = [array[index] ITEM_NAME];
                                                                                           self.style = [array[index] ITEM_NAME];
                                                                                           self.phoneHavaChoosedPackage = NO;
                                                                                           self.phonePriceAfterChoosepackage = 0;
                                                                                           if (self.isAlreadyHaveNum) {
                                                                                               [self.propertyDictList removeLastObject];
                                                                                               NSInteger rowNumber = [tableView numberOfRowsInSection:indexPath.section];
                                                                                               [self.dataTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowNumber-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                                                                                               self.isAlreadyHaveNum = NO;
                                                                                               self.discountPrice.text = [NSString stringWithFormat:@"裸机价:%.2f",self.productPrice];
                                                                                           }
                                                                                       }
                                                                                       else
                                                                                       {
                                                                                           if ([self.sendData objectForKey:@"skuId"] == [NSNull null])
                                                                                           {
                                                                                               [self ShowProgressHUDwithMessage:@"该商品暂时缺货"];
                                                                                           }
                                                                                           else
                                                                                           {
                                                                                               NSString *skuId = [self.sendData objectForKey:@"skuId"];
                                                                                               if ([skuId isEqualToString:@""]||skuId == nil)
                                                                                               {
                                                                                                   [self ShowProgressHUDwithMessage:@"该商品暂时缺货"];
                                                                                               }
                                                                                               else
                                                                                               {
                                                                                                   __weak ProductDetailVC *weakSelf = self;
                                                                                                   choosePackageVC = [[ChoosePackageVC alloc] init];
                                                                                                   choosePackageVC.block = ^(NSDictionary *package)
                                                                                                   {
                                                                                                       PropertyCell *cell = (PropertyCell *)[weakSelf.dataTable cellForRowAtIndexPath:indexPath];
                                                                                                       weakSelf.phoneHavaChoosedPackage = YES;
                                                                                                       [weakSelf.sendData setObject:package[@"period"] forKey:@"period"];
                                                                                                       [weakSelf.sendData setObject:package[@"pkgId"] forKey:@"pkgId"];
                                                                                                       [weakSelf.sendData setObject:package[@"packTypeName"] forKey:@"packageName"];
                                                                                                        weakSelf.phonePriceAfterChoosepackage = [package[@"totalPrice"] floatValue];
                                                                                                       cell.detailTextLabel.text = [NSString stringWithFormat:@"%@元\%@\%@个月",package[@"_lowCost"],package[@"packTypeName"],package[@"period"]];
                                                                                                       cell.detailTextLabel.textColor = [UIColor blueColor];
                                                                                                       
                                                                                                       if (weakSelf.isAlreadyHaveNum==NO)
                                                                                                       {
                                                                                                           [weakSelf.propertyDictList addObject:@{@"propertyName":@"号码"}];
                                                                                                           [weakSelf.dataTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                                                                                                           weakSelf.isAlreadyHaveNum = YES;
                                                                                                       }
                                                                                                       weakSelf.discountPrice.text = [NSString stringWithFormat:@"折扣价:%.2f元",weakSelf.phonePriceAfterChoosepackage + weakSelf.phoneNumPrice];
                                                                                                   };
                                                                                                   choosePackageVC.attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.moduleId,@"moduleId",skuId,@"skuId",self.params[@"productId"],@"productId", nil];
                                                                                                   [self.navigationController pushViewController:choosePackageVC animated:YES];
                                                                                               }
                                                                                           }
                                                                                       }
                                                                                       cell.detailTextLabel.textColor = [UIColor blueColor];
                                                                                       cell.userInteractionEnabled = YES;
                                                                                   }];
                    [buyWayPickerView show];
                    
                }
            }
            else
            {
                [self ShowProgressHUDwithMessage:@"请先选择商品属性"];
                [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
            }
        }
        else
        {
            [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:NO];
            //取出对应属性字典
            NSDictionary *propertyDict = self.propertyDictList[indexPath.row];
            //取出属性名称
            NSString *propertyName = propertyDict[@"propertyName"];
            //取出属性值数组
            NSArray *propertyValueList = propertyDict[@"propertyValueList"];
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:propertyValueList.count];
            for (NSDictionary *dict in propertyValueList)
            {
                DataDictionary_back_cart_item *item = [[DataDictionary_back_cart_item alloc] init];
                item.ITEM_NAME = dict[@"propertyValue"];
                item.ITEM_CODE = dict[@"propertyValueId"];
                [array addObject:item];
            }
            
            ZSYCommonPickerView *propertyPickerView = [[ZSYCommonPickerView alloc] initWithTitle:propertyName
                                                                                      includeAll:NO
                                                                                      dataSource:array
                                                                               selectedIndexPath:0
                                                                                        Firstrow:nil
                                                                               cancelButtonBlock:^{
                                                                                   [(PropertyCell *)[tableView cellForRowAtIndexPath:indexPath] setUserInteractionEnabled:YES];
                                                                               }
                                                                             makeSureButtonBlock:^(NSInteger index) {
                                                                                 
                                                                                 //step1.设置单元格
                                                                                 PropertyCell *cell = (PropertyCell *)[self.dataTable cellForRowAtIndexPath:indexPath];
                                                                                 cell.userInteractionEnabled = YES;
                                                                                 
                                                                                 if (![cell.detailTextLabel.text isEqualToString:[array[index] ITEM_NAME]]) {
                                                                                     cell.detailTextLabel.textColor = [UIColor blueColor];
                                                                                     cell.detailTextLabel.text = [array[index] ITEM_NAME];
                                                                                     //step2.添加属性到选中的属性列表
                                                                                     [self.selectedPropetryDict setValue:[array[index] ITEM_CODE] forKeyPath:propertyName];
                                                                                     //step3.筛选商品
                                                                                     NSArray *products = [self SelectProductsByPropetrys:[self.selectedPropetryDict allValues]];
                                                                                     
                                                                                     if (1 == [products count])
                                                                                     {
                                                                                         NSString *skuId = [self makeSureSkuId:[self.selectedPropetryDict allValues]];
                                                                                         if (skuId == nil)
                                                                                         {
                                                                                             [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                                                                                             [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                                                                                         }
                                                                                         else
                                                                                         {
                                                                                             [self.sendData setObject:skuId forKey:@"skuId"];
                                                                                             [self reShowViewWithProductInfo:[products firstObject]];
                                                                                             if ([[products firstObject] objectForKey:@"ginsengPremium"] != [NSNull null])
                                                                                             {
                                                                                                 NSString *ginsengPremium = [[products firstObject] objectForKey:@"ginsengPremium"];
                                                                                                 if (ginsengPremium != nil && ![ginsengPremium isEqualToString:@""]&&![ginsengPremium isEqualToString:@"null"])
                                                                                                 {
                                                                                                     self.ginsengPremium = [ginsengPremium floatValue];
                                                                                                     showYiWaibao = YES;
                                                                                                     [self.dataTable reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                                                                                                 }
                                                                                             }
                                                                                         }
                                                                                     }
                                                                                     else if (0 == [products count])
                                                                                     {
                                                                                         [self ShowProgressHUDwithMessage:@"没有匹配的商品"];
                                                                                         [self.sendData setObject:[NSNull null] forKey:@"skuId"];
                                                                                     }
                                                                                     //step4 保存属性
                                                                                     if ([propertyName isEqualToString:@"颜色"])
                                                                                     {
                                                                                         [self.sendData setObject:[array[index] ITEM_NAME] forKey:@"colorProp"];
                                                                                     }
                                                                                     else if([propertyName isEqualToString:@"内存"])
                                                                                     {
                                                                                         [self.sendData setObject:[array[index] ITEM_NAME] forKey:@"ramProp"];
                                                                                     }
                                                                                     //step5 清空合约
                                                                                     if (myIndexPath != nil)
                                                                                     {
                                                                                         PropertyCell *cell = (PropertyCell *)[tableView cellForRowAtIndexPath:myIndexPath];
                                                                                         cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1];
                                                                                         cell.detailTextLabel.text = @"未选择";
                                                                                         [self.sendData setObject:[NSNull null] forKey:@"period"];
                                                                                         [self.sendData setObject:[NSNull null] forKey:@"pkgId"];
                                                                                         [self.sendData setObject:[NSNull null] forKey:@"packTypeName"];
                                                                                     }
                                                                                     
                                                                                 }
                                                                             }];
            [propertyPickerView show];
        }
    }
    //评论
    else if (indexPath.section == 3)
    {
        ProductEvaluationVC *productEvaluationVC = [[ProductEvaluationVC alloc] init];
        productEvaluationVC.evaluateDict = self.evaluateInfo[0];
        productEvaluationVC.productId = self.params[@"productId"];
        [self.navigationController pushViewController:productEvaluationVC animated:YES];
    }
}

#pragma mark - MayYouLikeViewDelegate
- (void)mayYouLikeView:(MayYouLikeView *)mayYouLikeView didSelectWithClickUrl:(NSString *)clickUrl
{
    [UrlParser gotoNewVCWithUrl:clickUrl];
}

- (void)reShowViewWithProductInfo:(NSDictionary *)productInfo
{
    int moduleId = [self.moduleId intValue];
    self.productPrice = [productInfo[@"discountPrice"] floatValue];
    if (moduleId == DetailTypeContract || moduleId == DetailTypePhone)
    {
        float PriceCount = 0;
        if (self.selectedYiWaibao)
        {
            PriceCount = self.productPrice + self.phoneNumPrice +self.ginsengPremium;
        }
        else
            PriceCount = self.productPrice + self.phoneNumPrice;
        self.discountPrice.text = [NSString stringWithFormat:@"折扣价:%.2f元",PriceCount];
    }
    
    if (moduleId == DetailTypeContract || moduleId == DetailTypeParts || moduleId == DetailTypePhone)
    {
        int inventory = [productInfo[@"inventory"] intValue];
        if (inventory > 10)
        {
            self.ifHaveView.image = [UIImage imageNamed: @"lable_content_sku_y"];
            self.submitBtn.enabled = YES;
        }
        else if(inventory <= 10 && inventory > 0)
        {
            self.ifHaveView.image = [UIImage imageNamed: @"lable_content_sku_s"];
            self.submitBtn.enabled = YES;
        }
        else if(inventory <= 0)
        {
            self.ifHaveView.image = [UIImage imageNamed: @"lable_content_sku_w"];
            [self ShowProgressHUDwithMessage:@"该商品暂时缺货"];
            
            self.submitBtn.enabled = NO;
        }
    }
}

//根据属性筛选商品
- (NSMutableArray *)SelectProductsByPropetrys:(NSArray *)propetrys
{
    NSMutableArray *mySkuList = [NSMutableArray arrayWithArray:self.skuList];
    NSMutableArray *selectedProducts = [NSMutableArray array];
    //遍历属性
    for (int a= 0;a <propetrys.count;a++)
    {
        NSString *propetry = propetrys[a];
        //遍历所有单品
        for(int i = 0;i <mySkuList.count;i++)
        {
            NSDictionary *product = mySkuList[i];
            //获得单品属性列表
            NSArray *propertyList = product[@"propertyList"];
            //遍历所有属性
            for(int b = 0;b < propertyList.count;b++)
            {
                NSDictionary *propertyDict = propertyList[b];
                //如果属性匹配
                if ([propetry isEqualToString:propertyDict[@"propertyId"]])
                {
                    [selectedProducts addObject:product];
                    break;
                }
            }
        }
        [mySkuList removeAllObjects];
        [mySkuList addObjectsFromArray:selectedProducts];
        [selectedProducts removeAllObjects];
    }
    return mySkuList;
}

- (NSString *)makeSureSkuId:(NSArray *)propetrys
{
    NSArray *products = [self SelectProductsByPropetrys:propetrys];
    if (1 != [products count])
    {
        return nil;
    }
    else
    {
        NSString *skuId = [(NSDictionary *)[products objectAtIndex:0] objectForKey:@"skuId"];
        return skuId;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        if (self.gifts != nil && self.gifts.count >0)
        {
            if (headerView == nil)
            {
                headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[AppDelegate sharePhoneWidth], 44)];
                headerView.backgroundColor = [UIColor whiteColor];
                
                UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 30)];
                if (self.giftOrInstruction != nil)
                {
                    lable.text = self.giftOrInstruction;
                }
                else
                    lable.text = @"赠品";
                lable.tintColor = [ComponentsFactory createColorByHex:@"#000000"];
                [headerView addSubview:lable];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = headerView.frame;
                [button addTarget:self action:@selector(showDataCell:) forControlEvents:UIControlEventTouchUpInside];
                headImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_content_up_n.png"]];
                headImgView.frame = CGRectMake(290, 20, 13, 8);
                [headerView addSubview:headImgView];
                [headerView addSubview:button];
            }
            headImgView.image = [UIImage imageNamed:isShow?@"btn_content_up_n.png":@"btn_content_down_n.png"];
            return headerView;
        }
        else
            return nil;
    }
    else
        return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.gifts == nil||self.gifts.count == 0)
            return 0;
        else
            return 44;
    }
    else if (section == 1)
    {
        if (self.propertyDictList == nil ||self.propertyDictList.count == 0)
            return 0;
        else
            return 5;
    }
    else if (section == 2)
    {
        if (self.yiWaiBaoLink == nil)
            return 0;
        else
            return 5;
    }
    else if (section == 3)
    {
        if (self.evaluateInfo == nil ||self.evaluateInfo.count == 0)
            return 0;
        else
            return 5;
    }
    return 0;
}

//赠品收缩
- (void)showDataCell:(UIButton *)sender
{
    isShow = !isShow;
    [self.dataTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
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


#pragma mark - HTTPBackDelegate
- (void)requestDidFinished:(NSDictionary*)info
{
    NSString* oKCode = @"0000";
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* errCode = [info objectForKey:@"errorCode"];
    NSString* msg = [info objectForKey:@"MSG"];
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    if([[ProductDetail getBizCode] isEqualToString:bizCode])
    {
        if([oKCode isEqualToString:errCode])
        {
            bussineDataService *buss=[bussineDataService sharedDataService];
            [self initDetailWithData:buss.rspInfo];
        }
        else
        {
            msg = @"没有找到产品信息！";
            [self ShowProgressHUDwithMessage:msg];
            [self initNoProductImageView];
        }
    }
}

- (void)initNoProductImageView
{
    UIScrollView *scrollview = (UIScrollView *)[self.view viewWithTag:SCROLL_CONTENT_VIEW_TAG];
    UIImage *image = [UIImage imageNamed:@"has_no_content"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.center = CGPointMake(scrollview.center.x,scrollview.frame.size.height/2);
    [scrollview addSubview:imageView];
}

- (void)requestFailed:(NSDictionary*)info
{
    NSString* bizCode = [info objectForKey:@"bussineCode"];
    NSString* msg = [info objectForKey:@"MSG"];;
    [MBProgressHUD hideHUDForView:[AppDelegate shareMyApplication].window animated:YES];
    
    if([[ProductDetail getBizCode] isEqualToString:bizCode])
    {
        if([NSNull null] == [info objectForKey:@"MSG"] || nil == msg)
        {
            msg = @"没有找到产品信息！";
        }
        [self ShowProgressHUDwithMessage:msg];
        [self initNoProductImageView];
    }
}

#pragma mark - 异步图片
- (UIImage *)LoadImage:(NSDictionary*)aDic{
    UIImageView *view = [aDic objectForKey:@"imageView"];
    NSURL *aURL=[NSURL URLWithString:[aDic objectForKey:@"url"]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *data=[NSData dataWithContentsOfURL:aURL] ;
    UIImage *image=[UIImage imageWithData:data];
    
    CGSize origImageSize= [image size];
    CGRect newRect;
    newRect.origin= CGPointZero;
    //拉伸到多大
    newRect.size.width=view.frame.size.width *120.0f/190.0f;
    newRect.size.height= 120;
    //缩放倍数
    float ratio = MIN(newRect.size.width/origImageSize.width, newRect.size.height/origImageSize.height);
    UIGraphicsBeginImageContext(newRect.size);
    CGRect projectRect;
    projectRect.size.width =ratio * origImageSize.width;
    projectRect.size.height=ratio * origImageSize.height;
    projectRect.origin.x= (newRect.size.width -projectRect.size.width)/2.0;
    projectRect.origin.y= (newRect.size.height-projectRect.size.height)/2.0;
    [image drawInRect:projectRect];
    UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
    //压缩比例
    NSData *smallData=UIImageJPEGRepresentation(small, 1);
    if (smallData)
    {
        [fileManager createFileAtPath:pathForURL(aURL) contents:smallData attributes:nil];
    }
    UIGraphicsEndImageContext();
    return small;
}

#pragma mark - HUD
- (void)ShowProgressHUDwithMessage:(NSString *)msg
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.dimBackground = NO;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}
#pragma mark - 按钮事件
//查看图文详情
- (void)checkProductDetail
{
    WebProductDetailVC *webProductDetailVC = [[WebProductDetailVC alloc] init];
    webProductDetailVC.productDetailUrl = self.allDetailUrl;
    [self.navigationController pushViewController:webProductDetailVC animated:YES];
}

//分享
- (void)share:(UIButton *)sender
{
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:self.saveProductDesc
                                       defaultContent:@""
                                                image:nil
                                                title:@"沃创富"
                                                  url:self.saveProductUrl
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeText];
    
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo, ShareTypeTencentWeibo,ShareTypeQQSpace,ShareTypeSMS,ShareTypeWeixiSession,ShareTypeQQ, ShareTypeWeixiTimeline,nil];
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    MyLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    MyLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"确定"
                                                                          otherButtonTitles:nil];
                                    [alter show];
                                }
                            }];
    
}

//立即购买
- (void)BuyProduct
{
    CommitVC *commitVC = [[CommitVC alloc] init];
    
    [self.sendData setObject:self.params[@"productId"] forKey:@"productId"];
    [self.sendData setObject:self.cardNum == nil?[NSNull null]:self.cardNum forKey:@"cardNum"];
    [self.sendData setObject:[NSNull null] forKey:@"custType"];
    [self.sendData setObject:[NSNull null] forKey:@"seckillFlag"];
    [self.sendData setObject:self.moduleId forKey:@"moduleId"];
    
    if ([self.moduleId intValue] == DetailTypeNet)
    {
        [self.sendData setObject:self.netInfoDict[@"broadbrand"] forKey:@"broadbrand"];
        [self.sendData setObject:self.netInfoDict[@"areaName"] forKey:@"areaName"];
    }
    switch ([self.moduleId intValue])
    {
        case DetailTypeContract:
        {
            if (needCheckColor)
            {
                if (self.sendData[@"colorProp"] == [NSNull null]||self.sendData[@"colorProp"]==nil)
                {
                    [self ShowProgressHUDwithMessage:@"请选择颜色"];
                    return;
                }
            }
            if(needCheckRom)
            {
                if (self.sendData[@"ramProp"]== [NSNull null]||self.sendData[@"ramProp"]== nil)
                {
                    [self ShowProgressHUDwithMessage:@"请选择内存"];
                    return;
                }
            }
            if (self.sendData[@"period"] == [NSNull null] || self.sendData[@"pkgId"]== [NSNull null]||self.sendData[@"period"]==nil||self.sendData[@"pkgId"]==nil)
            {
                [self ShowProgressHUDwithMessage:@"请选择合约"];
                return;
            }
            if (self.sendData[@"cardNum"] == [NSNull null]||self.sendData[@"cardNum"] == nil)
            {
                [self ShowProgressHUDwithMessage:@"请选择号码"];
                return;
            }
            break;
        }
        case DetailTypeCard:
        {
            if (self.sendData[@"pkgId"] == [NSNull null]||self.sendData[@"pkgId"] == nil)
            {
                [self ShowProgressHUDwithMessage:@"请选择套餐"];
                return;
            }
            else if (self.sendData[@"cardNum"] == [NSNull null]||self.sendData[@"cardNum"] == nil)
            {
                [self ShowProgressHUDwithMessage:@"请选择号码"];
                return;
            }
            break;
        }
        case DetailTypePhone:
        {
            if (self.sendData[@"colorProp"] == [NSNull null]||self.sendData[@"colorProp"]==nil)
            {
                [self ShowProgressHUDwithMessage:@"请选择颜色"];
                return;
            }
            else if (![self.style isEqualToString:@"裸机"] &&![self.style isEqualToString:@""])
            {
                if (self.sendData[@"pkgId"] == [NSNull null]||self.sendData[@"pkgId"] == nil)
                {
                    [self ShowProgressHUDwithMessage:@"请选择方式"];
                    return;
                }
                else if (self.sendData[@"cardNum"] == [NSNull null]||self.sendData[@"cardNum"] == nil)
                {
                    [self ShowProgressHUDwithMessage:@"请选择号码"];
                    return;
                }
            }
            break;
        }
        case DetailTypeNet:
        {
            if (self.sendData[@"pkgId"] == [NSNull null]||self.sendData[@"pkgId"] == nil)
            {
                [self ShowProgressHUDwithMessage:@"请选择地址和套餐"];
                return;
            }
            break;
        }
        case DetailTypeParts:
        {
            if (needCheckColor)
            {
                if (self.sendData[@"colorProp"] == [NSNull null]||self.sendData[@"colorProp"]==nil)
                {
                    [self ShowProgressHUDwithMessage:@"请选择颜色"];
                    return;
                }
            }
        }
        default:
            break;
    }
    
    switch ([self.moduleId intValue]) {
        case DetailTypeCard:
        {
            float priceCount = 0;
            if (self.selectedYiWaibao) {
                priceCount = self.productPrice+self.ginsengPremium;
                [self.sendData setObject:@"1" forKey:@"woYibaoFlag"];
            }
            else
            {
                priceCount = self.productPrice;
                [self.sendData setObject:[NSNull null] forKey:@"woYibaoFlag"];
            }
            [self.sendData setObject:[NSString stringWithFormat:@"%f",priceCount] forKey:@"Price"];
        }
            break;
        case DetailTypeContract:
        {
            float priceCount = 0;
            if (self.selectedYiWaibao) {
                priceCount = self.productPrice+self.phoneNumPrice+self.ginsengPremium;
                [self.sendData setObject:@"1" forKey:@"woYibaoFlag"];
            }
            else
            {
                priceCount = self.productPrice+self.phoneNumPrice;
                [self.sendData setObject:[NSNull null] forKey:@"woYibaoFlag"];
            }
            [self.sendData setObject:[NSString stringWithFormat:@"%f",priceCount] forKey:@"Price"];
        }
            break;
        case DetailTypePhone:
        {
            float priceCount = 0;
            if (self.selectedYiWaibao)
            {
                if (self.phoneHavaChoosedPackage)
                {
                    priceCount = self.phonePriceAfterChoosepackage +self.ginsengPremium;
                }
                else
                {
                    priceCount = self.productPrice+self.ginsengPremium;
                }
                [self.sendData setObject:@"1" forKey:@"woYibaoFlag"];
            }
            else
            {
                if (self.phoneHavaChoosedPackage)
                {
                    priceCount = self.phonePriceAfterChoosepackage;
                }
                else
                {
                    priceCount = self.productPrice;
                }
                [self.sendData setObject:[NSNull null] forKey:@"woYibaoFlag"];
            }
            [self.sendData setObject:[NSString stringWithFormat:@"%f",priceCount] forKey:@"Price"];
        }
            break;
        case DetailTypeNet:
        {
            [self.sendData setObject:self.netInfoDict[@"broadBandPkg"][@"packCost"] forKey:@"Price"];
        }
            break;
        case DetailTypeParts:
        {
            [self.sendData setObject:[NSString stringWithFormat:@"%f",self.productPrice] forKey:@"Price"];
        }
            break;
        default:
            break;
    }
    MyLog(@"%@",self.sendData);
    commitVC.receiveData = [NSMutableDictionary dictionaryWithObject:self.sendData forKey:@"ProductInfo"];
    [self.navigationController pushViewController:commitVC animated:YES];
}

@end