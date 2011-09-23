/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;

	public class NoParamsConstructorInjectionPoint extends ConstructorInjectionPoint
	{
		public function NoParamsConstructorInjectionPoint()
		{
			super([]);
		}

		override public function createInstance(type : Class, injector : Injector) : *
		{
			return new type();
		}
	}
}