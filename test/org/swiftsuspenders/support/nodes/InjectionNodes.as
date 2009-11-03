package org.swiftsuspenders.support.nodes
{
	public class InjectionNodes
	{
		public static const PROPERTY_INJECTION_NODE:XML =     
			<variable name="property" type="org.swiftsuspenders.support.types::Clazz">
				<metadata name="Inject"/>
			</variable>
			
		public static const NAMED_INJECTION_NODE:XML =  
			<metadata name="Inject">
				<arg key="name" value="namedCollection"/>
			</metadata>;
		
		public static const CONSTRUCTOR_INJECTION_NODE_SINGLE_ARGUMENT:XML = 
			<constructor>
				<parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
			</constructor>;
			
		public static const CONSTRUCTOR_INJECTION_NODE_TWO_ARGUMENT:XML = 
			<factory type="org.swiftsuspenders.support.injectees::TwoParametersConstructorInjectee">
				<constructor>
				  <parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
				  <parameter index="2" type="String" optional="false"/>
			   </constructor>
			</factory>;
			
		public static const METHOD_SET_DEPENDENCIES_INJECTION_NODE_TWO_PARAMETER:XML =         
			<method name="setDependencies" declaredBy="org.swiftsuspenders.support.injectees::TwoParametersMethodInjectee" returnType="void">
		      <parameter index="1" type="org.swiftsuspenders.support.types::Clazz" optional="false"/>
		      <parameter index="2" type="org.swiftsuspenders.support.types::Interface" optional="false"/>
		      <metadata name="Inject"/>
		    </method>;
	}
}