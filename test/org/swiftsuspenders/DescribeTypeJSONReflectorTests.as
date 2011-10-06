/*
 * Copyright (c) 2009 - 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	public class DescribeTypeJSONReflectorTests extends ReflectorTests
	{
		
		[Before]
		public function setup():void
		{
			reflector = new DescribeTypeJSONReflector();
			injector = new Injector();
		}
	}
}
