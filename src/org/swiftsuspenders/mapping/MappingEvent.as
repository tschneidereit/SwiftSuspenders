/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.mapping
{
	import flash.events.Event;

	public class MappingEvent extends Event
	{
		//----------------------              Public Properties             ----------------------//
		/**
		 * @eventType preMappingCreate
		 */
		public static const PRE_MAPPING_CREATE : String = 'preMappingCreate';
		/**
		 * @eventType postMappingCreate
		 */
		public static const POST_MAPPING_CREATE : String = 'postMappingCreate';
		/**
		 * @eventType preMappingChange
		 */
		public static const PRE_MAPPING_CHANGE : String = 'preMappingChange';
		/**
		 * @eventType postMappingChange
		 */
		public static const POST_MAPPING_CHANGE : String = 'postMappingChange';
		/**
		 * @eventType postMappingRemove
		 */
		public static const POST_MAPPING_REMOVE : String = 'postMappingRemove';
		/**
		 * @eventType mappingOverride
		 */
		public static const MAPPING_OVERRIDE : String = 'mappingOverride';


		public var mappedType : Class;
		public var mappedName : String;
		public var mapping : InjectionMapping;



		//----------------------               Public Methods               ----------------------//
		public function MappingEvent(
			type : String, mappedType : Class, mappedName : String, mapping : InjectionMapping)
		{
			super(type);
			this.mappedType = mappedType;
			this.mappedName = mappedName;
			this.mapping = mapping;
		}

		override public function clone() : Event
		{
			return new MappingEvent(type, mappedType, mappedName, mapping);
		}
	}
}