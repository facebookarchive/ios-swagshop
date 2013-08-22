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
@property (weak, nonatomic) IBOutlet UILabel *valueField;
@property (weak, nonatomic) IBOutlet UILabel *friendsField;
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
  [self descriptionField].numberOfLines = 0;
  [[self descriptionField] sizeToFit];
  [[self nameField] setText:[item itemName]];
  [[self descriptionField] setText:[item itemDescription]];
  [self valueField].textAlignment = NSTextAlignmentCenter;
  [[self valueField] setText:[NSString stringWithFormat:@"$%d", [item itemPrice]]];
  UIImage *image = [UIImage imageWithData:[item itemImage]];
  [[self imageView] setImage:image];
    
  _friendsAdded = 0;
    
  _productObject = [self productObjectForItem:[self item]];
    
  // Graph API request for friends' wishlist data
  [FBRequestConnection startWithGraphPath:@"/me/friends?fields=fbswagshop:wishlist"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    NSArray* friends_wishlists = (NSArray*)[result data];
                            
    // Iterate over friends' wishlist and only add if has matching object.
    for (int i = 0; i < [friends_wishlists count]; i++) {
      NSArray* friend_wishlist_objects = [[[friends_wishlists objectAtIndex:i] objectForKey:@"fbswagshop:wishlist"] objectForKey:@"data"];
      for (int i  = 0; i < [friend_wishlist_objects count]; i++) {
        NSString* friend_wishlist_object_url =
          [[[[friend_wishlist_objects objectAtIndex:i] objectForKey:@"data"] objectForKey:@"product"] objectForKey:@"url"];
        if ([friend_wishlist_object_url isEqualToString:_productObject.url]) {
          _friendsAdded++;
          continue;
        }
      }
    }
           
    [[self friendsField] setText:[NSString stringWithFormat:@"%d of your friends wishlisted this.", _friendsAdded]];
                            
  }];
  
}

- (void) setItem:(Item *)item
{
  _item = item;
  [[self navigationItem] setTitle:[[self item] itemName]];
}

// Create a product UG object from an item
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
  [[ConfirmAddToWishlistViewController alloc] initWithObject:_productObject];
  [topViewController presentViewController:confirmCAddToWishlistViewController animated:NO completion:nil];
}

@end
