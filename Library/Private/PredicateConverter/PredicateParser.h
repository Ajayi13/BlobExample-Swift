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

@class PredicateParser;

@protocol PredicateParserDelegate

@required

- (void) writeComparison:(NSPredicateOperatorType)predicateOperatorType left:(NSExpression*)left right:(NSExpression*)right;
- (void) writeAnd:(NSArray*)predicates;
- (void) writeOr:(NSArray*)predicates;
- (void) writeNot:(NSPredicate*)predicate;

- (void) parserFailedWithError:(NSError*)error;

@end


@interface PredicateParser : NSObject

+ (void) parse:(NSPredicate*)predicate delegate:(id<PredicateParserDelegate>)delegate;

@end
