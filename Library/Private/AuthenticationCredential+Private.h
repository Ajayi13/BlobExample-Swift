/*
 Copyright 2010 Microsoft Corp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "AuthenticationCredential.h"
#import "CloudURLRequest.h"

@interface AuthenticationCredential (Private)

- (NSURL*)URLforEndpoint:(NSString *)endpoint forStorageType:(NSString *)storageType;
- (CloudURLRequest *)authenticatedRequestWithEndpoint:(NSString *)endpoint forStorageType:(NSString *)storageType, ... NS_REQUIRES_NIL_TERMINATION;
- (CloudURLRequest *)authenticatedRequestWithEndpoint:(NSString *)endpoint forStorageType:(NSString *)storageType httpMethod:(NSString*)httpMethod, ... NS_REQUIRES_NIL_TERMINATION;
- (CloudURLRequest *)authenticatedRequestWithEndpoint:(NSString *)endpoint forStorageType:(NSString *)storageType httpMethod:(NSString*)httpMethod contentData:(NSData *)contentData contentType:(NSString*)contentType, ... NS_REQUIRES_NIL_TERMINATION;

- (CloudURLRequest *)authenticatedBlobRequestWithURL:(NSURL *)serviceURL forStorageType:(NSString *)storageType, ... NS_REQUIRES_NIL_TERMINATION;
- (CloudURLRequest *)authenticatedBlobRequestWithURL:(NSURL *)serviceURL forStorageType:(NSString *)storageType httpMethod:(NSString*)httpMethod, ... NS_REQUIRES_NIL_TERMINATION;
- (CloudURLRequest *)authenticatedBlobRequestWithURL:(NSURL *)serviceURL forStorageType:(NSString *)storageType httpMethod:(NSString*)httpMethod contentData:(NSData *)contentData contentType:(NSString*)contentType, ... NS_REQUIRES_NIL_TERMINATION;

@end