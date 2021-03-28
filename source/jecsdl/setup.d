//#mix close audio - new
module jecsdl.setup;

//#sound

import jecsdl.base, jecsdl.draw;

//version = Trace;

bool bindbcSetup() {
	version(Trace) { 0.gh; }
	/*
	This version attempts to load the SDL shared library using well-known variations
	of the library name for the host system.
	*/
	SDLSupport ret = loadSDL();
	if(ret != sdlSupport) {
		// Handle error. For most use cases, this is enough. The error handling API in
		// bindbc-loader can be used for error messages. If necessary, it's  possible
		// to determine the primary cause programmtically:

		if(ret == SDLSupport.noLibrary) {
			// SDL shared library failed to load
			assert(0, "no library");
		}
		else if(SDLSupport.badLibrary) {
			// One or more symbols failed to load. The likely cause is that the
			// shared library is for a lower version than bindbc-sdl was configured
			// to load (via SDL_201, SDL_202, etc.)
			assert(0, "old library, or some thing");
		}
	}
	/*
	This version attempts to load the SDL library using a user-supplied file name.
	Usually, the name and/or path used will be platform specific, as in this example
	which attempts to load `SDL2.dll` from the `libs` subdirectory, relative
	to the executable, only on Windows. It has the same return values.
	*/
	// version(Windows) loadSDL("libs/SDL2.dll")

	/*
	The satellite library loaders also have the same two versions of the load functions,
	named according to the library name. Only the parameterless versions are shown
	here. These return similar values as loadSDL, but in an enum namespace that matches
	the library name: SDLImageSupport, SDLMixerSupport, and SDLTTFSupport.
	*/
	version(Trace) {
		1.gh;
	}
	if(loadSDLImage() != sdlImageSupport) {
		/* handle error */
		assert(0,"problem with loading image library");
	}
	version(Trace) { 2.gh; }
	if(loadSDLMixer() != sdlMixerSupport) {
		/* handle error */
		assert(0,"problem with loading mixer library");
	}
	version(Trace) { 3.gh; }
	if(loadSDLTTF() != sdlTTFSupport) {
		/* handle error */
		assert(0,"problem with loading font library");
	}
	version(Trace) { 4.gh; }

	return true;
}

bool initKeys() {
	version(Trace) { 5.gh; }
	g_keystate = SDL_GetKeyboardState(null);
	foreach(tkey; cast(SDL_Scancode)0 .. SDL_NUM_SCANCODES)
		g_keys ~= new TKey(cast(SDL_Scancode)tkey);
	version(Trace) { 4.gh; }

	return g_keys.length == SDL_NUM_SCANCODES;
}

bool fontSetup() {
	if (TTF_Init() < 0) {
		writef("TTF_Init failed\n");
		return false;
	}
	version(Trace) { 6.gh; }
	return true;
}

