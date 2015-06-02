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

#import "QueueMessageParser.h"
#import "QueueMessage.h"
#import "XmlHelper.h"

@implementation QueueMessageParser

+ (NSArray *)loadQueueMessages:(xmlDocPtr)doc {
    
    if (doc == nil) 
    { 
		return nil; 
	}
	
    NSMutableArray *queueMessages = [NSMutableArray arrayWithCapacity:30];
    
    [XmlHelper performXPath:@"/QueueMessagesList/QueueMessage" 
                 onDocument:doc 
                      block:^(xmlNodePtr node)
     {
         NSString *messageId = [XmlHelper getElementValue:node name:@"MessageId"];
         NSString *insertionTime = [XmlHelper getElementValue:node name:@"InsertionTime"];
         NSString *expirationTime = [XmlHelper getElementValue:node name:@"ExpirationTime"];
         NSString *popReceipt = [XmlHelper getElementValue:node name:@"PopReceipt"];
         NSString *timeNextVisible = [XmlHelper getElementValue:node name:@"TimeNextVisible"];
         NSString *messageText = [XmlHelper getElementValue:node name:@"MessageText"];
         
         QueueMessage *queueMessage = [[QueueMessage alloc] initQueueMessageWithMessageId:messageId insertionTime:insertionTime expirationTime:expirationTime popReceipt:popReceipt timeNextVisible:timeNextVisible messageText:messageText];
         [queueMessages addObject:queueMessage];
         [queueMessage release];
     }];
    
    return [[queueMessages copy] autorelease];
}

@end
