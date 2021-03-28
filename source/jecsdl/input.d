//#not used
//#here
//#new, untested
//#hack
 //#new
module jecsdl.input;

//debug = 5;

//#put some restriction
//#under construction
//#shouldn't be here
//#key doesn't work with DSFML!
//#up key press
//#define oneLine: just one line doesn't move. History: adds lines from input, and moves down
import std.stdio;
import std.conv;
import std.ascii;

import jecsdl.base, jecsdl.text;

class InputJex {
private:
	string _str;
	bool _keyShift, _control, _alt, _keySystem;
	JText[] _history;
	int _inputHistoryPos;
	string[] _inputHistory;
	string _button;
	JText _txt,
		 _header;
	int _fontSize;
	SDL_Color _colour;
	float _historyLineHeight;
	Point _vect,
			 _mousePos;
	//CircleShape _ss; //#not used
	bool _enterPressed;
	
	int _x;
	JText _measure; //cursor position

	InputType _inputType; //#define oneLine: just one line doesn't move. History: adds lines from input, and moves down

	//RectangleShape _cursor; // for drawing the cursor
	//SDL_Surface* 
	SDL_Rect _cursor;
	SDL_Color _cursorCol;

	bool _edge = false;

	bool _outPutToTerminal = true;
	bool _outPutOnlyToTerminal = false;
	bool _outPutToFile = true;

	bool _showHistory = true;

	dchar _lastKeyPressed;

	//#here
	//JSound[char] _aphaNum;

	bool _backSpaceHit;

	bool _drawCursor = true;
public:
	@property {
		/+
		auto () { return _; }
		void () { _ = 0; }
		+/

		auto fontSize() { return _fontSize; }
		void fontSize(int fontSize0) { _fontSize = fontSize0; }

		auto drawCursor() { return _drawCursor; }
		void drawCursor(bool drawCursor0) { _drawCursor = drawCursor0; }

		auto lastKeyPressed() { return _lastKeyPressed; }
		void lastKeyPressed(dchar lastKeyPressed0) { _lastKeyPressed = lastKeyPressed0; }

		auto showHistory() { return _showHistory; }
		void showHistory(bool showHistory0) { _showHistory = showHistory0; }

		auto edge() { return _edge; }
		auto edge(bool edge0) { _edge = edge0; }
		
		auto xpos() { return _x; }
		void xpos(int x0) { _x = x0; }
		
		auto button() { return _button; }
		void button(string button0) { _button = button0; }
		
		auto inputType() { return _inputType; }
		void inputType(InputType inputType) { _inputType = inputType; }
	
		auto enterPressed() { return _enterPressed; }
		void enterPressed(bool ep) { _enterPressed = ep; }
	
		auto textStr() { return _str; }
		void textStr(string str) { _str = str; _txt.setString = _str; }
		
		void clearHistory() { _history.length = 0; }

		auto backSpaceHit() { return _backSpaceHit; }
		void backSpaceHit(in bool backSpaceHit0) { _backSpaceHit = backSpaceHit0; }

		void moveHistoryUp() {
			foreach(ref line; _history)
				line.pos = Point(_header.mRect.x, line.mRect.y - _historyLineHeight);
		}
		
		auto historyColour() { return _colour; }

		void historyColour(SDL_Color colour) {
			_colour = colour;
		}

		void setColour(SDL_Color colour) {
			historyColour = colour;
			_txt.colour(_colour);
			_header.colour(_colour);
			//_cursor.fillColor = _colour;
			_cursorCol = _colour;
		}

		auto keyShift() { return _keyShift; }
		auto keyControl() { return _control; }
		auto keySystem() { return _keySystem; }
		auto keyAlt() { return _alt; }
	}

	void placeTextLine(in uint index, in int x, int y, in string str) {
		assert(index < _history.length, "Error: index out of bounds");

		//_history[index] = new Text(str, g_font, _txt.getCharacterSize);
		//assert(jtextMakeFont("DejaVuSans.ttf", fontSize), "make font fail");
		_history[index] = JText(str, SDL_Point(),_colour, fontSize, "DejaVuSans.ttf");
		with(_history[index])
			pos = Point(x, y);
			//setColor = _colour;
	}

	auto loadAphaNumSounds(in string dir) {
		import std.path : buildPath;

		
	}

