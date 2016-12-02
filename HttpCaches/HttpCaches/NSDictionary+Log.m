
#import <Foundation/Foundation.h>

@implementation NSDictionary (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"{\n"];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@:%@,\n", key, obj];
    }];
    [strM appendString:@"\t}\n"];
    
    // 删除最后一个,号
    if (self.count) {
        NSRange range = [strM rangeOfString:@"," options:NSBackwardsSearch];
        [strM deleteCharactersInRange:range];
    }
    return strM;
}
@end

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendString:@"(\n"];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    [strM appendString:@")\n"];
    
//     删除最后一个,号
    if (self.count) {
        NSRange range = [strM rangeOfString:@"," options:NSBackwardsSearch];
        [strM deleteCharactersInRange:range];
    }
    return strM;
}

@end
