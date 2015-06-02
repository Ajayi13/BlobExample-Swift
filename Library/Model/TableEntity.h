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

/*! TableEntity is a class used to represent entities with Windows Azure table storage.*/
@interface TableEntity : NSObject 
{
    NSString* _tableName;
    NSString* _partitionKey;
    NSString* _rowKey;
    NSDate* _timeStamp;
    NSMutableDictionary* _dictionary;
}

/*! The name of the table this entity is located within. */
@property (readonly) NSString* tableName;
/*! The name of the partition key for this entity. */
@property (copy) NSString* partitionKey;
/*! The name of the row key for this entity. */
@property (copy) NSString* rowKey;
/*! The timestamp for this entity */
@property (readonly) NSDate* timeStamp;

/*! Returns an array of all keys for this entity. */
- (NSArray*)keys;
/*! Returns the value for a specified key. */
- (id)valueForKey:(NSString *)key;
/*! Sets a value for a specified key. */
- (void)setValue:(id)value forKey:(NSString*)key;

/*! Creates a new TableEntity given the name of an existing table. */
+ (TableEntity*) createEntityForTable:(NSString*)table;

@end
