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

#import "CloudStorageClient.h"
#import "CloudURLRequest.h"
#import "ContainerParser.h"
#import "BlobParser.h"
#import "Blob.h"
#import "CommonCrypto/CommonHMAC.h"
#import "AuthenticationCredential+Private.h"
#import "NSString+URLEncode.h"
#import "XmlHelper.h"
#import "TableEntity.h"
#import "QueueParser.h"
#import "QueueMessageParser.h"

static NSString *CREATE_TABLE_REQUEST_STRING = @"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?><entry xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://www.w3.org/2005/Atom\"><title /><updated>$UPDATEDDATE$</updated><author><name/></author><id/><content type=\"application/xml\"><m:properties><d:TableName>$TABLENAME$</d:TableName></m:properties></content></entry>";
static NSString *TABLE_INSERT_ENTITY_REQUEST_STRING = @"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?><entry xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://www.w3.org/2005/Atom\"><title /><updated>$UPDATEDDATE$</updated><author><name /></author><id /><content type=\"application/xml\"><m:properties>$PROPERTIES$</m:properties></content></entry>";
static NSString *TABLE_UPDATE_ENTITY_REQUEST_STRING = @"<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\"?><entry xmlns:d=\"http://schemas.microsoft.com/ado/2007/08/dataservices\" xmlns:m=\"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata\" xmlns=\"http://www.w3.org/2005/Atom\"><title /><updated>$UPDATEDDATE$</updated><author><name /></author><id>$ENTITYID$</id><content type=\"application/xml\"><m:properties>$PROPERTIES$</m:properties></content></entry>";

@interface CloudStorageClient (Private)
- (void)privateGetQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount useBlockError:(BOOL)useBlockError peekOnly:(BOOL)peekOnly withBlock:(void (^)(NSArray *, NSError *))block;
@end

@interface TableEntity (Private)

- (id)initWithDictionary:(NSMutableDictionary*)dictionary fromTable:(NSString*)tableName;
- (NSString*)propertyString;
- (NSString*)endpoint;

@end

@interface TableFetchRequest (Private)

- (NSString*)endpoint;

@end

@implementation CloudStorageClient

@synthesize delegate = _delegate;

#pragma mark Creation

- (id)initWithCredential:(AuthenticationCredential*)credential
{
	if((self = [super init]))
	{
		_credential = [credential retain];
	}
	
	return self;
}

+ (CloudStorageClient*) storageClientWithCredential:(AuthenticationCredential*)credential
{
	return [[[self alloc] initWithCredential:credential] autorelease];
}

- (void)prepareTableRequest:(CloudURLRequest*)request
{
    [request setValue:@"2.0;NetFx" forHTTPHeaderField:@"MaxDataServiceVersion"];
    [request setValue:@"application/atom+xml,application/xml" forHTTPHeaderField:@"Accept"];
    [request setValue:@"NativeHost" forHTTPHeaderField:@"User-Agent"];
}

#pragma mark -
#pragma mark Queue API methods

- (void)getQueues
{
    [self getQueuesWithBlock:nil];
}

- (void)getQueuesWithBlock:(void (^)(NSArray*, NSError *))block
{
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:@"?comp=list" forStorageType:@"queue", nil];
    
    [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(nil, error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         NSArray* queues = [QueueParser loadQueues:doc];
         
         if(block)
         {
             block(queues, nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetQueues:)])
         {
             [_delegate storageClient:self didGetQueues:queues];
         }
     }];
    
}


- (void)addQueue:(NSString *)queueName
{
    
    [self addQueue:queueName withBlock:nil];
}

- (void)addQueue:(NSString *)queueName withBlock:(void (^)(NSError *))block
{
    
    queueName = [queueName lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@", [queueName URLEncode]];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"queue" httpMethod:@"PUT", nil];
    
	[request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didAddQueue:)])
         {
             [_delegate storageClient:self didAddQueue:queueName];
         }
     }];
}

- (void)deleteQueue:(NSString *)queueName
{
    
    [self deleteQueue:queueName withBlock:nil];
}

- (void)deleteQueue:(NSString *)queueName withBlock:(void (^)(NSError *))block
{
    
    queueName = [queueName lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@", [queueName URLEncode]];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"queue" httpMethod:@"DELETE", nil];
    
	[request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didDeleteQueue:)])
         {
             [_delegate storageClient:self didDeleteQueue:queueName];
         }
     }];

}

