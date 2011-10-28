/*
* Copyright (c) 2009-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class ValueProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _value : Object;


		//----------------------               Public Methods               ----------------------//
		public function ValueProvider(value : Object)
		{
			_value = value;
		}

		/**
		 * @inheritDoc
		 *
		 * @return The value provided to this provider's constructor
		 */
		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			return _value;
		}
	}
}