	this(Point pos, int fontSize0, string header = "H for help: ", InputType inputType = InputType.oneLine) {
		fontSize = fontSize0;
		//gh("start of 'this' " ~ __FUNCTION__);
		_colour = SDL_Color(255, 255, 255, 255);
		//assert(jtextMakeFont("DejaVuSans.ttf", fontSize), "make font fail");
		//if (_font is null)
		//	_font = TTF_OpenFont(header.toStringz, fontSize);
		_header = JText(header, SDL_Point(pos.Xi,pos.Yi), _colour, fontSize, buildPath("fonts", "DejaVuSans.ttf"));
		//_header = new Text(header, g_font, fontSize);
		//_header.position = pos;
		_inputType = inputType;
		
		//_txt = new Text("", g_font, fontSize);
		//_str = "<edit here>";
		_str = "";
		_txt = JText(_str.to!string, SDL_Point(pos.Xi + _header.mRect.w, pos.Yi), _colour, fontSize, buildPath("fonts", "DejaVuSans.ttf"));
		_txt.pos = Point(pos.X + _header.mRect.w.to!float, pos.Y);

		showHistory = true;
		_historyLineHeight = _header.mRect.h.to!float;
		_inputHistory ~= "";

		//_cursor = new RectangleShape;
		//_cursor.fillColor = Color(0,180,255);
		//_cursor.fillColor = _colour; //Color(255,0,0);
		//_cursor.size = Point(2, _header.getGlobalBounds.height);
		_cursor = SDL_Rect(0,0, 2, _txt.mRect.h + _txt.mRect.h / 5);
		_cursorCol = SDL_Color(0xFF,0xFF,0xFF,0xFF);
		
		//_x = _txt.position.x;
		//_measure = new Text(", g_font, fontSize);
		_measure = JText(_str.to!string, SDL_Point(pos.Xi, pos.Yi), _colour, fontSize, buildPath("fonts", "DejaVuSans.ttf"));
		_measure.pos = pos;
		//updateMeasure;
		//debug mixin(trace("pos"));
	}

	void updateMeasure() {
		if (_x <= _str.length) {
			_measure.setString = _str[0 .. _x].to!string;
		} else {
			_x = cast(int)_str.length;
		}
	}

	void insert(C)(C c)
		if (is(C == string))
	{
		debug(5) mixin(trace("c", "_x", "_str"));
		if (_x > _str.length)
			_x = cast(int)_str.length;
		else {
			_str = _str[0 .. _x] ~ c ~ _str[_x .. $];
			if (_x + 1 <= _str.length) {
				_x += 1;
				updateMeasure;
			}
		}
	}

	string getKeyString() {
		_keyShift = _control = _alt = _keySystem = false;

		SDL_PumpEvents();
		//if (Keyboard.isKeyPressed(Keyboard.Key.LShift) ||
		//	Keyboard.isKeyPressed(Keyboard.Key.RShift))
		if (g_keystate[SDL_SCANCODE_LSHIFT] ||
			g_keystate[SDL_SCANCODE_RSHIFT]) {
			_keyShift = true;
		}

		//if (Keyboard.isKeyPressed(Keyboard.Key.LControl) ||
		//	Keyboard.isKeyPressed(Keyboard.Key.RControl)) {
		if (g_keystate[SDL_SCANCODE_LCTRL] ||
			g_keystate[SDL_SCANCODE_RCTRL]) {
			_control = true;
		}
		//if (Keyboard.isKeyPressed(Keyboard.Key.LAlt) ||
		//	Keyboard.isKeyPressed(Keyboard.Key.RAlt)) {
		if (g_keystate[SDL_SCANCODE_LALT] ||
			g_keystate[SDL_SCANCODE_RALT]) {
			_alt = true;
		}

		//if (Keyboard.isKeyPressed(Keyboard.Key.LSystem) ||
		//	Keyboard.isKeyPressed(Keyboard.Key.RSystem)) {
		if (g_keystate[SDL_SCANCODE_LGUI] ||
			g_keystate[SDL_SCANCODE_RGUI]) {
			_keySystem = true;
		}

		int i = 0;
		foreach(key; SDL_SCANCODE_A .. SDL_SCANCODE_Z + 1) {
			if (g_keys[cast(ubyte)key].keyInput) {
				if (_keyShift == true)
					return uppercase[i].to!string;
				else
					return lowercase[i].to!string;
			}
			i += 1;
		} // foreach

		if (g_keys[SDL_SCANCODE_Z + 10].keyInput) {
			if (_keyShift)
				return ")";
			else
				return "0";
		}
		i = 0;
		foreach(key; SDL_SCANCODE_Z + 1 .. SDL_SCANCODE_Z + 9 + 1) {
			if (g_keys[key].keyInput) {
				if (_keyShift)
					return "!@#$%^&*("[i].to!string;
				else
					return (i + 1).to!string;
			}
			i++;
		} // foreach

		i = 0;
		foreach(key; 0 .. 5) {
			if (! _control && ! _alt) {
				if (g_keys[SDL_SCANCODE_SPACE + 1 + i].keyInput) {
					if (_keyShift)
						return "_+{}|"[i].to!string;
					else
						return "-=[]\\"[i].to!string;
				}
			}
			i++;
		} // foreach

		if (g_keys[SDL_SCANCODE_SPACE + 7].keyInput) {
			if (_keyShift)
				return ":";
			else
				return ";";
		}

		i = 0;
		foreach(key; 0 .. 4) {
			if (! _control && ! _alt) {
				if (g_keys[SDL_SCANCODE_SPACE + 9 + i].keyInput) {
					if (_keyShift)
						return "~<>?"[i].to!string;
					else
						return "`,./"[i].to!string;
				}
			}
			i++;
		} // foreach

		if (g_keys[SDL_SCANCODE_APOSTROPHE].keyInput) {
			if (_keyShift)
				return `"`;
			else
				return "'";
		}

		if (g_keys[SDL_SCANCODE_SPACE].keyInput)
			return " ";
		return "";
	} // get key string

