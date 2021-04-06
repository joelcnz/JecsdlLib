//#surface stub
module jecsdl.image;

import jecsdl.base;

/+
struct Map {
    ubyte r,g,b, a;
}
+/
/+
auto getSlice(SDL_Surface* source, Point pos, int w, int h) {
    assert(source, "source is null");
    SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormat(0, w,h, 32, SDL_PIXELFORMAT_RGBA32);
    assert(surf, "surf note created");
    scope(exit)
        SDL_FreeSurface(surf);
    SDL_Rect rsrc = {pos.Xi, pos.Yi, w,h};
    SDL_BlitSurface(source, &rsrc, surf, null);

    return SDL_CreateTextureFromSurface(gRenderer, surf);
}
+/

struct Image {
    SDL_Texture* mImg;
    SDL_Rect mRect;
    Point mPos;
    double angle = 0.0;
    SDL_RendererFlip flip;
    SDL_Point centre;
    bool mStamp;
    bool mReleaseMemory;

	bool isPic() { return mImg !is null; }

    auto pos() { return mPos; }
    void pos(Point pos0) { mPos = pos0; mRect.x = cast(int)pos0.X; mRect.y = cast(int)pos0.Y; }

/+
    this(SDL_Surface* source) // , SDL_Rect rect) {
        this(getTextureFromSuface(source, rect));
    }
    +/

    void setup(int w, int h) {
        if (mReleaseMemory)
            close;
        mImg = SDL_CreateTexture(gRenderer,SDL_PIXELFORMAT_RGBA8888,SDL_TEXTUREACCESS_TARGET,w,h);
        mRect = SDL_Rect(0,0,w,h);
        mReleaseMemory = true;
        mStamp = true;
        // mRect = SDL_Rect(0,0,w,h);
        // mPos = Point(0,0);
        // centre = SDL_Point(w/2, h/2);
    }

    //#surface stub
    void setup(SDL_Surface* surf) {

    }

    void setup(SDL_Texture* texture, SDL_Rect rect) {
        mImg = texture;
        //SDL_RenderGetClipRect(texture,null,null,&mRect);
        mRect = rect;
        mPos = Point(rect.x, rect.y);
        centre = SDL_Point(rect.w / 2, rect.h / 2);
        mReleaseMemory = false;
    }

    void setup(in string filename) {
        mImg = loadTexture(filename, &mRect); //, mRect);
        //SDL_RenderGetClipRect(texture,null,null,&mRect.w,&mRect.h);
        pos = Point(mRect.x, mRect.y);
        centre = SDL_Point(mRect.w / 2, mRect.h / 2);
        assert(mImg, filename ~ " - Image not load!");
        writeln("mImg created");
        mReleaseMemory = true;
        mixin(tce("filename pos centre angle flip mRect".split));
    }

    void close() {
        if (mReleaseMemory) {
            mReleaseMemory = false;
            SDL_DestroyTexture(mImg);
            writeln("mImg destroyed");
        } else {
            debug(10)
                writeln("Memory already released");
        }
    }

    void draw(Point p) {
        pos = p;
        draw;
    }

    void draw() {
        //SDL_RenderCopy(gRenderer, mImg, null, &mRect);
        if (mRect.w == 0 || mRect.h == 0)
            SDL_RenderCopyEx(gRenderer, mImg, null, null, angle, &centre, flip);
        else if (mStamp)
            SDL_RenderCopy(gRenderer, mImg, null, &mRect);
        else
            SDL_RenderCopyEx(gRenderer, mImg, null, &mRect, angle, &centre, flip);
    }
}

SDL_Surface* loadSuface(in string path) {
    import std.file : exists;
    if (! path.exists) {
        writeln("File not exist: '", path, "'");
        stdout.flush;
        return null;
    }
    import std.string : toStringz;
    //Load image at specified path
    SDL_Surface* loadedSurface = IMG_Load( path.toStringz );
    if( loadedSurface is null )
    {
        writef( "Unable to load image %s! SDL_image Error: %s\n", path, IMG_GetError().fromStringz );
    }
    else
    {
        
        return loadedSurface;
    }
    return null;
}

SDL_Texture* loadTexture( in string path, SDL_Rect* r)
{
    //The final texture
    SDL_Texture* newTexture;

    SDL_Surface* loadedSurface = loadSuface(path);
    if (! loadedSurface) {
        writef( "Unable to load image %s! SDL_image Error: %s\n", path, IMG_GetError().fromStringz );
    }
    else
    {
        r.w = loadedSurface.w;
        r.h = loadedSurface.h;
        //Create texture from surface pixels
        newTexture = SDL_CreateTextureFromSurface( gRenderer, loadedSurface );
        // mixin(tce("SDL_RenderTargetSupported(gRenderer)"));
        if( newTexture is null )
        {
            writef( "Unable to create texture from %s! SDL Error: %s\n", path, SDL_GetError().fromStringz );
        }

        //Get rid of old loaded surface
        SDL_FreeSurface( loadedSurface );
    }

    return newTexture;
}

/+
auto map = mapImageFile("Res/sample.png");
//auto newMap = map;
string[map.length] lines;
int x,y;
foreach(y, line; map) {
    foreach(a; line) {
        if (a.r + a.g + a.b > 256 * 2 + 200 )
            lines[y] ~= '0';
        else
            lines[y] ~= ' ';
        x += 1;
    }
    writeln("place:" ~ lines[y]);
    x = 0;
    y += 1;
}
+/
auto mapImageFile(in string fileName) {
    auto suf = loadSuface(fileName);
    if (suf is null) {
        writef( "Unable to load image %s! SDL_image Error: %s\n", fileName, IMG_GetError() );
        assert(0);
    }
    scope(exit)
        SDL_FreeSurface(suf);
    int w,h;
    w = suf.w;
    h = suf.h;
    auto map = new SDL_Color[][](h,w);
    size_t c;
    import std.range : iota;
    auto data = cast(ubyte*)suf.pixels;
    immutable bytesPerPixel = suf.format.BytesPerPixel;
    trace!bytesPerPixel;
    foreach(y; 0 .. h) {
        foreach(x; 0 .. w) {
            with(map[y][x]) {
                if (bytesPerPixel == 1) { // gray scale
                    r = g = b = data[c];
                } else {
                    r = data[c];
                    if (bytesPerPixel > 1) {
                        g = data[c + 1];
                        b = data[c + 2];
                        if (bytesPerPixel == 3)
                            a = 255;
                        else
                            a = data[c + 3]; // 4 channels (alpha)
                    }
                }
            }
            c += bytesPerPixel;
        }
    }

    return map;
}

SDL_Texture* getTextureFromSuface(SDL_Surface* source, SDL_Rect rect)  { //in int x, in int y, in int width, in int height) {
    SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormat(0, rect.w, rect.h, 32, SDL_PIXELFORMAT_RGBA32);
    scope(exit)
        SDL_FreeSurface(surf);
    SDL_BlitSurface(source, &rect, surf, null);

    return SDL_CreateTextureFromSurface(gRenderer, surf);
}
