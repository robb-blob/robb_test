# robb_test
Deploy using the [package install url](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t1n000001pGuxAAE). Make sure to accept the fixer.io remote site setting prompt.

You can also create and deploy a scratch org with:
    sfdx force:org:create -s -t scratch -a robb_test -f config/project-scratch-def.json
    sfdx force:package:version:create -x -p "robb_test"
    sfdx force:package:install -w 1 -p "robb_test" -r

However, the first method is preferred since this has been causing some issues with package/alias ID.