/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	public class PostConstructInjectionPoint extends OrderedInjectionPoint
	{
		//----------------------               Public Methods               ----------------------//
		public function PostConstructInjectionPoint(methodName : String, parameters : Array,
			requiredParameters : uint, order : int)
		{
			super(methodName, parameters, requiredParameters, order);
		}
	}
}