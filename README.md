### Comment Object

Inspired by ConradIrwin/vim-comment-object

Usage:

`ac` - around comment
                               /*
	// Comment along here       * Another comment
	// and Here                 */
	codeblock                   codeblock

With `cac` - (cursor on bar)
                                                
                                
	|                            |              
	codeblock                    codeblock         

`ic` - inside comment

	// Comment along here
	// and Here
	codeblock

With `cic` - (cursor on bar)
                                 /*                 
                                  * |
	//|                           */                
	codeblock                     codeblock         
