/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	import org.swiftsuspenders.Injector;

	public class NoParamsConstructorInjectionPoint extends ConstructorInjectionPoint
	{
		public function NoParamsConstructorInjectionPoint()
		{
			super([], 0, injectParameters);
		}

		override public function createInstance(type : Class, injector : Injector) : Object
		{
			return new type();
		}
	}
}