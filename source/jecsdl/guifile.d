module jecsdl.guifile;

import jecsdl.base;

/**
 * Handles file operations
 * load, save, delete, and rename
*/
struct GuiFile {
    /// list of boxes for each operation
    Wedget[] _wedgets;

    ref auto getWedgets() {
        return _wedgets;
    }

    /// Set up
    void setup(Wedget[] wedgets) {
        _wedgets = wedgets;
    }

    /// Process's
    void process(in Point pos) {
        for1: foreach(ref wedget; _wedgets) with(wedget) {
            process;
            if (gotFocus(pos)) {
                _focus = Focus.on;
            } else {
                _focus = Focus.off;
            }
            if (_focus == Focus.on && input !is null && input.enterPressed) {
                input.enterPressed = false;
                import std.ascii : isDigit;
                import std.string : split;
                import std.algorithm : canFind;

                if ("save load delete".split.canFind(nameid) &&
                    input.textStr.length &&
                    input.textStr[0].to!char.isDigit) {
                    import std.string : indexOf;
                    
                    auto i = input.textStr.to!size_t;
                    auto txts = g_guiFile.getWedgets[WedgetFile.projects].list;

                    if (i == 0 || i >= txts.length) {
                        //update(i, ", is out of bounds 1-", txts.length - 1);
                        break for1;
                    }
                    input.textStr = txts[i][txts[i].indexOf(" ") + 1 .. $];
                }
                import std.path : stripExtension, baseName;
                if (nameid == "save" || nameid == "load" || nameid == "rename" || nameid == "delete") {
                    g_guiConfirm.setHideAll(false); // show
                    g_fileRootName = input.textStr.to!string;
                }
                switch(nameid) {
                    default: break;
                    case "save":
                        g_guiConfirm.setQuestion(["Save '" ~ g_fileRootName.to!string ~ "'", "",
                            "project: Yes or No?"]);
                        g_wedgetFile = WedgetFile.save;
                    break;
                    case "load":
                        g_guiConfirm.setQuestion(["Load '" ~ g_fileRootName.to!string ~ "'", "",
                            "project: Yes or No?"]);
                        g_wedgetFile = WedgetFile.load;
                    break;
                    case "rename":
                        g_guiConfirm.setQuestion(["Rename '" ~
                            g_currentProjectName.trim.stripExtension.baseName.to!string ~ "'",
                                "to: '" ~ g_fileRootName.to!string ~ "'", "project: Yes or No"]);
                        g_wedgetFile = WedgetFile.rename;
                    break;
                    case "delete":
                        g_guiConfirm.setQuestion(["Delete '" ~ g_fileRootName.to!string ~ "'",
                            "", "project: Yes or No?"]);
                        g_wedgetFile = WedgetFile.del;
                    break;
                }
                input.clearInput;
            }
        }
    }

    /// Draw each file wedget
    void draw() {
        import std.algorithm : each;
        _wedgets.each!(w => w.draw);
    }
}
