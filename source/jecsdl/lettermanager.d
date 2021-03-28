//#seems to be redundant
//#DISPLAY_W )
//#no draw here yet
//#Ctrl + Delete to suck
//#shoudn't it be struct
//#poll key event
//#read key input

//wait = /+ might possibly be true on wednesdays - Hamish +/ true;
//#remed out
//#page up
//#I do not know how!
//#setTextClipboard
//#draw
//#need more than that (eg g_cr as well)
//#unused
//#unused
//#unused
//#character adder
//#not sure about this/these
//#I don't know if 'ref' does anything.
//#is this worth keeping?
//#not nice
/// Letter Manager
///
/// Handles printing and layout of letters also input
module jecsdl.lettermanager;

import std.stdio;
import std.range;
import std.conv;

import jecsdl;

version = AutoScroll;

/// Letter Manager
class LetterManager { //#shoudn't it be struct
private:
	SDL_Texture*[char] m_bmpLetters;
	SDL_Texture*[char][] m_bmpLettersMulti;
//	RenderTexture _stampArea;
	SDL_Texture* _stampArea;
	/// Draw to screen
	//Sprite _letSpriteBlock;
	string[] _history;
	size_t _hpos;

	//SDL_Texture*[] m_charSets;

	int m_width, /// letter width
		m_height; /// letter height

	int m_pos;
	bool m_wait;
	Lettera[] m_letters;
	bool m_alternate;
	SDL_Rect m_square;
	string m_copiedText;
	SDL_Color m_backgroundColour;

	JRectangle _cursorGfx;
	bool _textSelected;
	ubyte _currentgGfxIndex;
public:
	enum TextType {block, line} /// Text type
	TextType m_textType; /// Method text type
	SDL_Texture* getTextureLetter(char l) {
		if (l in m_bmpLetters)
			return m_bmpLetters[l];
		else
			return m_bmpLetters['?'];
	}

	void addHistory() {
		_history ~= getText();
		// _hpos += 1;
		_hpos = _history.length;
	}

	void undoHistory() {
		// addHistory();
		if (_history.length == 0)
			return;
		_hpos -= 1;
		if (_hpos == -1) {
			_hpos = 0;
			return;
		}
		setText(_history[_hpos]);
		g_doLetUpdate = true;
		// debug mixin(tce("/* undo: */ _hpos"));
	}

	void redoHistory() {
		// addHistory();
		if (_history.length == 0 || _hpos == _history.length)
			return;
		_hpos += 1;
		if (_hpos == _history.length) {
			_hpos = _history.length;
			return;
		}
		setText(_history[_hpos]);
		g_doLetUpdate = true;
		// debug mixin(tce("/* redo: */ _hpos"));
	}

	SDL_Texture* stampArea() { return _stampArea; }

	ubyte currentGfxIndex() { return _currentgGfxIndex; }

	/// character set setter
	void currentGfxIndex(ubyte gfx) {
		if (gfx < bmpLettersMultiLength)
			_currentgGfxIndex = gfx;
		else
			assert(0, "index out of range!");
	}

	/// get/set letters (Letter[])
	ref auto letters() { return m_letters; }
	//@property ref auto area() { return m_area; } /// get/set bounds
	
	/// get/set square(x, y, w, h) (text box)
	ref auto square() { return m_square; }
	
	/// get/set alternating colours on or off
	ref auto alternate() { return m_alternate; }
	
	/// get number of letters (including white space)
	auto count() { return cast(int)letters.length; } 
	
	/// access cursor position
	ref auto pos() { return m_pos; }
	
	/// access cursor position
	ref auto wait() { return m_wait; }
	//@property ref auto copiedText() { return m_copiedText; } /// access copiedText (string) //#remed out
	
	/// letters width
	ref auto width() { return m_width; }
	
	/// letters height
	ref auto height() { return m_height; }
	
	/// letters height
	ref auto bmpLetters() { return m_bmpLetters; }
	
	/// Copied text setter
	//void copiedText(string ctext0) { m_copiedText = ctext0; }
	void copiedText(string ctext0) {
		setClipboardText(ctext0);

		//m_copiedText = ctext0;
	}
	
