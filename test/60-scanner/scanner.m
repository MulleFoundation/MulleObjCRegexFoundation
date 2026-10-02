#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


static void   show( NSString *label, NSScanner *scanner)
{
   mulle_printf( "  %@: loc=%lu rest=[%@]\n",
                 label,
                 (unsigned long) [scanner scanLocation],
                 [[scanner string] substringFromIndex:[scanner scanLocation]]);
}


int   main( void)
{
   MulleObjCPattern         *empty;
   MulleObjCPattern         *letters;
   MulleObjCPattern         *number;
   MulleObjCPattern         *pair;
   MulleObjCPatternMatch    *match;
   NSScanner                *scanner;
   NSCharacterSet           *space;
   NSString                 *scanned;

#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   space   = [NSCharacterSet whitespaceCharacterSet];
   letters = [MulleObjCPattern patternWithString:@"[a-z]+"];
   number  = [MulleObjCPattern patternWithString:@"-[0-9]+"];
   pair    = [MulleObjCPattern patternWithString:@"([a-z]+)-([0-9]+)"];
   empty   = [MulleObjCPattern patternWithString:@"x*"];

   //
   // NSScanner already skips whitespace and newlines, naming the set here only
   // makes that visible
   //
   scanner = [NSScanner scannerWithString:@"  ab-12 cd-34"];
   [scanner setCharactersToBeSkipped:space];

   mulle_printf( "letters: %@\n",
                 [scanner scanPattern:letters] ? @"yes" : @"no");
   show( @"ab", scanner);

   //
   // a pattern that only matches further ahead is not a match *here*, and the
   // location must not move
   //
   mulle_printf( "letters again: %@\n",
                 [scanner scanPattern:letters] ? @"yes" : @"no");
   show( @"stuck", scanner);

   mulle_printf( "number: %@\n",
                 [scanner scanPattern:number] ? @"yes" : @"no");
   show( @"-12", scanner);

   //
   // the skip happens before the match, so this one reaches "cd"
   //
   mulle_printf( "letters: %@\n",
                 [scanner scanPattern:letters] ? @"yes" : @"no");
   show( @"cd", scanner);

   //
   // skipped characters stay consumed when the pattern then fails - the
   // behavior the built in scan methods have
   //
   scanner = [NSScanner scannerWithString:@"   x"];
   mulle_printf( "number: %@\n",
                 [scanner scanPattern:number] ? @"yes" : @"no");
   show( @"skipped", scanner);

   //
   // the capture groups come with the match
   //
   scanner = [NSScanner scannerWithString:@"ab-12"];
   mulle_printf( "pair: %@\n",
                 [scanner scanPattern:pair
                            intoMatch:&match] ? @"yes" : @"no");
   mulle_printf( "  match: %@\n", [match substring]);
   mulle_printf( "  group1: %@\n", [match substringOfCaptureGroupAtIndex:1]);
   mulle_printf( "  group2: %@\n", [match substringOfCaptureGroupAtIndex:2]);
   show( @"done", scanner);

   //
   // and a failed scan leaves the match nil
   //
   scanner = [NSScanner scannerWithString:@"ab"];
   mulle_printf( "pair: %@\n",
                 [scanner scanPattern:pair
                            intoMatch:&match] ? @"yes" : @"no");
   mulle_printf( "  match nil: %@\n", match ? @"no" : @"yes");
   show( @"unchanged", scanner);

   //
   // scanUpToPattern: gobbles up to the match and leaves the location there
   //
   scanner = [NSScanner scannerWithString:@"ab-12.cd-34"];
   mulle_printf( "pair: %@\n",
                 [scanner scanPattern:pair] ? @"yes" : @"no");
   mulle_printf( "up: %@\n",
                 [scanner scanUpToPattern:letters
                              intoString:&scanned] ? @"yes" : @"no");
   mulle_printf( "  gobbled: [%@]\n", scanned);
   show( @"cd", scanner);

   //
   // already there: YES with the empty string and no movement
   //
   mulle_printf( "up here: %@\n",
                 [scanner scanUpToPattern:letters
                              intoString:&scanned] ? @"yes" : @"no");
   mulle_printf( "  gobbled: [%@]\n", scanned);
   show( @"unchanged", scanner);

   //
   // and NO with the empty string when it never matches
   //
   mulle_printf( "cd: %@\n",
                 [scanner scanPattern:letters] ? @"yes" : @"no");
   mulle_printf( "up: %@\n",
                 [scanner scanUpToPattern:letters
                              intoString:&scanned] ? @"yes" : @"no");
   mulle_printf( "  gobbled: [%@]\n", scanned);

   //
   // a zero length match is a failure, so a successful scan always advances
   //
   scanner = [NSScanner scannerWithString:@"abc"];
   mulle_printf( "empty: %@\n",
                 [scanner scanPattern:empty] ? @"yes" : @"no");
   show( @"unchanged", scanner);

   //
   // and at the end of the text there is nothing to match
   //
   scanner = [NSScanner scannerWithString:@""];
   mulle_printf( "empty text: %@\n",
                 [scanner scanPattern:letters] ? @"yes" : @"no");
   show( @"unchanged", scanner);

   return( 0);
}
