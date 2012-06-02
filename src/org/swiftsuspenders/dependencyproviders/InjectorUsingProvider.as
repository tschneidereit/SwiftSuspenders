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

	public class InjectorUsingProvider extends ForwardingProvider
	{
		//----------------------              Public Properties             ----------------------//
		public var injector : Injector;

		//----------------------               Public Methods               ----------------------//
		public function InjectorUsingProvider(injector : Injector, provider : DependencyProvider)
		{
			super(provider);
			this.injector = injector;
		}

		override public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			return provider.apply(targetType, injector, injectParameters);
		}
	}
}