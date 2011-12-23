/*
 * Copyright (c) 2009 - 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	public class OrderedPreDestroyInjectee
	{
		public const loadOrder : Array = [];
		
		[PreDestroy(order=2)]
		public function methodTwo():void
		{
			loadOrder.push(2);
		}
		
		[PreDestroy]
		public function methodFour():void
		{
			loadOrder.push(4);
		}
		
		[PreDestroy(order=3)]
		public function methodThree():void
		{
			loadOrder.push(3);
		}
		
		[PreDestroy(order=1)]
		public function methodOne():void
		{
			loadOrder.push(1);
		}
	}
}