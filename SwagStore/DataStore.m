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

@interface ItemStore()
{
  NSMutableArray *_allItems;
  NSMutableArray *_allWishlistItems;
}
@end

@implementation ItemStore

@synthesize allItems = _allItems;
@synthesize allWishlistItems = _allWishlistItems;

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
    
    // Create items out of the OG objects and add them to the allItems array
    _allItems = [[NSMutableArray alloc] init];
    for (id key in products) {
      id product = [products objectForKey:key];
      Item *item = [[Item alloc] initWithNSDictionary:product];
      [_allItems addObject:item];
    }
      
    if (FBSession.activeSession.isOpen) {
      
      // TO DO: check for the permissions to do this!!
      
      // Retrieve all the OG actions ("add to wishlist" actions the user performed within this app)
      _allWishlistItems = [[NSMutableArray alloc] init];
      
      NSLog(@"making request");
      

      
    
      FBRequestConnection *connection = [[FBRequestConnection alloc] init];
      
      // First request gets the wishlist actions
      FBRequest *request1 =
      [FBRequest requestForGraphPath:@"me/fbswagshop:wishlist"];
      [connection addRequest:request1
           completionHandler:
       ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
           NSString *alertText;
           alertText = [NSString stringWithFormat:@"error1: domain = %@, code = %d", error.domain, error.code];
           NSLog(alertText);
         } else {
           NSLog(@" 1 went ok");
           NSLog([NSString stringWithFormat:@"%@", result]);
           
         }
       }
              batchEntryName:@"get-actions"
       ];
      
      // Second request gets the product details
      FBRequest *request2 = [FBRequest requestForGraphPath:@"?ids={result=get-actions:$.data.*.data.product.id}"];
      [connection addRequest:request2
           completionHandler:
       ^(FBRequestConnection *connection, id result, NSError *error) {
         if (error){
           NSString *alertText;

           NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
           
           alertText = [NSString stringWithFormat:@"error2: error code -> %d, error message -> %@", [error code], [errorInformation objectForKey:@"message"]];
           
           NSLog(alertText);
           
         } else if (!error &&  result) {
           NSLog(@"it went ok");
           for (id productObject in result) {
             Item *item = [[Item alloc] initWithFBObject:productObject];
             [_allWishlistItems addObject:item];
           }
         }
       }
      
       ];
      
      [connection start];
      
    }
  }
  
  return self;
}

- (void)request:(FBRequest *)request didLoad:(id)result {
  NSArray *allResponses = result;
  for ( int i=0; i < [allResponses count]; i++ ) {
    NSDictionary *response = [allResponses objectAtIndex:i];
    int httpCode = [[response objectForKey:@"code"] intValue];
    NSString *jsonResponse = [response objectForKey:@"body"];
    if ( httpCode != 200 ) {
      NSLog( @"Facebook request error: code: %d  message: %@", httpCode, jsonResponse );
    } else {
      NSLog( @"Facebook response: %@", jsonResponse );
    }
  }
}

// For testing purposes, a function to remove an item - this SHOULD NOT EXIST
- (void)removeWishlistItem:(Item *)item
{
  // TO DO: remove the item from the OG actions on FB
  
  
  // Remove the item from the wish list array
  [_allWishlistItems removeObjectIdenticalTo:item];
}
//

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