	void clearInput() {
		_str = "";
		_x = 0;
		updateMeasure;
		_txt.setString = _str.to!string;
	}

	void process() {
		auto dkey = getKeyString;

		if (dkey.length)
			_lastKeyPressed = dkey[0];
		if (dkey != "")
			insert(dkey),
			_txt.setString = _str,
			updateMeasure;

		if (g_keys[SDL_SCANCODE_BACKSPACE].keyInput && _str.length > 0) {
			if (_x > 0 && _x <= _str.length) {
				if (_control) {
					clearInput;
				} else {
					_str = _str[0 .. _x - 1] ~ _str[_x .. $];
					if (_x > 0)
						_x -= 1;
				}
				updateMeasure;
				_txt.setString = _str.to!string;
				_backSpaceHit = true;
			}
		}
		
		if (g_keys[SDL_SCANCODE_RETURN].keyInput) {
			if (inputType == InputType.history) {
				addToHistory(_str);
				_inputHistory ~= _str;
				_inputHistoryPos = cast(int)(_inputHistory.length);
				_x = 0;
				//_str = " ";
				//updateMeasure; //#new, untested
			}
			updateMeasure;
		 	_enterPressed = true;
		}

		//#up key press
		if (g_keys[SDL_SCANCODE_UP].keyInput) {
			if (_inputHistory.length && _inputHistoryPos > 0) {
				--_inputHistoryPos;
				debug(5) mixin(trace("/* key up */ _inputHistoryPos"));
				textStr = _inputHistory[_inputHistoryPos];
				_x = cast(int)textStr.length;
				updateMeasure;
			}
		}

		if (g_keys[SDL_SCANCODE_DOWN].keyInput) {
			if (_inputHistoryPos >= 0 && (_inputHistory.length > 0 && _inputHistoryPos < _inputHistory.length - 1)) {
				++_inputHistoryPos;
				debug(5) mixin(trace("/* key down */ _inputHistoryPos"));
				textStr = _inputHistory[_inputHistoryPos];
				_x = cast(int)textStr.length;
				updateMeasure;
			}
		}
		
		//#under construction
		if (g_keys[SDL_SCANCODE_LEFT].keyInput && _x - 1 >= 0) {
			if (_x > _str.length) //#hack
				_x = cast(int)_str.length;
			else
				_x -= 1;
			debug(5) mixin(trace("/* left */ _str[0 .. _x]"));
			_measure.setString = _str[0 .. _x].to!string;
		}

		if (g_keys[SDL_SCANCODE_RIGHT].keyInput && _x + 1 <= _str.length) {
			if (_x >= _str.length) //#hack
				_x = cast(int)_str.length;
			else
				_x += 1;
			debug(5) mixin(trace("/* right */ _str[0 .. _x]"));
			_measure.setString = _str[0 .. _x].to!string;
		}
		
		//#new
		//if (Mouse.isButtonPressed(Mouse.Button.Left)
		//	||
		//if (textStr == "l,") {
		if (gEvent.type == SDL_MOUSEBUTTONDOWN) {
			debug(5)
				writeln("Left mouse button pressed!");
			/+
			_mousePos = Mouse.getPosition(g_window);
			foreach(button; _history) {
				if (_mousePos.x >= button.position.x
					&&
					_mousePos.x < button.position.x + button.getGlobalBounds.width
					&&
					_mousePos.y >= button.position.y
					&&
					_mousePos.y < button.position.y + button.getGlobalBounds.height) {
						_button = button.getString.to!string;
						debug(5) mixin(trace("/* button: */ _button"));
					}
			}
			+/
		}

		_cursor = SDL_Rect(_txt.mRect.x + _measure.mRect.w, _measure.mRect.y, _cursor.w, _cursor.h); //#shouldn't be here
		//_cursor.size = Point(2, _header.getGlobalBounds.height);
		//_cursor.size = Point(2, _header.getCharacterSize);
	} // process
	
