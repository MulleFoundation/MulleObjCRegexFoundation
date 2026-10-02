#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   MulleObjCPattern           *pattern;
   MulleObjCPatternEnumerator *rover;
   MulleObjCPatternMatch      *match;
   NSArray                    *array;
   NSRange                    range;

#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   //
   // capture groups
   //
   pattern = [MulleObjCPattern patternWithString:@"([a-z]+)-([0-9]+)"];
   mulle_printf( "groups: %lu\n",
                 (unsigned long) [pattern numberOfCaptureGroups]);

   match = [pattern firstMatchInString:@"ab-12 cd-34"];
   mulle_printf( "match: %@\n", [match substring]);
   mulle_printf( "range: %lu,%lu\n",
                 (unsigned long) [match range].location,
                 (unsigned long) [match range].length);
   mulle_printf( "group1: %@\n",
                 [match substringOfCaptureGroupAtIndex:1]);
   mulle_printf( "group2: %@\n",
                 [match substringOfCaptureGroupAtIndex:2]);
   range = [match rangeOfCaptureGroupAtIndex:3];
   mulle_printf( "group3 out of range: %@\n",
                 (range.location == NSNotFound) ? @"yes" : @"no");

   //
   // enumeration via NSArray
   //
   array = [pattern matchesInString:@"ab-12 cd-34 ef-56"];
   mulle_printf( "count: %lu\n",
                 (unsigned long) [array count]);
   for( match in array)
      mulle_printf( "match: %@\n", [match substring]);

   //
   // lazy enumeration
   //
   rover = [pattern matchEnumeratorInString:@"xx-1 yy-22"];
   while( (match = [rover nextObject]))
      mulle_printf( "next: %@\n", [match substring]);

   for( match in [pattern matchEnumeratorInString:@"ab-12"])
      mulle_printf( "forin: %@\n", [match substring]);

   //
   // counting and range limitation
   //
   mulle_printf( "total: %lu\n",
                 (unsigned long) [pattern numberOfMatchesInString:@"ab-12 ab-34 ab-56"]);
   mulle_printf( "in-range: %lu\n",
                 (unsigned long) [pattern numberOfMatchesInString:@"ab-12 ab-34 ab-56"
                                                           range:NSRangeMake( 0, 6)]);

   //
   // anchored search
   //
   pattern = [MulleObjCPattern patternWithString:@"foo"
                                         options:MulleObjCAnchoredSearch];
   mulle_printf( "anchored foo: %@\n",
                 [pattern firstMatchInString:@"foo"] ? @"yes" : @"no");
   mulle_printf( "anchored xfoo: %@\n",
                 [pattern firstMatchInString:@"xfoo"] ? @"yes" : @"no");

   //
   // replace all, backreferences and whole match
   //
   pattern = [MulleObjCPattern patternWithString:@"([a-z]+)-([0-9]+)"];
   mulle_printf( "template: %@\n",
                 [pattern stringByReplacingMatchesInString:@"ab-12 cd-34"
                                              withTemplate:@"\\2-\\1"]);
   mulle_printf( "amp: %@\n",
                 [pattern stringByReplacingMatchesInString:@"ab-12"
                                              withTemplate:@"[&]"]);

   //
   // an empty match terminates and does not loop forever
   //
   pattern = [MulleObjCPattern patternWithString:@"x*"];
   mulle_printf( "empty: %lu\n",
                 (unsigned long) [pattern numberOfMatchesInString:@"abyc"]);

   //
   // group 2 did not participate in the match, it is NSNotFound but still
   // addressable, because the pattern knows it has three groups
   //
   pattern = [MulleObjCPattern patternWithString:@"(a)(b)?(c)"];
   match   = [pattern firstMatchInString:@"ac"];
   mulle_printf( "matched groups: %lu\n",
                 (unsigned long) [match numberOfCaptureGroups]);
   mulle_printf( "group1: %@\n",
                 [match substringOfCaptureGroupAtIndex:1]);
   range = [match rangeOfCaptureGroupAtIndex:2];
   mulle_printf( "group2 unset: %@\n",
                 (range.location == NSNotFound) ? @"yes" : @"no");
   mulle_printf( "group3: %@\n",
                 [match substringOfCaptureGroupAtIndex:3]);

   //
   // an optional group is greedy: `(X)?` takes X when the rest still matches
   // with it, even though skipping X would also match. `(a)?a` on "aa" is the
   // smallest case, and the `set\s*\(\s*(CACHE\{)?\s*(NAME)` shape is the one
   // that was once believed to read `CACHE` instead of `FOO`.
   //
   pattern = [MulleObjCPattern patternWithString:@"(a)?a"];
   match   = [pattern firstMatchInString:@"aa"];
   mulle_printf( "greedy whole: %@\n", [match substring]);
   mulle_printf( "greedy group1: %@\n",
                 [match substringOfCaptureGroupAtIndex:1]);

   pattern = [MulleObjCPattern patternWithString:@"set[[:space:]]*\\([[:space:]]*(CACHE\\{)?[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)"
                                        options:MulleObjCExtendedPattern];
   match   = [pattern firstMatchInString:@"set( CACHE{FOO}"];
   mulle_printf( "cache group2: %@\n",
                 [match substringOfCaptureGroupAtIndex:2]);

   return( 0);
}