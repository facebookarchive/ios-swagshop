//
//  Action.h
//  SwagStore
//
//  Created by Luz Caballero on 8/13/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Action : NSObject

@property (nonatomic) int actionID;
@property (nonatomic, strong) NSString *actionObjectName;
@property (nonatomic, strong) NSString *actionObjectDescription;
@property (nonatomic, strong) NSData *actionObjectImage;
@property (nonatomic, strong) NSString *actionURL;

@end
