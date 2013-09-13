//
//  WishlistViewController.h
//  SwagStore
//
//  Created by Luz Caballero on 8/12/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WishlistViewController : UITableViewController

- (instancetype)initWithWishlistItemsArray:(NSMutableArray *)wishlistItemsArray WishlistActionsArray:(NSArray *)wishlistActionsArray;

@end


