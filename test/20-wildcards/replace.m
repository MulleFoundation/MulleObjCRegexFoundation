#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"*/b"
                                                       withString:@"."
                                                          options:MulleObjCWildcards]);
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"*/b"
                                                       withString:@"."
                                                          options:MulleObjCWildcards|NSAnchoredSearch]);
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"*/b"
                                                       withString:@"."
                                                          options:MulleObjCWildcards|NSBackwardsSearch]);

   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"b/*"
                                                       withString:@"."
                                                          options:MulleObjCWildcards]);
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"b/*"
                                                       withString:@"."
                                                          options:MulleObjCWildcards|NSAnchoredSearch]);
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"b/*"
                                                       withString:@"."
                                                          options:MulleObjCWildcards|NSBackwardsSearch]);
   return( 0);
}
