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

/*! BlobContainer is a class used to represent blob containers within Windows Azure blob storage.*/
@interface BlobContainer : NSObject

/*! Name of the blob container.*/
@property (copy) NSString *name;
/*! URL of the blob container. */
@property (readonly) NSURL *URL;
/*! Metadata associated with the blob container. */
@property (readonly) NSString *metadata;

/*! Intialize a new container with the name, URL, and any associated metadata */
- (id)initContainerWithName:(NSString *)name URL:(NSString *)URL metadata:(NSString *)metadata;

@end