//jecsdlsetup("SDL Joel program", 640,480, SDL_WINDOW_SHOWN);
int jecsdlsetup(string title = "SDL Joel program",
	int screenWidth = 640, int screenHeight = 480,
	SDL_WindowFlags flags = SDL_WINDOW_SHOWN) {

	SCREEN_WIDTH = screenWidth;
	SCREEN_HEIGHT = screenHeight;

	bool init()
	{
		//Initialization flag
		bool success = true;

		if (! bindbcSetup) {
			success = false;
		} else {
			//Initialize SDL
			if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
			{
				writef( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError() );
				success = false;
			}
			else
			{
				version(Trace) { 6.gh; }
				import std.string : toStringz;
				//Create window
				gWindow = SDL_CreateWindow( title.toStringz, SDL_WINDOWPOS_UNDEFINED,
					SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, flags );
				version(Trace) { 7.gh; }
				if( gWindow is null )
				{
					writef( "Window could not be created! SDL_Error: %s\n", SDL_GetError() );
					success = false;
				}
			}

			//Set texture filtering to linear
			if( !SDL_SetHint( SDL_HINT_RENDER_SCALE_QUALITY, "1" ) )
			{
				writef( "Warning: Linear texture filtering not enabled!" );
			}
			version(Trace) { 8.gh; }

			//Create renderer for window
			gRenderer = SDL_CreateRenderer( gWindow, -1, SDL_RENDERER_ACCELERATED );
			if( gRenderer is null )
			{
				printf( "Renderer could not be created! SDL Error: %s\n", SDL_GetError() );
				success = false;
			}
			else
			{
				version(Trace) { 9.gh; }
				//Initialize renderer color
				SDL_SetRenderDrawColor( gRenderer, 0x00, 0x0, 0xFF, 0xFF );

				//Initialize PNG loading
				int imgFlags = IMG_INIT_PNG;
				if( !( IMG_Init( imgFlags ) & imgFlags ) )
				{
					writef( "SDL_image could not initialize! SDL_image Error: %s\n", IMG_GetError() );
					success = false;
				}
				version(Trace) { 10.gh; }
			}
		}
		if (! fontSetup) {
			return false;
		} else {
			gFont = TTF_OpenFont("DejaVuSans.ttf".toStringz, 12);
			assert(gFont, "font not load...");
		}

		//#sound
		for(int i = 0; i < SDL_GetNumAudioDrivers(); ++i) {
			const char* driver_name = SDL_GetAudioDriver(i);
			if (SDL_AudioInit(driver_name)) {
				printf("Audio driver failed to initialize: %s\n", driver_name);
				continue;
			}//else
				//break;
		}
		version(Trace) { 11.gh; }
		if (openAudio != 0) {
			writeln("Open audio failed.");
			return false;
		}
		version(Trace) { 12.gh; }

		if (! initKeys) {
			writeln("Init keys failed");
			return false;
		}
		version(Trace) { 13.gh; }

		return success;
	}

	if (! init)
		return 1;
	
	guiSetup;

	return 0;
}

void guiSetup() {
	version(Trace) { 14.gh; }
	SDL_Color col = {0xFF, 0xFF, 0, 0xFF};

	auto test = new Wedget("projects", JRectangle(SDL_Rect(20,20,300,400), BoxStyle.solid, col));

	int take = 100;
	g_guiFile.setup([
		new Wedget("projects", JRectangle(SDL_Rect(20,20,300,400 - take), BoxStyle.solid, col)),
		new EditBox("save", JRectangle(SDL_Rect(20,425 - take,300,20), BoxStyle.solid, col), "Save name: "),
		new EditBox("load", JRectangle(SDL_Rect(20,450 - take,300,20), BoxStyle.solid, col), "Load name: "),
		new EditBox("rename", JRectangle(SDL_Rect(20,475 - take,300,20), BoxStyle.solid, col), "Rename: "),
		new EditBox("delete", JRectangle(SDL_Rect(20,500 - take,300,20), BoxStyle.solid, col), "Delete name: "),
		new Wedget("current", JRectangle(SDL_Rect(20,525 - take,300,20), BoxStyle.solid, col))
		]);
	version(Trace) { 15.gh; }
	g_guiFile.getWedgets[WedgetFile.projects].focusAble = false;
	g_guiFile.getWedgets[WedgetFile.current].focusAble = false;
	
	int xpos = 320;
	g_guiConfirm.setup([
		new Wedget("sure", JRectangle(SDL_Rect(xpos + 20,20,300,60), BoxStyle.solid, col)),
		new Button("no", JRectangle(SDL_Rect(xpos + 20,85,140,20), BoxStyle.solid, col), "No"),
		new Button("yes", JRectangle(SDL_Rect(xpos + 20 + 160,85,140,20), BoxStyle.solid, col), "Yes"),
	]);
	g_guiConfirm.getWedgets[StateConfirm.ask].focusAble = false;
	version(Trace) { 16.gh; }
}

//Frees media and shuts down SDL
void close()
{
	//Destroy window
	SDL_DestroyWindow( gWindow );

	//Destroy texture
	SDL_DestroyTexture(gTexture);

	if (gFont) TTF_CloseFont(gFont);

	gSndCtrl.onCleanup;

	//Quit SDL subsystems
	SDL_Quit();
	IMG_Quit();
	TTF_Quit();
	SDL_AudioQuit();
	// Mix_CloseAudio(); //#mix close audio - new
}
