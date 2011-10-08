package org.swiftsuspenders
{
	public class InstanceInfo extends Object
	{
		//----------------------              Public Properties             ----------------------//
		public function get instance() : *
		{
			return _instance;
		}

		public function get instanceType() : Class
		{
			return _instanceType;
		}

		public function get targetType() : Class
		{
			return _targetType;
		}

		//----------------------       Private / Protected Properties       ----------------------//
		private var _instance : Object;
		private var _instanceType : Class;
		private var _targetType : Class;


		//----------------------               Public Methods               ----------------------//
		public function InstanceInfo(instance : Object, instanceType : Class, targetType : Class)
		{
			super();
			_instance = instance;
			_instanceType = instanceType;
			_targetType = targetType;
		}
	}
}