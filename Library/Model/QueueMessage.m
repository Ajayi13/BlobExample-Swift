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

#import "QueueMessage.h"


@implementation QueueMessage

@synthesize messageId = _messageId;
@synthesize insertionTime = _insertionTime;
@synthesize expirationTime = _expirationTime;
@synthesize popReceipt = _popReceipt;
@synthesize timeNextVisible = _timeNextVisible;
@synthesize messageText = _messageText;

- (id)initQueueMessageWithMessageId:(NSString *)messageId insertionTime:(NSString *)insertionTime expirationTime:(NSString *)expirationTime popReceipt:(NSString *)popReceipt timeNextVisible:(NSString *)timeNextVisible messageText:(NSString *)messageText {
	if ((self = [super init])) {
        _messageId = [messageId retain];
        _insertionTime = [insertionTime retain];
        _expirationTime = [expirationTime retain];
		_popReceipt = [popReceipt retain];
        _timeNextVisible = [timeNextVisible retain];
        self.messageText = messageText;
    }    
    return self;
}


- (NSString*) description {
    return [NSString stringWithFormat:@"QueueMessage { messageId = %@, insertionTime = %@, expirationTime = %@, popReceipt = %@, timeNextVisible = %@, messageText = %@ }", _messageId, _insertionTime, _expirationTime, _popReceipt, _timeNextVisible, _messageText];
}

- (void) dealloc {
	
    self.messageText = nil;
    [_messageId release];
	[_insertionTime release];
	[_expirationTime release];
	[_popReceipt release];
	[_timeNextVisible release];
    [super dealloc];
}



@end
