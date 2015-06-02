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

#import "BlobParser.h"
#import "Blob.h"
#import "XmlHelper.h"

@interface Blob (Private)

- (id)initBlobWithName:(NSString *)name URL:(NSString *)URL container:(BlobContainer*)container;

@end

@implementation BlobParser

+ (NSArray *)loadBlobs:(xmlDocPtr)doc container:(BlobContainer*)container
{
    if (doc == nil) 
    { 
		return nil; 
	}
    
	NSMutableArray *blobs = [NSMutableArray arrayWithCapacity:30];
    
    [XmlHelper performXPath:@"/EnumerationResults/Blobs/Blob" 
                 onDocument:doc 
                      block:^(xmlNodePtr node)
     {
         NSString *name = [XmlHelper getElementValue:node name:@"Name"];
         NSString *url = [XmlHelper getElementValue:node name:@"Url"];
       
         Blob *blob = [[Blob alloc] initBlobWithName:name URL:url container:container];
         [blobs addObject:blob];
         [blob release];
     }];
	
	return [[blobs copy] autorelease];
}

+ (NSArray *)loadBlobsForProxy:(xmlDocPtr)doc container:(BlobContainer*)container
{
    if (doc == nil) 
    { 
		return nil; 
	}
    
	NSMutableArray *blobs = [NSMutableArray arrayWithCapacity:30];
    
    [XmlHelper performXPath:@"/*/*/*" 
                 onDocument:doc 
                      block:^(xmlNodePtr node)
     {
         NSString *name = [XmlHelper getElementValue:node name:@"BlobName"];
         NSString *url = [XmlHelper getElementValue:node name:@"Uri"];
         
         Blob *blob = [[Blob alloc] initBlobWithName:name URL:url container:container];
         [blobs addObject:blob];
         [blob release];
     }];
	
	return [[blobs copy] autorelease];
}

@end
