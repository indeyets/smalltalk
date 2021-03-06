UndoCommand subclass: AddMethodUndoCommand [

    | selector method category classOrMeta oldCompiledMethod browserWidget compiledMethod |

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass [
	<category: 'instance creation'>

	^ (self new)
	    add: aString classified: aCategory in: aClass;
	    precondition;
	    yourself
    ]

    AddMethodUndoCommand class >> add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'instance creation'>

        ^ (self new)
            add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget;
            precondition;
            yourself
    ]

    compileError: aString [
	<category: 'error printing'>

	VisualGST compileError: aString
    ]

    add: aString classified: aCategory in: aClass browser: aGtkBrowserWidget [
        <category: 'initialize'>

	self add: aString classified: aCategory in: aClass.
	browserWidget := aGtkBrowserWidget.
    ]

    add: aString classified: aCategory in: aClass [
	<category: 'initialize'>

	method := aString.
        category := (#('still unclassified' '*') includes: (aCategory))
					    ifTrue: [ nil ]
					    ifFalse: [ aCategory ].
	classOrMeta := aClass
    ]

    description [
	<category: 'accessing'>

	^ 'Add a method'
    ]

    precondition [
        <category: 'checking'>

	| parser |
        parser := STInST.RBBracketedMethodParser new
                    errorBlock: [ :string :pos | ^ self compileError: string ];
                    initializeParserWith: method type: #'on:errorBlock:';
                    yourself.
	selector := parser parseMethod selector.
	oldCompiledMethod := classOrMeta methodDictionary ifNotNil: [ classOrMeta methodDictionary at: selector ifAbsent: [ nil ] ].
	compiledMethod := classOrMeta
				compile: method
				classified: category
				ifError: [ :fname :lineNo :errorString |
				    ^ self compileError: 'Compile error ', errorString ].
    ]

    undo [
	<category: 'events'>

	| selector |
	classOrMeta methodDictionary removeMethod: compiledMethod.
	oldCompiledMethod 
	    ifNotNil: [
		classOrMeta methodDictionary insertMethod: oldCompiledMethod.
		selector := oldCompiledMethod selector ]
	    ifNil: [ selector := nil ].

	browserWidget ifNil: [ ^ self ].
	browserWidget codeSaved.
	"browserWidget ifNil: [ ^ self ].
	browserWidget codeSaved.
	oldCompiledMethod methodClass isMetaclass
	    ifTrue: [ browserWidget selectAClassMethod: selector ]
	    ifFalse: [ browserWidget selectAnInstanceMethod: selector ]."
    ]

    redo [
	<category: 'events'>

	classOrMeta methodDictionary insertMethod: compiledMethod.

	browserWidget ifNil: [ ^ self ].
	browserWidget codeSaved.
	"browserWidget ifNil: [ ^ self ].
	browserWidget codeSaved.
	compiledMethod methodClass isMetaclass
	    ifTrue: [ browserWidget selectAClassMethod: compiledMethod selector ]
	    ifFalse: [ browserWidget selectAnInstanceMethod: compiledMethod selector ]."
    ]
]