	/// Copied text getter
	//string copiedText() { return m_copiedText; }
	string copiedText() { return getClipboardText; }

	/// copy selected text
	void copySelectedText() {
		import std.algorithm: each;

		m_copiedText.length = 0;
		foreach(l; letters)
			if (l.selected)
				m_copiedText ~= l.letter;
		copiedText(m_copiedText);
	}

	/// Paste copied text
	void pasteFromCopiedText() {
		pasteInputText;
	}

	ubyte bmpLettersMultiLength() {
		return cast(ubyte)m_bmpLettersMulti.length;
	}

	void chooseTextGfx(in ubyte index) {
		if (index < m_bmpLettersMulti.length) {
			m_bmpLetters = m_bmpLettersMulti[index];
		} else
			throw new Exception(text(__FUNCTION__, " - index out of bounds (",
				index, ") limit is 0-", m_bmpLettersMulti.length - 1, ", defaulting to 0"));
	}
	
	/// ctor, setting area
	this(in string fileName, int lwidth, int lheight, SDL_Rect asquare) {
		this([fileName], lwidth, lheight, asquare);
	}
 
	// main ctor
	this(in string[] fileNames, int lwidth, int lheight, SDL_Rect asquare) {
		width = lwidth;
		height = lheight;
		foreach(name; fileNames) {
			m_bmpLettersMulti ~= getLetters(name, null, width);
		}

		//_stampArea = SDL_CreateRGBSurface(0, asquare.width, asquare.height, 32, 0,0,0,0xFF);
		//_stampArea.create(asquare.width, asquare.height);
		//_letSpriteBlock = new Sprite;
		_stampArea = SDL_CreateTexture(gRenderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_TARGET,
			asquare.w, asquare.h);
		SDL_SetRenderTarget(gRenderer, null); //#seems to be redundant - maybe good practice
		import std.string : split;
		mixin(tce("asquare.w asquare.h".split));
		/+
		_cursorGfx = new RectangleShape;
		with(_cursorGfx) {
			size(Point(width, height));
			fillColor = Color(128,128,128, 128);
		}
		+/
		_cursorGfx = JRectangle(SDL_Rect(0,0, width, height), BoxStyle.solid, SDL_Color(255,255,255, 64));

		debug(10)
			writeln(width, ' ', height);
		try
			chooseTextGfx(0); // 0 or 1
		catch(Exception e) {
			writeln(e.msg);
			chooseTextGfx(1);
		}
		pos = -1;
		square = asquare;
		//with(asquare)
		//	this.square = SDL_Rect(cast(int)xpos,cast(int)ypos, width, height);
	}

	/// dtor Deal with C allocated memory
	~this() {
		import std.stdio : writeln;
		static cnt = 0;
		writeln("Deallowcate! ", cnt);
		cnt += 1;
		SDL_DestroyTexture(_stampArea);
		foreach(b; m_bmpLetters)
			SDL_DestroyTexture(b);
		foreach(m; m_bmpLettersMulti)
			foreach(b; m)
				SDL_DestroyTexture(b);
	}

	/// copy letters to bmps
	SDL_Texture*[char] getLetters(in string spritesFileName, in string order, int step) {
		SDL_Texture*[char] tletters;
		import std.string : toStringz;
		SDL_Surface* source = IMG_Load(spritesFileName.toStringz);
		if (source is null) {
			import std.string : fromStringz;
			writeln("Error loading bitmap file: ", IMG_GetError().fromStringz);
		}
		if (order is null) {
			foreach(char i; 32 .. 126 + 1) {
				SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormat(0, width, height - 1, 32, SDL_PIXELFORMAT_RGBA32);
				scope(exit)
					SDL_FreeSurface(surf);
				SDL_Rect rsrc = {(i - 32) * step, 1, width, height - 1};
				SDL_BlitSurface(source, &rsrc, surf, null);
				tletters[i] = SDL_CreateTextureFromSurface(gRenderer, surf);
			}
		}
		return tletters;
	}

	/// set type of text (block, line)
	void setTextType( TextType textType ) {
		m_textType = textType;
	}

	/// Get letter using passed index number
	//#is this worth keeping?
	Lettera opIndex(int pos) {
		assert( pos >= 0 && pos < count, "opIndex" );
		return letters[pos];
	}
	
