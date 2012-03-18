/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.reflection
{
	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public interface Reflector
	{
		function getClass(value : Object) : Class;
		function getFQCN(value : *, replaceColons : Boolean = false) : String;
		function typeImplements(type : Class, superType : Class) : Boolean;

		function describeInjections(type : Class) : TypeDescription;
	}
}