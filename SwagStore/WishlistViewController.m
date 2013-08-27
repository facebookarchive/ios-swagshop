//
//  WishlistViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/12/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import "WishlistViewController.h"
#import "ItemCell.h"
#import "SettingsViewController.h"

// this is only here for test purposes
#import "DataStore.h"
#import "Item.h"

@interface WishlistViewController ()

@property UIBarButtonItem *editWishlistButton;

@end

@implementation WishlistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      // Set the viewTitle
      UINavigationItem *nI = [self navigationItem];
      [nI setTitle:@"Wishlist"];
      
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
    ItemStore *itemStore = [ItemStore sharedStore];
    NSArray *wishlistItems = [itemStore allWishlistItems];
    Item *wishlistItem = [wishlistItems objectAtIndex:[indexPath row]];
    [itemStore removeWishlistItem:wishlistItem];
    
    // Remove the cell from the table
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
  return [[[ItemStore sharedStore] allWishlistItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  // Get a cell
  ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
  
  // Get the wish list item for the row
  NSArray *wishlistItems = [[ItemStore sharedStore] allWishlistItems];
  Item *wishlistItem = [wishlistItems objectAtIndex:[indexPath row]];
  
  // Return the cell populated with the wishlist items
  return [cell populateFromItem:wishlistItem];
  
  return cell;
}

@end
