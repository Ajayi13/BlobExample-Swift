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
#import "Blob.h"
#import "BlobContainer.h"
#import "TableEntity.h"
#import "TableFetchRequest.h"
#import "QueueMessage.h"

@protocol CloudStorageClientDelegate;

/*! The cloud storage client is used to invoke operations on, and return data from, Windows Azure storage. */
@interface CloudStorageClient : NSObject
{
	AuthenticationCredential* _credential;
	id<CloudStorageClientDelegate> _delegate;
}

@property (assign) id<CloudStorageClientDelegate> delegate;

/*! Returns a list of blob containers. */
- (void)getBlobContainers;
/*! Returns a list of blob containers. */
- (void)getBlobContainersWithBlock:(void (^)(NSArray*, NSError *))block;
/*! Adds a blob container, given a specified container name.  Returns error if the container already exists, or where the name is an invalid format.*/
- (BOOL)addBlobContainer:(NSString *)containerName;
/*! Adds a blob container, given a specified container name.  Returns error if the container already exists, or where the name is an invalid format.*/
- (BOOL)addBlobContainer:(NSString *)containerName withBlock:(void (^)(NSError *))block;
/*! Deletes a specified blob container. */
- (BOOL)deleteBlobContainer:(BlobContainer *)container;
/*! Deletes a specified blob container. */
- (BOOL)deleteBlobContainer:(BlobContainer *)container withBlock:(void (^)(NSError *))block;
/*! Returns an array of blobs from the specified blob container. */
- (void)getBlobs:(BlobContainer *)container;
/*! Returns an array of blobs from the specified blob container. */
- (void)getBlobs:(BlobContainer *)container withBlock:(void (^)(NSArray *, NSError *))block;
/*! Returns the binary data (NSData) object for the specified blob. */
- (void)getBlobData:(Blob *)blob;
/*! Returns the binary data (NSData) object for the specified blob. */
- (void)getBlobData:(Blob *)blob withBlock:(void (^)(NSData *, NSError *))block;
/*! Adds a new blob to a container, given the name of the blob, binary data for the blob, and content type. */
- (void)addBlobToContainer:(BlobContainer *)container blobName:(NSString *)blobName contentData:(NSData *)contentData contentType:(NSString*)contentType;
/*! Adds a new blob to a container, given the name of the blob, binary data for the blob, and content type. */
- (void)addBlobToContainer:(BlobContainer *)container blobName:(NSString *)blobName contentData:(NSData *)contentData contentType:(NSString*)contentType withBlock:(void (^)(NSError *))block;
/*! Deletes a blob.  Returns error if the blob doesn't exist or could not be deleted. */
- (void)deleteBlob:(Blob *)blob;
/*! Deletes a blob.  Returns error if the blob doesn't exist or could not be deleted. */
- (void)deleteBlob:(Blob *)blob withBlock:(void (^)(NSError *))block;

/*! Returns a list of queues. */
- (void)getQueues;
/*! Returns a list of queues. */
- (void)getQueuesWithBlock:(void (^)(NSArray*, NSError *))block;
/*! Adds a queue, given a specified queue name. */
- (void)addQueue:(NSString *)queueName;
/*! Adds a queue, given a specified queue name.  Returns error if the queue already exists, or where the name is an invalid format.*/
- (void)addQueue:(NSString *)queueName withBlock:(void (^)(NSError *))block;
/*! Deletes a queue, given a specified queue name. */
- (void)deleteQueue:(NSString *)queueName;
/*! Deletes a queue, given a specified queue name. Returns error if failed. */
- (void)deleteQueue:(NSString *)queueName withBlock:(void (^)(NSError *))block;
/*! Gets a message, given a specified queue name. */
- (void)getQueueMessages:(NSString *)queueName;
/*! Gets a message, given a specified queue name. Returns error if failed. */
- (void)getQueueMessages:(NSString *)queueName withBlock:(void (^)(NSArray *, NSError *))block;
/*! Gets a single message from the specified queue. */
- (void)getQueueMessage:(NSString *)queueName;
/*! Gets a single message from the specified queue. Returns error if failed. */
- (void)getQueueMessage:(NSString *)queueName withBlock:(void (^)(QueueMessage *, NSError *))block;
/*! Gets a batch of messages from the specified queue. */
- (void)getQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount;
/*! Gets a batch of messages from the specified queue. Returns error if failed. */
- (void)getQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount withBlock:(void (^)(NSArray *, NSError *))block;
/*! Peeks a single message from the specified queue. Peek is like Get, but the message is not marked for removal. */
- (void)peekQueueMessage:(NSString *)queueName;
/*! Peeks a single message from the specified queue. Peek is like Get, but the message is not marked for removal. Returns error if failed. */
- (void)peekQueueMessage:(NSString *)queueName withBlock:(void (^)(QueueMessage *, NSError *))block;
/*! Peeks a batch of messages from the specified queue. Peek is like Get, but the message is not marked for removal. */
- (void)peekQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount;
/*! Peeks a batch of messages from the specified queue. Peek is like Get, but the message is not marked for removal. Returns error if failed. */
- (void)peekQueueMessages:(NSString *)queueName fetchCount:(NSInteger)fetchCount withBlock:(void (^)(NSArray *, NSError *))block;
/*! Deletes a message, given a specified queue name and queueMessage. */
- (void)deleteQueueMessage:(QueueMessage *)queueMessage queueName:(NSString *)queueName;
/*! Deletes a message, given a specified queue name and queueMessage. Returns error if failed. */
- (void)deleteQueueMessage:(QueueMessage *)queueMessage queueName:(NSString *)queueName withBlock:(void (^)(NSError *))block;
/*! Puts a message into a queue, given a specified queue name and message. */
- (void)putMessageToQueue:(NSString *)message queueName:(NSString *)queueName;
/*! Puts a message into a queue, given a specified queue name and message. Returns error if failed. */
- (void)putMessageToQueue:(NSString *)message queueName:(NSString *)queueName withBlock:(void (^)(NSError *))block;

