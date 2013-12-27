//
//  ItemDetailViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ItemDetailViewController.h"
#import "Item.h"
#import "AppDelegate.h"
#import "ConfirmAddToWishlistViewController.h"

@interface ItemDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionField;
@property (weak, nonatomic) IBOutlet UIButton *addToWishlist;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

/* The detailed view of an item/product in the store. When an item/products is viewed, an App Event is used to log this user action. This view also has an "Add to wishlist" button which takes the user to the `ConfirmAddToWishListViewController`.  */

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
  [[self descriptionField] setText:[item itemDescription]];
  UIImage *image = [UIImage imageWithData:[item itemImage]];
  [[self imageView] setImage:image];
  
  _productObject = [self productObjectForItem:[self item]];
  
  // This line logs an App Event when the user has viewed a product
  // more info: http://developers.facebook.com/docs/ios/app-events
  [FBAppEvents logEvent:FBAppEventNameViewedContent
    parameters:@{FBAppEventParameterNameContentID:[item itemSKU]}];
  
}

- (void) setItem:(Item *)item
{
  _item = item;
  [[self navigationItem] setTitle:[[self item] itemName]];
}

// Create a product OG object from an item
- (id<OGProductObject>)productObjectForItem:(Item*)item
{
  // We create an FBGraphObject object, but we can treat it as an OGProductObject with typed properties, etc.
  // See <FacebookSDK/FBGraphObject.h> for more details.
  id<OGProductObject> product = (id<OGProductObject>)[FBGraphObject graphObject];
  
  // Give it the URL where the object is hosted, which will echo back the name of the item as its title, description, and body.
  product.url = [[self item] itemURL];
  
  return product;
}

- (IBAction)addToWishlist:(id)sender
{
  AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
  UIViewController *topViewController = [[appDelegate navigationController] topViewController];
  
  ConfirmAddToWishlistViewController* confirmCAddToWishlistViewController =
  [[ConfirmAddToWishlistViewController alloc] initWithObject:_productObject item:_item];
  [topViewController presentViewController:confirmCAddToWishlistViewController animated:NO completion:nil];
}

@end
