#import <Foundation/Foundation.h>

#define PREFS_ID @"com.adserviofilter.prefs"
#define PREFS_PATH @"/var/jb/var/mobile/Library/Preferences/com.adserviofilter.prefs.plist"

static BOOL prefBool(NSString *key, BOOL defaultVal) {
    NSDictionary *p = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
    NSNumber *v = p[key];
    return v ? [v boolValue] : defaultVal;
}

static NSData *filterAdservioJSON(NSData *data) {
    if (!data || data.length == 0) return data;

    BOOL hideAbsences = prefBool(@"hideAbsences", YES);
    BOOL hideGrades   = prefBool(@"hideGrades",   NO);

    if (!hideAbsences && !hideGrades) return data;

    NSError *err = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                             options:NSJSONReadingMutableContainers
                                               error:&err];
    if (err || !json) return data;

    // Returns YES if the item should be removed
    BOOL (^shouldDrop)(id) = ^BOOL(id item) {
        if (![item isKindOfClass:[NSDictionary class]]) return NO;

        // Keys that may carry the type/category string
        NSArray *keys = @[@"type", @"tip", @"tipNoutate", @"title",
                          @"categorie", @"category", @"name"];
        for (NSString *k in keys) {
            id val = item[k];
            if (![val isKindOfClass:[NSString class]]) continue;
            NSString *low = [(NSString *)val lowercaseString];

            if (hideAbsences && [low containsString:@"absent"]) return YES;
            if (hideGrades   && ([low containsString:@"nota"] ||
                                  [low containsString:@"calificativ"] ||
                                  [low containsString:@"grade"])) return YES;
        }
        return NO;
    };

    void (^cleanArray)(NSMutableArray *) = ^(NSMutableArray *arr) {
        NSIndexSet *drop = [arr indexesOfObjectsPassingTest:
            ^BOOL(id obj, NSUInteger idx, BOOL *stop) { return shouldDrop(obj); }];
        [arr removeObjectsAtIndexes:drop];
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

// ─── Hook ────────────────────────────────────────────────────────────────────

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
