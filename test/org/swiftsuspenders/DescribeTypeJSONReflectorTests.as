/*
 * Copyright (c) 2009 - 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.utils.Dictionary;

	import org.swiftsuspenders.utils.ClassDescriptor;

	public class DescribeTypeJSONReflectorTests extends ReflectorTests
	{
		
		[Before]
		public function setup():void
		{
			reflector = new DescribeTypeJSONReflector();
			configMap = new ClassDescriptor(new Dictionary());
			injector = new Injector();
		}
	}
}
