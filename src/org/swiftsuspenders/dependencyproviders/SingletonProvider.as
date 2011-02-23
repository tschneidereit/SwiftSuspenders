/*
* Copyright (c) 2009-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.utils.SsInternal;

	public class SingletonProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _responseType : Class;
		private var _response : Object;


		//----------------------               Public Methods               ----------------------//
		public function SingletonProvider(responseType : Class)
		{
			_responseType = responseType;
		}

		/**
		 * @inheritDoc
		 *
		 * @return The same instance of the class given to the ClassProvider's constructor on each
		 * invocation. The returned instance is created using the <code>creatingInjector</code> the
		 * first time it is requested.
		 */
		public function apply(creatingInjector : Injector, usingInjector : Injector) : Object
		{
			return _response ||= createResponse(creatingInjector);
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createResponse(injector : Injector) : Object
		{
			return injector.SsInternal::instantiateUnmapped(_responseType);
		}
	}
}