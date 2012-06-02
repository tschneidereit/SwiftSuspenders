/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import flash.utils.Dictionary;

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
		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			return _value;
		}

		public function destroy() : void
		{
			//TODO: figure out whether to invoke pre destroy methods here. And how.
		}
	}
}