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

#import "XmlHelper.h"


@implementation XmlHelper

+ (void)performXPath:(NSString*)xpath onDocument:(xmlDocPtr)doc block:(void (^)(xmlNodePtr))block
{
    [self performXPath:xpath onNode:(xmlNodePtr)doc block:block];
}

+ (void)performXPath:(NSString*)xpath onNode:(xmlNodePtr)node block:(void (^)(xmlNodePtr))block
{
    xmlDocPtr doc;
    if(node->type == XML_DOCUMENT_NODE)
    {
        doc = (xmlDocPtr)node;
    }
    else
    {
        doc = node->doc;
    }
    
    xmlXPathContextPtr xpathCtx = xmlXPathNewContext(doc);
    if (!xpathCtx) 
    {
        return;
    }
    
    xmlNodePtr root = xmlDocGetRootElement(doc);
    xpathCtx->node = ((void*)node == (void*)doc) ? root : node;
    
    // anchor at our current node
    if (root != NULL) 
    {
        for (xmlNsPtr nsPtr = root->nsDef; nsPtr != NULL; nsPtr = nsPtr->next) 
        {
            const xmlChar* prefix = nsPtr->prefix;
            if (prefix != NULL) 
            {
                xmlXPathRegisterNs(xpathCtx, prefix, nsPtr->href);
            }
            else
            {
                xmlXPathRegisterNs(xpathCtx, (xmlChar*)"_default", nsPtr->href);
            }            
        }
    }   
    
/*    int i = 0;
    xmlNsPtr *nsList = xmlGetNsList(doc, xpathCtx->node);
    
    if (nsList != NULL) 
    {
        while (nsList[i] != NULL)
        {
            i++;
        }
    }
    
    xpathCtx->namespaces = nsList;
    xpathCtx->nsNr = i; */
    
    xmlXPathObjectPtr xpathObj;
    xpathObj = xmlXPathEval((const xmlChar *)[xpath UTF8String], xpathCtx);
    if (xpathObj) 
    {
        xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
        if (nodeSet) 
        {
            for (int index = 0; index < nodeSet->nodeNr; index++) 
            {
                block(nodeSet->nodeTab[index]);
            }
        }

        xmlXPathFreeObject(xpathObj);
    }
    
    xmlXPathFreeContext(xpathCtx);
//    xmlFree(nsList);
}

+ (NSString*)getElementValue:(xmlNodePtr)parent name:(NSString*)name
{
    xmlChar* nameStr = (xmlChar*)[name UTF8String];
    
    for(xmlNodePtr child = xmlFirstElementChild(parent); child; child = xmlNextElementSibling(child))
    {
        if(xmlStrcmp(child->name, nameStr) == 0)
        {
            xmlChar* value = xmlNodeGetContent(child);
            NSString* str = [NSString stringWithUTF8String:(const char*)value];
            xmlFree(value);
            return str;
        }
    }
    
    return nil;
}

+ (NSError*)checkForError:(xmlDocPtr)doc
{
    if(!doc)
    {
        return nil;
    }
    
    xmlNodePtr root = xmlDocGetRootElement(doc);
    if(xmlStrcmp(root->name, (xmlChar*)"Error") == 0)
    {
        NSString* code = [self getElementValue:root name:@"Code"];
        NSString* message = [self getElementValue:root name:@"Message"];
        NSString* detail = [self getElementValue:root name:@"AuthenticationErrorDetail"];
        
        return [NSError errorWithDomain:@"com.microsoft.AzureIOSToolkit" 
                                   code:-1 
                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                         message, NSLocalizedDescriptionKey, 
                                         detail, NSLocalizedFailureReasonErrorKey, 
                                         code, @"AzureReasonCode", nil]];
    }

    if(xmlStrcmp(root->name, (xmlChar*)"error") == 0)
    {
        NSString* code = [self getElementValue:root name:@"code"];
        NSString* message = [self getElementValue:root name:@"message"];
        
        return [NSError errorWithDomain:@"com.microsoft.AzureIOSToolkit" 
                                   code:-1 
                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                         message, NSLocalizedDescriptionKey, 
                                         code, @"AzureReasonCode", nil]];
    }
    
    return nil;
}

+ (void)parseAtomPub:(xmlDocPtr)doc block:(void (^)(AtomPubEntry *))block
{
    [XmlHelper performXPath:@"/_default:feed/_default:entry" onDocument:doc block:^(xmlNodePtr node)
     {
         AtomPubEntry* entry = [[AtomPubEntry alloc] initWithNode:node];
         block(entry);
         [entry release];
     }];
}

@end