	/// lock/unlock all letters
	void setLockAll( bool lock0 ) {
		foreach( l; letters )
			l.lock = lock0;
	}
	
	/// Add text with new line added to the end
	//string addTextln( string str ) {
	auto addTextln(T...)(T args) {
		import std.typecons: tuple;
		import std.conv: text;

		immutable str = text(tuple(args).expand);
		string result = getText() ~ str ~ "\n";
		setText( result );

		return result;
	}
	
	/// Add text without new line being added to the end
	//void addText( string str ) {
	void addText(T...)(T args) {
		import std.typecons: tuple;
		import std.conv: text;

		auto str = text(tuple(args).expand);
		auto lettersStartLength = count;
		letters.length = lettersStartLength + str.length;
		foreach( index, l; str )
			letters[lettersStartLength + index] = Lettera(this,l, currentGfxIndex);
		pos = count - 1.to!int();
		placeLetters();
	}

	/// apply text from string - also places text
	// void setText(T...)(T args, bool addHistory = true) { //( in string stringLetters ) {
	void setText(T...)(T args) { //( in string stringLetters ) {
		import std.typecons: tuple;
		import std.conv: text;

		auto str = text(tuple(args).expand);
		letters.length = 0; // clear letter array
		letters.length = str.length;
		foreach(index, l; str)
			letters[index] = Lettera(this,l, currentGfxIndex);
		pos = cast(int)letters.length - 1;
		placeLetters();
		// addHistory();
	}

	/// Get converted text (string format)
	string getText() {
		auto str = new char[](letters.length);
		foreach(index, ref l; letters) { // ref for more speed
			str[index] = cast(char)l.letter;
		}

		return str.idup;
	}
	
	/// Postion text for display
	void placeLetters() {
		//"placeLetters".gh;
		//auto inword = false;
		//auto startWordIndex = -1;
		SDL_Color[] altcols = [SDL_Color(255, 180, 0, 0xFF), SDL_Color(255,0,0, 0xFF)];
		auto altcolcyc = 0;
		int x = 0, y = 0;
		int i = 0;
		Lettera l;
		while(i < letters.length) { // foreach(i, ref l; letters ) {
			l = letters[i];
			auto let = cast(char)l.letter;
			// if do new line
			if ( x + width > square.w || let == '\n') {
				if (let == '\n') {
					x = -width;
				} else {
					immutable iwas = i;

					int xi = x;
					x = 0;
					import std.algorithm : canFind;

					//while(! " -,.:;".canFind(letters[i].letter)) {
					while(! " ".canFind(letters[i].letter)) {
						i -= 1;
						xi -= width;
						if (i == -1 || xi < 0) {
							i = iwas;
							l = letters[i];
							break;
						} else l = letters[i];
					}
					if (i != iwas)
						x = -width;
					else {
						if (letters[i].letter == ' ') {
							i += 1;
							if (i != letters.length)
								l = letters[i];
						}
					}
				}
				y += height;
				if ( alternate == true ) {
					altcolcyc |= 1; // or should it be altcolcyc ^= 1; //( altcolcyc == 0 ? 1 : 0 );
				}
				// scroll
				if ( y + height > square.y + square.h) {
					foreach(ref l2; letters )
						l2.ypos -= height;
					y -= height;
				}
			}
			l.setPostion( x, y );
			if ( alternate == true ) {
				l.alternate = true; //#not nice
				l.altColour = altcols[ altcolcyc ];
			}
			if (i < letters.length)
				letters[i] = l;
			x += width;
			i += 1;
		} // while
		
		//#I do not know how!
		/+
		if ( y < ypos )
			foreach( l2; letters )
				l2.ypos -= height;
		+/
	}
	
	/// Eg. bouncing letters
	void update() {
		foreach( ref l; letters ) //#I don't think 'ref' does anything.
			l.update();
	}
	
	// array, start pos, step, delegate
	//int search( Letter[] arr, int stpos, int step, bool delegate ( Letter ) let ) {
	/// Check each letter starting from a curtain postion, going a curtain direction and not past a curtain limit
	int searchForProperty( int stpos, int step, int limit, bool delegate ( int ) dg ) {
		foreach( i; iota( stpos, limit, step ) )
			if ( dg( i ) == true )
				return i;
		return -1;
	}

