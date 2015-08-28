//
//  LFindLocationViewController.m
//  OMCN
//
//  Created by 邓杰豪 on 15/8/10.
//  Copyright (c) 2015年 doudou. All rights reserved.
//

#import "LFindLocationViewController.h"

#import "LCCollectionViewCell.h"
#import "MBProgressHUD.h"
#import "PooSearchBar.h"
#import "LCityModels.h"
#import <MapKit/MapKit.h>

#define DEFAULT_FONT(s)     [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:s]
#define INTERFACE_IS_PAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define IOS8after [[[UIDevice currentDevice] systemVersion] floatValue] >= 8

static NSString * const reuseIdentifiers = @"Cell";

@interface LFindLocationViewController ()<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate,CLLocationManagerDelegate>
{
    NSArray *provinces;
    NSArray *cities;
    NSMutableArray *arr;
    UICollectionView *attachedCellCollection;
    PooSearchBar *searchBar;
    NSMutableArray *tempArray;
    BOOL isSearch;
    UITableView *searchHistory_tb;
    UIButton *whereBtn;
    CLLocationManager *locationManager;
    NSString *whereStr;
    
    NSMutableArray *storeCities;
}
@end

@implementation LFindLocationViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIButton *leftNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftNavBtn.frame = CGRectMake(0, 0, 30, 30);
    [leftNavBtn setTitle:@"OO" forState:UIControlStateNormal];
    [leftNavBtn addTarget:self action:@selector(backAct:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:leftNavBtn]];
    
    whereStr = @"";

    searchBar = [[PooSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, 44)];
    searchBar.barStyle     = UIBarStyleDefault;
    searchBar.translucent  = YES;
    searchBar.delegate     = self;
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.searchPlaceholder = @"请输入地市名";
    searchBar.searchPlaceholderColor = [UIColor whiteColor];
    searchBar.searchPlaceholderFont = DEFAULT_FONT(16);
    searchBar.searchTextColor = [UIColor whiteColor];
    searchBar.searchBarImage = [UIImage imageNamed:@"Search"];
    searchBar.searchTextFieldBackgroundColor = [UIColor orangeColor];
    searchBar.searchBarOutViewColor = [UIColor clearColor];
    searchBar.searchBarTextFieldCornerRadius = 15;
    
    self.navigationItem.titleView = searchBar;

    searchHistory_tb                                = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    searchHistory_tb.dataSource                     = self;
    searchHistory_tb.delegate                       = self;
    searchHistory_tb.showsHorizontalScrollIndicator = NO;
    searchHistory_tb.showsVerticalScrollIndicator   = NO;
    [self.view addSubview:searchHistory_tb];
}

