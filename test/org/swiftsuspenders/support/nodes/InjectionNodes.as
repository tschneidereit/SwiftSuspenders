/*
 * Copyright (c) 2009-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.nodes
{
	public class InjectionNodes
	{
		public static const CONSTRUCTOR_INJECTION_NODE_TWO_ARGUMENT:XML =
			<factory type="org.swiftsuspenders.support.injectees::TwoParametersConstructorInjectee">
				<constructor>
				  <parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
				  <parameter index="2" type="String" optional="false"/>
			   </constructor>
			</factory>;

		public static const CONSTRUCTOR_INJECTION_NODE_TWO_OPTIONAL_PARAMETERS:XML =
			<factory type="org.swiftsuspenders.support.injectees::TwoParametersConstructorInjectee">
				<constructor>
				  <parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="true"/>
				  <parameter index="2" type="String" optional="true"/>
			   </constructor>
			</factory>;

		public static const OPTIONAL_METHOD_INJECTION_NODE_WITH_REQUIRED_PARAMETER:XML =
				<method name="setDependencies" declaredBy="org.swiftsuspenders.support.injectees::TwoParametersMethodInjectee" returnType="void">
					<parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
					<metadata name="Inject">
						<arg key="optional" value='true'/>
					</metadata>
				</method>;

		public static const METHOD_SET_DEPENDENCIES_INJECTION_NODE_TWO_PARAMETER:XML =
			<method name="setDependencies" declaredBy="org.swiftsuspenders.support.injectees::TwoParametersMethodInjectee" returnType="void">
		      <parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
		      <parameter index="2" type="org.swiftsuspenders.support.types::Interface" optional="false"/>
		      <metadata name="Inject"/>
		    </method>;

		public static const METHOD_SET_DEPENDENCIES_INJECTION_NODE_ONE_REQUIRED_ONE_OPTIONAL_PARAMETER:XML =
				<method name="setDependencies" declaredBy="org.swiftsuspenders.support.injectees::OneRequiredOneOptionalPropertyMethodInjectee" returnType="void">
					<parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
					<parameter index="2" type="org.swiftsuspenders.support.types::Interface" optional="true"/>
					<metadata name="Inject"/>
				</method>;

		public static const METHOD_NODE_WITH_UNTYPED_PARAMETER:XML =
				<method name="setDependencies" declaredBy="org.swiftsuspenders.support.injectees::OneRequiredOneOptionalPropertyMethodInjectee" returnType="void">
					<parameter index="1" type="*" optional="false"/>
					<metadata name="Inject"/>
				</method>;
	}
}