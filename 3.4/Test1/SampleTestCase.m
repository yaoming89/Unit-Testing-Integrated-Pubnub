#import <GHUnitIOS/GHUnit.h>
#import <OCMock/OCMock.h>
#import <CoreLocation/CoreLocation.h>

#import "PNDataManager.h"
#import "PNMacro.h"

#import "PNPresenceEvent.h"
#import "PNMessage.h"

#import "TestSemaphor.h"

@interface SampleLibTest : GHTestCase { }
@end

@implementation SampleLibTest

#pragma mark - Testing
//- (void)testSimpleFail {
//    GHAssertTrue(NO, nil);
//}
/*
- (void)testSimplePass {
    // Another test
}

- (void)testSimpleFail {
    GHAssertTrue(NO, nil);
}

// simple test to ensure building, linking, and running test case works in the project
- (void)testOCMockPass {
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"mocktest", returnValue, @"Should have returned the expected string.");
}

- (void)testOCMockFail {
    id mock = [OCMockObject mockForClass:NSString.class];
    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
    
    NSString *returnValue = [mock lowercaseString];
    GHAssertEqualObjects(@"thisIsTheWrongValueToCheck", returnValue, @"Should have returned the expected string.");
}
 */

#pragma mark - Connection Testing
#pragma mark - Instance methods

-(NSString*)generateRandomIdentifier{
    
    int userDefinedLength = arc4random() % 100;
    NSMutableString *output = [[NSMutableString alloc] init];
    while ([output length] < userDefinedLength)
    {
        //Generates a random character between a and z;
        char c = ((arc4random() % (122 - 96)) + 97);
        [output appendFormat:@"%c", c];
    }
    
    
    return output;
}


-(void)testClientIdentifier{
    id mock = [OCMockObject mockForClass:PubNub.class];
    
    NSString *clientIdentifier = [self generateRandomIdentifier];
    [[[mock stub] andReturn:clientIdentifier] clientIdentifier];
    
    NSString *returnValue = [mock clientIdentifier];
    GHAssertEqualObjects(clientIdentifier, returnValue, @"Should have returned the expected string.");

}

-(void)testSetConfiguration{
    id mockPubNub = [OCMockObject mockForClass:PubNub.class];
    
    [[mockPubNub stub] setConfiguration:[OCMArg any]];
    
//    [mockPubNub verify];
    
    
    mockPubNub = nil;
    
}
- (void)_testFunctionWithHandler
{
    CLGeocoder* gc = [[CLGeocoder alloc] init];
    [gc geocodeAddressString:@"Dandong China"
           completionHandler:^(NSArray *placemarks, NSError *error) {
               NSLog(@"get data : %@", placemarks);

               if (placemarks) {
                   GHAssertTrueNoThrow(YES, nil);
               }
               else{
                   GHAssertTrueNoThrow(NO, nil);
               }

               [[TestSemaphor sharedInstance] lift:@"geocode"];
           }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"geocode"];
}

-(void)testConnection{
    
    
    // Update PubNub client configuration
    
    [PubNub setConfiguration:[PNDataManager sharedInstance].configuration];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
                            GHAssertTrueNoThrow(YES, @"Connection is successfully established.");
                            [[TestSemaphor sharedInstance] lift:@"connection"];
                        }
    
            errorBlock:^(PNError *connectionError) {
                             GHAssertTrue(NO, [NSString stringWithFormat:@"Connection to '%@' failed because of error: %@",
                                               [PNDataManager sharedInstance].configuration.origin,
                                               connectionError]);
                
                             
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 GHAssertTrue(NO, @"Connection will be established as soon as internet connection will be restored");
                             }
                
                            [[TestSemaphor sharedInstance] lift:@"connection"];
                         }];
    
    [[TestSemaphor sharedInstance] waitForKey:@"connection"];
    
    
}

@end