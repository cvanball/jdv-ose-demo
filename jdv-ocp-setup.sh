#!/bin/bash
echo 'Logging into oc tool as admin'
oc login https://10.1.2.2:8443 -u admin -p admin
echo 'Switching to the openshift project'
oc project openshift
echo 'Creating the image stream for the OpenShift datavirt image'
oc create -f https://raw.githubusercontent.com/cvanball/jdv-ose-demo/master/extensions/is.json
echo 'Creating the s2i quickstart template. This will live in the openshift namespace and be available to all projects'
oc create -n openshift -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/datavirt/datavirt63-extensions-support-s2i.json
oc login -u openshift-dev -p devel
echo 'Creating a new project called jdv-demo'
oc new-project jdv-demo
echo 'Creating a service account and accompanying secret for use by the data virt application'
oc create -f https://raw.githubusercontent.com/cvanball/jdv-ose-demo/master/extensions/datavirt-app-secret.yaml
echo 'Retrieving datasource properties (market data flat file and country list web service hosted on public internet)'
curl https://raw.githubusercontent.com/cvanball/jdv-ose-demo/master/extensions/datasources.properties -o datasources.properties
echo 'Creating a secret around the datasource properties'
oc secrets new datavirt-app-config datasources.properties
echo 'Deploying JDV quickstart template with default values'
oc new-app datavirt63-extensions-support-s2i -p SOURCE_REPOSITORY_URL=https://github.com/cvanball/jdv-ose-demo,CONTEXT_DIR=vdb,EXTENSIONS_REPOSITORY_URL=https://github.com/cvanball/jdv-ose-demo,EXTENSIONS_DIR=extensions,TEIID_USERNAME=teiidUser,TEIID_PASSWORD=redhat1!
echo '==============================================='
echo 'The following urls will allow you to access the vdbs (of which there are two) via OData2 and OData4:'
echo '==============================================='
echo 'ODATA 2'
echo 'Metadata for Country web service - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/$metadata'
echo 'Querying data from Country web service - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/country.Countries?$format=json'
echo 'Querying data from Country web service via primary key - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/country.Countries(‘Zimbabwe’)?$format=json'
echo 'Querying data from Country web service and returning specific fields - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/country.Countries?$select=name&$format=json'
echo 'Querying data from Country web service and showing top 5 results - http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata/country-ws/country.Countries?$top=5&$format=json'
echo '==============================================='
echo 'ODATA 4'
echo 'http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata4/country-ws/country/$metadata'
echo 'http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata4/country-ws/country/Countries?$format=json'
echo 'http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata4/country-ws/country/Countries(‘Zimbabwe’)?$format=json'
echo 'http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata4/country-ws/country/Countries?$select=name&$format=json'
echo 'http://datavirt-app-jdv-demo.rhel-cdk.10.1.2.2.xip.io/odata4/country-ws/country/Countries?$top=5&$format=json'
