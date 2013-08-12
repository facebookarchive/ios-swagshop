//
//  ItemStore.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <Parse/Parse.h>

#import "ItemStore.h"
#import "Item.h"

@interface ItemStore()
{
  NSMutableArray *_allItems;
}
@end

@implementation ItemStore

@synthesize allItems = _allItems;

- (instancetype)init
{
  self = [super init];
  if (self){
    
    // Parse objects into an array
    PFQuery *query = [PFQuery queryWithClassName:@"Item"];
    NSArray *parseItems = [query findObjects];
    
    // transform the Parse objects into Items
    _allItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < [parseItems count]; i++) {
      Item *item = [[Item alloc] initWithPFObject:[parseItems objectAtIndex:i]];
      [_allItems addObject:item];
    }
    
  }
  return self;
}

+ (ItemStore *)sharedStore
{
  static ItemStore *sharedStore = nil;
  if (!sharedStore){
    sharedStore = [[super allocWithZone:nil] init];
  }
  return sharedStore;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
  return [self sharedStore];
}

@end
