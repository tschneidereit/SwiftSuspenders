/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.support.types.Interface2;

	public class MultipleNamedSingletonsOfSameClassInjectee
	{
		[Inject]
		public var property1:Interface;
		[Inject]
		public var property2:Interface2;
		[Inject(name='name1')]
		public var namedProperty1:Interface;
		[Inject(name='name2')]
		public var namedProperty2:Interface2;
		
		public function MultipleNamedSingletonsOfSameClassInjectee()
		{
		}
	}
}