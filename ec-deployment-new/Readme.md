# Deploy Ericom Connect on a Multiple Virtual Machines Environment

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/)

This template deploys the following resources:

<ul><li>storage account;</li><li>vnet, public ip, load balancer;</li><li>domain controller vm;</li><li>Ericom Connect Gateway;</li><li>Ericom Connect Grid;</li><li>a number of RD Session hosts (number defined by 'numberOfRdshInstances' parameter)</li></ul>

The template will deploy a domain controller, join all VMs to the new domain, configure each Windows VM and then setup and configure Ericom Connect.

<a href="http://www.ericom.com/connect-enterprise.asp" target="_blank">Additional information on Ericom Connect</a>

<a href="https://www.ericom.com/communities/guide/home/connect-7-3-0" target="_blank">Ericom Connect Online Guide</a>

<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/ErezPasternak/azure-quickstart-templates/EricomConnect/ec-deployment-new/azuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>
