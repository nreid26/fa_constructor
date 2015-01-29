part of fa_constructor;

class Transition extends DivElement with Positionable, Editable {
	//Data
	StateElement start, end;
	TransitionLabelElement label = new TransitionLabelElement();
	TransitionMenuElement _menu;
	
	//Constructor
	Transition.created() : super.created() { style.position = 'absolute'; }
	
	factory Transition(StateElement start, StateElement end) {
		Transition ret = ElementFactory.construct(Transition, 'transition', 'div');
		
		return ret
			..start = start
			..end = end
			.._menu = new TransitionMenuElement(ret)
			..append(ret.label)
			..append(ret._menu);
	}
	
	//Methods
	bool get editable => _menu.visible;
	void set editable(bool e) { _menu.visible = e; }
	
	void render(CanvasRenderingContext2D context) {
		//Vector an position calculations
		Point<double> s = unround(start.position), e = unround(end.position), mid = (s + e) * 0.5,
					  n = new Point<double>(e.y - s.y, s.x - e.x), //Normal
					  c = n * 0.2 + mid;
    	
    	Point<double> evaluate(num t) => (s * (1 - t) * (1 - t)) + (c * 2 * t * (1 - t)) + (e * t * t);
	    
		position = round(evaluate(0.5));
		label.position = round(n * (30 / n.magnitude));
    	Point<double> p = findTip(evaluate);
		
		//Render
		num angle = atan2(p.y - e.y, p.x - e.x), da = PI / 5;
		context
			..beginPath()
			..moveTo(s.x, s.y)
			..quadraticCurveTo(c.x, c.y, e.x, e.y)
			..stroke()
			..beginPath()
			..moveTo(p.x, p.y)
			..arc(p.x, p.y, 12, angle - da, angle + da)
			..fill();		
	}
	
	void remove() {
		super.remove();
		transitions.removeExact(this);
		handler = new NullHandler();
	}
	
	Point<double> findTip(Point<double> evaluate(num t)) {
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
		return p;
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
			..append(ret.label)
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
		label.position = round(r * 30);
		Point<double> p = findTip(evaluate);

		//Render
		num angle = atan2(p.y - e.y, p.x - e.x), da = PI / 5;
		context
			..beginPath()
			..moveTo(e.x, e.y)
			..bezierCurveTo(c0.x, c0.y, c1.x, c1.y, e.x, e.y)
			..stroke()
			..beginPath()
			..moveTo(p.x, p.y)
			..arc(p.x, p.y, 12, angle - da, angle + da)
			..fill();
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
		Point<double> p = findTip(evaluate);

		//Render
		num angle = atan2(p.y - e.y, p.x - e.x), da = PI / 5;
		context
			..beginPath()
			..moveTo(s.x, s.y)
			..quadraticCurveTo(c.x, c.y, e.x, e.y)
			..stroke()
			..beginPath()
			..moveTo(p.x, p.y)
			..arc(p.x, p.y, 12, angle - da, angle + da)
			..fill();
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
		origin = new Point<int>(clientWidth ~/ 2, clientHeight ~/ 2);
	}
}