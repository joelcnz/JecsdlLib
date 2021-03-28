//#not used
//#needs width and height
//#new
//# need to add like sleep(50.dur!msecs);, not that it stops the tight loop!
//jexa>>
//misc>>
module jecsdl.base;

public {
	//Using SDL and standard IO
	import std.stdio;
	import std.string; // for toStringz

	import bindbc.sdl,
		bindbc.sdl.image,            // SDL_image binding
		bindbc.sdl.mixer,            // SDL_mixer binding
		bindbc.sdl.ttf,              // SDL_ttf binding
		jecsdl.sdl_gfx_primitives;   // see file for author

	import std.math, std.conv, std.path;

	import jecsdl.setup,
		jecsdl.text,
		jecsdl.input,
		jecsdl.sound,
		jecsdl.gui,
		jecsdl.guifile,
		jecsdl.guiconfirm,
		jecsdl.image;

	import jmisc;
}

import std.datetime : Duration; //#not used
import std.datetime.stopwatch: StopWatch;

//public import jec.base, jec.input, jec.jexting, jec.setup, jec.sound, jmisc, jec.gui, jec.guifile, jec.guiconfirm;
//public import jec, jmisc;

//Screen dimensions
int SCREEN_WIDTH;
int SCREEN_HEIGHT;

int gNumber = 3_000;

enum BoxStyle {solid, outLine}
enum Focus {off, on}

bool gGlobalText = true; // if false then have local copy and paste

string getClipboardText() {
	import std.conv : to;

	return SDL_GetClipboardText().to!string;
}

void setClipboardText(string txt) {
	import std.string : toStringz;
	if (SDL_HasClipboardText() == SDL_TRUE)
		SDL_SetClipboardText(txt.toStringz);
}

JSoundList gSndCtrl;
JSound[] gSnds;
JText[] gTxts;
SDL_Event gEvent;

//Handy font
TTF_Font* gFont;
int gFontSize = 20;

//The window we'll be rendering to
SDL_Window* gWindow;
	
//The window renderer
SDL_Renderer* gRenderer;

//Current displayed texture
SDL_Texture* gTexture;

Uint8* g_keystate;

/+
//#needs width and height
SDL_Texture* loadTexture( string path )
{
	//The final texture
	SDL_Texture* newTexture;

	import std.string : toStringz;
	//Load image at specified path
	SDL_Surface* loadedSurface = IMG_Load( path.toStringz );
	if( loadedSurface is null )
	{
		writef( "Unable to load image %s! SDL_image Error: %s\n", path, IMG_GetError() );
	}
	else
	{
		//Create texture from surface pixels
        newTexture = SDL_CreateTextureFromSurface( gRenderer, loadedSurface );
		if( newTexture is null )
		{
			writef( "Unable to create texture from %s! SDL Error: %s\n", path, SDL_GetError() );
		}

		//Get rid of old loaded surface
		SDL_FreeSurface( loadedSurface );
	}

	return newTexture;
}
+/

/**
 * Handle keys, one hit buttons
 */
class TKey {
	/// Key state
	enum KeyState {up, down, startGap, smallGap}

	/// Key state variable
	KeyState _keyState;

	/// Start pause
	static _startPause = 200;
	
	/// Moving momments
	static _pauseTime = 40; // msecs
	
	/// Timer for start pause
	StopWatch _stopWatchStart;

	/// Timer for moving moments
	StopWatch _stopWatchPause;
	
	/// Key to use
	SDL_Scancode tKey;

	/// Is key set to down
	bool _keyDown;
	
	/**
	 * Constructor
	 */
	this(SDL_Scancode tkey0) {
		tKey = tkey0;
		_keyDown = false;
		_keyState = KeyState.up;
	}

	/// Is key pressed
	bool keyPressed() { // eg. g_keys[Keyboard.Key.A].keyPressed
		//return Keyboard.isKeyPressed(tKey) != 0;
		return g_keystate[tKey] != 0;
	}

	/// Goes once per key hit
	bool keyTrigger() { // eg. g_keys[Keyboard.Key.A].keyTrigger
		if (g_keystate[tKey] && _keyDown == false) {
			_keyDown = true;
			return true;
		} else if (! g_keystate[tKey]) {
			_keyDown = false;
		}
		
		return false;
	}
	
	// returns true doing trigger other wise false saying the key is already down
	/** One hit key */
	/+
		Press key down, print the character. Keep holding down the key and the cursor move at a staggered pace.
		+/
	bool keyInput() { // eg. g_keys[Keyboard.Key.A].keyInput
		if (! g_keystate[tKey])
			_keyState = KeyState.up;

		if (g_keystate[tKey] && _keyState == KeyState.up) {
			_keyState = KeyState.down;
			_stopWatchStart.reset;
			_stopWatchStart.start;

			return true;
		}
		
		if (_keyState == KeyState.down && _stopWatchStart.peek.total!"msecs" > _startPause)  {
			_keyState = KeyState.smallGap;
			_stopWatchPause.reset;
			_stopWatchPause.start;
		}
		
		if (_keyState == KeyState.smallGap && _stopWatchPause.peek.total!"msecs" > _pauseTime) {
			_keyState = KeyState.down;
			
			return true;
		}
		
		return false;
	}

