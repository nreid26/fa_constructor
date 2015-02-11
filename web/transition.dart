part of fa_constructor;

class Transition extends DivElement with Positionable, Editable {
	//Data
	StateElement start, end;
	TransitionLabelElement label = new TransitionLabelElement();
	TransitionMenuElement _menu;
	
	//Constructor
	Transition.created() : super.created() { 
		style.position = 'absolute';
		append(label);
	}
	
	factory Transition(StateElement start, StateElement end) {
		Transition ret = ElementFactory.construct(Transition, 'transition', 'div');
		
		return ret
			..start = start
			..end = end
			.._menu = new TransitionMenuElement(ret)
			..append(ret._menu);
	}
	
	//Methods
	bool get editable => _menu.visible;
	void set editable(bool e) { _menu.visible = e; }
	
	void render(CanvasRenderingContext2D context) {
		//Vector an position calculations
		Point<double> s = unround(start.position), e = unround(end.position), mid = (s + e) * 0.5,
					  n = new Point<double>(e.y - s.y, s.x - e.x), //Normal
					  c = n * ((n.magnitude < 200) ? 0.2 : (40 / n.magnitude)) + mid;
    	
    	Point<double> evaluate(num t) => (s * (1 - t) * (1 - t)) + (c * 2 * t * (1 - t)) + (e * t * t);
	    
		position = round(evaluate(0.5));
		label.adjust(n * (1 / n.magnitude));
		
		//Render
		context
			..beginPath()
			..moveTo(s.x, s.y)
			..quadraticCurveTo(c.x, c.y, e.x, e.y)
			..stroke();
		renderTip(context, evaluate);
	}
	
	void remove() {
		super.remove();
		transitions.removeExact(this);
		handler = new NullHandler();
	}
	
	void renderTip(CanvasRenderingContext2D context, Point<double> evaluate(num t)) {
		num t1 = 0, t2 = 1, t = 0.5;
		Point<double> e = unround(end.position), p = evaluate(t);
		
		if(p.distanceTo(e) > end.radius) {
			while(true) {
				t = (t1 + t2) / 2;
				p = evaluate(t);
				num m = p.distanceTo(e);
				
				if(m > end.radius - 1) { t1 = t; } //If p outside end, use forward half
				else if(m < end.radius - 3) { t2 = t; } //If p inside end, use backward half
				else { break; }
			}
		}
		
		num angle = atan2(p.y - e.y, p.x - e.x), da = PI / 5;
		context
			..beginPath()
			..moveTo(p.x, p.y)
			..arc(p.x, p.y, 12, angle - da, angle + da)
			..fill();
	}
	
	
}

class LoopbackTransition extends Transition {
	//Constructor
	LoopbackTransition.created() : super.created();
	
	factory LoopbackTransition(StateElement start, StateElement end) {
		LoopbackTransition ret = ElementFactory.construct(LoopbackTransition, 'loopback_tansition', 'div');
		
		return ret
			..start = start
			..end = end
			.._menu = new TransitionMenuElement(ret)
			..append(ret._menu);
	}
	
	//Methods
	void render(CanvasRenderingContext2D context) {
		Point<double> e = unround(end.position), //End
					  r = e - new Point<double>(window.innerWidth / 2, window.innerHeight / 2);
					  r *= (1 / r.magnitude); //Radial unit
		Point<double> n = new Point<double>(r.y, -r.x) * 2 * end.radius, //Scaled radial normal
					  c = r * 4 * end.radius + e, //Central control
					  c0 = c + n, c1 = c - n; //Actual controls
		
    	Point<double> evaluate(num t) => (e * (t * t * t + (1 - t) * (1 - t) * (1 - t))) + (c0 * (1 - t) + c1 * t) * 3 * t * (1 - t);	    
    	
		position = round(evaluate(0.5));
		label.adjust(r);

		//Render
		context
			..beginPath()
			..moveTo(e.x, e.y)
			..bezierCurveTo(c0.x, c0.y, c1.x, c1.y, e.x, e.y)
			..stroke();
		renderTip(context, evaluate);
	}
}

class StartTransition extends Transition {
	//Constructor
	StartTransition.created() : super.created();
	
	factory StartTransition(StateElement end) {
		StartTransition ret = ElementFactory.construct(StartTransition, 'start_transition', 'div');
		
		return ret..end = end;
	}
	
	//Methods
	void render(CanvasRenderingContext2D context) {
		Point<double> e = unround(end.position),
					  s = new Point<double>(e.x - 3 * end.radius, e.y - end.radius), //Start
					  c = new Point<double>((e.x + s.x) / 2, e.y - end.radius); //Control
		
    	Point<double> evaluate(num t) => (s * (1 - t) * (1 - t)) + (c * 2 * t * (1 - t)) + (e * t * t);	    
    	
		position = round(evaluate(0.5));
		label.adjust(new Point<double>(0.0, -1.0));

		//Render
		context
			..beginPath()
			..moveTo(s.x, s.y)
			..quadraticCurveTo(c.x, c.y, e.x, e.y)
			..stroke();
		renderTip(context, evaluate);
	}
}

class TransitionMenuElement extends DivElement with Positionable, Visible, PropagationStopping {
	//Data
	Transition transition;
	
	//Consructor
	TransitionMenuElement.created(): super.created() {
		visible = false;
		classes.add('menu');
		position = new Point<int>(0, 30);
		stopPropagation();
	}
	
	factory TransitionMenuElement(Transition transition) {
		TransitionMenuElement ret = ElementFactory.construct(TransitionMenuElement, 'transition_menu', 'div');
		
		var text = new InputElement(type: 'text')..placeholder = 'label';
		text.onChange.listen((Event e) => transition.label.innerHtml = text.value);
		ret.append(text);
		
		var remove = new InputElement(type: 'button')..value = 'Remove';
		remove.onClick.listen((Event e) => transition.remove());
		ret.append(remove);
		
		return ret;		
	}	
}

class TransitionLabelElement extends DivElement with Positionable {
	//Constructor
	TransitionLabelElement.created() : super.created() {
		classes.add('label');
	}
	
	factory TransitionLabelElement() => ElementFactory.construct(TransitionLabelElement, 'transition_label', 'div');
	
	//Methods
	String get innerHtml => super.innerHtml;
	void   set innerHtml(String s) {
		super.innerHtml = s;
		origin = round(new Point<double>(borderEdge.width / 2, borderEdge.height / 2));
		transitions.redraw();
	}
	
	void adjust(Point<double> unit) {
		unit *= 3;
		Point<double> k = unit;
		
		while(k.x.abs() < origin.x && k.y.abs() < origin.y) { k += unit; }
	
		position = round(k);
	}
}