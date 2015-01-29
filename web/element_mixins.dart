part of fa_constructor;

abstract class Positionable { //Positioning mixin for absolutly positioned elements
	//Data
	Point<int> _position = new Point(0, 0);
	Point<int> _origin = new Point(0, 0);
		
	//Methods
	Point<int> get position => _position;
	void       set position(Point<int> p) {
		_position = p;
		p -= origin;
		style
			..left = '${p.x}px'
			..top = '${p.y}px';
	}
	
	Point<int> get origin => _origin;
	void	   set origin(Point<int> p) {
		_origin = p;
		position = position;
	}
}

abstract class Editable { //Boolean editing state mixin
	//Data	
	bool get editable;
}

abstract class Visible { //For hiding DOM elements
	bool get visible => style.display != 'none';
	void set visible(bool b) { style.display = (b) ? '' : 'none'; }
}

abstract class PropagationStopping {
	void stopPropagation() {
		void stop(Event e) => e.stopPropagation();
		
		var streams = [onClick, onMouseDown, onMouseUp, onMouseOver];
		for(var s in streams) { s.listen(stop); }
	}
}
