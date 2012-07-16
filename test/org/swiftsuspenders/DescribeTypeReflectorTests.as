/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.swiftsuspenders.reflection.DescribeTypeReflector;
	import org.swiftsuspenders.reflection.Reflector;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.isTrue;
	
	public class DescribeTypeReflectorTests extends ReflectorTests
	{
		
		[Before]
		public function setup():void
		{
			reflector = new DescribeTypeReflector();
			injector = new Injector();
		}
		
		[Test]
		public function typeImplements_picks_up_interfaces_implemented() : void
		{
			assertThat( reflector.typeImplements(DescribeTypeReflector, Reflector), isTrue());
		}
	}
}