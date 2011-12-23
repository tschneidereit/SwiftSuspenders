/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	public class TypeDescription
	{
		//----------------------              Public Properties             ----------------------//
		public var ctor : ConstructorInjectionPoint;
		public var injectionPoints : InjectionPoint;
		public var preDestroyMethods : PreDestroyInjectionPoint;

		//----------------------               Public Methods               ----------------------//
		public function addInjectionPoint(injectionPoint : InjectionPoint) : void
		{
			if (injectionPoints)
			{
				injectionPoints.last.next = injectionPoint;
				injectionPoints.last = injectionPoint;
			}
			else
			{
				injectionPoints = injectionPoint;
				injectionPoints.last = injectionPoint;
			}
		}
		public function addPreDestroyMethod(method : PreDestroyInjectionPoint) : void
		{
			if (preDestroyMethods)
			{
				preDestroyMethods.last.next = method;
				preDestroyMethods.last = method;
			}
			else
			{
				preDestroyMethods = method;
				preDestroyMethods.last = method;
			}
		}
	}
}