//
//  DetailPageViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/9/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "DetailPageViewController.h"
#import "ItemDetailViewController.h"
#import "DataStore.h"
#import "Item.h"

@interface DetailPageViewController ()

@property (nonatomic) NSArray *items;

@end

// A page view controller that holds a detailed view from one item/product at a time. Swiping navigates to other items.

@implementation DetailPageViewController

- (instancetype)initWithPage:(int)page
{
  // Initialize the UIPageViewController
  self = [self initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
  
  if (self) {
    // Retrieve the items for the pages
    _items = [[ItemStore sharedStore] allItems];
    
    // Set the UIPageViewController as its own delegate
    [self setDataSource:self];
    [self setDelegate:self];
    
    // Set the currentPage to page
    _currentPage = page;
    
    // Set the itemDetailViewController for the currentPage within the detailPageViewController
    NSArray *detailArray = [[NSArray alloc] initWithObjects:[self itemDetailViewControllerForPage:_currentPage], nil];
    [self setViewControllers:detailArray
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
  }
  return self;
  
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageVC viewControllerBeforeViewController:(UIViewController *)currentVC
{
  // Decrease the page
  _currentPage = (_currentPage + [_items count] - 1) % [_items count];
  return [self itemDetailViewControllerForPage:_currentPage];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageVC viewControllerAfterViewController:(UIViewController *) currentVC
{
  // Increase the page
  _currentPage = (_currentPage + 1) % [_items count];
  return [self itemDetailViewControllerForPage:_currentPage];
}

- (ItemDetailViewController *)itemDetailViewControllerForPage:(int)page
{
  // Create the UIViewController that will contain the item detail
  ItemDetailViewController *itemDetailViewController =[[ItemDetailViewController alloc] init];
  Item *selectedItem = [_items objectAtIndex:page];
  [itemDetailViewController setItem:selectedItem];
  return itemDetailViewController;
}

@end
