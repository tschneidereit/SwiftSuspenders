package org.swiftsuspenders
{
	import flash.events.Event;

	public class InjectorEvent extends Event
	{
		//----------------------              Public Properties             ----------------------//
		/**
		 * @eventType postInstantiate
		 */
		public static const POST_INSTANTIATE : String = 'postInstantiate';
		/**
		 * @eventType preConstruct
		 */
		public static const PRE_CONSTRUCT : String = 'preConstruct';
		/**
		 * @eventType postConstruct
		 */
		public static const POST_CONSTRUCT : String = 'postConstruct';

		public var instanceInfo : InstanceInfo;


		//----------------------               Public Methods               ----------------------//
		public function InjectorEvent(type : String, instanceInfo : InstanceInfo)
		{
			super(type);
			this.instanceInfo = instanceInfo;
		}

		override public function clone() : Event
		{
			return new InjectorEvent(type, instanceInfo);
		}
	}
}