	/** hold key */
//	bool keyPress() {
//		return Keyboard.isKeyPressed(tKey) > 0;
//	}
}

/// Keys array
TKey[] g_keys; // g_keys[SDL_SCANCODE_T].keyTrigger

/// Trim off parts of file name
auto trim(T)(in T str) { //if (SomeString!T) {
	import std.path : stripExtension;
	if (str.length > 6 && str[0 .. 2] == "./")
		return str[2 .. $].stripExtension.dup;
	else
		return str.dup;
}

/// Stop with key
void keyHold(SDL_Scancode key) {
	SDL_Event event;
	while(g_keys[key].keyPressed) {
        SDL_PollEvent(&event);
        if(event.type == SDL_QUIT)
			break;

		SDL_PumpEvents();
		SDL_Delay(1);
		//gh;
	} //# need to add like sleep(50.dur!msecs);, not that it stops the tight loop!
	//while(Keyboard.isKeyPressed(cast(Keyboard.Key)key)) { sleep(50.dur!msecs); } // eg. keyHold(Keyboard.Key.Num0 + i);
}

/// Define input type for my terminal
enum InputType {oneLine, history}

/// My Jex terminal
InputJex g_inputJex;

/// jx for (see above)
alias jx = g_inputJex;

/// Show or hide terminal
bool g_terminal;

/// Update change variable
bool g_doLetUpdate = true;

/// Limit number range
ubyte chr( int c ) {
	return c & 0xFF;
}

/// Confirm states
enum StateConfirm {ask, no, yes}

/// File dialog box wedgets
enum WedgetFile {projects, save, load, rename, del, current}

/// Wedget type
enum WedgetType {wedget, edit, button}

/// File dialog GUI
GuiFile g_guiFile;

/// Confirm dialog GUI
GuiConfirm g_guiConfirm;

/// Widget file state
WedgetFile g_wedgetFile;

/// State confirm
StateConfirm g_stateConfirm;

/// Current project name
string g_currentProjectName;

/// File root name
string g_fileRootName;

/+

/// General texture
Texture g_texture;

/// General font
Font g_font;


/// Define basic stages
enum Mode {play, edit}

/// Stages variable
Mode g_mode = Mode.play;

//enum EnterPressed {no, yes}

/// Sprite size in pixels or so
immutable int g_spriteSize;

shared static this() {
	g_spriteSize = 32;
}

//jexa>>
import std.ascii, std.conv, std.file, std.stdio, std.string;

/// switch for weather to draw text, or cursor {text, input}
enum g_Draw {text, input}

//alias std.ascii.newline newline;
/// New line character
auto newLine = "\n";

version(Windows) {
	char g_cr = newline[0]; /// carrage(sp) return
	char g_lf = newline[1]; /// line feed - main one
} else {
	char g_cr = newline[0]; /// carrage(sp) return
	char g_lf = newline[0]; /// same as above
}

/// display box
struct Square {
	int xpos, /// x postion
		ypos, /// y postion
		width, /// width of square
		height; /// height of square
}

/// Limit number range
ubyte chr( int c ) {
	return c & 0xFF;
}
//jexa<<

debug = TDD; //#hack
+/

alias Color = SDL_Color;

