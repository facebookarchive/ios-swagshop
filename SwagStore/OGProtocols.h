//
//  OGProtocols.h
//  SwagStore
//
//  Created by Luz Caballero on 8/13/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol OGProductObject<FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

@protocol OGWishlistAction<FBOpenGraphAction>

@property (retain, nonatomic) id<OGProductObject> product;

@end
