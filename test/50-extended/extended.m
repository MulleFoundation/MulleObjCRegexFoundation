#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


//
// Prints how a pattern matches a subject. The matches are joined, so that a
// class that matches several characters shows up as several matches and the
// output stays deterministic.
//
static void   show( NSString *label,
                    NSString *pattern,
                    NSString *subject,
                    MulleObjCPatternOptions options)
{
   MulleObjCPattern         *pattern_compiled;
   MulleObjCPatternMatch    *match;
   NSMutableString          *joined;

   pattern_compiled = [MulleObjCPattern patternWithString:pattern
                                                  options:options];
   if( ! pattern_compiled)
   {
      mulle_printf( "%@: malformed\n", label);
      return;
   }

   joined = [NSMutableString string];
   for( match in [pattern_compiled matchesInString:subject])
   {
      if( [joined length])
         [joined appendString:@"|"];
      [joined appendString:[match substring]];
   }

   mulle_printf( "%@: %lu [%@]\n",
                 label,
                 (unsigned long) [pattern_compiled numberOfMatchesInString:subject],
                 joined);
}


int   main( void)
{
   MulleObjCPattern   *pattern;
   NSString           *subject;
   unichar            chars[ 3];
   unichar            nbsp;
   unichar            tab;

#if defined( __MULLE_OBJC__)
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) != mulle_objc_universe_is_ok)
      return( 1);
#endif

   //
   // A named class. The tab, the newline and the carriage return are all
   // members, so every run of whitespace is one match.
   //
   show( @"space class, extended",
         @"[[:space:]]+",
         @"a\tb\nc\rd e",
         MulleObjCExtendedPattern);

   //
   // The same class without the option: `[` and `]` are still a class, but
   // `[[:space:]]` is not a name, it is the members `[ : s p a c e` - and the
   // class ends at the first `]`, which leaves a stray `]` behind that has to
   // match literally. So there is no match here.
   //
   show( @"space class, plain",
         @"[[:space:]]+",
         @"a\tb\nc\rd e",
         0);

   //
   // The escape in the class. With the option a tab is a tab, without it `\t`
   // is the letter `t`.
   //
   tab = '\t';
   subject = [NSString stringWithCharacters:&tab
                                     length:1];
   show( @"[ \\t] on a tab, extended",
         @"[ \\t]+",
         subject,
         MulleObjCExtendedPattern);
   show( @"[ \\t] on a tab, plain",
         @"[ \\t]+",
         subject,
         0);
   show( @"[ \\t] on 't', plain",
         @"[ \\t]+",
         @"t",
         0);

   //
   // mulle-unicode decides membership, so this is not an ASCII class. NBSP is
   // whitespace in unicode and `[[:space:]]` accepts it.
   //
   nbsp = 0x00A0;
   subject = [NSString stringWithCharacters:&nbsp
                                     length:1];
   show( @"space class on nbsp",
         @"[[:space:]]",
         subject,
         MulleObjCExtendedPattern);

   //
   // The escaped members of a class. None of these can be spelled without the
   // option, `[\]]` would end the class at the `\` and match the `]` then.
   //
   show( @"[[\\]] on ']'",
         @"[\\]]",
         @"a]b",
         MulleObjCExtendedPattern);
   show( @"[[\\\\]] on backslash",
         @"[\\\\]",
         @"a\\b",
         MulleObjCExtendedPattern);
   show( @"[[\\-]] on '-'",
         @"[\\-]",
         @"a-b",
         MulleObjCExtendedPattern);

   //
   // The negated form is a class like any other.
   //
   show( @"[^[:space:]] on ' a '",
         @"[^[:space:]]",
         @" a ",
         MulleObjCExtendedPattern);

   //
   // [[:word:]] is alphanumeric plus `_`, [[:ident:]] is what a source language
   // accepts in an identifier. They are not the same set : ONE HALF is a
   // number, not an identifier. This is why both are named.
   //
   chars[ 0] = 'a';
   chars[ 1] = 0x00BD;   // ONE HALF
   chars[ 2] = 'b';
   subject   = [NSString stringWithCharacters:chars
                                       length:3];
   show( @"[[:word:]]+ on a ONE HALF",
         @"[[:word:]]+",
         subject,
         MulleObjCExtendedPattern);
   show( @"[[:ident:]]+ on a ONE HALF",
         @"[[:ident:]]+",
         subject,
         MulleObjCExtendedPattern);
   show( @"[[:ident:]]+ on 'abc_1'",
         @"[[:ident:]]+",
         @"abc_1",
         MulleObjCExtendedPattern);

   //
   // An escape that is not defined is a compile error, it is not a literal.
   // The caller sees a nil pattern.
   //
   show( @"\\d, extended",
         @"\\d",
         @"a1",
         MulleObjCExtendedPattern);
   show( @"\\d, plain",
         @"\\d",
         @"ad",
         0);

   //
   // Counting the capture groups has to skip a character class the same way the
   // engine does. With the option an escaped `]` does not end the class, so the
   // `(` after it is a member and not a group.
   //
   pattern = [MulleObjCPattern patternWithString:@"[\\]()]"
                                         options:MulleObjCExtendedPattern];
   mulle_printf( "escaped bracket class: %lu groups\n",
                 (unsigned long) [pattern numberOfCaptureGroups]);
   show( @"escaped bracket class, match",
         @"[\\]()]",
         @"a(b",
         MulleObjCExtendedPattern);

   // without the option the same pattern is a class, that holds the `\\`, and
   // the `(` does open a group
   pattern = [MulleObjCPattern patternWithString:@"[\\]()]"
                                         options:0];
   mulle_printf( "escaped bracket class, plain: %lu groups\n",
                 (unsigned long) [pattern numberOfCaptureGroups]);

   //
   // A group next to a named class still counts and still captures.
   //
   pattern = [MulleObjCPattern patternWithString:@"([[:digit:]]+)[[:space:]]+" options:MulleObjCExtendedPattern];
   mulle_printf( "digit group: %lu groups\n",
                 (unsigned long) [pattern numberOfCaptureGroups]);
   mulle_printf( "digit group: %@\n",
                 [[pattern firstMatchInString:@"ab 123 \n cd"] substringOfCaptureGroupAtIndex:1]);

   return( 0);
}
