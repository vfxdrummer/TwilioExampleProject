//
//  SPAPIManager.m
//  FocusCalling
//
//  Created by Allen Wu on 5/5/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import "SPAPIManager.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"

@implementation SPAPIManager

+ (SPAPIManager *)sharedManager {
  static SPAPIManager* sharedManager = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedManager = [[SPAPIManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.parse.com/1/functions/"]];
    [sharedManager.requestSerializer setValue:@"XPoFsoLDCNlJ7NzwYu10wn7jpNQ5SGAqbLXggVYE" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [sharedManager.requestSerializer setValue:@"tjrXRbKQo4tb4xvzcZP3wxb9nheWrw73dTrttsbj" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
  });
  
  return sharedManager;
}

// TODO: verify block existence
// TODO: refactor - split class up
// TODO: refactor - include auth token automatically

// TODO: encapsulate an instance of AFNetworking rather than subclass
// TODO: did this once already, but it might be a good idea to revert back to it:
//       write a single method that takes the HTTP Method as a parameter, so
//       we dont need 4+ nearly identical implementations of sp_GET/sp_POST/...
#pragma mark - REST helper methods

// Automatically handle error response in JSON and forward to the proper callbacks
// i.e. all `successBlock` need to handle the case where the server returns JSON with
// an error message. This will be forwarded to the `failureBlock`. Only actual successes
// will call `successBlock`.

- (void)sp_GET:(NSString *)path
    parameters:(id)parameters
       success:(void (^)(id json))successBlock
       failure:(void (^)(NSString* message))failureBlock
       network:(void (^)(NSError* error))networkBlock
{
  [self GET:path
 parameters:parameters
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
      // dictionary at root
      if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSString* errorMessage = [responseObject valueForKey:@"error"];
        if (errorMessage) {
          if (failureBlock) {
            failureBlock(errorMessage);
          }
        }
        else {
          if (successBlock) {
            successBlock(responseObject);
          }
        }
      }
      // array at root
      else {
        if (successBlock) {
          successBlock(responseObject);
        }
      }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (networkBlock) {
        networkBlock(error);
      }
  }];
}

- (void)sp_POST:(NSString *)path
     parameters:(id)parameters
        success:(void (^)(id json))successBlock
        failure:(void (^)(NSString* message))failureBlock
        network:(void (^)(NSError* error))networkBlock
{
  [self POST:path
  parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // dictionary at root
       if ([responseObject isKindOfClass:[NSDictionary class]]) {
         NSString* errorMessage = [responseObject valueForKey:@"error"];
         if (errorMessage) {
           if (failureBlock) {
             failureBlock(errorMessage);
           }
         }
         else {
           if (successBlock) {
             successBlock(responseObject);
           }
         }
       }
       // array at root
       else {
         if (successBlock) {
           successBlock(responseObject);
         }
       }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       if (networkBlock) {
         networkBlock(error);
       }
    }];
}

- (void)sp_PUT:(NSString *)path
    parameters:(id)parameters
       success:(void (^)(id json))successBlock
       failure:(void (^)(NSString* message))failureBlock
       network:(void (^)(NSError* error))networkBlock
{
  [self PUT:path
 parameters:parameters
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
      // dictionary at root
      if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSString* errorMessage = [responseObject valueForKey:@"error"];
        if (errorMessage) {
          if (failureBlock) {
            failureBlock(errorMessage);
          }
        }
        else {
          if (successBlock) {
            successBlock(responseObject);
          }
        }
      }
      // array at root
      else {
        if (successBlock) {
          successBlock(responseObject);
        }
      }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      if (networkBlock) {
        networkBlock(error);
      }
    }];
}


#pragma mark - API methods

//curl -X POST \
//-H "X-Parse-Application-Id: XPoFsoLDCNlJ7NzwYu10wn7jpNQ5SGAqbLXggVYE" \
//-H "X-Parse-REST-API-Key: tjrXRbKQo4tb4xvzcZP3wxb9nheWrw73dTrttsbj" \
//-H "Content-Type: application/json" \
//-d '{}' \
//https://api.parse.com/1/functions/token

- (void)tokenForUser:(NSString*)username
      successBlock:(void (^)(NSString *))successBlock
      failureBlock:(void (^)(NSString *))failureBlock
      networkBlock:(void (^)(NSError *))networkBlock
{
  [self sp_POST:@"token"
    parameters:@{@"client"   : username}
       success:^(id json) {
         NSString* token = json[@"result"];
         
         successBlock(token);
       }
       failure:failureBlock
       network:networkBlock];
}

@end
