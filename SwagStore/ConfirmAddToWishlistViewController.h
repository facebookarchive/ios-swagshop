//
//  ConfirmAddToWishlistViewController.h
//  SwagStore
//
//  Created by Luz Caballero on 8/21/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OGProtocols.h"
#import "Item.h"

@interface ConfirmAddToWishlistViewController : UIViewController <UITextViewDelegate>

- (instancetype)initWithObject:(id<OGProductObject>)object item:(Item *)item;

@end
