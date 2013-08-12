//
//  DetailPageViewController.h
//  SwagStore
//
//  Created by Luz Caballero on 8/9/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) int currentPage;

- (instancetype)initWithPage:(int)page;

@end
