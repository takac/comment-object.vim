### Comment Object

Inspired by ConradIrwin/vim-comment-object

Usage:

`ac` - around comment

                               /*
	// Comment along here       * Another comment
	// and Here                 */
	codeblock                   codeblock

With `cac` - (cursor as bar)
                                                
                                
	|                            |              
	codeblock                    codeblock         

`ic` - inside comment

                                 /*                 
	// Comment along here         * Another comment 
	// and Here                   */                
	codeblock                     codeblock         

With `cic` - (cursor as bar)

                                 /*                 
                                  * |
	//|                           */                
	codeblock                     codeblock         
