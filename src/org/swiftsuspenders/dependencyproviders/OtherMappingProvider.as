/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import flash.utils.Dictionary;

	import org.swiftsuspenders.mapping.InjectionMapping;
	import org.swiftsuspenders.Injector;

	public class OtherMappingProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _mapping : InjectionMapping;

		//----------------------               Public Methods               ----------------------//
		public function OtherMappingProvider(mapping : InjectionMapping)
		{
			_mapping = mapping;
		}

		/**
		 * @inheritDoc
		 *
		 * @return The result of invoking <code>apply</code> on the <code>InjectionMapping</code>
		 * provided to this provider's constructor
		 */
		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			return _mapping.getProvider().apply(targetType, activeInjector, injectParameters);
		}

		public function destroy() : void
		{
		}
	}
}