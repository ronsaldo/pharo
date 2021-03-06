Class {
	#name : #GTInspectorVariableValuePairsTest,
	#superclass : #TestCase,
	#category : #'GT-Tests-Inspector'
}

{ #category : #object }
GTInspectorVariableValuePairsTest >> testArrayPairsEqualLimit [

	| limit pairs|	
	limit := 2*GTInspector indexableDisplayLimit.
	pairs := (1 to: limit) asArray gtInspectorVariableValuePairs.
	self assert: pairs size equals: limit.
	(pairs collect: [:each | each key]) allSatisfy: [ :e | (pairs at: e) = e ].
	self assert: (pairs collect: [:each | each key]) equals: (1 to: limit) asOrderedCollection
]

{ #category : #object }
GTInspectorVariableValuePairsTest >> testArrayPairsLong [
	
	| limit pairs |
	limit := 3 * GTInspector indexableDisplayLimit.
	pairs := (1 to: limit) asArray gtInspectorVariableValuePairs.
	self assert: pairs size equals: (2 * GTInspector indexableDisplayLimit).
	(pairs collect: [:each | each key]) allSatisfy: [ :e | (pairs at: e) = e ].
	self assert: (pairs collect: [:each | each key]) equals: ((1 to: GTInspector indexableDisplayLimit ) asOrderedCollection 
		addAll: (limit - GTInspector indexableDisplayLimit + 1 to: limit) asOrderedCollection; yourself)
]

{ #category : #object }
GTInspectorVariableValuePairsTest >> testArrayPairsOverLimit [
	
	| limit pairs |
	limit := 2 * GTInspector indexableDisplayLimit + 1.
	pairs := (1 to: limit) asArray gtInspectorVariableValuePairs.
	self assert: pairs size equals: (2 * GTInspector indexableDisplayLimit).
	(pairs collect: [:each | each key]) allSatisfy: [ :e | (pairs at: e) = e ].
	self assert: (pairs collect: [:each | each key]) equals: ((1 to: GTInspector indexableDisplayLimit ) asOrderedCollection 
		addAll: (limit - GTInspector indexableDisplayLimit + 1 to: limit) asOrderedCollection; yourself).
]

{ #category : #object }
GTInspectorVariableValuePairsTest >> testArrayPairsSmall [
	| pairs |
	
	pairs := (1 to: 10) asArray gtInspectorVariableValuePairs.
	self assert: pairs size equals: 10.
	(pairs collect: [:each | each key]) allSatisfy: [ :e | (pairs at: e) = e ]
]

{ #category : #object }
GTInspectorVariableValuePairsTest >> testArrayPairsUnderLimit [

	| limit pairs |
	limit := 2 * GTInspector indexableDisplayLimit - 1.
	pairs := (1 to: limit) asArray gtInspectorVariableValuePairs.
	self assert: pairs size equals: limit.
	(pairs collect: [:each | each key]) allSatisfy: [ :e | (pairs at: e) = e ].
	self assert: (pairs collect: [:each | each key]) equals: (1 to: limit) asOrderedCollection
]

{ #category : #context }
GTInspectorVariableValuePairsTest >> testContextNodes [
	| pairs x tempVariables indexVariables instVariables |
	
	x:=42.
	pairs := OrderedCollection new.
	[:y| y+1+x ] asContext gtInspectorVariableNodesIn: pairs.	
	pairs := pairs withIndexCollect: [ :e :i | i -> e].
	
	tempVariables := pairs select: [ :e | e value label beginsWith: '[' ].
	indexVariables := pairs select: [ :e | e value key isInteger ].
	instVariables := pairs select: [ :e | e value isKindOf: GTInspectorSlotNode ].
	
	self assert: (tempVariables sort last key) < (indexVariables first key).
	self assert: (indexVariables sort last key) < (instVariables first key).
]

{ #category : #float }
GTInspectorVariableValuePairsTest >> testFloatPairs [
	| pairs |
	
	pairs := 4.2 gtInspectorVariableValuePairs.
	self assert: pairs size equals: 2.
	
	self assert: pairs first equals: ('1' -> 1074842828).
	self assert: pairs second equals: ('2' -> 3435973837)
]