- (void)getQueueMessage:(NSString *)queueName
{
	[self privateGetQueueMessages:queueName fetchCount:1 useBlockError:NO peekOnly:NO withBlock:^(NSArray* items, NSError* error) 
	 {
		 if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetQueueMessage:)])
		 {
			 return;
		 }
		 
		 if(items.count >= 1)
		 {
			 [_delegate storageClient:self didGetQueueMessage:[items objectAtIndex:0]];
		 }
		 else
		 {
			 [_delegate storageClient:self didGetQueueMessage:nil];
		 }
	 }];
}

- (void)getQueueMessage:(NSString *)queueName withBlock:(void (^)(QueueMessage *, NSError *))block
{
	[self privateGetQueueMessages:queueName fetchCount:1 useBlockError:!!block peekOnly:NO withBlock:^(NSArray* items, NSError* error) 
	{
		if(error)
		{
			if(block)
			{
				block(nil, error);
			}
			else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
			{
				[_delegate storageClient:self didFailRequest:nil withError:error];
			}
			return;
		}
		
		if(block)
		{
			if(items.count >= 1)
			{
				block([items objectAtIndex:0], nil);
			}
			else
			{
				block(nil, nil);
			}
		}
		else if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetQueueMessage:)])
		{
			if(items.count >= 1)
			{
				[_delegate storageClient:self didGetQueueMessage:[items objectAtIndex:0]];
			}
			else
			{
				[_delegate storageClient:self didGetQueueMessage:nil];
			}
		}
	}];
}

- (void)getQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount
{
	[self privateGetQueueMessages:queueName fetchCount:fetchCount useBlockError:NO peekOnly:NO withBlock:^(NSArray* items, NSError* error)
	 {
		 if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetQueueMessages:)])
		 {
			 return;
		 }
		 
		 [_delegate storageClient:self didGetQueueMessages:items];
	 }];
}

- (void)getQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount withBlock:(void (^)(NSArray *, NSError *))block
{
	[self privateGetQueueMessages:queueName fetchCount:fetchCount useBlockError:!!block peekOnly:NO withBlock:^(NSArray* items, NSError* error)
	 {
		 if(error)
		 {
			 if(block)
			 {
				 block(nil, error);
			 }
			 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
			 {
				 [_delegate storageClient:self didFailRequest:nil withError:error];
			 }
			 return;
		 }
		 
		 if(block)
		 {
			 block(items, nil);
		 }
		 else if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetQueueMessages:)])
		 {
			 [_delegate storageClient:self didGetQueueMessages:items];
		 }
	 }];
}

- (void)peekQueueMessage:(NSString *)queueName
{
	[self privateGetQueueMessages:queueName fetchCount:1 useBlockError:NO peekOnly:YES withBlock:^(NSArray* items, NSError* error) 
	 {
		 if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didPeekQueueMessage:)])
		 {
			 return;
		 }
		 
		 if(items.count >= 1)
		 {
			 [_delegate storageClient:self didPeekQueueMessage:[items objectAtIndex:0]];
		 }
		 else
		 {
			 [_delegate storageClient:self didPeekQueueMessage:nil];
		 }
	 }];
}

- (void)peekQueueMessage:(NSString *)queueName withBlock:(void (^)(QueueMessage *, NSError *))block
{
	[self privateGetQueueMessages:queueName fetchCount:1 useBlockError:!!block peekOnly:YES withBlock:^(NSArray* items, NSError* error) 
	 {
		 if(error)
		 {
			 if(block)
			 {
				 block(nil, error);
			 }
			 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
			 {
				 [_delegate storageClient:self didFailRequest:nil withError:error];
			 }
			 return;
		 }
		 
		 if(block)
		 {
			 if(items.count >= 1)
			 {
				 block([items objectAtIndex:0], nil);
			 }
			 else
			 {
				 block(nil, nil);
			 }
		 }
		 else if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didPeekQueueMessage:)])
		 {
			 if(items.count >= 1)
			 {
				 [_delegate storageClient:self didPeekQueueMessage:[items objectAtIndex:0]];
			 }
			 else
			 {
				 [_delegate storageClient:self didPeekQueueMessage:nil];
			 }
		 }
	 }];
}

