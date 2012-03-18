/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.swiftsuspenders.injection.Injector;
	import org.swiftsuspenders.reflection.DescribeTypeReflector;

	public class DescribeTypeReflectorTests extends ReflectorTests
	{
		
		[Before]
		public function setup():void
		{
			reflector = new DescribeTypeReflector();
			injector = new Injector();
		}
	}
}
