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

#import "PredicateParser.h"

@implementation PredicateParser

+ (void) error:(NSString*)errorDesc code:(NSInteger)code delegate:(id<PredicateParserDelegate>)delegate
{
	if([(NSObject*)delegate respondsToSelector:@selector(parserFailedWithError:)])
	{
		NSError* error = [NSError errorWithDomain:@"PredicateParser" 
											 code:code 
										 userInfo:[NSDictionary dictionaryWithObject:errorDesc forKey:NSLocalizedDescriptionKey]];
		[delegate parserFailedWithError:error];
	}
}

+ (void) parse:(NSPredicate*)predicate delegate:(id<PredicateParserDelegate>)delegate
{
	if([predicate isKindOfClass:[NSComparisonPredicate class]])
	{
		NSComparisonPredicate* comparison = (NSComparisonPredicate*)predicate;
		
		[delegate writeComparison:[comparison predicateOperatorType] 
							 left:[comparison leftExpression] 
							right:[comparison rightExpression]];
	}
	else if([predicate isKindOfClass:[NSCompoundPredicate class]])
	{
		NSCompoundPredicate* compound = (NSCompoundPredicate*)predicate;
		
		switch([compound compoundPredicateType])
		{
			case NSAndPredicateType:
			{
				[delegate writeAnd:[compound subpredicates]];
				break;
			}

			case NSOrPredicateType:
			{
				[delegate writeOr:[compound subpredicates]];
				break;
			}

			case NSNotPredicateType:
			{
				[delegate writeNot:[[compound subpredicates] objectAtIndex:0]];
				break;
			}
		}
	}
	else 
	{
		[self error:@"Unexpected predicate class" 
			   code:1 
		   delegate:delegate];
	}

}

@end