- (void)peekQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount
{
	[self privateGetQueueMessages:queueName fetchCount:1 useBlockError:NO peekOnly:YES withBlock:^(NSArray* items, NSError* error)
	 {
		 if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didPeekQueueMessages:)])
		 {
			 return;
		 }
		 
		 [_delegate storageClient:self didPeekQueueMessages:items];
	 }];
}

- (void)peekQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount withBlock:(void (^)(NSArray *, NSError *))block
{
	[self privateGetQueueMessages:queueName fetchCount:1 useBlockError:!!block peekOnly:YES withBlock:^(NSArray* items, NSError* error)
	 {
		 if(error)
		 {
			 if(block)
			 {
				 block(nil, error);
			 }
			 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
			 {
				 [_delegate storageClient:self didFailRequest:nil withError:error];
			 }
			 return;
		 }
		 
		 if(block)
		 {
			 block(items, nil);
		 }
		 else if(![(NSObject*)_delegate respondsToSelector:@selector(storageClient:didPeekQueueMessages:)])
		 {
			 [_delegate storageClient:self didPeekQueueMessages:items];
		 }
	 }];
}

- (void)getQueueMessages:(NSString *)queueName
{
    [self getQueueMessages:queueName withBlock:nil];
}

- (void)getQueueMessages:(NSString *)queueName withBlock:(void (^)(NSArray *, NSError *))block
{
    queueName = [queueName lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@/messages?numofmessages=32", [queueName URLEncode]];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"queue", nil];
    [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(nil, error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         NSArray* queueMessages = [QueueMessageParser loadQueueMessages:doc];
         
         if(block)
         {
             block(queueMessages, nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetQueueMessages:)])
         {
             [_delegate storageClient:self didGetQueueMessages:queueMessages];
         }
     }];
}

- (void)deleteQueueMessage:(QueueMessage *)queueMessage queueName:(NSString *)queueName
{
    [self deleteQueueMessage:queueMessage queueName:queueName withBlock:nil];
}

- (void)deleteQueueMessage:(QueueMessage *)queueMessage queueName:(NSString *)queueName withBlock:(void (^)(NSError *))block
{
    queueName = [queueName lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@/messages/%@?popreceipt=%@", [queueName URLEncode], queueMessage.messageId, queueMessage.popReceipt];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"queue" httpMethod:@"DELETE", nil];
    
	[request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didDeleteQueueMessage:queueName:)])
         {
             [_delegate storageClient:self didDeleteQueueMessage:queueMessage queueName:queueName];
         }
     }];
}

- (void)putMessageToQueue:(NSString *)message queueName:(NSString *)queueName
{
    [self putMessageToQueue:message queueName:queueName withBlock:nil];

}

- (void)putMessageToQueue:(NSString *)message queueName:(NSString *)queueName withBlock:(void (^)(NSError *))block
{
    NSString* endpoint = [NSString stringWithFormat:@"/%@/messages", [queueName URLEncode]];
    NSString *queueMsgStart = @"<QueueMessage><MessageText>";
	NSString *queueMsgEnd = @"</MessageText></QueueMessage>";
	NSString *queueMsg = [NSString stringWithFormat:@"%@%@%@", queueMsgStart, message, queueMsgEnd];
    NSData *contentData = [queueMsg dataUsingEncoding:NSUTF8StringEncoding];
    CloudURLRequest *request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"queue" httpMethod:@"POST" contentData:contentData contentType:@"text/xml", nil];
    
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didAddBlobToContainer:blobName:)])
         {
             [_delegate storageClient:self didPutMessageToQueue:message queueName:queueName];
         }
     }];
    
}

#pragma mark -
#pragma mark Blob API methods

- (void)getBlobContainers
{
    [self getBlobContainersWithBlock:nil];
}

