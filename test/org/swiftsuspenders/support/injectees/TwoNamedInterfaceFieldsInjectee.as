/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Interface;

	public class TwoNamedInterfaceFieldsInjectee
	{
		[Inject(name="Name1")]
		public var property1:Interface;
		[Inject(name="Name2")]
		public var property2:Interface;
		
		public function TwoNamedInterfaceFieldsInjectee()
		{
		}
	}
}