//
//  AppDelegate.h
//  InAppPurchaseDemo
//
//  Created by Pradeep Kumar Yadav on 27/05/15.
//  Copyright (c) 2015 Pradeep Kumar Yadav. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface InAppPurchaseHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSString *productIdentifier;
}

@property (nonatomic, retain) NSMutableArray *restoredProducts;


/**
 *  This function is used to get singelton object of this class.
 *
 *  @return shared instance of the class
 */
+ (InAppPurchaseHelper *)sharedManager;

/**
 *  This function is used for request for product and purchase it.
 *
 *  @param productID Product Identifier
 *  @param callback  It returns callback with message and status. Status can be 0 or 1 according to success or fail for In App Purchase.
 */
- (void)requestForProduct:(NSString*)productID callback:(void(^)(NSDictionary *responseDic))callback;

/**
 *  This method is used to restore the transactions
 */
- (void)restoreCompletedTransactions;

@end
