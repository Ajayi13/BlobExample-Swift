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
#import <libxml/tree.h>

#define USE_QUEUE	1   // set to 1 to perform requests in order rather than all at once
#define FULL_LOGGING 0  // set to 1 to enable logging of request/response data

typedef void (^xmlBlock)(xmlDocPtr doc, NSError* err);
typedef void (^dataBlock)(NSData* data, NSError* err);
typedef void (^noResponseBlock)(NSError* err);

@interface CloudURLRequest : NSMutableURLRequest {
    noResponseBlock _noResponseBlock;
    xmlBlock _xmlBlock;
    dataBlock _dataBlock;
    long long _expectedContentLength;
	NSMutableData* _data;
#if USE_QUEUE
    CloudURLRequest* _next;
#endif
}

- (void) fetchNoResponseWithBlock:(noResponseBlock)block;
- (void) fetchXMLWithBlock:(xmlBlock)block;
- (void) fetchDataWithBlock:(dataBlock)block;

@end
