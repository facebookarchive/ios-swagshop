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
    NSString *name =  [object objectForKey:@"title"];
    NSString *description = [object objectForKey:@"description"];
    
    NSDictionary *offer = [object objectForKey:@"offer"];
    
    int price = [[[offer objectForKey:@"USD"] objectForKey:@"price"] intValue];
    
    NSDictionary *images = [object objectForKey:@"images"];
    NSDictionary *image = [images objectForKey:@"800"];
    
    NSURL *imageURL = [NSURL URLWithString:[image objectForKey:@"url"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    return [self initWithItemName:name itemPrice:price itemDescription: description itemImage:imageData];
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
