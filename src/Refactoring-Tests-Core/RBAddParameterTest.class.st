Class {
	#name : #RBAddParameterTest,
	#superclass : #RBRefactoringTest,
	#category : #'Refactoring-Tests-Core-Refactorings'
}

{ #category : #running }
RBAddParameterTest >> setUp [
	super setUp.
	model := self abstractVariableTestData.
]

{ #category : #tests }
RBAddParameterTest >> testAddParameterForTwoArgumentMessage [
	| oldSelector newSelector refactoring class |
	oldSelector := ('called:' , 'on:') asSymbol.
	newSelector := #called:bar:on:.
	refactoring := RBAddParameterRefactoring 
		addParameterToMethod: oldSelector
		in: RBRefactoryTestDataApp
		newSelector: newSelector
		initializer: '#(1.0)'.
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self assert: (class parseTreeFor: newSelector) equals: (self parseMethod: 'called: anObject bar: aBlock on: anObject1
							Transcript
								show: anObject printString;
								cr.
								aBlock value').
	self assert: (class parseTreeFor: #caller) equals: (self parseMethod: 'caller
							| anObject |
							anObject := 5.
							self 
								called: anObject + 1
								bar: [^anObject] on: #(1.0)').
	self deny: (class directlyDefinesMethod: oldSelector)
]

{ #category : #tests }
RBAddParameterTest >> testAddParameterThatReferencesGlobalAndLiteral [

	| refactoring class oldSelector newSelector |
	oldSelector := ('test' , 'Foo:') asSymbol.
	newSelector := #testFoo:bar:.
	refactoring := RBAddParameterRefactoring
		               addParameterToMethod: oldSelector
		               in: RBRefactoryTestDataApp
		               newSelector: newSelector
		               initializer: 'OrderedCollection new: 5'.
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self
		assert: (class parseTreeFor: newSelector)
		equals: (self parseMethod: 'testFoo: anObject bar: anObject1
								^self class + anObject').
	self
		assert: (class parseTreeFor: #callFoo)
		equals: (self parseMethod:
				 'callFoo ^self testFoo: 5 bar: (OrderedCollection new: 5)').
	self deny: (class directlyDefinesMethod: oldSelector)
]

{ #category : #tests }
RBAddParameterTest >> testAddParameterThatReferencesModelGlobal [

	| refactoring class oldSelector newSelector |
	oldSelector := ('test' , 'Foo:') asSymbol.
	newSelector := #testFoo:bar:.
	refactoring := RBAddParameterRefactoring
		               model: model
		               addParameterToMethod: oldSelector
		               in: RBRefactoryTestDataApp
		               newSelector: newSelector
		               initializer: 'Bar new'.
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self
		assert: (class parseTreeFor: newSelector)
		equals: (self parseMethod: 'testFoo: anObject bar: anObject1
								^self class + anObject').
	self
		assert: (class parseTreeFor: #callFoo)
		equals:
		(self parseMethod: 'callFoo ^self testFoo: 5 bar: (Bar new)').
	self deny: (class directlyDefinesMethod: oldSelector)
]

{ #category : #tests }
RBAddParameterTest >> testAddParameterThatReferencesSelf [

	| refactoring class oldSelector newSelector |
	oldSelector := ('test' , 'Foo:') asSymbol.
	newSelector := #testFoo:bar:.
	refactoring := RBAddParameterRefactoring
		               addParameterToMethod: oldSelector
		               in: RBRefactoryTestDataApp
		               newSelector: newSelector
		               initializer: 'self printString'.
	self proceedThroughWarning: [ self executeRefactoring: refactoring ].
	class := refactoring model classNamed: #RBRefactoryTestDataApp.
	self
		assert: (class parseTreeFor: newSelector)
		equals: (self parseMethod: 'testFoo: anObject bar: anObject1
								^self class + anObject').
	self
		assert: (class parseTreeFor: #callFoo)
		equals:
		(self parseMethod:
			 'callFoo ^self testFoo: 5 bar: (self printString)').
	self deny: (class directlyDefinesMethod: oldSelector)
]

{ #category : #'failure tests' }
RBAddParameterTest >> testBadInitializationCode [
	self
		shouldFail: (RBAddParameterRefactoring 
				addParameterToMethod: #name
				in: RBLintRuleTestData
				newSelector: #name:
				initializer: 'foo:');
		shouldFail: (RBAddParameterRefactoring 
				addParameterToMethod: #name
				in: RBLintRuleTestData
				newSelector: #name:
				initializer: 'foo')
]

{ #category : #'failure tests' }
RBAddParameterTest >> testInvalidNumArgsOfNewSelector [
	self shouldFail: (RBAddParameterRefactoring 
			addParameterToMethod: #checkSendersAccessTo:
			in: RBLintRuleTestData
			newSelector: #checkSendersAccessTo:
			initializer: 'nil')
]

{ #category : #'failure tests' }
RBAddParameterTest >> testModelBadInitializationCode [
	| refactoring |
	model removeClassNamed: #RBRefactoring.
	refactoring := RBAddParameterRefactoring 
		model: model
		addParameterToMethod: #name1
		in: RBLintRuleTestData
		newSelector: #name1:
		initializer: 'AddParameterRefactoring new'.
	self shouldFail: refactoring
]

{ #category : #'failure tests' }
RBAddParameterTest >> testModelNonExistantName [
	| refactoring |
	(model classNamed: #RBLintRuleTestData) removeMethod: #name.
	refactoring := RBAddParameterRefactoring 
		model: model
		addParameterToMethod: #name
		in: RBLintRuleTestData
		newSelector: #nameNew:
		initializer: 'nil'.
	self shouldFail: refactoring
]

{ #category : #'failure tests' }
RBAddParameterTest >> testNonExistantName [
	self shouldFail: (RBAddParameterRefactoring 
			addParameterToMethod: #name1
			in: RBLintRuleTestData
			newSelector: #name1:
			initializer: 'nil')
]

{ #category : #'failure tests' }
RBAddParameterTest >> testPrimitiveMethods [
	| refactoring |
	(model classNamed: #Object) 
		compile: 'foo <primitive: 100> ^#() primitiveFailed'
		classified: #(#accessing).
	refactoring := RBAddParameterRefactoring 
				model: model
				addParameterToMethod: #foo
				in: Object
				newSelector: #foo123124321s:
				initializer: '1'.
	self shouldFail: refactoring.
	refactoring := RBAddParameterRefactoring 
				addParameterToMethod: #at:
				in: Object
				newSelector: #at:foo:
				initializer: '1'.
	self shouldFail: refactoring.
	
]

{ #category : #'failure tests' }
RBAddParameterTest >> testUseExistingNewSelector [
	self shouldFail: (RBAddParameterRefactoring 
			addParameterToMethod: #checkSendersAccessTo:
			in: RBLintRuleTestData
			newSelector: #safeVariableNameFor:temporaries:
			initializer: 'nil')
]
