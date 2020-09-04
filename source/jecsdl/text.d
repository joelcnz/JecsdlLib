//#not sure about this (p += Point(10,10); not work)
//#hack
module jecsdl.text;

import jecsdl.base;

//version = Trace;

TTF_Font* gmFont;

bool jtextMakeFont(string fontName, int size) {
    if (gmFont)
        TTF_CloseFont(gmFont);

    import std.string : toStringz;
    gmFont = TTF_OpenFont(fontName.toStringz, size);

    return gmFont !is null;
}

struct JText {
    string mText;
    SDL_Texture* mTex;
    private SDL_Surface* mSur;
    SDL_Rect mRect;
    Point mPos;
    Point mSize;
    SDL_Color mCol;
    TTF_Font* mFont;

    void pos(Point pos0) { mPos = pos0; mRect.x = pos0.Xi; mRect.y = pos0.Yi; } //#not sure about this (p += Point(10,10); not work)
    auto pos() { return mPos; }

    //this(TTF_Font* font) { mFont = font; }

    this(string message, SDL_Rect r, SDL_Color col, int fontSize, string fileName) {
    //void setup(string message, SDL_Rect r, SDL_Color col, int fontSize, string fileName) {
        //assert(mFont, "font is null");
        import std.string : toStringz;
        mFont = TTF_OpenFont(fileName.toStringz, fontSize);
        assert(mFont, "Font fail...");
	version(Trace) {
		17.gh;
	}
        setString(message, col);
	version(Trace) {
		18.gh;
	}
        mRect = SDL_Rect(r.x, r.y, mSur.w, mSur.h);
        mPos = Point(r.x, r.y);
    }

    void setString(string message) {
        setString(message, mCol);
    }

    void setString(string message, SDL_Color col) { //} = SDL_Color(255,180,0,0xFF)) {
        mCol = col;
        if (mTex || mSur)
            close(/* font too: */ false);
	version(Trace) {
		19.gh;
	}
        mText = message;
        //assert(gmFont, "Text font no made (makeFont(name, size))");
        if (! message.length)
            mText = message = " ";      
        assert(mFont, "font not created..");      
        mSur = TTF_RenderText_Blended(mFont, message.toStringz, col);
	version(Trace) {
		20.gh;
	}
        mRect = SDL_Rect(mRect.x, mRect.y, mSur.w, mSur.h);
        mTex = SDL_CreateTextureFromSurface( gRenderer, mSur );
	version(Trace) {
		21.gh;
	}
        int w, h;
        assert(TTF_SizeText(mFont, message.toStringz, &w, &h) == 0);
        mSize = Point(w, h);
    }

/+
    void position(Point pos0) {
        pos = pos0;
//        mRect.x = pos.Xi;
//        mRect.y = pos.Yi;
    }
+/
    void colour(SDL_Color col) {
        setString(mText, col);
    }

    auto colour() {
        return mCol;
    }

    //#hack
    void close(bool closeFontToo = true) {
        SDL_DestroyTexture(mTex);
        SDL_FreeSurface(mSur);
        if (closeFontToo)
            TTF_CloseFont(mFont);
    }

    void draw(SDL_Renderer* renderer) {
        SDL_RenderCopy(renderer, mTex, null, &mRect);
    }
    
    string toString() const {
        return text(`text: "`, mText, `" pos: (`, mRect.x, ",", mRect.y, ")");
    }
}
