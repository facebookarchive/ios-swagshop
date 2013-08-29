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

@implementation DetailPageViewController

- (instancetype)initWithPage:(int)page
{
  // Initialize the UIPageViewController
  /* TO DO
   UIPageViewControllerTransitionStyleScroll is glitchy, we're waiting out to see if the some iOS release fixes it
   if not, we can fix it before release, the hack is here: http://stackoverflow.com/questions/12939280/uipageviewcontroller-navigates-to-wrong-page-with-scroll-transition-style
   Also: debug code in this class needs cleanup
   */
  self = [self initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl
                 navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:nil];
  
  if (self) {
    // Retrieve the items for the pages
    _items = [[ItemStore sharedStore] allItems];
    
    // Set the UIPageViewController as its own delegate
    [self setDataSource:self];
    
    // Needed to debug/fix the UIPageViewControllerTransitionStyleScroll glitch
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

// Needed to debug/fix the UIPageViewControllerTransitionStyleScroll glitch
- (void)pageViewController:(UIPageViewController *)pageVC didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
  if (completed){
      NSLog(@"transition completed");
  }
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
