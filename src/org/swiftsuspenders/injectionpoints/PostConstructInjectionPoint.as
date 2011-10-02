/*
* Copyright (c) 2009-2011 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;

	public class PostConstructInjectionPoint extends InjectionPoint
	{
		//----------------------       Private / Protected Properties       ----------------------//
		protected var _methodName : String;
		protected var _orderValue : int;


		//----------------------               Public Methods               ----------------------//
		public function PostConstructInjectionPoint(methodName : String, order : int)
		{
			_methodName = methodName;
			_orderValue = order;
		}
		
		public function get order():int
		{
			return _orderValue;
		}

		override public function applyInjection(
				target : Object, targetType : Class, injector : Injector) : void
		{
			//TODO: Restore parameter-injection
			target[_methodName]();
		}
	}
}