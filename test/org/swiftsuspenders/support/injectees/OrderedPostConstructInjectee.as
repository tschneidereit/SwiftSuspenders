/*
 * Copyright (c) 2009 - 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	public class OrderedPostConstructInjectee
	{
		public const loadOrder : Array = [];
		
		[PostConstruct(order=2)]
		public function methodTwo():void
		{
			loadOrder.push(2);
		}
		
		[PostConstruct]
		public function methodFour():void
		{
			loadOrder.push(4);
		}
		
		[PostConstruct(order=3)]
		public function methodThree():void
		{
			loadOrder.push(3);
		}
		
		[PostConstruct(order=1)]
		public function methodOne():void
		{
			loadOrder.push(1);
		}
	}
}