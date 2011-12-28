/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;

	public class UnknownInjectParametersInjectee
	{
		[Inject(optional=true,name='test',param1=true,param2='str',param3=123)]
		public var property:Clazz;
	}
}