//
//  WishlistViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/12/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "WishlistViewController.h"
#import "ItemCell.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "DataStore.h"
#import "Item.h"

@interface WishlistViewController ()

@property UIBarButtonItem *editWishlistButton;
@property NSMutableArray *wishlistItemsArray;
@property NSMutableArray *wishlistActionsArray;

@end

/* This view displays the all the products the user has added to their wishlist. On the nav bar there's an "Edit" button that turns the list to the iOS list edit mode and allows the user to remove items from the list. When an item is removed, a Graph API call is made to delete the action (addition to the user's wishlist) tied with that object from the Facebook graph. */

@implementation WishlistViewController

- (instancetype)initWithWishlistItemsArray:(NSMutableArray *)wishlistItemsArray WishlistActionsArray:(NSMutableArray *)wishlistActionsArray
{
  _wishlistItemsArray = wishlistItemsArray;
  _wishlistActionsArray = wishlistActionsArray;
  NSLog(@"wishlistActionsArray %@", wishlistActionsArray);
  self = [self init];
  if (self) {
    // Set the viewTitle
    UINavigationItem *nI = [self navigationItem];
    [nI setTitle:@"Wishlist"];
    
    // Add empty footer to prevent empty rows from showing
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = tableFooterView;
    
    // Add "Edit wishlist" button
    UIBarButtonItem *editWishlistButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(editWishlist:)];
    [editWishlistButton setPossibleTitles:[NSSet setWithObjects:@"Edit", @"Done", nil]];
    
    [[self navigationItem] setRightBarButtonItem:editWishlistButton];
    
  }
  return self;
}

- (IBAction)editWishlist:(id)sender{
  // If we're currently in edititng mode...
  if ([[self tableView] isEditing]) {
    // Change the text of the button to inform the user of the state
    [sender setTitle:@"Edit"];
    // Turn off editing mode
    [[self tableView] setEditing:NO animated:YES];
  } else {
    // Change button to inform user of state
    [sender setTitle:@"Done"];
    [[self tableView] setEditing:YES animated:YES];
  }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  // If the table view is asking to commit a delete command
  if (editingStyle == UITableViewCellEditingStyleDelete) {  
    // Remove the item from the wish list
    [self removeWishlistItemWithIndexPath:indexPath fromTable:tableView];
  }
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  // Load the cell nib file and register it for reuse
  UINib *nib = [UINib nibWithNibName:@"ItemCell" bundle:nil];
  [[self tableView] registerNib:nib forCellReuseIdentifier:@"ItemCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows
  return [_wishlistItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // Get a cell
  ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
  
  // Get the wish list item for the row
  Item *wishlistItem = [_wishlistItemsArray objectAtIndex:[indexPath row]];
  
  // Return the cell populated with the wishlist items
  return [cell populateFromItem:wishlistItem];
  
  return cell;
}

/* Remove a product from the wishlist = remove the action associated with it from _wishlistActionsArray +
   remove the product from _wishlistItemsArray + remove the OG story associated with that action (and product) from Facebook */
// To remove the OG story from Facebook we need to delete the OG action connected with that OG object from the Facebook graph
- (void)removeWishlistItemWithIndexPath:(NSIndexPath *)indexPath fromTable:(UITableView *)tableView
{
  // First, obtain the FBID of the OG object associated with the item
  Item *item = [_wishlistItemsArray objectAtIndex:[indexPath row]];
  NSString *productId = [item itemFBID];
  NSLog(@"product id of the product to be removed: %@", productId);
  // Find the FBID of the OG action connected with that OG Object
  for (id action in _wishlistActionsArray) {
    if ([[NSString stringWithFormat:@"%@", [[[action objectForKey:@"data"] objectForKey:@"product"] objectForKey:@"id"]] isEqualToString:productId]) {
      NSLog(@"found an action to delete, its id is: %@", [action objectForKey:@"id"]);
      //Make an HTTP DELETE request with the OG action's FBID
      [FBRequestConnection startForDeleteObject:[action objectForKey:@"id"]
                     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
          // An error occurred, we don't handle the error here but you should
          // more info: http://developers.facebook.com/docs/ios/errors
        } else {
          // Deleting the action from Facebook was successful
          // Below we do some more stuff related to removing the action from the Swag Shop UI
          // Remove the action from the wishlistActionsArray
          [_wishlistActionsArray removeObject:action];
          // Remove the object from the wishlistItemsArray
          [_wishlistItemsArray removeObject:item];
          // Remove the item's row from the table
          [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
      }];
      break;
    }
  }
}
    
@end
