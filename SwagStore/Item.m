//
//  AppDelegate.h
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "Item.h"

@implementation Item

- (instancetype)initWithNSDictionary:(NSDictionary *)object
{
    // Call the superclass's designated initializer
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
      // Give the instance variables initial values
      [self setItemName:[object objectForKey:@"title"]];
      [self setItemDescription:[object objectForKey:@"description"]];
      [self setItemPrice:[[[[object objectForKey:@"offer"] objectForKey:@"USD"] objectForKey:@"price"] intValue]];
      [self setItemURL:[object objectForKey:@"link"]];
      NSDictionary *image = [[object objectForKey:@"images"] objectForKey:@"800"];
      NSURL *imageURL = [NSURL URLWithString:[image objectForKey:@"url"]];
      NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
      [self setItemImage:imageData];
    }
    
    return self;
}

@end
