/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.providers
{
	import flash.utils.Dictionary;

	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.FallbackDependencyProvider;

	public class ProviderThatCanDoInterfaces implements FallbackDependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _responseType : Class;
		
		//----------------------               Public Methods               ----------------------//
		public function ProviderThatCanDoInterfaces(responseType : Class)
		{
			_responseType = responseType;
		}

		/**
		 * @inheritDoc
		 *
		 * @return A new instance of the class given to the ClassProvider's constructor,
		 * constructed using the <code>usingInjector</code>
		 */
		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			return new _responseType();
		}

		public function destroy() : void
		{
		}
		
		public function prepareNextRequest(mappingId : String) : Boolean
		{
			return true;
		}
	}
}