	/// Lock letter
	bool pLock( int a ) {
		return letters[ a ].lock;
	}

	/// Copy input text
	void copyInputText() {
		if (count > 1) {
			int lastLocked = searchForProperty( count() - 1, -1, -1, 
				&pLock //#not sure about this/these
			);
			
			if (lastLocked != count) {
				copiedText = getText()[ lastLocked + 1.. $ ];
				//#setTextClipboard
				//setTextClipboard( copy );
			}
		}
	}
	
	/// Paste input text
	void pasteInputText() {
		letters.length = searchForProperty(
			/+ start: +/ count - 1,
			/+ end: +/ -1,
			/+ step: +/ -1,
			/+ rule(s): +/ &pLock
		) + 1;
		addText( copiedText );
		pos = count - 1;
	}

	/// Main function for recieving key presses
	char doInput(ref bool enterPressed) {
		char c;
		auto st = jx.getKeyString;
		g_doLetUpdate = false;
		if (! jx.keyControl && ! jx.keyAlt && ! jx.keySystem && st.length == 1) {
			c = cast(char)st[0];
			g_doLetUpdate = true;
		}

		void ifUnselect() {
			if (! jx.keyShift && _textSelected) {
				import std.algorithm: each;

				letters.each!((ref l) => l.selected = false);
				_textSelected = false;
			}
		}

		void directionalMostly() {
			if (jx.keyControl) {
				if (g_keys[SDL_SCANCODE_Z].keyTrigger && ! jx.keyShift) {
					// gh;
					undoHistory;
					g_doLetUpdate = true;
				}

				if (g_keys[SDL_SCANCODE_A].keyTrigger) {
					import std.algorithm: each;

					letters.each!((ref l) => l.selected = ! l.lock ? true : false);
					g_doLetUpdate = true;
					foreach(ref l; letters) { 
						if (! l.lock) {
							_textSelected = true;
							break;
						}
					}
				}

				if (gGlobalText && g_keys[SDL_SCANCODE_C].keyTrigger) {
					//copyInputText();
					copySelectedText;
					g_doLetUpdate = true;
				}

				if (gGlobalText && g_keys[SDL_SCANCODE_V].keyTrigger) {
					//pasteInputText();
					pasteFromCopiedText;
					g_doLetUpdate = true;
				}

				if (g_keys[SDL_SCANCODE_UP].keyInput) {
					int i = pos;
					for( i = pos; i > -1 && letters[ i ].lock == false; --i )
					{}
					pos = i;
					g_doLetUpdate = true;
					ifUnselect;
				}

				if (g_keys[SDL_SCANCODE_DOWN].keyInput) {
					pos = count - 1;
					g_doLetUpdate = true;
					ifUnselect;
				}

				/*
				if (g_keys[Keyboard.Key.BackSpace].keyInput) {
					int i;
					for( i = count() - 1;
						i >= 0 && letters[ i ].lock == false; --i )
					{}
					letters.length = i + 1;
					pos = i;
					g_doLetUpdate = true;
					ifUnselect;
				}
				*/

				if (g_keys[SDL_SCANCODE_LEFT].keyInput && pos >= 0 ) {
					int i = pos;
					for( ; i > 0 && letters[ i ].lock == false
						&& cast(int)letters[ i ].xpos != 0; --i ) { }
					pos = i - 1;
					g_doLetUpdate = true;
					ifUnselect;
				}
				
				if (g_keys[SDL_SCANCODE_RIGHT].keyInput && pos < count - 1 ) {
					ifUnselect;
					int hght = cast(int)letters[ pos > -1 ? pos + 1 : 1 ].ypos;
					auto offTheEnd = true;
					foreach( i; iota( pos, count, 1 ) ) {
						if (i < 0) {
							writeln("Out of range: ", i);
							break;
						}
						if ( letters[ i ].ypos != hght ) {
							if ( letters[ i ].xpos + width * 2 > square.w )
								i -= 2;
							else
								--i;
							pos = i;
							offTheEnd = false;
							break;
						}
					}
					if ( offTheEnd == true )
						pos = count - 1;
					g_doLetUpdate = true;
					ifUnselect;
				}
			} // ctrl key
				
			if (jx.keyAlt) {
				if (g_keys[SDL_SCANCODE_LEFT].keyInput) {
					if ( pos > -1 && letters[ pos ].lock != true ) {
						int i = 0;
						for( i = pos - 1;
							i > -1 && letters[ i ].letter != ' '
							&& letters[ i ].lock == false; --i )
						{}
						if ( pos > -1 )
							pos = i;
					}
					g_doLetUpdate = true;
					ifUnselect;
				}
				if (g_keys[SDL_SCANCODE_RIGHT].keyInput) {
					int i = 0;
					for( i = pos + 1;
						i < letters.length &&
						letters[ i ].letter != ' ' ; ++i )
					{}
					if ( i < letters.length )
						pos = i;
					else
						pos = letters.length.to!int() - 1.to!int();
					g_doLetUpdate = true;
					ifUnselect;
				}
			} // alt key
				
			if (! jx.keyControl && ! jx.keyAlt && ! jx.keySystem) {
				if (g_keys[SDL_SCANCODE_LEFT].keyInput && count > 0 ) {
					if ( pos - 1 > -2 )
						--pos;
					if ( letters[ pos + 1 ].lock == true )
						++pos;
					g_doLetUpdate = true;
					ifUnselect;
				}

				if (g_keys[SDL_SCANCODE_RIGHT].keyInput) {
					++pos;
					if ( pos >= letters.length  )
						--pos;
					g_doLetUpdate = true;
					ifUnselect;
				}
				
				if (g_keys[SDL_SCANCODE_UP].keyInput && count > 0 && pos != -1 ) {
					int xpos = cast(int)letters[ pos ].xpos,
						ypos = cast(int)letters[ pos ].ypos - height;
					foreach_reverse(i, l; letters[0 .. pos]) {
						if (l.lock == true)
							break;
						if (cast(int)l.xpos == xpos && cast(int)l.ypos == ypos) {
							pos = cast(int)i;
							break;
						}
					}
					g_doLetUpdate = true;
					ifUnselect;
				} // key up
				
				if (g_keys[SDL_SCANCODE_DOWN].keyInput && count > 0 && pos != -1 ) {
					int xpos = cast(int)letters[ pos ].xpos,
						ypos = cast(int)letters[ pos ].ypos + height;
					foreach(i, l; letters[pos .. $]) {
						if (cast(int)l.xpos == xpos && cast(int)l.ypos == ypos) {
							pos = pos + cast(int)i;
							break;
						}
					}
					g_doLetUpdate = true;
					ifUnselect;
				} // key down
			} // if not control pressed
		} // directionalMostly()

		if (jx.keyControl && jx.keyShift) {
			if (g_keys[SDL_SCANCODE_Z].keyTrigger) {
				redoHistory;
				g_doLetUpdate = true;
			}
		}

		directionalMostly();
/+
		if (jx.keySystem && ! jx.keyControl && ! jx.keyAlt) {
			if (g_keys[SDL_SCANCODE_A].keyInput) {
				"command+A".gh;
				import std.algorithm: each;

				letters.each!(l => l.selected = ! l.lock ? true : false);
				g_doLetUpdate = true;
				foreach(l; letters)
					if (! l.lock) {
						_textSelected = true;
						break;
					}
			}
		} // system key 2
+/
		auto doPut = false;
		
		//#character adder
		if ( chr( c ) >= 32 && c != char.init) {
			doPut = true;
			//insert letter
			// pos = -1
			// Bd press a -> aBc
			// #              #
			//mixin( traceLine( "pos letters.length".split ) );
			letters = letters[ 0 .. pos + 1 ] ~
				Lettera(this,chr(c), currentGfxIndex) ~ letters[pos + 1 .. $];
			++pos;
			placeLetters();
			g_doLetUpdate = true;
		}
		
		if (g_keys[SDL_SCANCODE_RETURN].keyInput) {
			addHistory();
			enterPressed = true;
			final switch ( m_textType ) {
				case TextType.block:
					letters = letters[ 0 .. pos + 1 ]
						~ Lettera(this, '\n', currentGfxIndex)
						~ letters[ pos + 1 .. $ ];
					pos += 1; // was += 2;
					placeLetters();
				break;
				case TextType.line:
					letters ~= Lettera(this, '\n', currentGfxIndex);
				break;
			} // switch
			g_doLetUpdate = true;
		}
		
		if (! jx.keyControl && g_keys[SDL_SCANCODE_BACKSPACE].keyInput && pos > -1
			&& letters[ pos ].lock == false) {
			if (_textSelected) {
				int i;
				text(count(), " - count").gh;
				for( i = count() - 1;
					i >= 0 && letters[ i ].lock == false; --i )
				{}
				//letters.length = i + 1;
				//pos = i;
				if (i < 0) {
					"back space, i < 0".gh;
				} else {
					int st2 = -1, ed = -1;
					foreach(i2, l; letters[i .. $]) {
						if (l.selected && st2 == -1) {
							st2 = cast(int)i2 + i;
						} else if (st2 != -1 && ! l.selected) {
							ed = cast(int)i2 + i - 2;
						}
					}
					if (ed == -1)
						ed = count;
					trace!st2; trace!ed;
					if (st2 == -1) {
						gh("Some thing wrong!");
					} else {
						letters = letters[0 .. st2] ~
							letters[ed .. $];
						//pos = ed - 1;
						pos = i;
						placeLetters();
						g_doLetUpdate = true;
					}
					_textSelected = false;
				}
			} else {
				doPut = true;
				version( Terminal )
					write( " \b" );
				letters = letters[ 0 .. pos ] ~ letters[ pos + 1 .. $ ];
				--pos;
				placeLetters();
				g_doLetUpdate = true;
			}
		}
		
		//Suck - it sucks (letters that is)
		version(none) { //#Ctrl + Delete to suck
		if (g_keys[Keyboard.Key.BackSpace].keyInput
			&& pos != count - 1) {
			// pos = 0
			// aBc press del -> aC
			//  #                #
			letters = letters[ 0 .. pos + 1 ] ~ letters[ pos + 2 .. $ ],
			placeLetters();
		}
		} // version

		version( Terminal ) {
			if ( doPut ) 
				write( cast(char)c ~ "#\b" );
			std.stdio.stdout.flush;
		}

		return chr( c ); //#unused
	}
	
