/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.system.ApplicationDomain;

	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public interface Reflector
	{
		function getClass(value : *, applicationDomain : ApplicationDomain = null) : Class;
		function getFQCN(value : *, replaceColons : Boolean = false) : String;
		function classExtendsOrImplements(classOrClassName : Object, superclass : Class,
				application : ApplicationDomain = null) : Boolean;

		function describeInjections(type : Class) : TypeDescription;
	}
}