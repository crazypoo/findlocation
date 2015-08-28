//
//  LCCollectionViewCell.m
//  OMCN
//
//  Created by crazypoo on 15-1-30.
//  Copyright (c) 2015年 doudou. All rights reserved.
//

#import "LCCollectionViewCell.h"

#define DEFAULT_FONT(s)     [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:s]
@implementation LCCollectionViewCell
@synthesize cellTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        cellTitle               = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        cellTitle.textAlignment = NSTextAlignmentCenter;
        cellTitle.lineBreakMode = NSLineBreakByWordWrapping;
        cellTitle.numberOfLines = 0;
        cellTitle.font          = DEFAULT_FONT(13);
        cellTitle.textColor     = [UIColor whiteColor];
        [self.contentView addSubview:cellTitle];

        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}
@end