	/// Draw cursor
	void draw() {
		if (g_doLetUpdate) {
			g_doLetUpdate = false;
			//_stampArea.clear(Colour.black);
			if (count > 0) {
				//mixin(trace("count"));
				SDL_SetRenderTarget(gRenderer, stampArea);
				assert(stampArea, "Stamp!");

				//SDL_SetRenderDrawColor(gRenderer, 128,128,0, 0);
				SDL_SetRenderDrawColor(gRenderer, 0,0,0, 0xFF);
				SDL_RenderClear(gRenderer);

				foreach(ref l; letters)
					l.draw;
			}
			double xpos;
			double ypos;
			if (letters.length > 0 && pos > -1) {
				xpos = letters[pos].xpos;
				ypos = letters[pos].ypos;
			} else {
				xpos = -width;
				ypos = 0;
			}
			if (xpos + width >= square.x + square.w) {
				xpos = -width;
				ypos += height;
			}

			_cursorGfx.position = Point(cast(float)xpos + width, cast(float)ypos);
			_cursorGfx.draw;

			//_stampArea.draw(_cursorGfx);
			//_stampArea.display;
			//const letTexture = _stampArea.getTexture;
			//_letSpriteBlock.setTexture(letTexture);
			SDL_SetRenderTarget(gRenderer, null);
		} // if update
		//g_window.draw(_letSpriteBlock);
		// Render the actual render target texture to the default render target
		import std.string : split;
		//mixin(trace("m_square.x m_square.y m_square.w m_square.h".split));
		
		SDL_RenderCopy(gRenderer, stampArea, null, &m_square);
		// auto centre = SDL_Point(0,0);
		// SDL_RendererFlip flip;
		//SDL_RenderCopyEx(gRenderer, stampArea, null, &m_square, 0, &centre, flip);

		//SDL_Rect r = {25,50, 32,32};
		//SDL_RenderCopy(gRenderer, getTextureLetter('J'), null, &r);
	}
}
