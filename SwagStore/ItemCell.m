//
//  ItemCell.m
//  SwagStore
//
//  Created by Luz Caballero on 8/7/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "ItemCell.h"

/* Each of the cells in the ListViewController and WishlistViewController. They display the products and some of their properties: name, description, image. */

@implementation ItemCell

- (instancetype)populateFromItem:(Item *)item
{    
    [[self nameLabel] setText:[item itemName]];
    [[self descriptionLabel] setText:[item itemDescription]];
    UIImage *image = [UIImage imageWithData:[item itemImage]];
    [[self thumbnailView] setImage:image];

    return self;
}

@end
