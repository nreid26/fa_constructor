part of fa_constructor;

class StateElement extends DivElement with Positionable, Editable {		
	//Data
	StateMenuElement _menu;
	DivElement _label = new DivElement();
	int _radius = 0;
	Transition _starting;
	
	//Constructor
	StateElement.created() : super.created() {
		radius = 50;
		origin = new Point<int>(radius, radius);
		classes.add('circle');
		accepting = false;

		_label.classes.add('name');
		_menu = new StateMenuElement(this);
		append(_label);
		append(_menu);
	}
	
	factory StateElement(Point p) {
		StateElement ret = ElementFactory.construct(StateElement, 'state', 'div');
		return ret
			..position = p
			..onClick.listen((Event e) { handler.click(ret, e); e.stopPropagation(); })
			..onMouseDown.listen((Event e) { handler.down(ret, e); e.stopPropagation(); })
			..onMouseUp.listen((Event e) { handler.up(ret, e); e.stopPropagation(); })
			..onMouseMove.listen((Event e) { handler.move(ret, e); e.stopPropagation(); });
	}
	
	//Methods		
	bool get accepting => style.borderStyle == 'double';
	void set accepting(bool b) { 
		if(b) {
			style
				..borderWidth = '12px'
				..borderStyle = 'double';
		}
		else {
			style
				..borderWidth = '4px'
				..borderStyle = 'solid';
		}
	}
	
	void remove() {
		super.remove();
		transitions.removeAssociated(this);
    	handler = new NullHandler();
	}
	
	bool get editable => _menu.visible;
	void set editable(bool e) { _menu.visible = e; }
	
	int  get radius => _radius;
	int  get diameter => 2 * radius; 
	void set radius(int r) {
		_radius = r;
		
		style
			..borderRadius = '${_radius}px'
			..width = '${diameter}px'
			..height = '${diameter}px';			
	}
	
	bool get starting => _starting != null;
	void set starting(bool b) {
		if(b) { _starting = transitions.getOrConstruct(null, this); }
		else { 
			transitions.removeExact(_starting);
			_starting = null;
		}
	}
}

class StateMenuElement extends DivElement with Positionable, Visible, PropagationStopping {	
	//Data
	StateElement state;
	
	//Constructor
	StateMenuElement.created() : super.created() {
		var accepting = new CheckboxInputElement();
		accepting.onChange.listen((Event e) => state.accepting = accepting.checked);
		append(accepting);
		
		var start = new CheckboxInputElement();
		start.onChange.listen((Event e) => state.starting = start.checked);
		append(start);
		
		var text = new TextInputElement()..placeholder = 'label';
		text.onChange.listen((Event e) => state._label.innerHtml = text.value);
		append(text);
		
		var label = new TextInputElement()..placeholder = 'start';
		label.onChange.listen((Event e) { 
			if(state.starting) { state._starting.label.innerHtml = label.value; }
		});
		append(label);
		
		var remove = new ButtonInputElement()..value = 'Remove';
        remove.onClick.listen((Event e) => state.remove());  
		append(remove);
				
		classes.add('menu');
		visible = false;
		stopPropagation();
	}
	
	factory StateMenuElement(StateElement state) {
		StateMenuElement ret = ElementFactory.construct(StateMenuElement, 'state_menu', 'div');
		return ret..position = new Point<int>(state.radius, state.diameter + 30)..state = state;	
	}
}