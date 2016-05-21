//
//  AppDelegate.h
//  InAppPurchaseDemo
//
//  Created by Pradeep Kumar Yadav on 27/05/15.
//  Copyright (c) 2015 Pradeep Kumar Yadav. All rights reserved.
//

#import "InAppPurchaseHelper.h"

@interface InAppPurchaseHelper()
{
  
}

@property (nonatomic, copy) void (^callback)(NSDictionary *responseDic);

@end

static InAppPurchaseHelper *sharedInstance;

@implementation InAppPurchaseHelper
{

}

#pragma mark - Public Methods

+ (InAppPurchaseHelper *)sharedManager
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[InAppPurchaseHelper alloc] init];
  });
  return sharedInstance;
}

- (void)requestForProduct:(NSString*)productID callback:(void(^)(NSDictionary *responseDic))callback
{
  self.callback = callback;
  productIdentifier = productID;
  NSArray *transactions = [[SKPaymentQueue defaultQueue] transactions];
  for(id transaction in transactions)
  {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  }
  
  if ([SKPaymentQueue canMakePayments])
  {
    NSArray *arrayProducts = [NSArray arrayWithObjects:productID, nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:arrayProducts]];
    productsRequest.delegate = self;
    [productsRequest start];
    
  }else
  {
    self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"You are restricted to purchase.",@"Message",@"0",@"Success",nil]);
  }
}

- (void)restoreCompletedTransactions
{
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductRequest Delegate Methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
  NSArray *products = response.products;

  if ([products count] > 0)
  {
    BOOL isExists = FALSE;
    for (SKProduct *product in products)
    {
      NSLog(@"  Available %@ - %@ - %@ - %@", product.productIdentifier, product.localizedTitle, product.localizedDescription, product.price);
      
      if ([product.productIdentifier isEqualToString:productIdentifier])
      {
        isExists = TRUE;
          [self purchaseProduct:product];
        break;
      }
      
    }
    if (!isExists)
    {
      self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"No product available.",@"Message",@"0",@"Success",nil]);
      
    }
  }
  else
  {
     self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"No product available.",@"Message",@"0",@"Success",nil]);
  }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
  NSLog(@"Error! %@",error);
 self.callback([NSDictionary dictionaryWithObjectsAndKeys:error.localizedDescription,@"Message",@"0",@"Success",nil]);
}

#pragma mark - SKTransaction Observer Delegate Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
      {
        if ([self verifyReceipt])
        {
          [self completeTransaction:transaction];
        }
        else
          [self failedVerifyReceipt:transaction];
      }
        break;
  
      case SKPaymentTransactionStateFailed:
        
        [self failedTransaction:transaction];
        
        break;
        
      case SKPaymentTransactionStateRestored:
        
        [self restoreTransaction:transaction];
        
        break;
      default:
        
        break;
    }
  }
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    self.restoredProducts = [[NSMutableArray alloc] init];
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [self.restoredProducts addObject:productID];
    }
}



#pragma mark - Private Methods

/**
 *  This function is used to purchase a product.
 *
 *  @param product SKProduct object which got from the SKProductRequest Delegate
 */
-(void)purchaseProduct:(SKProduct*)product
{
  if ([SKPaymentQueue canMakePayments])
  {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  else
  {
    self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"You are not authorized to purchase from AppStore.",@"Message",@"0",@"Success",nil]);
  }
}

/**
 *  This method is called when transaction will be completed.
 *
 *  @param transaction SKPaymentTransaction state
 */
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"Purchase completed.",@"Message",@"1",@"Success",nil]);
}

/**
 *  This method is called when transaction will not be completed successfully.
 *
 *  @param transaction SKPaymentTransaction state
 */
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"Transaction Failed!",@"Message",@"0",@"Success",nil]);
  }
  else
  {
      self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"Transaction Cancelled",@"Message",@"0",@"Success",nil]);
  }
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

/**
 *  This method is called when receipt verification will be failed.
 *
 *  @param transaction SKPaymentTransaction state
 */
- (void)failedVerifyReceipt:(SKPaymentTransaction *)transaction
{
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"Verify receipt failed.",@"Message",@"0",@"Success",nil]);
}

/**
 *  This method is called when transaction will restore successfully.
 *
 *  @param transaction SKPaymentTransaction state
 */
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
   self.callback([NSDictionary dictionaryWithObjectsAndKeys:@"Transaction restore successfully.",@"Message",@"1",@"Success",nil]);
}

/**
 *  This method is used to verify the receipt
 *
 *  @return Yes if receipt is valid otherwise return No
 */
- (BOOL)verifyReceipt
{
  NSURL *receiptFileURL = [[NSBundle mainBundle] appStoreReceiptURL];
  NSData *receiptData = [NSData dataWithContentsOfURL:receiptFileURL];
  NSString *recieptString = [receiptData base64EncodedStringWithOptions:kNilOptions];
  NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:recieptString,@"receipt-data",@"827d5be5c5944b3db18bbb0278c3e8bd",@"password", nil];
  NSError *error;
  NSData *requestData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                        options:0
                                                          error:&error];
  if (requestData)
  {
    //NSURL *url =[NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
    NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:requestData];
    
    NSURLResponse *response;
    NSData* result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:&error];
    
    if(jsonResponse)
    {
      int status = [[jsonResponse objectForKey:@"status"] intValue];
      if(status == 0)
      {
        NSDictionary *dicReceipt = [jsonResponse objectForKey:@"receipt"];
        NSLog(@"Receipt Information - %@ ", dicReceipt);
        return YES;
      }
      else
        return NO;
    }
    else
      return NO;
  }
  else
    return NO;
}

@end
