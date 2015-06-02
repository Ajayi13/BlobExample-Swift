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

#import "TableEntity.h"
#import "NSString+URLEncode.h"

@implementation TableEntity

@synthesize tableName = _tableName;
@synthesize partitionKey = _partitionKey;
@synthesize rowKey = _rowKey;
@synthesize timeStamp = _timeStamp;

- (id)initWithDictionary:(NSMutableDictionary*)dictionary fromTable:(NSString*)tableName
{
    if((self = [super init]))
    {
        _dictionary = [dictionary retain];
        _tableName = [tableName retain];
        _partitionKey = [[_dictionary objectForKey:@"PartitionKey"] retain];
        _rowKey = [[_dictionary objectForKey:@"RowKey"] retain];
        
        NSString* timeStamp = [_dictionary valueForKey:@"Timestamp"];        
        if(timeStamp)
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"];
            _timeStamp = [[dateFormat dateFromString:timeStamp] retain];
            [dateFormat release];
        }
        
        [_dictionary removeObjectsForKeys:[NSArray arrayWithObjects:@"PartitionKey", @"RowKey", @"Timestamp", nil]];
    }
    
    return self;
}

+ (TableEntity*) createEntityForTable:(NSString*)table
{
    return [[[TableEntity alloc] initWithDictionary:[NSMutableDictionary dictionaryWithCapacity:10] fromTable:table] autorelease];
}

- (void)dealloc
{
    [_tableName release];
    [_dictionary release];
    [_partitionKey release];
    [_rowKey release];
    [_timeStamp release];
    
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"TableEntity { partitionKey = %@, row = %ld, timeStamp = %@, values = %@ }", self.partitionKey, _rowKey, _timeStamp, _dictionary];
}

- (NSArray*)keys
{
    return [_dictionary allKeys];
}

- (id)valueForKey:(NSString *)key
{
    return [_dictionary objectForKey:key];
}

- (void)setValue:(id)value forKey:(NSString*)key
{
    return [_dictionary setObject:value forKey:key];
}

- (NSString*)propertyString
{
    if(!_partitionKey || !_rowKey)
    {
        return nil;
    }
    
    NSMutableString* properties = [NSMutableString stringWithCapacity:100];
    
    [properties appendFormat:@"<d:PartitionKey>%@</d:PartitionKey>", _partitionKey];
    [properties appendFormat:@"<d:RowKey>%@</d:RowKey>", _rowKey];

    if(_dictionary.count)
    {
        for (NSString *nextKey in [_dictionary allKeys])
        {
			[properties appendFormat:@"<d:%@>%@</d:%@>", nextKey, [_dictionary valueForKey:nextKey], nextKey];
        }
    }

    return [[properties copy] autorelease];
}

- (NSString*)endpoint
{
    if(!_tableName || !_partitionKey || !_rowKey)
    {
        return nil;
    }
    
    return [_tableName stringByAppendingFormat:@"(PartitionKey=\'%@\',RowKey=\'%@\')", [_partitionKey URLEncode], [_rowKey URLEncode]];
}
            
@end