	auto addToHistory(T...)(T args) {
		import std.typecons: tuple;
		import std.conv: text;

		immutable str = text(tuple(args).expand);

		import std.file;
		if (_outPutToFile)
			append("history.txt", dateTimeString ~ " " ~ str ~ "\n");

		if (_outPutToTerminal)
			writeln(str),
			stdout.flush;
		if (! _outPutOnlyToTerminal) {
			moveHistoryUp;
		
			//_history ~= new Text(str, g_font, _txt.getCharacterSize);
			//assert(jtextMakeFont("DejaVuSans.ttf", fontSize), "font make fail");
			_history ~= JText(str.to!string, SDL_Point(), _colour, fontSize, "DejaVuSans.ttf"); //_txt.getCharacterSize);
			_history[$ - 1].pos = Point(_header.mRect.x, _txt.mRect.y - _historyLineHeight);
			//_history[$ - 1].setColor = _colour;
			
			_inputHistoryPos = cast(int)_inputHistory.length - 1;
		} // onlyMirror

		return str;
	}
	
	void draw() {
		if (inputType == InputType.history &&
			//g_mode == Mode.edit && 
			showHistory) {
			if (_edge) {
				/+
				foreach(line; _history) {
					immutable orgColour = line.getColor;
					immutable orgPos = line.position;

					scope(exit) {
						line.setColor = orgColour;
						line.position = orgPos;
					}

					line.setColor = Color(0,0,0);
					float posx = line.position.x - 1,
						posy = line.position.y - 1;
					foreach(y; 0 .. 3)
						foreach(x; 0 .. 3) {
							if (! (x == 1 && y == 1)) {
								line.position = Point(posx + x, posy + y);
								g_window.draw(line);
							}
						}
				}
				+/
			}
			import std.algorithm: filter, each;

			SDL_SetRenderDrawColor(gRenderer,
					historyColour.r,historyColour.g,historyColour.b,historyColour.a);
			_history
				.filter!(a => a.mRect.y >= 0)
				.each!drawLine;
		}
		if (g_terminal) {
			if (_edge) {
			}

			//g_window.draw(_header);
			//g_window.draw(_txt);
			SDL_RenderCopy(gRenderer, _header.mTex, null, &_header.mRect);
			if (_txt.mRect.w > 0)
				SDL_RenderCopy(gRenderer, _txt.mTex, null, &_txt.mRect);
			//mixin(trace("_txt.mRect.x _txt.mRect.y _txt.mRect.w _txt.mRect.h".split));
			
			if (drawCursor) {
			//	g_window.draw(_cursor);
				SDL_SetRenderDrawColor(gRenderer,
					_cursorCol.r,_cursorCol.g,_cursorCol.b,_cursorCol.a);
				foreach(y; _cursor.y .. _cursor.y + _cursor.h)
					foreach(x; _cursor.x .. _cursor.x + _cursor.w)
						SDL_RenderDrawPoint(gRenderer, x,y);
//				SDL_RenderCopy(gRenderer, _cursor.mTex, null, &_cursor.mRect);
			}
		}
	}
}

/**
 * Draw line of history
 */
auto drawLine(R)(R r, ref JText line) {
	SDL_RenderCopy(gRenderer, line.mTex, null, &line.mRect);
	//g_window.draw(line.mTex);

	return r;
}
