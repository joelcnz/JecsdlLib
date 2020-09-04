module jecsdl.image;

import jecsdl.base;

struct Map {
    ubyte r,g,b, a;
}

struct Image {
    SDL_Texture* mImg;
    SDL_Rect mRect;
    Point mPos;
    bool mReleaseMemory;

    auto pos() { return mPos; }
    void pos(Point pos0) { mPos = pos0; mRect.x = cast(int)pos0.X; mRect.y = cast(int)pos0.Y; }

    this(SDL_Texture* texture, SDL_Rect rect) {
        mImg = texture;
        mRect = rect;
        mPos = Point(rect.x, rect.y);
        mReleaseMemory = false;
    }

    this(in string filename) {
        mImg = loadTexture(filename, mRect);
        pos = Point(mRect.x, mRect.y);
        assert(mImg, "Image not load!");
        writeln("mImg created");
        mReleaseMemory = true;
    }

    void close() {
        if (mReleaseMemory) {
            SDL_DestroyTexture(mImg);
            mReleaseMemory = false;
            writeln("mImg destoried");
        } else {
            writeln("Memory already released");
        }
    }

    void draw() {
        SDL_RenderCopy(gRenderer, mImg, null, &mRect);
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

SDL_Texture* loadTexture( in string path, out SDL_Rect r )
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
    auto gMap = new ubyte[][][](4,w,h);
    auto map = new Map[][](h,w);
    int c;
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
