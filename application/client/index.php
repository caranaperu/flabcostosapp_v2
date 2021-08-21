<html>
<head>
    <meta charset="utf-8">
    <title>Future Labs</title>
    <SCRIPT>var isomorphicDir = "../../../common/client/isomorphic/";</SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Core.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Foundation.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Containers.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Grids.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_Forms.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic/system/modules-debug/ISC_DataBinding.js></SCRIPT>

    <SCRIPT SRC=../../../common/client/isomorphic/skins/EnterpriseBlue/load_skin.js></SCRIPT>

    <SCRIPT SRC=./appConfig.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/IControlledCanvas.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/controller/DefaultController.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/DynamicFormExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/WindowBasicFormExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/WindowBasicFormNCExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/WindowGridListExt.js></SCRIPT>
    <SCRIPT SRC=../../../common/client/isomorphic_lib/view/TabSetExt.js></SCRIPT>


    <SCRIPT SRC=./model/LoginModel.js></SCRIPT>
    <SCRIPT SRC=./view/login/LoginForm.js></SCRIPT>

</head>
<body></body>
<SCRIPT>
    var controller = isc.DefaultController.create({mainWindowClass: undefined, formWindowClass: 'WinLoginForm'});
    controller.doSetup(true, null);

</SCRIPT>
</html>