/*! Returns a list of tables. */
- (void)getTables;
/*! Returns a list of tables. */
- (void)getTablesWithBlock:(void (^)(NSArray *, NSError *))block;
/*! Creates a new table with a specified name. */
- (void)createTableNamed:(NSString *)newTableName;
/*! Creates a new table with a specified name. */
- (void)createTableNamed:(NSString *)newTableName withBlock:(void (^)(NSError *))block;
/*! Deletes a specifed table.  Returns error is the table doesn't exist or could not be deleted. */
- (void)deleteTableNamed:(NSString *)tableName;
/*! Deletes a specifed table.  Returns error is the table doesn't exist or could not be deleted. */
- (void)deleteTableNamed:(NSString *)tableName withBlock:(void (^)(NSError *))block;
/*! Returns the entities for a given table. */
- (void)getEntities:(TableFetchRequest*)fetchRequest;
/*! Returns the entities for a given table. */
- (void)getEntities:(TableFetchRequest*)fetchRequest withBlock:(void (^)(NSArray *, NSError *))block;
/*! Inserts a new entity into an existing table. */
- (BOOL)insertEntity:(TableEntity *)newEntity;
/*! Inserts a new entity into an existing table. */
- (BOOL)insertEntity:(TableEntity *)newEntity withBlock:(void (^)(NSError *))block;
/*! Updates an existing entity within a table. */
- (BOOL)updateEntity:(TableEntity *)existingEntity;
/*! Updates an existing entity within a table. */
- (BOOL)updateEntity:(TableEntity *)existingEntity withBlock:(void (^)(NSError *))block;
/*! Merges an existing entity within a table. */
- (BOOL)mergeEntity:(TableEntity *)existingEntity;
/*! Merges an existing entity within a table. */
- (BOOL)mergeEntity:(TableEntity *)existingEntity withBlock:(void (^)(NSError *))block;
/*! Deletes an existing entity within a table. */
- (BOOL)deleteEntity:(TableEntity *)existingEntity;
/*! Merges an existing entity within a table. */
- (BOOL)deleteEntity:(TableEntity *)existingEntity withBlock:(void (^)(NSError *))block;

/*! Initializes a new cloud storage client, based on a passed set of authentication credentials. */
+ (CloudStorageClient*) storageClientWithCredential:(AuthenticationCredential*)credential;

@end

/*! The CloudStorageClientDelegate is a protocol for handling delegated requests from CloudStorageClient. */
@protocol CloudStorageClientDelegate

@optional

/*! Called if a URL request failed. */
- (void)storageClient:(CloudStorageClient *)client didFailRequest:(NSURLRequest*)request withError:(NSError *)error;

