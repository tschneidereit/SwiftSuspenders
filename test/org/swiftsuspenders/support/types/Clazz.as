/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.types
{
	public class Clazz implements Interface, Interface2
	{
		public var preDestroyCalled : Boolean;

		public function Clazz()
		{
		}

		[PreDestroy]
		public function preDestroy() : void
		{
			preDestroyCalled = true;
		}
	}
}
