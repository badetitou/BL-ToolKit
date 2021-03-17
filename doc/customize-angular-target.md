# Customize Angular Target <!-- omit in toc -->

For your project, you might want to use other widgets as targets.
Or you want to modify the default export of a widget.
This is possible in Casino using *Angular Configuration*.

- [Angular Configuration](#angular-configuration)
- [Widget Representation](#widget-representation)
  - [Add a component](#add-a-component)
  - [Customize a component generation](#customize-a-component-generation)
    - [Customize Header](#customize-header)
    - [Customize Footer](#customize-footer)
    - [Customize Content](#customize-content)
    - [Dependencies between Angular module/components](#dependencies-between-angular-modulecomponents)
    - [Default attributes](#default-attributes)

## Angular Configuration

For the exportation, the `CSNModelExporterAngular` takes as parameter a `CSNExporterAngularConfiguration` instance.
This class is responsible for the mapping between Casino widgets and Angular widgets.

In Casino, there are two existing configuration:

- `CSNExporterAngularMaterialConfiguration` is the configuration that uses most of the [angular.material.io](https://angular.material.io) components set
- `CSNExporterAngularCoreWeb2Configuration` is specific industrial partner of this project

Each configuration has a mapping dictionary that link, a casino widget *class* to an Angular widget representation *instance*.

```st
CSNExporterAngularMaterialConfiguration >> #defaultConfiguration
  ^ super defaultConfiguration
    addAll:
      {(CSNUIButton -> MCButton new).
      (CSNUICWAutoComplete -> MCAutocomplete new).
      (CSNUILink
        ->
          (MCButton new
            isLink: true;
            yourself)).
      (CSNUIImage -> HTMLImgComponent new)} asDictionary;
  yourself
```

In the above example (part of the Material Configuration), a `CSNUIButton` is converted into a [raised MCButton](https://material.angular.io/components/button/overview).
The `CSNUICWAutoComplete` is converted into a [MCAutocomplete](https://material.angular.io/components/autocomplete/overview).
And a `CSNUILink` is converted into a [basic MCButton](https://material.angular.io/components/button/overview).

## Widget Representation

The `WidgetRepresentation` class offers a nice API to create target Angular widget.
In the following, we present two examples: adding a simple component, customize a component generation

### Add a component

This example presents how to add a component for the angular export.
First, we choose a component we to add in Casino.
For the example, we will add a [slide toogle](https://material.angular.io/components/slide-toggle/overview) component.

First, we create a Pharo class that will represent the component.

```st
MaterialComponent subclass: #MCSlideToggle
  instanceVariableNames: ''
  classVariableNames: ''
  package: 'Casino-Core-ExternalLibrary'
```

> The `MaterialComponent` class is a subclass of `WidgetRepresentation`

Then, we must implement five methods:

- `isLocal` returns
  - `true` if the component is defined in the target Angular project
  - `false` if the component is imported from an external project (*It is our case*)

  ```st
  isLocal
   ^ false
  ```

- `isNative` returns
  - `true` if the component is part of the html standard (*e.g.*, `<p>`, `<img/>`, *etc*.)
  - `false` instead

  ```st
  isNative
 "The widget is part of the html standard"
 ^ false
  ```

- `moduleName` returns the name of the Angular Module to import to access this component

  ```st
  moduleName
   ^ 'MatSlideToggleModule'
  ```

- `modulePath` returns the path to access the module

  ```st
  modulePath
    ^ '@angular/material/slide-toggle'
  ```

- `getSelector` returns the tag name (*i.e.*, `<tag-name>`)

  ```st
  getSelector
   ^ 'mat-slide-toggle'
  ```

Once all these methods are implemented, it is possible to use the component in an Angular Configuration.

For instance, the `MCSlideToggle` component is added as follow:

```st
CSNExporterAngularMaterialConfiguration >> #defaultConfiguration
  ^ super defaultConfiguration
    addAll:
      {"..."
      (CSNUICWSwitch -> MCSlideToggle new).
      "..."
      } asDictionary;
    yourself
```

### Customize a component generation

A component might need more configuration.
It is the case, for example, of the [material date picker](https://material.angular.io/components/datepicker/overview).

A material date picker does not follow the classic component structure.
Additionally to the classic `input` tag, it is embedded into a complex structure that allows a nice display in the GUI.

The following snippet presents a simple date picker

```html
<mat-form-field appearance="fill">
  <mat-label>Choose a date</mat-label>
  <input matInput [matDatepicker]="picker"> <!-- The actual component -->
  <mat-datepicker-toggle matSuffix [for]="picker"></mat-datepicker-toggle>
  <mat-datepicker #picker></mat-datepicker>
</mat-form-field>
```

To better control the data picker, we also need to use a [DateAdapter](https://material.angular.io/components/datepicker/examples#date-range-picker-forms).
In the following, we present how we adapted the component using the `WidgetRepresentation` extensive API.

First, we created a helper method that gives us a name for the datepicker (`[matDatepicker]="the name"`)

```st
MCDatePicker >> #variableFor: widget
  ^ 'picker', widget mooseID printString
```

Then, we modified the header and the footer.

#### Customize Header

For the *header*, we extended the existing `#exportHeaderOf:with:` method.

```st
MCDatePicker >> #exportHeaderOf: aWidget with: anExporter
  anExporter << '<mat-form-field appearance="fill">'; crlf.
  aWidget attributes
    detect: [ :att | att isOfType: CSNUILabel ]
    ifFound: [ :att | 
      anExporter
        indentPlus;
        << '<mat-label>';
        crlf;
        visit: att;
        crlf;
        << '</mat-label>';
        indentMinus
    ]
```

The second line adds the container `mat-form-field` tag.
Then, we look if the widget has a label attribute in the Casino GUI model.
If so, we export it inside a `mat-label` tag.
As you can see, the `exporter` also has a nice API to adds/removes indentations (`indentPlus`/`indentMinus`) or breakLine (`crlf`).

#### Customize Footer

For the *footer*, we extended the existing `#exportFooterOf:with:` method.

```st
MCDatePicker >> #exportFooterOf: aWidget with: anExporter
  anExporter
    << '<mat-datepicker-toggle matSuffix [for]="';
    <<< (self variableFor: aWidget);
    <<< '"></mat-datepicker-toggle>';
    crlf;
    << '<mat-datepicker #picker></mat-datepicker>';
    crlf;
    << '</mat-form-field>'
```

This modification allows the tags below the `input` one.
In particular, it closes the `mat-form-field` opened in the header.

#### Customize Content

Then, we default way to export the content of the widget to add the `matDatepicker` information.
As for the header and footer, we extended a preexisting method: `#exportContentOf:with:`.

```st
MCDatePicker >> #exportContentOf: aWidget with: anExporter
  anExporter indentPlus; << '<'.
  aWidget getListPropertiesAsStringWith: anExporter.
  anExporter
    <<< ' [matDatepicker]="';
    <<< (self variableFor: aWidget);
    <<< '"';
    <<< '>';
    crlf;
    indentMinus
```

#### Dependencies between Angular module/components

Finally, we declared a that our `MCDatePicker` has a `MCDateAdapter` as dependency.
Dependencies are also handled by Casino.
Thus, we only need to extend the following method:

```st
MCDatePicker >> #internalDependencies
  ^ { MCDateAdapter new }
```

#### Default attributes

We did not need to declare default attribute in the previous example because we modified completely the header.
However, it is possible to add default attribute to components.
To do so, two methods exist:

- `#componentAttributeOn:` allows to hard code an attribute that will be added in a tag. The attribute can be absent of the Casino model and can not respect the "key -> value" attribute structure
  ```st
  MCInput >> #componentAttributeOn: anExporter
    "Example for the MCInput"
    "<input matInput type=""radio""/>"
    anExporter <<< ' matInput '
  ```
- `#attributeOf:` allows to add a Casino Attribute at generation time (not added in the model). This option is the one used when adding value to multi-value attribute such as `style` or `class`
  ```st
  CSNELCWBLInputComponent >> #attributeOf: aWidget
    "An example coming from our industrial partner"
    ^ (super attributeOf: aWidget) , ({CSNUIClass new attributeValue: 'blcore-input'})
  ```
