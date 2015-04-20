//
//  SPAPIManager.h
//  FocusCalling
//
//  Created by Allen Wu on 5/5/14.
//  Copyright (c) 2014 Originate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@class SPUser;

@interface SPAPIManager : AFHTTPRequestOperationManager

+ (SPAPIManager *)sharedManager;

// REST helper methods

- (void)sp_GET:(NSString *)path
    parameters:(id)parameters
       success:(void (^)(id json))successBlock
       failure:(void (^)(NSString* message))failureBlock
       network:(void (^)(NSError* error))networkBlock;

- (void)sp_POST:(NSString *)path
     parameters:(id)parameters
        success:(void (^)(id json))successBlock
        failure:(void (^)(NSString* message))failureBlock
        network:(void (^)(NSError* error))networkBlock;

- (void)sp_PUT:(NSString *)path
    parameters:(id)parameters
       success:(void (^)(id json))successBlock
       failure:(void (^)(NSString* message))failureBlock
       network:(void (^)(NSError* error))networkBlock;


// API methods
// TODO: rearchitect network layer.. break this class up, approaching "god class"

- (void)tokenForUser:(NSString*)username
        successBlock:(void (^)(NSString *))successBlock
        failureBlock:(void (^)(NSString *))failureBlock
        networkBlock:(void (^)(NSError *))networkBlock;

@end
