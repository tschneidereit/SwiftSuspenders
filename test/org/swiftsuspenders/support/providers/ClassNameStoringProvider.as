/*
 * Copyright (c) 2012 the original author or authors
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

	public class ClassNameStoringProvider implements DependencyProvider
	{
		//----------------------              Public Properties             ----------------------//
		public var lastTargetClassName : String;

		//----------------------               Public Methods               ----------------------//
		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			lastTargetClassName = getQualifiedClassName(targetType);
			return new Clazz();
		}

		public function destroy() : void
		{
		}
	}
}