/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.providers
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.support.types.Clazz;

	public class UnknownParametersUsingProvider implements DependencyProvider
	{
		//----------------------              Public Properties             ----------------------//
		public var parameterValue : String;

		//----------------------               Public Methods               ----------------------//
		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			parameterValue = injectParameters.param;
			return new Clazz();
		}
	}
}