- (void)getBlobContainersWithBlock:(void (^)(NSArray*, NSError*))block
{
    if(_credential.usesProxy)
    {
        CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:@"/SharedAccessSignatureService/container" forStorageType:@"blob", nil];
        
        [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
         {
             if(error)
             {
                 if(block)
                 {
                     block(nil, error);
                 }
                 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
                 {
                     [_delegate storageClient:self didFailRequest:request withError:error];
                 }
                 return;
             }
             
             NSArray* containers = [ContainerParser loadContainersForProxy:doc];
             
             if(block)
             {
                 block(containers, nil);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetBlobContainers:)])
             {
                 [_delegate storageClient:self didGetBlobContainers:containers];
             }
         }];
    }
    else
    {
        CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:@"?comp=list&include=metadata" forStorageType:@"blob",
                                    @"x-ms-blob-type", @"BlockBlob", nil];
        
        [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
         {
             if(error)
             {
                 if(block)
                 {
                     block(nil, error);
                 }
                 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
                 {
                     [_delegate storageClient:self didFailRequest:request withError:error];
                 }
                 return;
             }
             
             NSArray* containers = [ContainerParser loadContainers:doc];
             
             if(block)
             {
                 block(containers, nil);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetBlobContainers:)])
             {
                 [_delegate storageClient:self didGetBlobContainers:containers];
             }
         }];
    }
}

- (BOOL)addBlobContainer:(NSString *)containerName
{
    return [self addBlobContainer:containerName withBlock:nil];
}

- (BOOL)addBlobContainer:(NSString *)containerName withBlock:(void (^)(NSError*))block
{
    if(_credential.usesProxy)
    {
        return NO;
    }
    
    containerName = [containerName lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@?restype=container", [containerName URLEncode]];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob" httpMethod:@"PUT" contentData:[NSData data] contentType:nil, nil];

	[request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didAddBlobContainer:)])
         {
             [_delegate storageClient:self didAddBlobContainer:containerName];
         }
     }];
    
    return YES;
}

- (BOOL)deleteBlobContainer:(BlobContainer *)container
{
    return [self deleteBlobContainer:container withBlock:nil];
}

- (BOOL)deleteBlobContainer:(BlobContainer *)container withBlock:(void (^)(NSError*))block
{
    if(_credential.usesProxy)
    {
        return NO;
    }
    //NSString* containerName = [container.name lowercaseString];
    NSString *containerName = [[NSString stringWithFormat:@"%@", container.name] lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@?restype=container", [containerName URLEncode]];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob" httpMethod:@"DELETE" contentData:[NSData data] contentType:nil, nil];
    	
	[request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didDeleteBlobContainer:)])
         {
             [_delegate storageClient:self didDeleteBlobContainer:container];
         }
     }];

    
    return YES;
}

- (void)getBlobs:(BlobContainer *)container
{
    [self getBlobs:container withBlock:nil];
}

- (void)getBlobs:(BlobContainer *)container withBlock:(void (^)(NSArray*, NSError*))block
{
    if(_credential.usesProxy)
    {
        CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:@"/SharedAccessSignatureService/blob" forStorageType:@"blob",
                                    @"x-ms-blob-type", @"BlockBlob", nil];
        
        [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
         {
             if(error)
             {
                 if(block)
                 {
                     block(nil, error);
                 }
                 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
                 {
                     [_delegate storageClient:self didFailRequest:request withError:error];
                 }
                 return;
             }
             
             NSArray* items = [BlobParser loadBlobsForProxy:doc container:container];
             
             if(block)
             {
                 block(items, nil);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetBlobs:inContainer:)])
             {
                 [_delegate storageClient:self didGetBlobs:items inContainer:container];
             }
         }];
    }
    else
    {
        NSString* containerName = container.name;
        NSString* endpoint = [NSString stringWithFormat:@"/%@?comp=list&restype=container", [containerName URLEncode]];
        CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob",
                                    @"x-ms-blob-type", @"BlockBlob", nil];
        
        [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
         {
             if(error)
             {
                 if(block)
                 {
                     block(nil, error);
                 }
                 else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
                 {
                     [_delegate storageClient:self didFailRequest:request withError:error];
                 }
                 return;
             }
             
             NSArray* items = [BlobParser loadBlobs:doc container:container];
             
             if(block)
             {
                 block(items, nil);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetBlobs:inContainer:)])
             {
                 [_delegate storageClient:self didGetBlobs:items inContainer:container];
             }
         }];
    }
}

- (void)getBlobData:(Blob *)blob
{
    [self getBlobData:blob withBlock:nil];
}

- (void)getBlobData:(Blob *)blob withBlock:(void (^)(NSData*, NSError*))block
{
    //CloudURLRequest* request = [_credential authenticatedBlobRequestWithURL:blob.URL forStorageType:@"blob", nil];
    
    NSString* endpoint = [NSString stringWithFormat:@"/%@/%@", blob.container.name, blob.name];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob", nil];
    
    [request fetchDataWithBlock:^(NSData* data, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(nil, error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(data, nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetBlobData:blob:)])
         {
             [_delegate storageClient:self didGetBlobData:data blob:blob];
         }
     }];
}

