//
//  ItemStore.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "DataStore.h"
#import "Item.h"
#import "AppDelegate.h"

// Contains `allItems`, a singleton array that holds a list of all the items/products in the shop.
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
    
    // Retrieve all the OG objects from the app's server
    NSString *productsURL = @"http://dev.facebooksampleapp.com/swagshop/api/products.php?images";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:productsURL]];
    NSURLResponse *resp = nil;
    NSError *err = nil;
      
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&err];
    
    NSDictionary *products = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&err];
    NSLog(@"products: %@", products);
    
    // Create items out of the OG objects and add them to the allItems array
    _allItems = [[NSMutableArray alloc] init];
    for (id key in products) {
      id product = [products objectForKey:key];
      Item *item = [[Item alloc] initWithNSDictionary:product];
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
