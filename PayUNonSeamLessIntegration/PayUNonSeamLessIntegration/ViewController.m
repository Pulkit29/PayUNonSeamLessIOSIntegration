//
//  ViewController.m
//  PayUNonSeamLessIntegration
//
//  Created by pulkitarora on 5/1/17.
//  Copyright © 2017 pulkitarora. All rights reserved.
//




#define Test 1

#define Key  Test? @"gtKFFx" : @"gtKFFx"
#define Salt Test? @"eCwWELxi" : @"eCwWELxi"

#import "ViewController.h"
#import "PUUIPaymentOptionVC.h"
#import <CommonCrypto/CommonDigest.h>


@interface ViewController ()
@property (nonatomic, strong) PayUModelPaymentParams *paymentParam;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)paymentButtonPressed:(id)sender{
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(responseReceived:)
     name:kPUUINotiPaymentResponse object:nil];

    
    _paymentParam = [[PayUModelPaymentParams alloc] init];
    
    _paymentParam.key = Key;
    _paymentParam.transactionID = [NSString stringWithFormat:@"%ld", arc4random() % 9999999999];
    _paymentParam.amount = @"10";
    _paymentParam.productInfo = @"iPhone";
    _paymentParam.SURL = @"https://payu.herokuapp.com/success";
    _paymentParam.FURL = @"https://payu.herokuapp.com/failure";
    _paymentParam.firstName = @"Pulkit";
    _paymentParam.email = [NSString stringWithFormat:@"pulkitarora%ld@gmail.com", arc4random() % 9999999999];
    
    // Set this property if you want to get the stored cards:
    _paymentParam.userCredentials = [NSString stringWithFormat:@"%@:%@", Key, _paymentParam.email];
    
    _paymentParam.udf1 = @"";
    _paymentParam.udf2 = @"";
    _paymentParam.udf3 = @"";
    _paymentParam.udf4 = @"";
    _paymentParam.udf5 = @"";

    [self setPaymentRelatedDetailsForMobileSdkHash:_paymentParam];

    
    // Set the environment according to merchant key ENVIRONMENT_PRODUCTION for Production &
    // ENVIRONMENT_TEST for test environment:
    _paymentParam.environment =  Test ? ENVIRONMENT_MOBILEDEV : ENVIRONMENT_PRODUCTION;
    
    // Set this property if you want to give offer:
    _paymentParam.offerKey = @"";
    
    if (!Test){
        [self getPaymentDetails : _paymentParam];
    }
    
}

-(void)callSDKWithHashes:(PayUModelHashes *) allHashes withError:(NSString *) errorMessage{
    if (errorMessage == nil) {
        _paymentParam.hashes = allHashes;
    }
//    [defaultActivityIndicator stopAnimatingActivityIndicator];
    [self getPaymentDetails:_paymentParam];
}


- (void)setPaymentRelatedDetailsForMobileSdkHash : (PayUModelPaymentParams*)params{
    
    PayUModelHashes *hashes = [PayUModelHashes new];// Set the hashes here
    
    NSString *hashValue = [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|||||||||||%@", params.key, params.transactionID, params.amount, params.productInfo, params.firstName, params.email, Salt];
    NSString *hash = [self createSHA512:hashValue]; //Payment Hash
    hashes.paymentHash = hash;
    
    
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
    
    
    params.hashes = hashes;
    
}

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

- (void)getPaymentDetails : (PayUModelPaymentParams *)paymentParam{
    PayUWebServiceResponse *webServiceResponse =[[PayUWebServiceResponse alloc]init]; [webServiceResponse getPayUPaymentRelatedDetailForMobileSDK:paymentParam withCompletionBlock:^(PayUModelPaymentRelatedDetail *paymentRelatedDetails, NSString *errorMessage, id extraParam) {
        
        if (!errorMessage) { UIStoryboard *stryBrd = [UIStoryboard storyboardWithName:@"PUUIMainStoryBoard" bundle:nil]; PUUIPaymentOptionVC * paymentOptionVC = [stryBrd instantiateViewControllerWithIdentifier:VC_IDENTIFIER_PAYMENT_OPTION];
            
            paymentOptionVC.paymentParam = paymentParam;
            paymentOptionVC.paymentRelatedDetail = paymentRelatedDetails;
            
            [self.navigationController pushViewController:paymentOptionVC animated:true];
        } else{
            // error occurred while creating the request
        }
    }];
}

#pragma mark Payment notification

-(void)responseReceived:(NSNotification *) notification{
    
    NSString *strConvertedRespone = [NSString stringWithFormat:@"%@",notification.object];
    NSLog(@"Response Received %@",strConvertedRespone);
    
    NSError *serializationError;
    id JSON = [NSJSONSerialization JSONObjectWithData:[strConvertedRespone dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&serializationError];
    if (serializationError == nil && notification.object) {
        NSLog(@"%@",JSON);
        NSLog(@"%@  %@", [JSON objectForKey:@"status"], strConvertedRespone);
        if ([[JSON objectForKey:@"status"] isEqual:@"success"]) {
            NSString *merchant_hash = [JSON objectForKey:@"merchant_hash"];
            if ([[JSON objectForKey:@"card_token"] length] >1 && merchant_hash.length >1 && self.paymentParam) {
                NSLog(@"Saving merchant hash----> to verify the hash for security purpose using inverse hash calculation");
            }
        }
    }
    else{
        NSLog(@"Response : %@", strConvertedRespone);
    }
}

@end
