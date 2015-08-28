//
//  LFindLocationViewController.h
//  OMCN
//
//  Created by 邓杰豪 on 15/8/10.
//  Copyright (c) 2015年 doudou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFindLocationViewControllerDelegete <NSObject>

-(void)cityViewdidSelectCity:(NSString *)city anamation:(BOOL)anamation;

@end

@interface LFindLocationViewController : UIViewController

@property(nonatomic, assign) id<LFindLocationViewControllerDelegete>delegete;
@property(nonatomic, strong) NSString * loctionCity;

@end