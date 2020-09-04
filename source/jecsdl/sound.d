//# from 1 to 0
//#work
module jecsdl.sound;

import jecsdl.base;

int openAudio() {
	if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 4096) < 0) {
		import std.string : fromStringz;
		writeln(SDL_GetError().fromStringz);
 		return 1;
	}
	return 0;
}

struct JSound {
	static int mIdPos = 0; //# from 1 to 0
	int mId;
	Mix_Chunk* mSnd;

	Mix_Chunk* refSnd() {
		return mSnd;
	}

	this(in string file) {
		assert(loadSnd(file), "[" ~ file ~ "] Sound file not load!");
		mId = mIdPos;
		mIdPos += 1;
	}
	
	bool loadSnd(in string file) {
		Mix_Chunk* tmp;
	
		if((tmp = Mix_LoadWAV(file.toStringz)) is null) {
			import std.string : fromStringz;
			writeln(SDL_GetError().fromStringz);
			return false;
		}
		mSnd = tmp;

		return true;
	}

	void play() {
		Mix_PlayChannel(mId, mSnd, 0);
	}


	bool playing() {
		return Mix_Playing(mId) > 0;
	}

	void close() {
		if (mSnd)
			Mix_FreeChunk(mSnd);
	}
}

struct JSoundList {
	Mix_Chunk*[] sndList;

	bool idInbounds(int id) {
		if (id < 0 || id >= sndList.length) {
			writeln(id, " - Out of bounds");
			return false;
		}
		return true;
	}

	Mix_Chunk* refSnd(int id) {
		if (idInbounds(id)) {
			return sndList[id];
		}
		return null;
	}

	this(string file) {
		if (onLoad(file) >= 0)
			writeln("File not load: ", file);
	}

	int onLoad(string file) {
		import std.file : exists;
		if (! file.exists) {
			writeln("[", file, "] - not exist");
			return -1;
		}

		Mix_Chunk* tmp;
	
		if((tmp = Mix_LoadWAV(file.toStringz)) is null) {
			import std.string : fromStringz;
			writeln(SDL_GetError().fromStringz);
			return -2;
		}
	
		sndList ~= tmp;
	
		return cast(int)(sndList.length - 1);
	}

	void onCleanup() {
		foreach(i, s; sndList) {
			Mix_FreeChunk(sndList[i]);
		}
		
		sndList.length = 0;
		Mix_CloseAudio();
	}

	void play(int id) {
		if (! idInbounds(id))			
			return;
		if (sndList[id] is null) {
			writeln("Sound is null");
			return;
		}
	
		Mix_PlayChannel(-1, sndList[id], 0);
	}
}
