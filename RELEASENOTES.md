## 0.21.0


* document `MulleObjCPattern` for reusable, compile-once patterns with capture groups, all-match enumeration and replacement
* document the table-driven `MulleObjCTokenSet`/`MulleObjCTokenizer` with rule dispatch and unrecognized/undeclared-start problem reporting
* document the `NSScanner(Regex)` category for pattern-based scanning
* document `MulleObjCExtendedPattern` and its escapes and named character classes (`[[:alpha:]]`, `[[:ident:]]`)


feature: add tokenizer and pattern matching APIs

* new MulleObjCPattern compiled regex class with capture groups, match enumeration and template based replacement
* new MulleObjCTokenizer, MulleObjCTokenSet and MulleObjCTokenRule classes for rule driven tokenization
* new MulleObjCTokenProblem to report dead or shadowed tokenizer rules
* new NSScanner(Regex) category for pattern based scanning of strings
* NSString(Regex) gains extended pattern language with escapes and named character classes


### 0.20.11




* fixed stale project name in header comments (was MulleObjCRegexExpansion/MulleStringExpansion)
* added standard license headers to generated generic headers
* reorganized API docs and added API summary link to README

### 0.20.10

Various small improvements
