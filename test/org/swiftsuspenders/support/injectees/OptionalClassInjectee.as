/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;

	public class OptionalClassInjectee
	{
		[Inject(optional=1)]
		public var property:Clazz;
		
		public var someProperty:Boolean;
		
		public function OptionalClassInjectee()
		{
			someProperty = false;
		}
		
		[PostConstruct(order=1)]
		public function doSomeStuff():void
		{
			someProperty = true;
		}
	}
}