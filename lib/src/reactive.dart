library reactive;

import 'package:flutter/material.dart';

abstract class Reactive <T extends Core> extends StatefulWidget
{
	final T core;

	const Reactive({super.key, required this.core});

	void react () { if(core.isInitialized) core.rebuild(); }

	@override
	State<Reactive> createState();
}

abstract class Core
{
	late bool Function() isMounted;
	late void Function() rebuild;
	bool isInitialized = false;

	void linkBuild(void Function(void Function()) setState, bool Function() isMounted) 
	{
		this.isMounted = isMounted;
		rebuild = () { if(isMounted()) setState((){}); };
		isInitialized = true;
	}
}

abstract class Build <T extends Core> extends State<Reactive<T>>
{
	late T core;

	@override
	@mustCallSuper
	void initState()
	{
		super.initState();
		core = widget.core;
		core.linkBuild(setState, () => mounted);
	}

	@override
	Widget build(BuildContext context);
}


class Catalyst extends Reactive<CatalystCore>
{
	final Widget Function() builder;

	Catalyst({super.key, required this.builder}) 
		: super(core: CatalystCore(builder: builder));

	@override
	CatalystBuild createState() => CatalystBuild();
}

class CatalystCore extends Core
{
	final Widget Function() builder;

	CatalystCore({required this.builder});
}

class CatalystBuild extends Build<CatalystCore>
{
	@override
	Widget build(BuildContext context) => core.builder();
}


class Reactor<T> extends Reactive<ReactorCore<T?>>
{
	Reactor({super.key, required Widget Function(T?) builder, T? data}) 
		: super(core: ReactorCore<T>(builder: builder, data: data));

	void reactWith(T newData)
	{
		if(core.data.hashCode != newData.hashCode)
		{
			core.data = newData;
			react();
		}
	}

	T? coreDump() => core.data;

	@override
	ReactorBuild<T> createState() => ReactorBuild<T>();
}

class ReactorCore<T> extends Core
{
	final Widget Function(T?) builder;
	T? data;

	ReactorCore({required this.builder, required this.data});
}

class ReactorBuild<T> extends Build<ReactorCore<T>>
{
	@override
	Widget build(BuildContext context) => core.builder(core.data);
}


class Shield extends Reactive<ShieldCore> 
{
	Shield
	({
		super.key,
		required Widget child,
		required Widget Function(Object error, StackTrace stackTrace) fallbackBuilder,
	}) : super(core: ShieldCore(fallbackBuilder: fallbackBuilder, child: child));

	void setError(Object error, StackTrace stackTrace) =>
		core.setError(error, stackTrace);

	void clearError() =>
		core.clearError();

	@override
	ShieldBuild createState() => ShieldBuild();
}

class ShieldCore extends Core 
{
	final Widget Function(Object error, StackTrace stackTrace) fallbackBuilder;
	final Widget child;

	ShieldCore
	({
		required this.fallbackBuilder, 
		required this.child
	});
	
	Object? error;
	StackTrace? stackTrace;

	void setError(Object error, StackTrace stackTrace) 
	{
		this.error = error;
		this.stackTrace = stackTrace;
		rebuild();
	}

	void clearError() 
	{
		error = null;
		stackTrace = null;
		rebuild();
	}
}

class ShieldBuild extends Build<ShieldCore> 
{
	@override
	Widget build(BuildContext context) 
	{
		if (core.error != null && core.stackTrace != null) {
			return core.fallbackBuilder(core.error!, core.stackTrace!);
		}
		return core.child;
	}
}
