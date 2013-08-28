//
//  ItemDetailViewController.h
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGProtocols.h"

@class Item;

@interface ItemDetailViewController : UIViewController
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) id<OGProductObject> productObject;

@end
