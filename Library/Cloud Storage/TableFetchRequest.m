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

#import "TableFetchRequest.h"
#import "AzureFilterBuilder.h"
#import "CloudURLRequest.h"
#import "NSString+URLEncode.h"

@implementation TableFetchRequest

@synthesize tableName = _tableName;
@synthesize partitionKey = _partitionKey;
@synthesize rowKey = _rowKey;
@synthesize filter = _filter;
@synthesize topRows = _topRows;

- (id) initWithTable:(NSString*)tableName
{
    if((self = [super init]))
    {
        _tableName = [tableName copy];
    }
    
    return self;
}

+ (TableFetchRequest*)fetchRequestForTable:(NSString*)tableName
{
    return [[[TableFetchRequest alloc] initWithTable:tableName] autorelease];
}

+ (TableFetchRequest*)fetchRequestForTable:(NSString*)tableName predicate:(NSPredicate*)predicate error:(NSError**)error
{
    NSString* filter = [AzureFilterBuilder filterStringWithPredicate:predicate error:error];
    if(!filter)
    {
        return nil;
    }

#if FULL_LOGGING
    NSLog(@"Filter=%@", filter);
#endif
    
    TableFetchRequest* request = [[[TableFetchRequest alloc] initWithTable:tableName] autorelease];
    
    request.filter = filter;
    
    return request;
}

- (NSString*)endpoint
{
    if (_partitionKey && _rowKey)
    {
		return [_tableName stringByAppendingFormat:@"(PartitionKey=\'%@\',RowKey=\'%@\')", [_partitionKey URLEncode], [_rowKey URLEncode]];
    }
	else if (_partitionKey)
    {
		return [_tableName stringByAppendingFormat:@"(PartitionKey=\'%@\')", [_partitionKey URLEncode]];
    }
	else if (_rowKey)
    {
		return [_tableName stringByAppendingFormat:@"(RowKey=\'%@\')", [_rowKey URLEncode]];
    }
	else if (_filter && _topRows > 0)
    {
		return [_tableName stringByAppendingFormat:@"()?$filter=%@&$top=%d", [_filter URLEncode], _topRows];
    }
	else if (_filter)
    {
		return [_tableName stringByAppendingFormat:@"()?$filter=%@", [_filter URLEncode]];
    }
	else if (_topRows > 0)
    {
		return [_tableName stringByAppendingFormat:@"()?$top=%d", _topRows];
    }

    return [_tableName stringByAppendingString:@"()"];
}

- (void)dealloc
{
    [_tableName release];
    [_partitionKey release];
    [_rowKey release];
    [_filter release];
    
    [super dealloc];
}
@end
