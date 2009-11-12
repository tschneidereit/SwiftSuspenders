/*
 * Copyright (c) 2009 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import org.swiftsuspenders.Injector;
	
	public class NoParamsConstructorInjectionPoint extends InjectionPoint
	{
		public function NoParamsConstructorInjectionPoint()
		{
			super(null, null);
		}
		
		override public function applyInjection(target : Object, injector : Injector, singletons : Dictionary) : Object
		{
			return new target();
		}
	}
}