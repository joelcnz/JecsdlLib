//#more work here?
//#dummy I think
module jecsdl.gui;

import jecsdl.base, jecsdl.draw;

/// Root wedget
class Wedget {
//private:
    WedgetType _wedgetType;

    /// name id
    string _nameid; 
    /// box or button dimentions
    JRectangle _box;
    /// Focus box
    JRectangle _rectOutLineShp;
    /// box or button graphic
    JRectangle _rectFillShp;
    /// box, button, icon, mouse over status
    Focus _focus;
    /// Font
    //TTF_Font* _font;
    /// Text
    JText _listTxt;
    /// My input text
    InputJex _input;
    /// List of text strings
    string[] _list;
    /// Show or hide
    bool _hidden;
    /// Does is show the focus outline with the mouse pointer
    bool _focusAble = true;
public:
    /// name
    auto nameid() { return _nameid; }
    /// box
    auto box() { return _box; }
    /// 1st text of strings setter
    void txtHead(string txt0) {
        if (_list.length)
            _list[0] = txt0;
        //#more work here?
    }
    /// 1st text of strings setter
    auto txtHead() { 
        if (_list.length)
            return _list[0];
        return "?";
    }
    /// list getter
    auto list() { return _list; }
    /// list setter
    void list(string[] list0) { _list = list0; }
    /// Input getter
    auto input() { return _input; }
    /// hide setter
    void hidden(bool hidden0) { _hidden = hidden0; } 
    /// hide getter
    auto hidden() { return _hidden; }
    /// Setter whether focusable or not
    void focusAble(bool focusAble0) { _focusAble = focusAble0; }
    /// focusable getter
    auto focusAble() { return _focusAble; }

    /// Ctor name and box (location and size)
    this(in string nameid0, in JRectangle box0) {
        _wedgetType = WedgetType.wedget;
        _nameid = nameid0;
        _box = box0;
        _rectFillShp = box0;
        _rectFillShp.mColour = SDL_Color(180, 64, 0);
        _rectOutLineShp = box0;
        //_rectOutLineShp.mColour = SDL_Color(255,255,255, 0xFF);
        //_font = TTF_OpenFont(buildPath("Fonts", "DejaVuSans.ttf").toStringz, 15);
        //assert(_font, "Font load fail");
        _listTxt = JText( "", SDL_Point(), SDL_Color(255,255,0,0xFF), 15,
            buildPath("Fonts", "DejaVuSans.ttf"));

        _list ~= nameid; //#dummy I think
        //_font = TTF_OpenFont("DejaVuSans.ttf".toStringz, 15);
        //assert(_font, "Font not set");
    }

    void close() {
        _listTxt.close;
        //TTF_CloseFont(_font);
    }

    /// Check for focus
    bool gotFocus(Point pos) {
        import std.string : split;
        //mixin(trace("_box.x _box.y _box.w _box.h".split));
        if (! hidden && pos.X >= _box.x && pos.X < _box.x + _box.w &&
            pos.Y >= _box.y && pos.Y < _box.y + _box.h)
            return true;
        return false;
    }

    /// Position filler
    void process() {}

    /// Minimal drawing
    void draw() {
        SDL_SetRenderDrawColor(gRenderer,
            _rectFillShp.mColour.r,
            _rectFillShp.mColour.g,
            _rectFillShp.mColour.b, 0xFF);
        SDL_RenderFillRect(gRenderer, &_rectFillShp.mRect);

        if (_wedgetType != WedgetType.edit && _list.length) {
            auto pos = Point(box.x + 1, box.y + 1);
            foreach(item; _list) {
                _listTxt.setString(item);
                _listTxt.pos = Point(pos.X, pos.Y);
                _listTxt.draw(gRenderer);
                pos = Point(pos.X, pos.Y + _listTxt.mRect.h);
            }
        }
        if (focusAble && _focus == Focus.on) {
            SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
            SDL_RenderDrawRect(gRenderer, &_rectOutLineShp.mRect);
        }
    }
}

/// Edit box wedget
class EditBox : Wedget {
    /// Ctor name, boc, and label
    this(in string name, in JRectangle box0, string txt0) {
        super(name, box0);
        _wedgetType = WedgetType.edit;
       _input = new InputJex(/* position */ Point(_box.x + 2, box.y + 2),
                    /* font size */ 12,
                    /* header */ txt0,
                    /* Type (oneLine, or history) */ InputType.oneLine);
        _input.setColour(SDL_Color(0xFF, 0xFF, 0xFF, 0xFF));
    }

    override void process() {
        with(_input) {
            if (_focus == Focus.on) {
                    process; //#input
                    drawCursor = true;
            } else
                drawCursor = false;
        }
    }

    override void draw() {
        super.draw;
        _input.draw;
    }
}

/// Button wedget
class Button : Wedget {
    /// Ctor name, box, and text for button
    this(in string name, in JRectangle box0, string txt0) {
        super(name, box0);
        _wedgetType = WedgetType.button;
    }

    override void process() {
    }

    override void draw() {
        super.draw;
    }
}
