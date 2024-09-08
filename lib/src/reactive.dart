library reactive;

import 'package:flutter/material.dart';

// A more transparent interface to facilitate an imperative style
abstract class ReactiveData
{
	Key? key;

	ReactiveData({this.key});

	late bool Function() isMounted;
	late void Function() rebuild;

	void registerUpdate(void Function(void Function()) setState, bool Function() isMounted) 
	{
		rebuild = () => setState((){});
		this.isMounted = isMounted;
	}
}

abstract class ReactiveWidget<T extends ReactiveData> extends StatefulWidget
{
	final T data;

	ReactiveWidget({Key? key, required this.data}) 
		: super(key: key ?? data.key);

	@override
	State<ReactiveWidget> createState();
}

abstract class ReactiveState<T extends ReactiveData> extends State<ReactiveWidget<T>>
{
	late T data;

	@override
	@mustCallSuper
	void initState()
	{
		super.initState();
		data = widget.data;
		data.registerUpdate(setState, () => mounted);
	}

	@override
	Widget build(BuildContext context);
}


// Builder based interface to facilitate a more declarative style
class Reactor extends ReactiveWidget<ReactorData>
{
	Reactor({super.key, required super.data});

	@override
	ReactorState createState() => ReactorState();
}

class ReactorData extends ReactiveData
{
	Widget Function() builder;
	ReactorData({required this.builder});
}

class ReactorState extends ReactiveState<ReactorData>
{
	Widget build(BuildContext) => data.builder();
}