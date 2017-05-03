# PayUNonSeamLessIOSIntegration
PayU Non-SeamLess IOS Integration


PAYU Non-SeamLess  Integration in iOS

Prerequisites:
	1	Add libz.tbd libraries into your project (Project->Build Phases->Link Binary With Libraries)
	2	Add -ObjC and $(OTHER_LDFLAGS)in Other Linker Flags in Project Build Settings(Project->Build Settings->Other Linker Flags)
	3	To run the app on iOS9, please add the below code in info.plist NSAppTransportSecurity NSAllowsArbitraryLoads

Steps :

1) Download the PayU SDK and drag drop the PAYU folder into the Xcode project

2) In AppDelegate.h add the below property

@property (weak, nonatomic) UIViewController *paymentOptionVC;

2) Create a button in your View Controller to start payment on its action

3) Initialize the PayUModelPaymentParams with mandatary values in the action selector

Test Environment

Key : gtKFFx
Salt : eCwWELxi

Production Environment

Key : Generate by Logining to PayU Money Portal
Salt : Generate by Logining to PayU Money Portal

Note: Production key and salt can only be used if Account is activated by the merchant with all the details otherwise it may not give proper results

Sample :

	_paymentParam = [[PayUModelPaymentParams alloc] init];
    
    _paymentParam.key = Key;
    _paymentParam.transactionID = [NSString stringWithFormat:@"%ld", arc4random() % 9999999999];
    _paymentParam.amount = @"10";
    _paymentParam.productInfo = @"iPhone";
    _paymentParam.SURL = @"https://payu.herokuapp.com/success";
    _paymentParam.FURL = @"https://payu.herokuapp.com/failure";
    _paymentParam.firstName = @"Pulkit";
    _paymentParam.email = [NSString stringWithFormat:@"pulkitarora%ld@gmail.com", arc4random() % 9999999999];
    
    // Set this property if you want to get the stored cards otherwise set as empty string:

In Production Mode:
    _paymentParam.userCredentials = [NSString stringWithFormat:@"%@:%@", Key, _paymentParam.email];

In Test Mode: 
    _paymentParam.userCredentials = @“ra:ra”;

// Set any user defined values if U want otherwise set as empty string:
    _paymentParam.udf1 = @"";
    _paymentParam.udf2 = @"";
    _paymentParam.udf3 = @"";
    _paymentParam.udf4 = @"";
    _paymentParam.udf5 = @"";

 // Set the environment according to merchant key ENVIRONMENT_PRODUCTION for Production &
    // ENVIRONMENT_TEST for test environment:
    _paymentParam.environment = ENVIRONMENT_MOBILEDEV;
    
    // Set this property if you want to give offer:
    _paymentParam.offerKey = @"";


// Set required hashes

PayUModelHashes *hashes = [PayUModelHashes new];
    
    NSString *hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|||||||||||%@", params.key, params.transactionID, params.amount, params.productInfo, params.firstName, params.email, Salt];
    NSString *hash = [self createSHA512:hashValue]; //Payment Hash
    hashes.paymentHash = hash;
    
    
//    hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"get_merchant_ibibo_codes", @"default", Salt];
//    hash = [self createSHA512:hashValue]; //IBIBO hash
    
    
    hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"vas_for_mobile_sdk", @"default", Salt];
    hash = [self createSHA512:hashValue]; //VAS hash
    hashes.VASForMobileSDKHash = hash;
    
    if(params.userCredentials != nil && ![params.userCredentials  isEqual: @""])
    {
        hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"delete_user_card", params.userCredentials, Salt];
        hash = [self createSHA512:hashValue]; //Delete User Card Hash
        hashes.deleteUserCardHash = hash;
        
        hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"get_user_cards", params.userCredentials, Salt];
        hash = [self createSHA512:hashValue]; //Delete User Card Hash
        hashes.getUserCardHash = hash;
        
        hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"edit_user_card", params.userCredentials, Salt];
        hash = [self createSHA512:hashValue]; //Delete User Card Hash
        hashes.editUserCardHash = hash;
        
        hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"save_user_card", params.userCredentials, Salt];
        hash = [self createSHA512:hashValue]; //Delete User Card Hash
        hashes.saveUserCardHash = hash;
        
        hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@", params.key, @"payment_related_details_for_mobile_sdk", params.userCredentials, Salt];
        hash = [self createSHA512:hashValue]; //Payment Details Hash
        hashes.paymentRelatedDetailsHash = hash;
    }
 
  Note: For Security purpose generate these hashes on Server side and pass it to the client
    
    _paymentParam.hashes = hashes;




// Function to generate SHA512 in Objective - C

-(NSString *)createSHA512:(NSString *)string {
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString* output = [NSMutableString  stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}


4) Add an Observer to Payment Service before initiating the Payment 

[[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(responseReceived:)
     name:kPUUINotiPaymentResponse object:nil];


5) Call the Payment related details for mobile SDK function from PayU SDK with the instance of PayUModelPaymentParams

Sample Code:

PayUWebServiceResponse *webServiceResponse =[[PayUWebServiceResponse alloc]init]; [webServiceResponse getPayUPaymentRelatedDetailForMobileSDK:paymentParam withCompletionBlock:^(PayUModelPaymentRelatedDetail *paymentRelatedDetails, NSString *errorMessage, id extraParam) {
        
        if (!errorMessage) { UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"PUUIMainStoryBoard" bundle:nil]; PUUIPaymentOptionVC * paymentOptionVC = [stryBrd instantiateViewControllerWithIdentifier:VC_IDENTIFIER_PAYMENT_OPTION];
            
            paymentOptionVC.paymentParam = paymentParam;
            paymentOptionVC.paymentRelatedDetail = paymentRelatedDetails;
            
            [self.navigationController pushViewController:paymentOptionVC animated:true];
        } else{
            // error occurred while creating the request
        }
    }];


5) Use this notification for catching the response of the Payment status

-(void)responseReceived:(NSNotification *) notification{
    
    NSString *strConvertedRespone = [NSString stringWithFormat:@"%@",notification.object];
    NSLog(@"Response Received %@",strConvertedRespone);
    
    NSError *serializationError;
    id JSON = [NSJSONSerialization JSONObjectWithData:[strConvertedRespone dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&serializationError];
    if (serializationError == nil && notification.object) {
        NSLog(@"%@",JSON);
		
		// Parse the response and show the user with some success or error message and integrate with the app flow

	}
}
