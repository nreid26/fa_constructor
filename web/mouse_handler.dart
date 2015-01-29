part of fa_constructor;

abstract class MouseHandler {
	MouseHandler() { if(handler != null) { handler.reset(); } }
	
	void click(StateElement initiate, MouseEvent e) { }
	
	void down(StateElement initiate, MouseEvent e) { }
	void up(StateElement initiate, MouseEvent e) { }
	void move(StateElement initiate, MouseEvent e) { }

	void reset() { }
}

class NullHandler extends MouseHandler {
	//Methods
	void click(StateElement initiate, MouseEvent e) {
		if(initiate == null) { document.body.append(new StateElement(e.client)); }
		else { handler = new StateSelectedHandler(initiate); }
	}	
	
	void down(StateElement initiate, MouseEvent e) {
		if(initiate == null) { return; }
		handler = new StateDraggingHandler(initiate);
	}
}

class StateDraggingHandler extends MouseHandler {
	//Data
	final StateElement element;
	
	//Constructor
	StateDraggingHandler(this.element) { }
	
	//Methods
	void move(StateElement initiate, MouseEvent e) {
		element.position = (initiate == null) ? e.client : e.client + element.parent.offset.topLeft;
		transitions.redraw();
	}
	
	void up(StateElement initiate, MouseEvent e) { handler = new NullHandler(); }
	
	void reset() { transitions.redraw(); }
}

class StateSelectedHandler extends MouseHandler {	
	//Data
	final StateElement element;
	
	//Constructor
	StateSelectedHandler(this.element) { 
		element
			..style.borderColor = 'red'
			..editable = true;
	}
	
	//Methods
	void click(StateElement initiate, MouseEvent e) {
		handler = (initiate == null) ? new NullHandler() : new TransitionSelectedHandler( transitions.getOrConstruct(element, initiate) );
	}
	
	void reset() {
		element
			..style.borderColor = 'black'
			..editable = false;
	}
}

class TransitionSelectedHandler extends MouseHandler {
	//Data
	final Transition transition;
	
	//Constructor
	TransitionSelectedHandler(this.transition) {
		transition.editable = true;
	}
	
	//Methods
	void click(StateElement initiate, MouseEvent e) {
		handler = (initiate == null) ? new NullHandler() : new StateSelectedHandler(initiate);
	}
	
	void reset() {
		transition.editable = false;
	}	
}