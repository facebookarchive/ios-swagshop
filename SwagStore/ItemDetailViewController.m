//
//  ItemDetailViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "ItemDetailViewController.h"
#import "Item.h"

@interface ItemDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *serialField;
@property (weak, nonatomic) IBOutlet UILabel *valueField;
@property (weak, nonatomic) IBOutlet UILabel *dateField;
@property (weak, nonatomic) IBOutlet UIButton *addToWishlist;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ItemDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self){
    [[self addToWishlist] addTarget:self
                             action:@selector(addToWishlist:)
                   forControlEvents:UIControlEventTouchDown];
  }
  return self;
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:(BOOL)animated];
  Item *item = [self item];
  [[self nameField] setText:[item itemName]];
  [[self serialField] setText:[item itemDescription]];
  [[self valueField] setText:[NSString stringWithFormat:@"%d", [item itemPrice]]];
  UIImage *image = [UIImage imageWithData:[item itemImage]];
  [[self imageView] setImage:image];

}

- (void) setItem:(Item *)item {
  _item = item;
  [[self navigationItem] setTitle:[[self item] itemName]];
}

- (IBAction)addToWishlist:(id)sender
{
 // some shit
}

@end
