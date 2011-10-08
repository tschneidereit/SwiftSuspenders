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
		private var _creatingInjector : Injector;
		private var _response : Object;


		//----------------------               Public Methods               ----------------------//
		/**
		 *
		 * @param responseType The class the provider returns the same, lazily created, instance
		 * of for each request
		 * @param creatingInjector The injector that was used to create the
		 * <code>InjectionMapping</code> this DependencyProvider is associated with
		 */
		public function SingletonProvider(responseType : Class, creatingInjector : Injector)
		{
			_responseType = responseType;
			_creatingInjector = creatingInjector;
		}

		/**
		 * @inheritDoc
		 *
		 * @return The same, lazily created, instance of the class given to the SingletonProvider's
		 * constructor on each invocation
		 */
		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			return _response ||= createResponse(_creatingInjector, targetType);
		}


		//----------------------         Private / Protected Methods        ----------------------//
		private function createResponse(injector : Injector, targetType : Class) : Object
		{
			return injector.SsInternal::instantiateUnmapped(_responseType, targetType);
		}
	}
}