/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class SoftDependencyProvider implements DependencyProvider
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//
		private var _provider : DependencyProvider;


		//----------------------               Public Methods               ----------------------//
		public function SoftDependencyProvider(provider : DependencyProvider)
		{
			_provider = provider;
		}

		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			return _provider.apply(targetType, activeInjector);
		}
	}
}