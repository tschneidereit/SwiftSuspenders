/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;
	
	public class PostConstructInjectionPoint extends InjectionPoint
	{
		/*******************************************************************************************
		 *								private properties										   *
		 *******************************************************************************************/
		protected var methodName : String;
		protected var orderValue:int;
		
		
		/*******************************************************************************************
		 *								public methods											   *
		 *******************************************************************************************/
		public function PostConstructInjectionPoint(node:XML, injector : Injector = null)
		{
			super(node, injector);
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
		
		
		/*******************************************************************************************
		 *								protected methods										   *
		 *******************************************************************************************/
		override protected function initializeInjection(node : XML) : void
		{
			var orderArg : XMLList = node.arg.(@key == 'order');
			var methodNode : XML = node.parent();
			orderValue = int(orderArg.@value);
			methodName = methodNode.@name.toString();
		}
	}
}