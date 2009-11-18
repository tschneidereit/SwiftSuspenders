package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	
	import org.swiftsuspenders.Injector;
	
	public class PostConstructInjectionPoint extends InjectionPoint
	{
		protected var methodName : String;
		protected var orderValue:int;
		
		public function PostConstructInjectionPoint(node:XML, injectorMappings:Dictionary)
		{
			super(node, injectorMappings);
		}
		
		public function get order():int
		{
			return orderValue;
		}

		override public function applyInjection(
			target : Object, injector : Injector, singletons : Dictionary) : Object
		{
			var method : Function = target[methodName];
			method.call();
			return target;
		}
		
		override protected function initializeInjection(node : XML, injectorMappings : Dictionary) : void
		{
			var orderArg : XMLList = node.arg.(@key == 'order');
			var methodNode : XML = node.parent();
			orderValue = int(orderArg.@value)
			methodName = methodNode.@name.toString();
		}
	}
}