//
//  ItemStore.h
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface ItemStore : NSObject

- (void)removeItem:(Item *)item;

+ (ItemStore *)sharedStore;

@property (nonatomic, strong, readonly) NSArray *allItems;

@end
