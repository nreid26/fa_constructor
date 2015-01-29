library fa_constructor;

import 'dart:html';
import 'dart:math';

part './element_mixins.dart';
part './mouse_handler.dart';
part './state_element.dart';
part './transition.dart';
part './transition_set_element.dart';


MouseHandler handler;
TransitionSetElement transitions;

void main() {	
	handler = new NullHandler();
	transitions = document.body.append(new TransitionSetElement());
	
	document.onMouseLeave.listen((MouseEvent e) { handler = new NullHandler(); });
}


class ElementFactory {
	static Map<Type, List<String>> _registrations = {};
	
	static Element construct(Type type, String name, [String superName]) {
		name = 'x-' + name;

		if(!_registrations.containsKey(type)) {
			document.registerElement(name, type, extendsTag: superName);
			_registrations[type] = [name, superName];
		}
		
		var x = _registrations[type];
		if(x[0] != name || x[1] != superName) { throw new ArgumentError("'$type' was previously registered as '${x[0]}' extending '${x[1]}'"); }
		return new Element.tag(x[1], x[0]);
	}
}

Point<int> round(Point<num> p) => new Point<int>(p.x.toInt(), p.y.toInt());
Point<double> unround(Point<num> p) => new Point<double>(p.x.toDouble(), p.y.toDouble());

