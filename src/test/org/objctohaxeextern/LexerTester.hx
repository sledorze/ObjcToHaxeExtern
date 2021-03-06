package test.org.objctohaxeextern;


import org.objctohaxeextern.Lexer;

class LexerTester extends haxe.unit.TestCase
{
    public function testEnum():Void
    {
    	var objc:String = "typedef NS_ENUM(NSInteger, UIViewContentMode) {\n\tUIViewAnimationTransitionNone,\n\tUIViewAnimationTransitionFlipFromLeft,\n\tUIViewAnimationTransitionFlipFromRight,\n\tUIViewAnimationTransitionCurlUp,\n\tUIViewAnimationTransitionCurlDown,\n};";
    
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(objc);
    	
    	assertEquals(20, tokens.length);
    	
    	assertEquals("enum", tokens[0]);
    	
    }
    
    public function testEnumMultiLine():Void
    {
    	var obj:Array<String> = ["typedef NS_ENUM(NSInteger, UIViewContentMode) {\n",
    		"\tUIViewAnimationTransitionNone,\n",
    		"\tUIViewAnimationTransitionFlipFromLeft,\n",
    		"\tUIViewAnimationTransitionFlipFromRight,\n",
    		"\tUIViewAnimationTransitionCurlUp,\n",
    		"\tUIViewAnimationTransitionCurlDown,\n",
    		"};\n"];
    	
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(obj[0]);
    	
    	assertTrue(lexer.instructionSpansToNextLine);
    	var index:Int = 1;
    	while(lexer.instructionSpansToNextLine)
    	{
    		tokens = tokens.concat(lexer.createTokens(obj[index]));
    		++index;
    	}
    	
    	assertEquals(20, tokens.length);
    	
    	assertEquals("enum", tokens[0]);
    }
    
    public function testEnum2():Void
    {
	    var obj:Array<String> = ["typedef NS_ENUM(NSInteger, UITextBorderStyle) {\n",
	    		"\tUITextBorderStyleNone,\n",
	    		"\tUITextBorderStyleBezel,\n",
	    		"\tUITextBorderStyleRoundedRect\n",
	    		"};\n"];
	    		
	    		
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(obj[0]);
    	
    	assertTrue(lexer.instructionSpansToNextLine);
    	var index:Int = 1;
    	while(lexer.instructionSpansToNextLine)
    	{
    		tokens = tokens.concat(lexer.createTokens(obj[index]));
    		++index;
    	}
    	
    	trace(tokens.join(","));
    	
    	assertEquals(15, tokens.length);
    }
    
    public function testEnumComentsAndValues():Void
    {
	    var obj:Array<String> = ["typedef NS_ENUM(NSInteger, UIViewContentMode) {\n",
	    		"\tUIViewAnimationOptionLayoutSubviews            = 1 <<  0,\n",
	    		"\tUIViewAnimationOptionAllowUserInteraction      = 1 <<  1, // turn on user interaction while animating\n",
	    		"\tUIViewAnimationTransitionFlipFromRight,\n",
	    		"\tUIViewAnimationTransitionCurlUp,\n",
	    		"\tUIViewAnimationTransitionCurlDown,\n",
	    		"};\n"];
	    	
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(obj[0]);
    	
    	assertTrue(lexer.instructionSpansToNextLine);
    	var index:Int = 1;
    	while(lexer.instructionSpansToNextLine)
    	{
    		tokens = tokens.concat(lexer.createTokens(obj[index]));
    		++index;
    	}
    	
    	assertEquals(30, tokens.length);
    }
    
    public function testNSAvailableWithMethod():Void
    {
    	var methodStr:String = "- (UIView *)viewForBaselineLayout NS_AVAILABLE_IOS(6_0);";
    	
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens(methodStr);
    	
    	assertEquals(11, tokens.length);
    }
    
    public function testEndSpanNewLine():Void
    {
    	var lexer:Lexer = new Lexer();
    	
    	var enum1:String = "typedef NS_ENUM(NSInteger, UITableViewCellStyle) {\n";
    	var enum2:String = "};             // available in iPhone OS 3.0\n";
    	
    	lexer.createTokens(enum1);
    	assertTrue(lexer.instructionSpansToNextLine);
    	lexer.createTokens(enum2);
    	assertFalse(lexer.instructionSpansToNextLine);
    	
    }
    
    public function testBlockCommentRemoval():Void
    {
    	var lexer:Lexer = new Lexer();
    	
    	lexer.createTokens("some tokens /* more stuff");
    	lexer.createTokens("some comments");
    	lexer.createTokens("some comments*/");
    	
    	assertEquals(2, lexer.createTokens("1 2").length);
    	
    }
    
    public function testRemoveToEndOfBlockComment():Void
    {
    	var lexer:Lexer = new Lexer();
    	assertEquals("This is it", lexer.removeToEndOfBlockComment("gobble gobble */This is it"));
    }
    
    public function testParseConst():Void
    {
    	var lexer:Lexer = new Lexer();
    	var tokens:Array<String> = lexer.createTokens("UIKIT_EXTERN const CGSize UILayoutFittingExpandedSize NS_AVAILABLE_IOS(6_0);");
    	assertEquals(9, tokens.length);
    	assertEquals("const", tokens[1]);
    }
    
}