/*! Called when the client successfully returns a list of blob containers */
- (void)storageClient:(CloudStorageClient *)client didGetBlobContainers:(NSArray *)containers;
/*! Called when the client successsfully adds a new blob container. */
- (void)storageClient:(CloudStorageClient *)client didAddBlobContainer:(NSString *)name;
/*! Called when the client successfully removes an existing blob container. */
- (void)storageClient:(CloudStorageClient *)client didDeleteBlobContainer:(BlobContainer *)name;
/*! Called when the client successfully returns blobs from an existing container. */
- (void)storageClient:(CloudStorageClient *)client didGetBlobs:(NSArray *)blobs inContainer:(BlobContainer *)container;
/*! Called when the client successfully returns blob data for a given blob. */
- (void)storageClient:(CloudStorageClient *)client didGetBlobData:(NSData *)data blob:(Blob *)blob;
/*! Called when the client successfully adds a blob to a specified container. */
- (void)storageClient:(CloudStorageClient *)client didAddBlobToContainer:(BlobContainer *)container blobName:(NSString *)blobName;
/*! Called when the client successfully deletes a blob. */
- (void)storageClient:(CloudStorageClient *)client didDeleteBlob:(Blob *)blob;

/*! Called when the client successfully add a queue */
- (void)storageClient:(CloudStorageClient *)client didAddQueue:(NSString *)queueName;
/*! Called when the client successfully removes an existing queue. */
- (void)storageClient:(CloudStorageClient *)client didDeleteQueue:(NSString *)queueName;
/*! Called when the client successfully returns a list of queues */
- (void)storageClient:(CloudStorageClient *)client didGetQueues:(NSArray *)queues;
/*! Called when the client successfully got a single message from the specified queue */
- (void)storageClient:(CloudStorageClient *)client didGetQueueMessage:(QueueMessage *)queueMessage;
/*! Called when the client successfully get messages from the specified queue */
- (void)storageClient:(CloudStorageClient *)client didGetQueueMessages:(NSArray *)queueMessages;
/*! Called when the client successfully peeked a single message from the specified queue */
- (void)storageClient:(CloudStorageClient *)client didPeekQueueMessage:(QueueMessage *)queueMessage;
/*! Called when the client successfully peeked messages from the specified queue */
- (void)storageClient:(CloudStorageClient *)client didPeekQueueMessages:(NSArray *)queueMessages;
/*! Called when the client successfully delete a message from the specified queue */
- (void)storageClient:(CloudStorageClient *)client didDeleteQueueMessage:(QueueMessage *)queueMessage queueName:(NSString *)queueName;
/*! Called when the client successfully put a message into the specified queue */
- (void)storageClient:(CloudStorageClient *)client didPutMessageToQueue:(NSString *)message queueName:(NSString *)queueName;

/*! Called when the client successfully returns a list of tables. */
- (void)storageClient:(CloudStorageClient *)client didGetTables:(NSArray *)tables;
/*! Called when the client successfully creates a table. */
- (void)storageClient:(CloudStorageClient *)client didCreateTableNamed:(NSString *)tableName;
/*! Called when the client successfully deletes a specified table. */
- (void)storageClient:(CloudStorageClient *)client didDeleteTableNamed:(NSString *)tableName;
/*! Called when the client successfully returns a list of entities from a table. */
- (void)storageClient:(CloudStorageClient *)client didGetEntities:(NSArray *)entities fromTableNamed:(NSString *)tableName;

/*! Called when the client successfully inserts an entity into a table. */
- (void)storageClient:(CloudStorageClient *)client didInsertEntity:(TableEntity *)entity;
/*! Called when the client successfully updates an entity within a table. */
- (void)storageClient:(CloudStorageClient *)client didUpdateEntity:(TableEntity *)entity;
/*! Called when the client successfully merges an entity within a table. */
- (void)storageClient:(CloudStorageClient *)client didMergeEntity:(TableEntity *)entity;
/*! Called when the client successfully deletes an entity from a table. */
- (void)storageClient:(CloudStorageClient *)client didDeleteEntity:(TableEntity *)entity;
/*
- (void)storageClient:(CloudStorageClient *)client didInsertEntity:(NSDictionary *)entity intoTableNamed:(NSString *)tableName;
- (void)storageClient:(CloudStorageClient *)client didUpdateEntity:(NSDictionary *)entity inTableNamed:(NSString *)tableName;
- (void)storageClient:(CloudStorageClient *)client didMergeEntity:(NSDictionary *)entity inTableNamed:(NSString *)tableName;
- (void)storageClient:(CloudStorageClient *)client didDeleteEntity:(NSDictionary *)entity inTableNamed:(NSString *)tableName;
 */

@end
