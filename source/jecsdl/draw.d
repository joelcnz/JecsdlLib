module jecsdl.draw;
//#Colour changing not working

import jecsdl.base;

// enum BoxStyle {solid, outLine}

struct JRectangle {
    SDL_Rect mRect;
    alias mRect this; // x y w h (void main() { JRectangle r; r.x = 10; r.y = 20; r.w = 32; r.h = 32; r.mColour.b = 255; } )
    SDL_Color mColour;
    BoxStyle _boxStyle;

    this(SDL_Rect rect, BoxStyle bs, SDL_Color col) {
        setup(rect, bs, col);
    }

    void setup(SDL_Rect rect, BoxStyle style, SDL_Color col) {
        mRect = rect;
        _boxStyle = style;
        mColour = col;
        /+
        SDL_Surface* surf = SDL_CreateRGBSurfaceWithFormat(0, mRect.w,mRect.h, 32, SDL_PIXELFORMAT_RGBA32);
        scope(exit)
            SDL_FreeSurface(surf);
//        SDL_Rect rsrc = {1 + (i - 33) * step, 1, width, height - 1};
//        SDL_BlitSurface(source, &rsrc, surf, null);
        mRect.x = mRect.y = 0;
        SDL_SetRenderDrawColor(gRenderer, mColour.r, mColour.g, mColour.b, mColour.a);
        SDL_RenderFillRect(gRenderer, &mRect);
        mTex = SDL_CreateTextureFromSurface(gRenderer, surf);
        +/
    }

    void position(Point pos) {
        mRect.x = pos.Xi;
        mRect.y = pos.Yi;
    }

    void size(Point size) {
        mRect.w = size.Xi;
        mRect.h = size.Yi;
    }

    void draw() {
        //foreach(dy; 0 .. mRect.h)
        //    foreach(dx; 0 .. mRect.w)
        //        SDL_RenderDrawPoint(gRenderer, mRect.x + dx,mRect.y + dy);
        //SDL_FillRect(gStamp, &mRect,
        //    SDL_MapRGB(gStamp.format, mColour.r, mColour.g, mColour.b));
        SDL_SetRenderDrawBlendMode(gRenderer, SDL_BLENDMODE_BLEND);
        scope(exit)
            SDL_SetRenderDrawBlendMode(gRenderer, SDL_BLENDMODE_NONE);
        SDL_SetRenderDrawColor(gRenderer, mColour.r, mColour.g, mColour.b, mColour.a);
        final switch(_boxStyle) with(BoxStyle) {
            case solid:
                SDL_RenderFillRect(gRenderer, &mRect);
            break;
            case outLine:
//                SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
                SDL_RenderDrawRect(gRenderer, &mRect);
            break;
        }
        /+
        if (! SDL_FillRect(mDest,
                 &mRect,
                 SDL_MapRGB(
                     mColour)
                     )
         assert(0, "FillRect failure");
         +/
    }
}

/+
/// Draw a single dot
void jecDrawDot(ref Image img, Point pos, Color colour) {
    if (pos.X >=0 && pos.X < img.getSize.x &&
        pos.Y >= 0 && pos.Y < img.getSize.y)
        img.setPixel(cast(int)pos.X, cast(int)pos.Y, colour);
}

//#Colour changing not working
/// fast draw modified for my purposes
/// See: http://www.brackeen.com/vga/source/bc31/lines.c.html
void jecDrawLine(ref Image img, Point pst, Point ped, Color cst, Color ced) {
    int i,dx,dy,sdx,sdy,dxabs,dyabs,x,y, px, py;
    immutable x1 = pst.Xi, x2 = ped.Xi,
        y1 = pst.Yi, y2 = ped.Yi;

    dx=x2-x1;      /* the horizontal distance of the line */
    dy=y2-y1;      /* the vertical distance of the line */
    dxabs=abs(dx);
    dyabs=abs(dy);
    sdx=sgn(dx);
    sdy=sgn(dy);
    x=dyabs>>1;
    y=dxabs>>1;
    px=x1;
    py=y1;

    Color colour;
    int clen;
    int[] nums = [ced.r - cst.r, ced.g - cst.g, ced.b - cst.b];

    import std.array : array;
    import std.algorithm : sort, map;
    import std : abs;

    clen = nums.map!"abs(a)".array.sort!"a > b"[0];
    //trace!clen;
    float r,g,b,dr,dg,db;
    float[] flts = [ped.X - pst.X, ped.Y - pst.Y];
    float llen;
    llen = flts.map!"abs(a)".array.sort!"a > b"[0];
    dr = ((cast(float)ced.r - cst.r) / clen) * llen;
    dg = ((cast(float)ced.g - cst.g) / clen) * llen;
    db = ((cast(float)ced.b - cst.b) / clen) * llen;

    r = cst.r;
    g = cst.g;
    b = cst.b;

    //mixin(trace("r g b dr dg db clen".split));

    if (dxabs>=dyabs) /* the line is more horizontal than vertical */
    {
        for(i=0;i<dxabs;i++)
        {
        y+=dyabs;
        if (y>=dxabs)
        {
            y-=dxabs;
            py+=sdy;
        }
        px+=sdx;
        colour = cst; //Color(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);
        jecDrawDot(img, Point(px, py), colour);
        r += dr;
        g += dg;
        b += db;
        //trace!colour;
        }
    }
    else /* the line is more vertical than horizontal */
    {
        for(i=0;i<dyabs;i++)
        {
        x+=dxabs;
        if (x>=dyabs)
        {
            x-=dyabs;
            px+=sdx;
        }
        py+=sdy;
        colour = cst; //Color(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b);
        jecDrawDot(img, Point(px, py), colour);
        r += dr;
        g += dg;
        b += db;
        //trace!colour;
        }
    }
}
+/