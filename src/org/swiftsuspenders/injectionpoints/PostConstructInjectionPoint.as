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
		protected var methodName : String;
		protected var orderValue : int;


		//----------------------               Public Methods               ----------------------//
		public function PostConstructInjectionPoint(node : XML)
		{
			initializeInjection(node);
		}
		
		public function get order():int
		{
			return orderValue;
		}

		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			target[methodName]();
			return target;
		}


		//----------------------         Private / Protected Methods        ----------------------//
		protected function initializeInjection(node : XML) : void
		{
			var orderArg : XMLList = node.arg.(@key == 'order');
			var methodNode : XML = node.parent();
			orderValue = int(orderArg.@value);
			methodName = methodNode.@name.toString();
		}
	}
}