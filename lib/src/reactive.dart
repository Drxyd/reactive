// Made more changes to save on key strokes.

library reactive;

import 'package:flutter/material.dart';

// A more transparent interface to facilitate an imperative style
// Replaces StatefulWidget
abstract class Core
{
	Key? key;

	Core({this.key});

	late bool Function() isMounted;
	late void Function() _rebuild;
	bool isInitialized = false;

	void rebuild () { if(isInitialized) _rebuild(); }

	void registerUpdate(void Function(void Function()) setState, bool Function() isMounted) 
	{
		this.isMounted = isMounted;
		_rebuild = () {
			if(isMounted()) {
				setState((){});
			}
		};
		isInitialized = true;
	}
}

abstract class Reactive <T extends Core> extends StatefulWidget
{
	final T core;

	Reactive({Key? key, required this.core}) 
		: super(key: key ?? core.key);

	void rebuild () { core.rebuild(); }

	@override
	State<Reactive> createState();
}

abstract class Optic <T extends Core> extends State<Reactive<T>>
{
	late T core;

	@override
	@mustCallSuper
	void initState()
	{
		super.initState();
		core = widget.core;
		core.registerUpdate(setState, () => mounted);
	}

	@override
	Widget build(BuildContext context);
}


// Builder based interface to facilitate a more declarative style
// Replaces StatelessWidget
class Reactor extends Reactive<ReactorCore>
{
	Reactor({super.key, required this.builder}) 
		: super(core: ReactorCore(builder: builder));

	final Widget Function() builder;

	@override
	ReactorOptic createState() => ReactorOptic();
}

class ReactorCore extends Core
{
	Widget Function() builder;
	ReactorCore({required this.builder});
}

class ReactorOptic extends Optic<ReactorCore>
{
	@override
	Widget build(BuildContext context) => core.builder();
}