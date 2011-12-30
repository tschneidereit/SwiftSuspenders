/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;

	public class PostConstructGetterInjectee
	{
		public var property:Clazz;

		[PostConstruct]
		public function get postConstruct() : Function
		{
			return function() : void
			{
				property = new Clazz();
			}
		}
	}
}