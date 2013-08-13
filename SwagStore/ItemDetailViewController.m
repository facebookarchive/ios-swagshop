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
#import "OGProtocols.h"

@interface ItemDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *descriptionField;
@property (weak, nonatomic) IBOutlet UILabel *valueField;
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

}

- (void) setItem:(Item *)item {
  _item = item;
  [[self navigationItem] setTitle:[[self item] itemName]];
}

- (IBAction)addToWishlist:(id)sender
{
  // Check for publish permissions
   if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
     // Permission hasn't been granted, so ask for publish_actions
     [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                        defaultAudience:FBSessionDefaultAudienceFriends
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                        if (FBSession.activeSession.isOpen && !error) {
                                          // Permission was granted, publish the OG story
                                          [self publishStory];
                                        } else {
                                          // TO DO: Handle permission denied and errors
                                        }
                                      }];
   } else {
     // If permissions present, publish the OG story
     [self publishStory];
   }
}

- (void)publishStory
{
  // Create the OG product object for the item
  id<OGProductObject> productObject = [self productObjectForItem:[self item]];
  
  // Now create an OG wishlist action with the product object
  id<OGWishlistAction> action = (id<OGWishlistAction>)[FBGraphObject graphObject];
  action.product = productObject;
  
  // Post the action to Facebook
  [FBRequestConnection startForPostWithGraphPath:@"me/fbswagshop:wishlist"
                                     graphObject:action
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          NSString *alertText;
                          if (!error) {
                            alertText = [NSString stringWithFormat:@"Posted OG action, id: %@", [result objectForKey:@"id"]];
                          } else {
                            alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d", error.domain, error.code];
                          }
                          // Show the result in an alert
                          [[[UIAlertView alloc] initWithTitle:@"Result"
                                                      message:alertText
                                                     delegate:self
                                            cancelButtonTitle:@"OK!"
                                            otherButtonTitles:nil] show];
                        }];
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

@end
