//
//  ItemCell.m
//  SwagStore
//
//  Created by Luz Caballero on 8/7/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell

- (instancetype)populateFromItem:(Item *)item
{
  [[self nameLabel] setText:[item itemName]];
  [[self descriptionLabel] setText:[item itemDescription]];
  [[self valueLabel] setText:[NSString stringWithFormat:@"$%d", [item itemPrice]]];
  UIImage *image = [UIImage imageWithData:[item itemImage]];
  [[self thumbnailView] setImage:image];
  
  return self;
}

@end
