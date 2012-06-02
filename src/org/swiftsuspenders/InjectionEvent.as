/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.events.Event;

	public class InjectionEvent extends Event
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

		public var instance : *;
		public var instanceType : Class;


		//----------------------               Public Methods               ----------------------//
		public function InjectionEvent(type : String, instance : Object, instanceType : Class)
		{
			super(type);
			this.instance = instance;
			this.instanceType = instanceType;
		}

		override public function clone() : Event
		{
			return new InjectionEvent(type, instance, instanceType);
		}
	}
}