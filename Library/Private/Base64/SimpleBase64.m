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

#import "SimpleBase64.h"

static char ByteEncode(uint8_t byte);
static uint8_t ByteDecode(char c);

@implementation SimpleBase64

+ (NSString*) encode:(const uint8_t*) input length:(NSInteger) length 
{
	if(!length)
	{
		return @"";
	}
	
	char* output = malloc(1 + ((length + 2) / 3) * 4);
	char* ptr = output;
	
	for(int i = 0; i < length; i += 3)
	{
		uint8_t src1, src2, src3;
		
		src1 = input[i];
		src2 = (i + 1 < length) ? input[i + 1] : 0;
		src3 = (i + 2 < length) ? input[i + 2] : 0;
		
		uint8_t dest1, dest2, dest3, dest4;
		
		dest1 = src1 >> 2;
		dest2 = ((src1 & 0x3) << 4) | (src2 >> 4);
		dest3 = ((src2 & 0xF) << 2) | (src3 >> 6);
		dest4 = src3 & 0x3F;
		
		*ptr++ = ByteEncode(dest1);
		*ptr++ = ByteEncode(dest2);
		*ptr++ = (i + 1 < length) ? ByteEncode(dest3) : '=';
		*ptr++ = (i + 2 < length) ? ByteEncode(dest4) : '=';
	}

	*ptr++ = 0;
	
	NSString* result = [[NSString alloc] initWithCString:output encoding:NSASCIIStringEncoding];
	free(output);
	
	return [result autorelease];
}

+ (NSString*) encode:(NSData*)rawBytes 
{
    return [self encode:(const uint8_t*) rawBytes.bytes length:rawBytes.length];
}

+ (NSData*) decode:(const char*)string length:(NSInteger)inputLength 
{
	if ((string == NULL) || (inputLength % 4 != 0)) 
	{
		return nil;
	}
	
	while (inputLength > 0 && string[inputLength - 1] == '=') 
	{
		inputLength--;
	}
	
	NSInteger outputLength = inputLength * 3 / 4;
	NSMutableData* output = [NSMutableData dataWithLength:outputLength];
	uint8_t* outputBytes = output.mutableBytes;
	
	for(int i = 0; i < inputLength; i += 4)
	{
		char c1, c2, c3, c4;
		
		c1 = string[i];
		c2 = (i + 1 < inputLength) ? string[i + 1] : '=';
		c3 = (i + 2 < inputLength) ? string[i + 2] : '=';
		c4 = (i + 3 < inputLength) ? string[i + 3] : '=';
		
		uint8_t b1 = ByteDecode(c1);
		uint8_t b2 = ByteDecode(c2);
		uint8_t b3 = ByteDecode(c3);
		uint8_t b4 = ByteDecode(c4);
		
		*outputBytes++ = (b1 << 2) | (b2 >> 4);

		if(c3 != '=')
		{
			*outputBytes++ = ((b2 & 0xF) << 4) | (b3 >> 2);

			if(c4 != '=')
			{
				*outputBytes++ = ((b3 & 0x3) << 6) | b4;
			}
		}
	}
	
	return output;
}

+ (NSData*) decode:(NSString*)string 
{
	return [self decode:[string cStringUsingEncoding:NSASCIIStringEncoding] length:string.length];
}

@end

#pragma mark Byte encode/decode

static char ByteEncode(uint8_t byte) 
{
	if (byte < 26) 
	{
		return 'A' + byte;
	}
	if (byte < 52) 
	{
		return 'a' + (byte - 26);
	}
	if (byte < 62) 
	{
		return '0' + (byte - 52);
	}
	if (byte == 62) 
	{
		return '+';
	}
	
	return '/';
}

static uint8_t ByteDecode(char c)
{
	if (c >= 'A' && c <= 'Z')
	{
		return c - 'A';
	}
	
	if (c >= 'a' && c <= 'z')
	{
		return c - 'a' + 26;
	}
	
	if (c >= '0' && c <= '9')
	{
		return  c - '0' + 52;
	}
	
	if(c == '+')
	{
		return 62;
	}
	
	return 63;
}

#pragma mark -