/// Quick colour
struct Colour {
	/// colour
	enum aliceblue = Color(240, 248, 255);
	/// colour
	enum antiquewhite = Color(250, 235, 215);
	/// colour
	enum aqua = Color(0, 255, 255);
	/// colour
	enum aquamarine = Color(127, 255, 212);
	/// colour
	enum azure = Color(240, 255, 255);
	/// colour
	enum beige = Color(245, 245, 220);
	/// colour
	enum bisque = Color(255, 228, 196);
	/// colour
	enum black = Color(0, 0, 0); // basic color
	/// colour
	enum blanchedalmond = Color(255, 235, 205);
	/// colour
	enum blue = Color(0, 0, 255); // basic color
	/// colour
	enum blueviolet = Color(138, 43, 226);
	/// colour
	enum brown = Color(165, 42, 42);
	/// colour
	enum burlywood = Color(222, 184, 135);
	/// colour
	enum cadetblue = Color(95, 158, 160);
	/// colour
	enum chartreuse = Color(127, 255, 0);
	/// colour
	enum chocolate = Color(210, 105, 30);
	/// colour
	enum coral = Color(255, 127, 80);
	/// colour
	enum cornflowerblue = Color(100, 149, 237);
	/// colour
	enum cornsilk = Color(255, 248, 220);
	/// colour
	enum crimson = Color(220, 20, 60);
	/// colour
	enum cyan = Color(0, 255, 255); // basic color
	/// colour
	enum darkblue = Color(0, 0, 139);
	/// colour
	enum darkcyan = Color(0, 139, 139);
	/// colour
	enum darkgoldenrod = Color(184, 134, 11);
	/// colour
	enum darkgray = Color(169, 169, 169);
	/// colour
	enum darkgreen = Color(0, 100, 0);
	/// colour
	enum darkgrey = Color(169, 169, 169);
	/// colour
	enum darkkhaki = Color(189, 183, 107);
	/// colour
	enum darkmagenta = Color(139, 0, 139);
	/// colour
	enum darkolivegreen = Color(85, 107, 47);
	/// colour
	enum darkorange = Color(255, 140, 0);
	/// colour
	enum darkorchid = Color(153, 50, 204);
	/// colour
	enum darkred = Color(139, 0, 0);
	/// colour
	enum darksalmon = Color(233, 150, 122);
	/// colour
	enum darkseagreen = Color(143, 188, 143);
	/// colour
	enum darkslateblue = Color(72, 61, 139);
	/// colour
	enum darkslategray = Color(47, 79, 79);
	/// colour
	enum darkslategrey = Color(47, 79, 79);
	/// colour
	enum darkturquoise = Color(0, 206, 209);
	/// colour
	enum darkviolet = Color(148, 0, 211);
	/// colour
	enum deeppink = Color(255, 20, 147);
	/// colour
	enum deepskyblue = Color(0, 191, 255);
	/// colour
	enum dimgray = Color(105, 105, 105);
	/// colour
	enum dimgrey = Color(105, 105, 105);
	/// colour
	enum dodgerblue = Color(30, 144, 255);
	/// colour
	enum firebrick = Color(178, 34, 34);
	/// colour
	enum floralwhite = Color(255, 250, 240);
	/// colour
	enum forestgreen = Color(34, 139, 34);
	/// colour
	enum fuchsia = Color(255, 0, 255);
	/// colour
	enum gainsboro = Color(220, 220, 220);
	/// colour
	enum ghostwhite = Color(248, 248, 255);
	/// colour
	enum gold = Color(255, 215, 0);
	/// colour
	enum goldenrod = Color(218, 165, 32);
	/// colour
	enum gray = Color(128, 128, 128); // basic color
	/// colour
	enum green = Color(0, 128, 0); // basic color
	/// colour
	enum greenyellow = Color(173, 255, 47);
	/// colour
	enum grey = Color(128, 128, 128); // basic color
	/// colour
	enum honeydew = Color(240, 255, 240);
	/// colour
	enum hotpink = Color(255, 105, 180);
	/// colour
	enum indianred = Color(205, 92, 92);
	/// colour
	enum indigo = Color(75, 0, 130);
	/// colour
	enum ivory = Color(255, 255, 240);
	/// colour
	enum khaki = Color(240, 230, 140);
	/// colour
	enum lavender = Color(230, 230, 250);
	/// colour
	enum lavenderblush = Color(255, 240, 245);
	/// colour
	enum lawngreen = Color(124, 252, 0);
	/// colour
	enum lemonchiffon = Color(255, 250, 205);
	/// colour
	enum lightblue = Color(173, 216, 230);
	/// colour
	enum lightcoral = Color(240, 128, 128);
	/// colour
	enum lightcyan = Color(224, 255, 255);
	/// colour
	enum lightgoldenrodyellow = Color(250, 250, 210);
	/// colour
	enum lightgray = Color(211, 211, 211);
	/// colour
	enum lightgreen = Color(144, 238, 144);
	/// colour
	enum lightgrey = Color(211, 211, 211);
	/// colour
	enum lightpink = Color(255, 182, 193);
	/// colour
	enum lightsalmon = Color(255, 160, 122);
	/// colour
	enum lightseagreen = Color(32, 178, 170);
	/// colour
	enum lightskyblue = Color(135, 206, 250);
	/// colour
	enum lightslategray = Color(119, 136, 153);
	/// colour
	enum lightslategrey = Color(119, 136, 153);
	/// colour
	enum lightsteelblue = Color(176, 196, 222);
	/// colour
	enum lightyellow = Color(255, 255, 224);
	/// colour
	enum lime = Color(0, 255, 0);
	/// colour
	enum limegreen = Color(50, 205, 50);
	/// colour
	enum linen = Color(250, 240, 230);
	/// colour
	enum magenta = Color(255, 0, 255); // basic color
	/// colour
	enum maroon = Color(128, 0, 0);
	/// colour
	enum mediumaquamarine = Color(102, 205, 170);
	/// colour
	enum mediumblue = Color(0, 0, 205);
	/// colour
	enum mediumorchid = Color(186, 85, 211);
	/// colour
	enum mediumpurple = Color(147, 112, 219);
	/// colour
	enum mediumseagreen = Color(60, 179, 113);
	/// colour
	enum mediumslateblue = Color(123, 104, 238);
	/// colour
	enum mediumspringgreen = Color(0, 250, 154);
	/// colour
	enum mediumturquoise = Color(72, 209, 204);
	/// colour
	enum mediumvioletred = Color(199, 21, 133);
	/// colour
	enum midnightblue = Color(25, 25, 112);
	/// colour
	enum mintcream = Color(245, 255, 250);
	/// colour
	enum mistyrose = Color(255, 228, 225);
	/// colour
	enum moccasin = Color(255, 228, 181);
	/// colour
	enum navajowhite = Color(255, 222, 173);
	/// colour
	enum navy = Color(0, 0, 128);
	/// colour
	enum oldlace = Color(253, 245, 230);
	/// colour
	enum olive = Color(128, 128, 0);
	/// colour
	enum olivedrab = Color(107, 142, 35);
	/// colour
	enum orange = Color(255, 165, 0);
	/// colour
	enum orangered = Color(255, 69, 0);
	/// colour
	enum orchid = Color(218, 112, 214);
	/// colour
	enum palegoldenrod = Color(238, 232, 170);
	/// colour
	enum palegreen = Color(152, 251, 152);
	/// colour
	enum paleturquoise = Color(175, 238, 238);
	/// colour
	enum palevioletred = Color(219, 112, 147);
	/// colour
	enum papayawhip = Color(255, 239, 213);
	/// colour
	enum peachpuff = Color(255, 218, 185);
	/// colour
	enum peru = Color(205, 133, 63);
	/// colour
	enum pink = Color(255, 192, 203);
	/// colour
	enum plum = Color(221, 160, 221);
	/// colour
	enum powderblue = Color(176, 224, 230);
	/// colour
	enum purple = Color(128, 0, 128);
	/// colour
	enum red = Color(255, 0, 0); // basic color
	/// colour
	enum rosybrown = Color(188, 143, 143);
	/// colour
	enum royalblue = Color(65, 105, 225);
	/// colour
	enum saddlebrown = Color(139, 69, 19);
	/// colour
	enum salmon = Color(250, 128, 114);
	/// colour
	enum sandybrown = Color(244, 164, 96);
	/// colour
	enum seagreen = Color(46, 139, 87);
	/// colour
	enum seashell = Color(255, 245, 238);
	/// colour
	enum sienna = Color(160, 82, 45);
	/// colour
	enum silver = Color(192, 192, 192);
	/// colour
	enum skyblue = Color(135, 206, 235);
	/// colour
	enum slateblue = Color(106, 90, 205);
	/// colour
	enum slategray = Color(112, 128, 144);
	/// colour
	enum slategrey = Color(112, 128, 144);
	/// colour
	enum snow = Color(255, 250, 250);
	/// colour
	enum springgreen = Color(0, 255, 127);
	/// colour
	enum steelblue = Color(70, 130, 180);
	/// colour
	enum ctan = Color(210, 180, 140);
	/// colour
	enum teal = Color(0, 128, 128);
	/// colour
	enum thistle = Color(216, 191, 216);
	/// colour
	enum tomato = Color(255, 99, 71);
	/// colour
	enum turquoise = Color(64, 224, 208);
	/// colour
	enum violet = Color(238, 130, 238);
	/// colour
	enum wheat = Color(245, 222, 179);
	/// colour
	enum white = Color(255, 255, 255); // basic color
	/// colour
	enum whitesmoke = Color(245, 245, 245);
	/// colour
	enum yellow = Color(255, 255, 0); // basic color
	/// colour
	enum yellowgreen = Color(154, 205, 50);
}

/+
enum Blue = 0;
enum Green = 1;

/// Errer return Type
enum ErrorType {notLoad = -1, alright = 0}

/// Progress bar fill
RectangleShape g_progBarFill;

/// Conver decimal point to 0 - 255 range
byte decimalToByte(float value) {
	return cast(byte)(255 * value);
}

//#made template instead of normal functions
/// Snap to grid
float makeSquare(float a) {
	return cast(int)(a / g_spriteSize) * cast(float)g_spriteSize;
}

/// Snap to grid horizontal and vertical
Point makeSquare(Point a) {
	return Point(makeSquare(a.x), makeSquare(a.y));
}

float makeSquare(T : float)(T a) {
	return cast(int)(a / g_spriteSize) * cast(float)g_spriteSize;
}

Point makeSquare(T : Point)(T a) {
	return Point(makeSquare(a.x), makeSquare(a.y));
}
+/