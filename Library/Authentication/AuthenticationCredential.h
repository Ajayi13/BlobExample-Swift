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

#define FULL_LOGGING 0

/*! When used with the proxy service, the authentication delegate returns indication whether the login was successful. */
@protocol AuthenticationDelegate
- (void)loginDidSucceed;
- (void)loginDidFailWithError:(NSError *)error;
@end

/*! The AuthenticationCredential class is used to create an authentication object that can be passed to the CloudStorageClient.  This class can be initialized using a Windows Azure account name and key, or with a proxy server URL, username, and password. */
@interface AuthenticationCredential : NSObject <NSXMLParserDelegate>
{
	BOOL					_usesProxy;
	BOOL					_loggedIn;
	NSError					*_authError;
	NSURL					*_proxyURL;
	NSString				*_token;
	NSString				*_accountName;
	NSString				*_accessKey;
	NSString				*_username;
	NSString				*_password;
	NSString				*_tableServiceURL;
	NSString				*_blobServiceURL;
}

/*! Boolean value indicating whether this authentication credential uses the proxy service. */
@property (readonly) BOOL usesProxy;
/*! URL of the proxy service. */
@property (nonatomic, readonly) NSURL *proxyURL;
/*! Session token returns from authentication with the proxy service. */
@property (nonatomic, readonly) NSString *token;

/*! Account name, if used directly against the Windows Azure blob/table storage.*/
@property (nonatomic, readonly) NSString *accountName;
/*! Access key, if used directly against the Windows Azure blob/table storage */
@property (nonatomic, readonly) NSString *accessKey;

/*! URL of the table service endpoint, if used with the proxy service */
@property (nonatomic, readonly) NSString *tableServiceURL;
/*! URL of the blob service endpoint, if used with the proxy service */
@property (nonatomic, readonly) NSString *blobServiceURL;

/*! Initialize a new instance of credentials with a Windows Azure account name and access key, obtained from the portal. */
+ (AuthenticationCredential *)credentialWithAzureServiceAccount:(NSString*)accountName accessKey:(NSString*)accessKey;

/*! Initialize a new instance of credentials using a proxy URL, supplying the username and password.*/
+ (AuthenticationCredential *)authenticateCredentialSynchronousWithProxyURL:(NSURL *)proxyURL user:(NSString *)user password:(NSString *)password error:(NSError **)returnError;
/*! Initialize a new instance of credentials using a proxy URL, supplying the username and password, and explictly supplying the URLs for the table and blob storage endpoints.*/
+ (AuthenticationCredential *)authenticateCredentialSynchronousWithProxyURL:(NSURL *)proxyURL tableServiceURL:(NSURL *)tablesURL blobServiceURL:(NSURL *)blobsURL user:(NSString *)user password:(NSString *)password error:(NSError **)returnError;
/*! Initialize a new instance of credentials using a proxy URL, supplying the username and password.*/
+ (AuthenticationCredential *)authenticateCredentialWithProxyURL:(NSURL *)proxyURL user:(NSString *)user password:(NSString *)password delegate:(id<AuthenticationDelegate>)delegate;
/*! Initialize a new instance of credentials using a proxy URL, supplying the username and password.*/
+ (AuthenticationCredential *)authenticateCredentialWithProxyURL:(NSURL *)proxyURL user:(NSString *)user password:(NSString *)password withBlock:(void (^)(NSError*))block;

@end