-(void)viewDidAppear:(BOOL)animated
{
    storeCities = [[NSMutableArray alloc] init];
    for (int i = 1; i<30; i++) {
        for (NSString *str in [[provinces objectAtIndex:i] objectForKey:@"cities"]) {
            LCityModels * newCity = [[LCityModels alloc] init];
            NSMutableDictionary *lllll = [[NSMutableDictionary alloc] init];
            [lllll setObject:str forKey:@"cities"];
            newCity.cityNAme = lllll[@"cities"];
            NSMutableString *ms = [[NSMutableString alloc] initWithString:newCity.cityNAme];
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
            }
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                newCity.letter = ms;
            }
            [storeCities addObject:newCity];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city.plist" ofType:nil]];
    tempArray = [[NSMutableArray alloc] init];
    cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
    
    arr = [[NSMutableArray alloc] init];
    for (int i = 0; i<30; i++) {
        [arr addObject:[[provinces objectAtIndex:i] objectForKey:@"state"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return arr;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isSearch) {
        return 1;
    }
    return provinces.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (isSearch) {
        return tempArray.count;
    }
    cities = [[provinces objectAtIndex:section] objectForKey:@"cities"];
    
    if (section == 0)
    {
        return 2;
    }
    return cities.count;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (isSearch) {
        return 1;
    }
    MBProgressHUD *hub = [[MBProgressHUD alloc] initWithView:self.view];
    hub.mode = MBProgressHUDModeCustomView;
    hub.labelFont = DEFAULT_FONT(16);
    hub.labelText = title;
    hub.minShowTime = 0.1;
    [self.view addSubview:hub];
    [hub showAnimated:YES whileExecutingBlock:^{
        [hub hide:YES];
    } completionBlock:^{
        
    }];
    return index;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearch) {
        return 40;
    }
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1) {
            return 150;
        }
        return 40;
    }
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (isSearch) {
        return 0.0000001;
    }
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        if (isSearch) {
            return nil;
        }
        else
        {
            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
            titleView.backgroundColor = [UIColor whiteColor];
            
            whereBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            whereBtn.frame = CGRectMake(10, 0, self.view.frame.size.width-120, 40);
            [whereBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            whereBtn.titleLabel.font = DEFAULT_FONT(14);
            [whereBtn addTarget:self action:@selector(userTap:) forControlEvents:UIControlEventTouchUpInside];
            [titleView addSubview:whereBtn];
            
            if (self.loctionCity) {
                [whereBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [whereBtn setTitle:[NSString stringWithFormat:@"定位城市:%@",self.loctionCity] forState:UIControlStateNormal];
                whereBtn.userInteractionEnabled = YES;
            }else{
                [whereBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [whereBtn setTitle:@"定位失败，请重新定位" forState:UIControlStateNormal];
                whereBtn.userInteractionEnabled = NO;
            }
            
            UIButton * tapBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            tapBtn.frame = CGRectMake(self.view.frame.size.width-100, 0, 40, 40);
            [tapBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [titleView addSubview:tapBtn];
            tapBtn.titleLabel.font = DEFAULT_FONT(14);
            [tapBtn setTitle:@"定位" forState:UIControlStateNormal];
            [tapBtn addTarget:self action:@selector(reLOadLoction) forControlEvents:UIControlEventTouchUpInside];
            
            return titleView;
        }
    }
    else
    {
        NSString *HeaderString = [[provinces objectAtIndex:section] objectForKey:@"state"];
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        titleView.backgroundColor = [UIColor colorWithWhite:0.880 alpha:1.000];

        UILabel *HeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 180, 40)];
        HeaderLabel.font = DEFAULT_FONT(16);
        HeaderLabel.textColor = [UIColor blackColor];
        HeaderLabel.text = HeaderString;
        
        [titleView addSubview:HeaderLabel];
        return titleView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cities = [[provinces objectAtIndex:indexPath.section] objectForKey:@"cities"];
    
    UITableViewCell *cell = nil;
    static NSString *searchIdentifier = @"cell_id";
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchIdentifier];
    }
    else
    {
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    
    LCityModels * city;
    if (isSearch) {
        city = [tempArray objectAtIndex:indexPath.row];
        cell.textLabel.text = city.cityNAme;
    }
    else
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell.backgroundColor = [UIColor colorWithWhite:0.880 alpha:1.000];

                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, 40)];
                titleLabel.textColor = [UIColor blackColor];
                titleLabel.font = DEFAULT_FONT(16);
                titleLabel.text = @"常用城市";
                [cell.contentView addSubview:titleLabel];
            }
            else if (indexPath.row == 1) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                if (INTERFACE_IS_PAD) {
                    layout.itemSize                    = CGSizeMake(126, 45);
                }
                else
                {
                    layout.itemSize                    = CGSizeMake((self.view.frame.size.width-80-30)/3, 31);
                }
                CGFloat paddingY                   = 5;
                CGFloat paddingX                   = 5;
                layout.sectionInset                = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX);
                layout.minimumLineSpacing          = paddingY;
                
                attachedCellCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-80, 150) collectionViewLayout:layout];
                
                attachedCellCollection.backgroundColor                = [UIColor whiteColor];
                attachedCellCollection.dataSource                     = self;
                attachedCellCollection.delegate                       = self;
                attachedCellCollection.showsHorizontalScrollIndicator = NO;
                attachedCellCollection.showsVerticalScrollIndicator   = NO;
                attachedCellCollection.pagingEnabled                  = NO;
                [attachedCellCollection registerClass:[LCCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifiers];
                attachedCellCollection.tag                            = 0;
                attachedCellCollection.scrollEnabled                  = NO;
                [cell.contentView addSubview:attachedCellCollection];
            }
        }
        else
        {
            cell.textLabel.font = DEFAULT_FONT(14);
            cell.textLabel.text = [cities objectAtIndex:indexPath.row];
        }
        
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchBar resignFirstResponder];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    [_delegete cityViewdidSelectCity:cell.textLabel.text anamation:YES];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    //#warning Incomplete method implementation -- Return the number of sections
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //#warning Incomplete method implementation -- Return the number of items in the section
    
    cities = [[provinces objectAtIndex:section] objectForKey:@"cities"];
    
    switch (collectionView.tag) {
        case 0:
        {
            return cities.count;
            
        }
            break;
        default:
            break;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifiers forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
    
    switch (collectionView.tag) {
        case 0:
        {
            cell.cellTitle.text = [cities objectAtIndex:indexPath.row];
        }
            break;
        default:
            break;
    }
    cell.cellTitle.textColor = [UIColor whiteColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegete cityViewdidSelectCity:[cities objectAtIndex:indexPath.row] anamation:YES];
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}


#pragma mark searchBarDelegete
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [tempArray removeAllObjects];
    if (searchText.length == 0) {
        isSearch = NO;
    }
    else
    {
        isSearch = YES;
        for (LCityModels * city in storeCities) {
            NSRange chinese = [city.cityNAme rangeOfString:searchText options:NSCaseInsensitiveSearch];
            NSRange  letters = [city.letter rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (chinese.location != NSNotFound) {
                [tempArray addObject:city];
            }
            else if (letters.location != NSNotFound)
            {
                [tempArray addObject:city];
            }
        }

    }
    [searchHistory_tb reloadData];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    isSearch = NO;
}

-(void)backAct:(id)sender
{
    [searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)userTap:(id)sender
{
    [searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [_delegete cityViewdidSelectCity:whereStr anamation:YES];
    }];
}

-(void)reLOadLoction
{
    locationManager                 = [[CLLocationManager alloc] init];
    locationManager.delegate        = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter  = 1000.0f;
    [locationManager startUpdatingLocation];
    
    if (IOS8after) {
        [locationManager requestAlwaysAuthorization];
    }
}

#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            whereStr = placemark.locality;
            [whereBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [whereBtn setTitle:[NSString stringWithFormat:@"定位城市:%@",whereStr] forState:UIControlStateNormal];
            whereBtn.userInteractionEnabled = YES;
            
            [[NSUserDefaults standardUserDefaults] setObject:placemark.locality forKey:@"USER_WHERE"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败, 错误: %@",error);
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (!isSearch) {
        [searchBar resignFirstResponder];
    }
}

@end

