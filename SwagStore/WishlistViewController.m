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

@implementation WishlistViewController

- (instancetype)initWithWishlistItemsArray:(NSMutableArray *)wishlistItemsArray WishlistActionsArray:(NSMutableArray *)wishlistActionsArray
{
  _wishlistItemsArray = wishlistItemsArray;
  _wishlistActionsArray = wishlistActionsArray;
  NSLog([NSString stringWithFormat:@"wishlistActionsArray %@", wishlistActionsArray]);
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
  NSLog([NSString stringWithFormat:@"wishlistItemArray when creating cells: %@", _wishlistItemsArray]);
  
  // Return the cell populated with the wishlist items
  return [cell populateFromItem:wishlistItem];
  
  return cell;
}

// Removes an item from _allWishListItems and from the user's OG action history on Facebook
- (void)removeWishlistItemWithIndexPath:(NSIndexPath *)indexPath fromTable:(UITableView *)tableView
{
  
  NSLog(@"removeWishlistItem");
  // TO DO: remove the item from the wishlist, to do this we need to remove the OG action connected with that OG object on Facebook
  // Obtain the FBID of the OG object associated with the item
  Item *item = [_wishlistItemsArray objectAtIndex:[indexPath row]];
  NSString *productId = [item itemFBID];
  NSLog([NSString stringWithFormat:@"product id %@", productId]);
  // Find the FBID of the OG action connected with that OG Object
  __block BOOL actionDeleted = NO;
  for (id action in _wishlistActionsArray) {
    if ([[NSString stringWithFormat:@"%@", [[[action objectForKey:@"data"] objectForKey:@"product"] objectForKey:@"id"]] isEqualToString:productId]) {
      NSLog(@"found an item to delete");
      //Make an HTTP DELETE request with the OG action's FBID
      [FBRequestConnection startForDeleteObject:[action objectForKey:@"id"]
                     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"finished request");
        if (error) {
          NSString *alertText;
          NSString *alertTitle;
          if (error.fberrorShouldNotifyUser == YES){
            // Error requires people using an app to make an out-of-band action to recover
            alertTitle = @"Something went wrong :S";
            alertText = [NSString stringWithString:error.fberrorUserMessage];
            [self showMessage:alertText withTitle:alertTitle];
          } else {
            NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];            
            // Show the user an error message
            alertTitle = @"Something went wrong #1";
            alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            [self showMessage:alertText withTitle:alertTitle];
          }
        } else {
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
       
 - (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
  [[[UIAlertView alloc] initWithTitle:title
                              message:text
                             delegate:self
                    cancelButtonTitle:@"OK!"
                    otherButtonTitles:nil] show];
}
    
@end
