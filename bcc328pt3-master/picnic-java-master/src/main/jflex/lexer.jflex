package parse;

import absyn.Loc;
import error.ErrorHelper;

import java_cup.runtime.Symbol;
import java_cup.runtime.SymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;
import java_cup.runtime.ComplexSymbolFactory;

%%

%public
%final
%class Lexer
%implements Terminals
%cupsym Terminals
%cup
%line
%column
%char

%eofval{
    return tok(EOF);
%eofval}


%ctorarg String unitName

%init{
   this.unit = unitName;
%init}

%{
   private String unit;

   private ComplexSymbolFactory complexSymbolFactory = new ComplexSymbolFactory();

   public SymbolFactory getSymbolFactory() {
      return complexSymbolFactory;
   }

   // auxiliary methods to construct terminal symbols at current location

   private Location locLeft() {
      return new Location(unit, yyline + 1, yycolumn + 1, yychar);
   }

   private Location locRight() {
      return new Location(unit, yyline + 1, yycolumn + 1 + yylength(), yychar + yylength());
   }

   private java_cup.runtime.Symbol tok(int type, Object value, Location left, Location right) {
      return complexSymbolFactory.newSymbol(yytext(), type, left, right, value);
   }

   private Symbol tok(int type, String lexeme, Object value) {
      return complexSymbolFactory.newSymbol(lexeme, type, locLeft(), locRight(), value);
   }

   private Symbol tok(int type, Object value) {
      return tok(type, yytext(), value);
   }

   private Symbol tok(int type) {
      return tok(type, null);
   }

   // Error handling
   private void error(String format, Object... args) {
      throw ErrorHelper.error(Loc.loc(locLeft(), locRight()),
                              "lexical error: " + format,
                              args);
   }

   // Auxiliary variables
   private int commentLevel;
%}

%state COMMENT

litint    = [0-9]+
litbool   = true | false
id        = [a-zA-Z][a-zA-Z0-9_]*

%%

<YYINITIAL>{
[ \t\f\n\r]+ { /* skip */ }
"#" .*       { /* skip */ }
"{#"         { yybegin(COMMENT); commentLevel = 1; }

{litint}     { return tok(LITINT, yytext()); }
{litbool}    { return tok(LITBOOL, yytext()); }

bool         { return tok(BOOL); }
int          { return tok(INT); }
if           { return tok(IF); }
then         { return tok(THEN); }
else         { return tok(ELSE); }
let          { return tok(LET); }
in           { return tok(IN); }

{id}         { return tok(ID, yytext().intern()); }

"="          { return tok(EQ); }
"~="         { return tok(NE); }
"<"          { return tok(LT); }
"<="         { return tok(LE); }
">"          { return tok(GT); }
">="         { return tok(GE); }
"&&"         { return tok(AND); }
"||"         { return tok(OR); }
"+"          { return tok(PLUS); }
"-"          { return tok(MINUS); }
"*"          { return tok(TIMES); }
"/"          { return tok(DIV); }
"^"          { return tok(POWER); }
"("          { return tok(LPAREN); }
")"          { return tok(RPAREN); }
","          { return tok(COMMA); }
}

<COMMENT>{
"{#"         { ++commentLevel; }
"#}"         { if (--commentLevel == 0) yybegin(YYINITIAL); }
[^]          { }
<<EOF>>      { yybegin(YYINITIAL); error("unclosed comment"); }
}

.            { error("invalid character '%s'", yytext()); }
