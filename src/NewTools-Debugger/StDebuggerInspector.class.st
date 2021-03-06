"
I am an inspector dedicated to the debugger.
I wrap a StInspector object which provides inspection views for the inspected object.
I add specific debugger functionalities:
- I remember selection in the inspector list depending on the context
- I dynamically change my layout depending on the context (e.g., I show a diff view in case of an assertion failure)
"
Class {
	#name : #StDebuggerInspector,
	#superclass : #SpPresenter,
	#instVars : [
		'inspector',
		'model',
		'label',
		'rawInspectionSelectionCache',
		'assertionFailure',
		'currentLayout',
		'currentLayoutSpec'
	],
	#category : #'NewTools-Debugger-View'
}

{ #category : #specs }
StDebuggerInspector class >> assertionFailureSpec [
	^ SpPanedLayout newVertical
		position: 40 percent;
		add: #assertionFailure;
		add: #inspector;
		yourself
]

{ #category : #specs }
StDebuggerInspector class >> defaultSpec [
	^ SpBoxLayout newVertical
		  add: #inspector;
		  yourself
]

{ #category : #'instance creation' }
StDebuggerInspector class >> openOn: anObject [

	^ (self on: (StInspectorModel on: anObject)) openWithSpec
]

{ #category : #specs }
StDebuggerInspector class >> title [
	 ^'Debugger Inspection'
]

{ #category : #accessing }
StDebuggerInspector >> assertionFailure [
	^assertionFailure 
]

{ #category : #layout }
StDebuggerInspector >> assertionLayoutSpec [
	^#assertionFailureSpec
]

{ #category : #layout }
StDebuggerInspector >> currentLayoutSpec [
	^currentLayoutSpec
]

{ #category : #accessing }
StDebuggerInspector >> debuggerInspectorModelClass [
	^ StDebuggerInspectorModel
]

{ #category : #layout }
StDebuggerInspector >> defaultLayoutSpec [
	^#defaultSpec
]

{ #category : #updating }
StDebuggerInspector >> forceRawInspectionUpdate [

	self getRawInspectorPresenterOrNil ifNotNil: [ :inspection | 
		inspection update ]
]

{ #category : #private }
StDebuggerInspector >> getRawInspectorPresenterOrNil [
	^ inspector millerList pages first rawInspectorPageOrNil activePresenter
]

{ #category : #private }
StDebuggerInspector >> getRawInspectorSelectedPath [
	^ self getRawInspectorPresenterOrNil
		  ifNil: [ #(  ) ]
		  ifNotNil: [ :raw | raw selectedPath ]
]

{ #category : #initialization }
StDebuggerInspector >> initializePresenters [

	label := self newLabel.
	inspector := self instantiate: StInspector on: self model.
	currentLayoutSpec := self defaultLayoutSpec
]

{ #category : #accessing }
StDebuggerInspector >> inspectedObject [

	^ self model inspectedObject
]

{ #category : #accessing }
StDebuggerInspector >> label: aString [

	label label: aString
]

{ #category : #'accessing model' }
StDebuggerInspector >> model [

	^ model
]

{ #category : #'accessing model' }
StDebuggerInspector >> model: aModel [

	model := aModel.
	inspector model: model
]

{ #category : #accessing }
StDebuggerInspector >> rawInspectionSelectionCache [
	^ rawInspectionSelectionCache ifNil: [ 
		  rawInspectionSelectionCache := Dictionary new ]
]

{ #category : #private }
StDebuggerInspector >> restoreRawInspectionSelectionForContext: aContext [
	aContext ifNil: [ ^ self ].
	self getRawInspectorPresenterOrNil
		ifNotNil: [ :raw | 
			| receiverClass selector path |
			receiverClass := aContext receiver class.
			selector := aContext selector.
			path := self rawInspectionSelectionCache
				at: receiverClass -> selector
				ifAbsent: [ #() ].
			path ifEmpty: [ self rawInspectionSelectionCache at: receiverClass ifAbsent: [ #() ] ].
			path ifEmpty: [ | roots pathStart |
					roots := raw attributeTable roots.
					pathStart := 1.
					1 to: roots size do: [ :i | 
						(roots at: i) key = 'Temps' ifTrue: [ pathStart := i ] ].
					path := {pathStart. 1} ].
			raw selectPath: path ]
]

{ #category : #private }
StDebuggerInspector >> saveRawInspectionSelectionForContext: aContext [
	| selectionPath |
	aContext ifNil: [ ^ self ].
	selectionPath := self getRawInspectorSelectedPath.
	self rawInspectionSelectionCache
		at: aContext receiver class -> aContext selector
		put: selectionPath.
	self rawInspectionSelectionCache
		at: aContext receiver class
		put: selectionPath
]

{ #category : #layout }
StDebuggerInspector >> setAssertionLayout [
	currentLayoutSpec := self assertionLayoutSpec.
	self layout: self class assertionFailureSpec
]

{ #category : #layout }
StDebuggerInspector >> setDefaultLayout [
	
	currentLayoutSpec := self defaultLayoutSpec.
	self layout: self class defaultSpec
]

{ #category : #'accessing model' }
StDebuggerInspector >> setModelBeforeInitialization: aModel [

	model := aModel
]

{ #category : #stepping }
StDebuggerInspector >> step [
	inspector step
]

{ #category : #updating }
StDebuggerInspector >> updateEvaluationPaneReceiver [
	"| context evaluator |
	
	context := self model inspectedObject context.
	evaluator := inspector millerList pages first evaluator.
	evaluator beForContextReceiver: context"
]

{ #category : #layout }
StDebuggerInspector >> updateLayoutForContexts: aContext isAssertionFailure: isTopContextFailingAssertion [
	isTopContextFailingAssertion
		ifFalse: [ currentLayoutSpec = self defaultLayoutSpec
				ifTrue: [ ^ self ].
			self setDefaultLayout.
			^ self ].
	currentLayoutSpec = self assertionLayoutSpec
		ifTrue: [ ^ self ].
	self flag: 'Way too much magickal: why these indexes?'.
	assertionFailure := StFailingAssertionInspector
		diffInspectorsFromActual: ((aContext at: 2) at: 2)
		expected: ((aContext at: 2) at: 1)
		application: self application.
	self setAssertionLayout
]

{ #category : #updating }
StDebuggerInspector >> updateWith: inspectedObject [
	| oldContext newContext |
	oldContext := self model inspectedObject ifNotNil: [ :dbgCtx | 
		              dbgCtx context ].
	newContext := inspectedObject ifNotNil: [ :dbgCtx | dbgCtx context ].
	(oldContext notNil and: [ newContext notNil ]) ifTrue: [ 
		(oldContext receiver == newContext receiver and: [ 
			 oldContext selector == newContext selector ]) ifTrue: [ ^ self ] ].

	self saveRawInspectionSelectionForContext: oldContext.
	self model: (self debuggerInspectorModelClass on: inspectedObject).
	self updateEvaluationPaneReceiver.
	self restoreRawInspectionSelectionForContext: newContext
]
