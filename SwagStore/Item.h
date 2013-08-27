//
//  AppDelegate.h
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

- (id)initWithNSDictionary:(NSDictionary *)object;
- (instancetype)initWithFBObject:(NSDictionary *)object;

@property (nonatomic, strong) NSData *itemImage;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *itemDescription;
@property (nonatomic, strong) NSString *itemURL;
@property (nonatomic) int itemPrice;

@end
