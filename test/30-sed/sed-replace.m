#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"\\(b\\)"
                                                       withString:@"-\\1-"
                                                          options:MulleObjCSedPattern]);
   return( 0);
}
