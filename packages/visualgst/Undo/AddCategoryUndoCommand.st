UndoCommand subclass: AddCategoryUndoCommand [
    | categoryWidget category selectedCategory |

    AddCategoryUndoCommand class >> add: aSymbol onWidget: aGtkCategoryWidget [
	<category: 'instance creation'>

	^ (self new)
	    add: aSymbol onWidget: aGtkCategoryWidget;
	    precondition;
	    yourself
    ]

    add: aSymbol onWidget: aGtkCategoryWidget [
	<category: 'initialize'>

	category := aSymbol.
	categoryWidget := aGtkCategoryWidget
    ]

    description [
	<category: 'accessing'>

	^ 'Add a category'
    ]

    precondition [
        <category: 'checking'>

	category = '*' ifTrue: [ self error: 'Can''t create a * category' ].
	(categoryWidget hasCategory: category asString) ifTrue: [ self error: 'Category is present' ].
	categoryWidget hasSelectedCategory ifTrue: [ selectedCategory := categoryWidget selectedCategory ]
    ]

    undo [
	<category: 'events'>

	SystemChangeNotifier uniqueInstance categoryRemoved: category asString inClass: categoryWidget classOrMeta.
	categoryWidget selectACategory: selectedCategory
    ]

    redo [
	<category: 'events'>

	SystemChangeNotifier uniqueInstance categoryAdded: category asString inClass: categoryWidget classOrMeta.
	categoryWidget selectACategory: category asString
    ]
]

