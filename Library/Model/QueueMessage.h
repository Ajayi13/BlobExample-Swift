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

/*! QueueMessage is a class used to represent queueMessage within Windows Azure QueueMessage. */
@interface QueueMessage : NSObject

/*! Message Id of the QueueMessage object */
@property (readonly) NSString *messageId;
/*! Insertion Time of the QueueMessage object */
@property (readonly) NSString *insertionTime;
/*! Expiration Time of the QueueMessage object */
@property (readonly) NSString *expirationTime;
/*! Pop Receipt of the QueueMessage object */
@property (readonly) NSString *popReceipt;
/*! Time Next Visible of the QueueMessage object */
@property (readonly) NSString *timeNextVisible;
/*! Message Text of the QueueMessage object */
@property (copy) NSString *messageText;

/*! Intialize a new QueueMessage with the messageId, insertionTime etc. */
- (id)initQueueMessageWithMessageId:(NSString *)messageId insertionTime:(NSString *)insertionTime expirationTime:(NSString *)expirationTime popReceipt:(NSString *)popReceipt timeNextVisible:(NSString *)timeNextVisible messageText:(NSString *)messageText;

@end
