//#what about load?!
module jecsdl.guiconfirm;

import jecsdl.base;

/// Confirm (yes/no) dialog box
struct GuiConfirm {
    Wedget[] _wedgets; /// List of wedgets

    ref auto getWedgets() {
        return _wedgets;
    }

    /// basic set up
    void setup(Wedget[] wedgets) {
        _wedgets = wedgets;
        setHideAll(true);
    }

    void setHideAll(bool state) {
        import std.algorithm : each;

        _wedgets.each!(w => w.hidden = state);
    }

    void setQuestion(string[] headerLines) {
        _wedgets[StateConfirm.ask].list(headerLines);
    }

    /// Process checking for button press
    void process(in Point pos) {
        /+
        if (! getWedgets[0].hidden) {
            if (g_keys[SDL_SCANCODE_Y].keyTrigger) {
                g_stateConfirm = StateConfirm.yes; 
                //g_wedgetFile = WedgetFile.save; //#what about load?!
                setHideAll(true);
            }
            if (g_keys[SDL_SCANCODE_N].keyTrigger) {
                g_stateConfirm = StateConfirm.no; 
                g_wedgetFile = WedgetFile.current;
                setHideAll(true);
            }
        }
        +/
        foreach(ref wedget; _wedgets) with(wedget) {
            process;
            if (gotFocus(pos)) {
                _focus = Focus.on;
                if (gEvent.type == SDL_MOUSEBUTTONDOWN) {
                //if (g_keys[SDL_SCANCODE_V].keyInput) {
                    setHideAll(true);
                    if (wedget.nameid == "yes")
                        g_stateConfirm = StateConfirm.yes;
                    else if (wedget.nameid == "no")
                        g_stateConfirm = StateConfirm.no;
                }
            } else {
                _focus = Focus.off;
            }
        }
    }

    /// Draw
    void draw() {
        foreach(w; _wedgets) {
            if (! w.hidden)
                w.draw;
        }
    }
}