- (void)addBlobToContainer:(BlobContainer *)container blobName:(NSString *)blobName contentData:(NSData *)contentData contentType:(NSString*)contentType
{
    [self addBlobToContainer:container blobName:blobName contentData:contentData contentType:contentType withBlock:nil];
}

- (void)addBlobToContainer:(BlobContainer *)container blobName:(NSString *)blobName contentData:(NSData *)contentData contentType:(NSString*)contentType withBlock:(void (^)(NSError*))block
{
    CloudURLRequest* request;

    if(_credential.usesProxy)
    {
        //NSURL* serviceURL = [[NSURL URLWithString:[@"./%@" stringByAppendingString:blobName] relativeToURL:container.URL] absoluteURL];
        //NSString * tempString = [NSString stringWithFormat:@"%@/%@", container.name, blobName];
        //NSURL* serviceURL = [[NSURL URLWithString:tempString relativeToURL:container.URL] absoluteURL];
        request = [_credential authenticatedRequestWithEndpoint:@"/SharedAccessSignatureService/blob" forStorageType:@"blob" httpMethod:@"PUT" contentData:contentData contentType:contentType, @"x-ms-blob-type", @"BlockBlob", nil];
        //request = [_credential authenticatedBlobRequestWithURL:serviceURL forStorageType:@"blob" httpMethod:@"PUT" contentData:contentData contentType:contentType, @"x-ms-blob-type", @"BlockBlob", nil];
    }
    else
    {
        NSString* containerName = [container.name lowercaseString];
        NSString* endpoint = [NSString stringWithFormat:@"/%@/%@", [containerName URLEncode], [blobName URLEncode]];
        request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob" httpMethod:@"PUT" contentData:contentData contentType:contentType, @"x-ms-blob-type", @"BlockBlob", nil];
    }
    
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didAddBlobToContainer:blobName:)])
         {
             [_delegate storageClient:self didAddBlobToContainer:container blobName:blobName];
         }
     }];
}

- (void)deleteBlob:(Blob *)blob 
{
    [self deleteBlob:blob withBlock:nil];
}

- (void)deleteBlob:(Blob *)blob withBlock:(void (^)(NSError*))block
{
    //CloudURLRequest* request = [_credential authenticatedBlobRequestWithURL:blob.URL forStorageType:@"blob" httpMethod:@"DELETE", nil];
    CloudURLRequest* request;
    if (_credential.usesProxy) {
        //NSURL* serviceURL = [[NSURL URLWithString:[@"./%@" stringByAppendingString:blob.name] relativeToURL:blob.container.URL] absoluteURL];
        //NSString * tempString = [NSString stringWithFormat:@"%@/%@", blob.container.name, blob.name];
        //NSURL* serviceURL = [[NSURL URLWithString:tempString relativeToURL:blob.container.URL] absoluteURL];
        
        //request = [_credential authenticatedBlobRequestWithURL:serviceURL forStorageType:@"blob" httpMethod:@"DELETE" contentData:[NSData data] contentType:nil, nil];
        request = [_credential authenticatedRequestWithEndpoint:@"/SharedAccessSignatureService/blob" forStorageType:@"blob" httpMethod:@"DELETE" contentData:[NSData data] contentType:nil, nil];
    }
    else {
        NSString* endpoint = [NSString stringWithFormat:@"/%@/%@", [blob.container.name URLEncode], [blob.name URLEncode]];
        request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob" httpMethod:@"DELETE" contentData:[NSData data] contentType:nil, nil];
        
    }
//  NSString* endpoint = [NSString stringWithFormat:@"/%@/%@", blob.container, blob.name];
//  CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"blob" httpMethod:@"DELETE", nil];
    
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if(block)
         {
             block(nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didDeleteBlob:)])
         {
             [_delegate storageClient:self didDeleteBlob:blob];
         }
     }];
}

#pragma mark -
#pragma mark Table API methods

- (void)getTables
{
    [self getTablesWithBlock:nil];
}

