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

	public class MoodyProvider implements FallbackDependencyProvider
	{
		private var _satisfies:Boolean
		
		public static const ALLOW_INTERFACES:Boolean = true;
	
		public function MoodyProvider(satisfies:Boolean)
		{
			_satisfies = satisfies;
		}
		
		//---------------------------------------
		// FallbackDependencyProvider Implementation
		//---------------------------------------

		public function prepareNextRequest(mappingId : String) : Boolean
		{
			return _satisfies;
		}

		//---------------------------------------
		// DependencyProvider Implementation
		//---------------------------------------

		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			return null;
		}

		public function destroy() : void
		{
			
		}
	}
}