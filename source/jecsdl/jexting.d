module jecsdl.jexting;
/+
//#like black
//#not being used
//#define
import std.stdio;
import core.thread;
import std.string;
import std.conv;
import std.datetime;
import std.range;

import jec.base;

//version = chunk;

class Jexting {
private:
	Text[] _txts;
	int _fontSize;
	int _textHeight;
	Point _pos,
			 _spd;
	enum Type {oneLine, history} //#define oneLine: just one line doesn't move. History: adds lines from input, and moves down
	Type _type;
	
	Rect!int _rect;

	bool _edge;
	//Text[] _txtsEdge; //#like black
public:
	@property {
		void type(Type type) { _type = type; }
		auto type() { return _type; }

		void edge(bool edge) { _edge = edge; }
		auto edge() { return _edge; }

		auto txts() { return _txts; }
	}
	
	this(int fontSize, Type type = Type.oneLine) {
		_fontSize = fontSize;
		_pos = Point(300, 200);
		_spd = Point(0,0);
		_edge = false;
	}

/+
	void setEdge() {
		foreach(tx; _txts) {
			_txtsEdge ~= new Text(tx.txtStr, g_font, _fontSize);
			_txtsEdge[$ - 1].color = 0;
		}
	}
+/

	void chunkCate(string str, int chunkSize) {
		_txts.length = 0;
			
		auto txts = wrap(str, chunkSize, null, null, 4).split('\n');
		debug(5)
			writeln([txts]);
		import std.array;
		if (txts.length && txts[$ - 1] == "")
			txts.popBack;
		
		debug(5)
			writeln([txts]);
		foreach(i, txt; txts) {
			_txts ~= new Text(txt, g_font, _fontSize);
			_textHeight = _txts[0].getLocalBounds.height.to!int; // repeats with no effect
			_txts[$ - 1].position = _txts[$ - 1].position + Point(0, i * _textHeight );
		}

		//#not being used
		version(chunk) {
			int i;
			foreach(chunk; chunks(str, chunkSize)) {
				_txts ~= new Text(chunk, g_font, _fontSize);
				_textHeight = _txts[0].getLocalBounds.height.to!int; // repeats with no effect
				_txts[$ - 1].position = _txts[$ - 1].position + Point(0, i * _textHeight);
				i++;
			}
		}
		
		void buildRect() {
			int greatest;
			int index;
			foreach(i, tx; _txts) {
				int rc = tx.getLocalBounds().width.to!int;
				if (rc > greatest) {
					greatest = rc;
					index = i.to!int;
				}
			}
			
			_rect.width = _txts[index].getLocalBounds.width.to!int;
			_rect.height = _txts[0].getLocalBounds.height.to!int * _txts.length.to!int;
		}
		buildRect;
	}
		
	void position(float x, float y) {
		foreach(i, txt; _txts) {
			txt.position = Point(x, y + i * _textHeight);
		}
	}
	
	void draw() {
		if (edge) {
			Text edgeTxt = new Text("", g_font, _fontSize);
			edgeTxt.setColor = Color(0, 0, 0);
			foreach(etxt; _txts) {
				edgeTxt.setString = etxt.text;
				float posx = etxt.position.x - 1,
					posy = etxt.position.y - 1;
				foreach(y; 0 .. 3)
					foreach(x; 0 .. 3) {
						edgeTxt.position = Point(posx + x, posy + y);
						g_window.draw(edgeTxt);
					}
			}
		}
		foreach(txt; _txts) {
			g_window.draw(txt);
		}
	}
}
+/
