"Reset Work"
MooseModel resetRoot.
MooseModel resetMeta.

"Generate BlApp"
aw := AnalyseCommand new.
fileName := 'D:\Users\benoit.verhaeghe\Documents\PFE\Source\BLCoreIncubatorGwt\src\fr\bl\application.module.xml'. 
xml := aw getXmlFile: fileName.
mseFile := StandardFileStream fileNamed: 'D:\Users\benoit.verhaeghe\Documents\PFE\GeneralXmlui.mse' .
mooseModel := MooseModel importFromMSEStream: mseFile .
mooseModel rootFolder: 'D:\Users\benoit.verhaeghe\Documents\PFE\'.
blApp := BLApplication new model: mooseModel; applicationXml: xml ; sourceApp: './Source/BLCoreIncubatorGwt/'; sourceCore: './Source/BLCore-6.1.4/'.

"Generate Bl Model"
model := MooseModel new name: 'Showroom'; yourself.
BLMooseModelCreator runOn: model from: blApp.

"Add Model to moose panel"
MooseModel root add: model.



model := BLModelExample generateModelWithTwoPhasesAndThreePageMetierAnd1Widget.
BLModelExporterAngular export: model.