- (void)getTablesWithBlock:(void (^)(NSArray *, NSError *))block
{
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:@"Tables" forStorageType:@"table" httpMethod:@"GET", nil];
    [self prepareTableRequest:request];
    
    [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(nil, error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         NSMutableArray* tables = [NSMutableArray arrayWithCapacity:20];
         
         [XmlHelper parseAtomPub:doc block:^(AtomPubEntry* entry) 
         {
             [entry processContentPropertiesWithBlock:^(NSString * name, NSString * value) {
                 if([name isEqualToString:@"TableName"])
                 {
                     [tables addObject:value];
                 }
             }];
         }];
         
         if(block)
         {
             block(tables, nil);
         }
         else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didGetTables:)])
         {
             [_delegate storageClient:self didGetTables:tables];
         }
     }];
}

- (void)createTableNamed:(NSString *)newTableName
{
    [self createTableNamed:newTableName withBlock:nil];
}

- (void)createTableNamed:(NSString *)newTableName withBlock:(void (^)(NSError *))block
{
    NSString* requestDataString;
    NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	NSString *dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    
    [dateFormatter release];
    
	requestDataString = [[CREATE_TABLE_REQUEST_STRING stringByReplacingOccurrencesOfString:@"$UPDATEDDATE$" withString:dateString] stringByReplacingOccurrencesOfString:@"$TABLENAME$" withString:newTableName];
    
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:@"Tables" 
                                                              forStorageType:@"table" 
                                                                  httpMethod:@"POST"
                                                                 contentData:[requestDataString dataUsingEncoding:NSUTF8StringEncoding]
                                                                 contentType:@"application/atom+xml", nil];    
    [self prepareTableRequest:request];

    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if(error)
         {
             if(block)
             {
                 block(error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }

		if (block)
		{
			block(nil);
		}
		else if ([(id)_delegate respondsToSelector:@selector(storageClient:didCreateTableNamed:)])
		{
			[_delegate storageClient:self didCreateTableNamed:newTableName];
		}
     }];
}

- (void)deleteTableNamed:(NSString *)tableName
{
    [self deleteTableNamed:tableName withBlock:nil];
}

- (void)deleteTableNamed:(NSString *)tableName withBlock:(void (^)(NSError *))block
{
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:[@"Tables" stringByAppendingFormat:@"(\'%@\')", tableName] forStorageType:@"table" httpMethod:@"DELETE", nil];
	[self prepareTableRequest:request];
	
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if (error)
         {
             if (block)
             {
                 block (error);
             }
             else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if (block)
         {
             block (nil);
         }
         else if ([(id)_delegate respondsToSelector:@selector(storageClient:didDeleteTableNamed:)])
         {
             [_delegate storageClient:self didDeleteTableNamed:tableName];
         }
     }];
}

- (void)getEntities:(TableFetchRequest*)fetchRequest
{
    [self getEntities:fetchRequest withBlock:nil];
}

- (void)getEntities:(TableFetchRequest*)fetchRequest withBlock:(void (^)(NSArray*, NSError *))block
{
	NSString* endpoint = [fetchRequest endpoint];
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"table" httpMethod:@"GET", nil];
	
    [self prepareTableRequest:request];
    
	[request fetchXMLWithBlock:^(xmlDocPtr doc, NSError *error)
     {
         if (error)
         {
             if (block)
             {
                 block (nil, error);
             }
             else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         // NSArray *entities = [self parseEntities:doc];
         NSMutableArray* entities = [NSMutableArray arrayWithCapacity:50];
         [XmlHelper parseAtomPub:doc block:^(AtomPubEntry* entry) 
          {
              NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:10];
              
              [entry processContentPropertiesWithBlock:^(NSString * name, NSString * value) 
              {
                  [dict setObject:value forKey:name];
              }];
              
              TableEntity* entity = [[TableEntity alloc] initWithDictionary:dict fromTable:fetchRequest.tableName];
              [entities addObject:entity];
              [entity release];
          }];
         
         if (block)
         {
             block(entities, nil);
         }
         else if ([(id)_delegate respondsToSelector:@selector(storageClient:didGetEntities:fromTableNamed:)])
         {
             [_delegate storageClient:self didGetEntities:entities fromTableNamed:fetchRequest.tableName];
         }
     }];
}

- (BOOL)insertEntity:(TableEntity *)newEntity
{
    return [self insertEntity:newEntity withBlock:nil];
}

