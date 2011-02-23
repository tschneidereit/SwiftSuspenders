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

	public class ClassProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _responseType : Class;


		//----------------------               Public Methods               ----------------------//
		public function ClassProvider(responseType : Class)
		{
			_responseType = responseType;
		}

		/**
		 * @inheritDoc
		 *
		 * @return A new instance of the class given to the ClassProvider's constructor,
		 * constructed using the <code>usingInjector</code>
		 */
		public function apply(creatingInjector : Injector, usingInjector : Injector) : Object
		{
			return usingInjector.SsInternal::instantiateUnmapped(_responseType);
		}

		override public function equals(otherResult : InjectionResult) : Boolean
		{
			if (otherResult == this)
			{
				return true;
			}
			if (!(otherResult is InjectClassResult))
			{
				return false;
			}
			var castedResult : InjectClassResult =  InjectClassResult(otherResult);
			return castedResult.m_responseType == m_responseType;
		}
	}
}