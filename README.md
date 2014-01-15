ios-swagshop
============

Facebook SDK for iOS sample application (for iOS 7) for the e-commerce vertical, demonstrating:

* Login with Facebook
* Retrieving and using a person's name and profile picture
* Publishing custom stories to Facebook
* Making stories link back to the app
* Requesting the user's past Swag Shop actions
* Deleting a story from Facebook
* Logging events that happen inside the app

Swag Shop is a sample application that allows users to save Facebook-brand items to a wishlist. Swag Shop implements some of the iOS SDK features that e-commerce apps can benefit from.

Swag Shop allows people to log in with Facebook, and when users are logged in it uses their name and profile picture to personalize their experience. 

People can browse the Facebook products using a list and detail views. When people save a product to their wishlist, it publishes a story to Facebook.

Swag Shop implements deep linking. As a result, when the user's friends engage with these stories on the Facebook for iOS app, they are directed to the Swag Shop app in their iOS devices. If the user's friends don't have Swag Shop installed, they are directed to the Swag Shop App Store page where they can download the app.

Users can also view their wishlist. Making a call to the Graph API, Swag Shop retrieves all the user's saved products from the Facebook graph, to show the user their current saved products. Swag shop also allows users to delete a product from their wishlist, and removes the corresponding Facebook post.

Finally, Swag Shop implements App Events to log when a product is viewed or added to someone's wishlist.

The [Swag Shop tutorial](https://developers.facebook.com/docs/ios/swagshop/) on the [Facebook developer website](http://developers.facebook.com/) walks you through this sample.
