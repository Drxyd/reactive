library Reactive;

import 'package:flutter/material.dart';

abstract class ReactiveData
{
	final Key? key;

	ReactiveData({this.key});

	late void Function() rebuild;

	void registerUpdate(void Function(void Function()) setState) 
		=> rebuild = () => setState((){});
}

abstract class ReactiveWidget<T extends ReactiveData> extends StatefulWidget
{
	final T data;

	ReactiveWidget({required this.data}) : super(key: data.key);

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
		data.registerUpdate(setState);
	}

	@override
	Widget build(BuildContext context);
}
