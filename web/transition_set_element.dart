part of fa_constructor;

class TransitionSetElement extends CanvasElement {	
	//Data
	Set _data = new Set<Transition>();
	
	//Constructor
	TransitionSetElement.created() : super.created() {
		tabIndex = 1;
		resize();
		window.onResize.listen(resize);
		style.position = 'absolute';
		
		onClick.listen((MouseEvent e) => handler.click(null, e));
		onMouseDown.listen((MouseEvent e) => handler.down(null, e));
		onMouseUp.listen((MouseEvent e) => handler.up(null, e));
		onMouseMove.listen((MouseEvent e) => handler.move(null, e));				
	}
	
	factory TransitionSetElement() => ElementFactory.construct(TransitionSetElement, 'transition_set', 'canvas');
	
	//Methods
	Transition getOrConstruct(StateElement start, StateElement end) {
		for(Transition t in _data) { if(t.start == start && t.end == end) { return t; }}
		
		Transition t;
			if(start == end) { t = new LoopbackTransition(start, end); }
			else if(start == null) { t = new StartTransition(end); }
			else { t = new Transition(start, end);}
		_data.add(t);
		document.body.append(t);
		redraw();
		return t;
	}
	
	void removeAssociated(StateElement state) {
		var l = [];
		for(Transition t in _data) {
			if(t.start == state || t.end == state) { l.add(t); }
		}
		for(Transition t in l) { t.remove(); }
		redraw();
	}
	
	void removeExact(Transition t) {
		_data.remove(t);
		redraw();
	}
	
	void resize([Event e]) {
		width = window.innerWidth;
		height = window.innerHeight;
		context2D.lineWidth = 4;
		redraw();
	}
	
	void redraw() {
		context2D.clearRect(0, 0, width, height);
		for(Transition t in _data) { t.render(context2D); }
	}
}