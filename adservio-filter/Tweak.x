#import <Foundation/Foundation.h>

static NSData *filterAdservioJSON(NSData *data) {
    if (!data || data.length == 0) return data;

    NSError *err = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                             options:NSJSONReadingMutableContainers
                                               error:&err];
    if (err || !json) return data;

    BOOL (^shouldDrop)(id) = ^BOOL(id item) {
        if (![item isKindOfClass:[NSDictionary class]]) return NO;
        NSArray *keys = @[@"type", @"tip", @"tipNoutate", @"title", @"categorie", @"category"];
        for (NSString *k in keys) {
            id val = item[k];
            if (![val isKindOfClass:[NSString class]]) continue;
            if ([[val lowercaseString] containsString:@"absent"]) return YES;
        }
        return NO;
    };

    void (^cleanArray)(NSMutableArray *) = ^(NSMutableArray *arr) {
        [arr removeObjectsAtIndexes:[arr indexesOfObjectsPassingTest:
            ^BOOL(id obj, NSUInteger idx, BOOL *stop) { return shouldDrop(obj); }]];
    };

    if ([json isKindOfClass:[NSMutableArray class]]) {
        cleanArray(json);
    } else if ([json isKindOfClass:[NSMutableDictionary class]]) {
        for (NSString *k in [(NSDictionary *)json allKeys]) {
            if ([json[k] isKindOfClass:[NSMutableArray class]]) cleanArray(json[k]);
        }
    }

    NSData *out = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    return out ?: data;
}

%hook NSURLSession
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                           completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))ch {
    if ([[request.URL host] containsString:@"adservio"] && ch) {
        return %orig(request, ^(NSData *data, NSURLResponse *resp, NSError *err) {
            ch(filterAdservioJSON(data), resp, err);
        });
    }
    return %orig;
}
%end
