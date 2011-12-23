/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	import org.swiftsuspenders.Injector;

	public class OrderedInjectionPoint extends InjectionPoint
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		protected var _methodName : String;

		protected var _orderValue : int;

		public function OrderedInjectionPoint()
		{
		}

		public function get order() : int
		{
			return _orderValue;
		}

		override public function applyInjection(
			target : Object, targetType : Class, injector : Injector) : void
		{
			//TODO: Restore parameter-injection
			target[_methodName]();
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}