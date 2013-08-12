//
//  AppDelegate.h
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "Item.h"

@implementation Item

- (instancetype)initWithPFObject:(PFObject *)object
{
  NSString *name =  [object objectForKey:@"name"];
  NSString *description = [object objectForKey:@"description"];
  int price = [[object objectForKey:@"price"] intValue];
  PFFile *image = [object objectForKey:@"image"];
  NSData *imageData = [image getData];
  
  return [self initWithItemName:name itemPrice:price itemDescription:description itemImage:imageData];
}

- (instancetype)initWithItemName:(NSString *)name
             itemPrice:(int)price
       itemDescription:(NSString *)description
             itemImage:(NSData *)image
{
    // Call the superclass's designated initializer
    self = [super init];
    // Did the superclass's designated initializer succeed?
    if (self) {
        // Give the instance variables initial values
        [self setItemName:name];
        [self setItemDescription:description];
        [self setItemPrice:price];
        [self setItemImage:image];
    }
    
    // Return the address of the newly initialized object
    return self;
}

//- (instancetype)init {
//    return [self initWithItemName:@"Item"
//                        itemPrice:0
//                  itemDescription:@""
//                        itemImage:nil];
//}

@end
