//
//  ItemsListViewController.m
//  SwagStore
//
//  Created by Luz Caballero on 8/5/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "ItemListViewController.h"
#import "DataStore.h"
#import "Item.h"
#import "ItemDetailViewController.h"
#import "SettingsViewController.h"
#import "ItemCell.h"
#import "DetailPageViewController.h"

/* A list view controller that displays all the items/products in the shop. This view has a nav bar button on the top right that changes with session state and reads "Log in" when logged out and "Account" when logged in. In both cases this button takes the user to the SettingsViewController. Tapping on the cells takes the user to a detailed view of the item in the cell (an `ItemDetailViewController` inside a `DetailPageViewController`). */

@implementation ItemListViewController

- (instancetype)init
{
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    // Set the viewTitle
    UINavigationItem *nI = [self navigationItem];
    [nI setTitle:@"Swag Store"];
    
    // Create the button that will go to the account settings
    NSString *accountSettingsButtonTitle;
    if (FBSession.activeSession.isOpen) {
      accountSettingsButtonTitle = @"Account";
    } else {
      accountSettingsButtonTitle = @"Log in";
    }
    [self setAccountSettingsButtonWithTitle:accountSettingsButtonTitle];
    
  }
  return self;
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  // Load the cell nib file and register it for reuse
  UINib *nib = [UINib nibWithNibName:@"ItemCell" bundle:nil];
  [[self tableView] registerNib:nib forCellReuseIdentifier:@"ItemCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [[[ItemStore sharedStore] allItems] count];
}

- (ItemCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Get a cell
  ItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
  
  //Set the content of the cell and return the populated cell
  NSArray *items = [[ItemStore sharedStore] allItems];
  Item *item = [items objectAtIndex:[indexPath row]];
  
  return [cell populateFromItem:item];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Create a detailPageViewController and point it to the page containing the selected item
  DetailPageViewController *detailPageViewController = [[DetailPageViewController alloc]
                                                        initWithPage:[indexPath row]];
  
  // Push the detailPageViewController to the navigationController
  [[self navigationController] pushViewController:detailPageViewController animated:YES];

}

- (IBAction)goToAccountSettings:(id)sender
{
  SettingsViewController *settingsViewController =[[SettingsViewController alloc] init];
  [[self navigationController] pushViewController:settingsViewController animated:YES];

}

// Set the button that will go to the account settings
- (void)setAccountSettingsButtonWithTitle:(NSString *)title
{
  UIBarButtonItem *accountButton = [[UIBarButtonItem alloc]
                                    initWithTitle: title
                                    style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(goToAccountSettings:)];
  [[self navigationItem] setRightBarButtonItem:accountButton];

}

@end