- (BOOL)insertEntity:(TableEntity *)newEntity withBlock:(void (^)(NSError *))block
{
    NSString	*requestDataString = nil;
	NSString	*properties = [newEntity propertyString];
    
    if(!properties)
    {
		if (block)
		{
			block ([NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Required properties not found in entity" forKey:NSLocalizedDescriptionKey]]);
		}
		else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
		{
			[_delegate storageClient:self didFailRequest:nil withError:[NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Required properties not found in entity" forKey:NSLocalizedDescriptionKey]]];
		}
        return NO;
    }
    
	// Construct the date in the right format
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	NSString *dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
	
	requestDataString = [[TABLE_INSERT_ENTITY_REQUEST_STRING stringByReplacingOccurrencesOfString:@"$UPDATEDDATE$" withString:dateString] stringByReplacingOccurrencesOfString:@"$PROPERTIES$" withString:properties];
	
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:newEntity.tableName 
                                                              forStorageType:@"table" 
                                                                  httpMethod:@"POST" 
                                                                 contentData:[requestDataString dataUsingEncoding:NSASCIIStringEncoding] 
                                                                 contentType:@"application/atom+xml", nil];
    [self prepareTableRequest:request];
    
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if (error)
         {
             if (block)
             {
                 block (error);
             }
             else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if (block)
         {
             block (nil);
         }
         else if ([(id)_delegate respondsToSelector:@selector(storageClient:didInsertEntity:)])
         {
             [_delegate storageClient:self didInsertEntity:newEntity];
         }
     }];
    
    return YES;
}

- (BOOL)updateEntity:(TableEntity *)existingEntity
{
    return [self updateEntity:existingEntity withBlock:nil];
}

- (BOOL)updateEntity:(TableEntity *)existingEntity withBlock:(void (^)(NSError *))block
{
	NSString* properties = [existingEntity propertyString];
    
    if(!properties)
    {
		if (block)
		{
			block ([NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Required properties not found in entity" forKey:NSLocalizedDescriptionKey]]);
		}
		else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
		{
			[_delegate storageClient:self didFailRequest:nil withError:[NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Required properties not found in entity" forKey:NSLocalizedDescriptionKey]]];
		}
		return NO;
    }

    NSString* requestDataString = nil;
	NSString* endpoint = [existingEntity endpoint];
	
    // Construct the date in the right format
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc]init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	NSString *dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    
    NSURL* serviceURL = [_credential URLforEndpoint:endpoint forStorageType:@"table"];
    
	requestDataString = [[[TABLE_UPDATE_ENTITY_REQUEST_STRING stringByReplacingOccurrencesOfString:@"$UPDATEDDATE$" withString:dateString] stringByReplacingOccurrencesOfString:@"$PROPERTIES$" withString:properties] stringByReplacingOccurrencesOfString:@"$ENTITYID$" withString:[serviceURL absoluteString]];
	
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint 
                                                              forStorageType:@"table" 
                                                                  httpMethod:@"PUT"
                                                                 contentData:[requestDataString dataUsingEncoding:NSASCIIStringEncoding]
                                                                 contentType:@"application/atom+xml", nil];
    [self prepareTableRequest:request];
	[request setValue:@"*" forHTTPHeaderField:@"If-Match"];
	
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if (error)
         {
             if (block)
             {
                 block (error);
             }
             else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if (block)
         {
             block (nil);
         }
         else if ([(id)_delegate respondsToSelector:@selector(storageClient:didUpdateEntity:)])
         {
             [_delegate storageClient:self didUpdateEntity:existingEntity];
         }
     }];
    
    return YES;
}

- (BOOL)mergeEntity:(TableEntity *)existingEntity 
{
    return [self mergeEntity:existingEntity withBlock:nil];
}

- (BOOL)mergeEntity:(TableEntity *)existingEntity withBlock:(void (^)(NSError *))block
{
	NSString* properties = [existingEntity propertyString];
    
    if(!properties)
    {
		if (block)
		{
			block ([NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Required properties not found in entity" forKey:NSLocalizedDescriptionKey]]);
		}
		else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
		{
			[_delegate storageClient:self didFailRequest:nil withError:[NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"Required properties not found in entity" forKey:NSLocalizedDescriptionKey]]];
		}
		return NO;
    }
    
    NSString* requestDataString = nil;
	NSString* endpoint = [existingEntity endpoint];

	// Construct the date in the right format
	NSDate *date = [NSDate date];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	NSString *dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
	
    NSURL* serviceURL = [_credential URLforEndpoint:endpoint forStorageType:@"table"];
	requestDataString = [[[TABLE_UPDATE_ENTITY_REQUEST_STRING stringByReplacingOccurrencesOfString:@"$UPDATEDDATE$" withString:dateString] stringByReplacingOccurrencesOfString:@"$PROPERTIES$" withString:properties] stringByReplacingOccurrencesOfString:@"$ENTITYID$" withString:[serviceURL path]];
    
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint 
                                                              forStorageType:@"table" 
                                                                  httpMethod:@"MERGE"
                                                                 contentData:[requestDataString dataUsingEncoding:NSASCIIStringEncoding]
                                                                 contentType:@"application/atom+xml", nil];
    [self prepareTableRequest:request];
	[request setValue:@"*" forHTTPHeaderField:@"If-Match"];
	
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if (error)
         {
             if (block)
             {
                 block (error);
             }
             else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if (block)
         {
             block (nil);
         }
         else if ([(id)_delegate respondsToSelector:@selector(storageClient:didMergeEntity:)])
         {
             [_delegate storageClient:self didMergeEntity:existingEntity];
         }
     }];
    
    return YES;
}

- (BOOL)deleteEntity:(TableEntity *)existingEntity
{
    return [self deleteEntity:existingEntity withBlock:nil];
}

- (BOOL)deleteEntity:(TableEntity *)existingEntity withBlock:(void (^)(NSError *))block
{
	NSString* endpoint = [existingEntity endpoint];
	
	if (!endpoint)
    {
		if (block)
		{
			block ([NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"No endpoint defined" forKey:NSLocalizedDescriptionKey]]);
		}
		else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
		{
			[_delegate storageClient:self didFailRequest:nil withError:[NSError errorWithDomain:@"CloudStorageClient" code:-1 userInfo:[NSDictionary dictionaryWithObject:@"No endpoint defined" forKey:NSLocalizedDescriptionKey]]];
		}
		return NO;
    }
    
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint 
                                                              forStorageType:@"table" 
                                                                  httpMethod:@"DELETE", nil];
    [self prepareTableRequest:request];

	[request setValue:@"*" forHTTPHeaderField:@"If-Match"];
	
    [request fetchNoResponseWithBlock:^(NSError* error)
     {
         if (error)
         {
             if (block)
             {
                 block (error);
             }
             else if ([(id)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         if (block)
         {
             block (nil);
         }
         else if ([(id)_delegate respondsToSelector:@selector(storageClient:didDeleteEntity:)])
         {
             [_delegate storageClient:self didDeleteEntity:existingEntity];
         }
     }];
    
    return YES;
}

#pragma mark -
#pragma mark Private methods

- (void)privateGetQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount useBlockError:(BOOL)useBlockError peekOnly:(BOOL)peekOnly withBlock:(void (^)(NSArray *, NSError *))block
{
	queueName = [queueName lowercaseString];
    NSString* endpoint = [NSString stringWithFormat:@"/%@/messages?numofmessages=%d", [queueName URLEncode], fetchCount];
	if(peekOnly)
	{
		endpoint = [endpoint stringByAppendingString:@"&peekonly=true"];
	}
	else
	{
		// allow 60 seconds to turn around and delete the message
		endpoint = [endpoint stringByAppendingString:@"&visibilitytimeout=60"];
	}
	
    CloudURLRequest* request = [_credential authenticatedRequestWithEndpoint:endpoint forStorageType:@"queue", nil];
    [request fetchXMLWithBlock:^(xmlDocPtr doc, NSError* error)
     {
         if(error)
         {
             if(useBlockError)
             {
                 block(nil, error);
             }
             else if([(NSObject*)_delegate respondsToSelector:@selector(storageClient:didFailRequest:withError:)])
             {
                 [_delegate storageClient:self didFailRequest:request withError:error];
             }
             return;
         }
         
         NSArray* queueMessages = [QueueMessageParser loadQueueMessages:doc];
		 block(queueMessages, nil);
     }];
}

- (void) dealloc 
{
    _delegate = nil;
    [_credential release];

    [super dealloc];
}

#pragma mark -

@end
