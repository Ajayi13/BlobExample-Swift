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

#import "AzureFilterBuilder.h"

@implementation AzureFilterBuilder

@synthesize error;

- (id) init
{
	if((self = [super init]))
	{
		string = [[NSMutableString alloc] initWithCapacity:1000];
	}
	
	return self;
}

- (void) dealloc
{
	[string release];
	[error release];
	
	[super dealloc];
}

- (NSString*) parse:(NSPredicate*)predicate
{
	[PredicateParser parse:predicate delegate:self];
	
	if(error)
	{
		return nil;
	}
	
	return [[string copy] autorelease];
}

- (void) writeExpression:(NSExpression*)expr
{
	switch([expr expressionType])
	{
		case NSConstantValueExpressionType: // Expression that always returns the same value
		{
			id constant = [expr constantValue];
			if([constant isKindOfClass:[NSString class]])
			{
				NSString* s = [(NSString*)constant stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
				[string appendFormat:@"'%@'", s];
			}
			else if([constant isKindOfClass:[NSDate class]])
			{
				NSDateFormatter* formatter = [NSDateFormatter new];
				[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
				
				NSString* s = [formatter stringFromDate:(NSDate*)constant];
				[formatter release];

				[string appendFormat:@"'%@'", s];
			}
			else
			{
				[string appendString:[constant description]];
			}
			break;
		}
		
		case NSKeyPathExpressionType: // Expression that returns something that can be used as a key path
		{
			NSString* keyPath = [expr keyPath];
			[string appendString:keyPath];
			break;
		}
			
		default:
		{
			NSError* err = [NSError errorWithDomain:@"AzureFilterBuilder" 
											   code:-1
										   userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unsupported expression type", [expr expressionType]]
																				forKey:NSLocalizedDescriptionKey]];
			[self parserFailedWithError:err];
		}
	}
}

- (void) writeComparison:(NSPredicateOperatorType)predicateOperatorType left:(NSExpression*)left right:(NSExpression*)right
{
	switch(predicateOperatorType)
	{
		case NSLessThanPredicateOperatorType: // compare: returns NSOrderedAscending
		{
			[self writeExpression:left];
			[string appendString:@" lt "];
			[self writeExpression:right];
			break;
		}
			
		case NSLessThanOrEqualToPredicateOperatorType: // compare: returns NSOrderedAscending || NSOrderedSame
		{
			[self writeExpression:left];
			[string appendString:@" le "];
			[self writeExpression:right];
			break;
		}
			
		case NSGreaterThanPredicateOperatorType: // compare: returns NSOrderedDescending
		{
			[self writeExpression:left];
			[string appendString:@" gt "];
			[self writeExpression:right];
			break;
		}
			
		case NSGreaterThanOrEqualToPredicateOperatorType: // compare: returns NSOrderedDescending || NSOrderedSame
		{
			[self writeExpression:left];
			[string appendString:@" ge "];
			[self writeExpression:right];
			break;
		}
			
		case NSEqualToPredicateOperatorType: // isEqual: returns true
		{
			[self writeExpression:left];
			[string appendString:@" eq "];
			[self writeExpression:right];
			break;
		}
			
		case NSNotEqualToPredicateOperatorType: // isEqual: returns false
		{
			[self writeExpression:left];
			[string appendString:@" ne "];
			[self writeExpression:right];
			break;
		}
			
		case NSBeginsWithPredicateOperatorType:
		{
		/*	// not currently support... fall through
            [string appendString:@"startswith ("];
			[self writeExpression:left];
			[string appendString:@", "];
			[self writeExpression:right];
			[string appendString:@")"];
			break;  */
		}
			
		case NSEndsWithPredicateOperatorType:
		{
        /*	// not currently support... fall through
			[string appendString:@"endswith ("];
			[self writeExpression:left];
			[string appendString:@", "];
			[self writeExpression:right];
			[string appendString:@")"];
			break;  */
		} 
			
		case NSLikePredicateOperatorType:
		case NSInPredicateOperatorType: // rhs contains lhs returns true
		case NSCustomSelectorPredicateOperatorType:
		default:
		{
			NSError* err = [NSError errorWithDomain:@"AzureFilterBuilder" 
											   code:-1
										   userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Unsupported operator type", predicateOperatorType]
																				forKey:NSLocalizedDescriptionKey]];
			[self parserFailedWithError:err];
			break;
		}
	}
}

- (void) writeAnd:(NSArray*)predicates
{
	BOOL first = YES;
	
	for(NSPredicate* predicate in predicates)
	{
		if(first)
		{
			first = NO;
		}
		else 
		{
			[string appendString:@" and "];
		}

		[string appendString:@"("];
		[PredicateParser parse:predicate delegate:self];
		[string appendString:@")"];
		
		if(error)
		{
			break;
		}
	}
}

- (void) writeOr:(NSArray*)predicates
{
	BOOL first = YES;
	
	for(NSPredicate* predicate in predicates)
	{
		if(first)
		{
			first = NO;
		}
		else 
		{
			[string appendString:@" or "];
		}
		
		[string appendString:@"("];
		[PredicateParser parse:predicate delegate:self];
		[string appendString:@")"];
		
		if(error)
		{
			break;
		}
	}
}

- (void) writeNot:(NSPredicate*)predicate
{
	[string appendString:@"not ("];
	[PredicateParser parse:predicate delegate:self];
	[string appendString:@")"];
}

- (void) parserFailedWithError:(NSError*)_error
{
	[error release];
	error = [_error retain];
}


+ (NSString*) filterStringWithPredicate:(NSPredicate*)predicate error:(NSError**)error
{
	AzureFilterBuilder* builder = [AzureFilterBuilder new];
	
	NSString* result = [builder parse:predicate];
	
	if(error)
	{
		*error = [[builder.error retain] autorelease];
	}	
	
	[builder release];
	
	return result;
}


@end
