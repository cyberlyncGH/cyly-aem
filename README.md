# sfdc-aem-cookbook

This is a wrapper cookbook around the community AEM cookbook, for DigitalLync

See docs at 

https://supermarket.getchef.com/cookbooks/aem/versions/1.0.3

for usage/details.

## Local Dev VM Setup

The local dev VM is built using Vagrant and Chef. The Chef cookbooks are the same as production but they have different configurations for the local vm.

### Prerequisites  (can be installed using setup_vagrant_prereqs.sh)

* VirtualBox ~> 4.3.30 (download and install from https://www.virtualbox.org/wiki/Downloads)
* Vagrant ~> 1.7.4 (download and install from http://vagrantup.com)
* Test Kitchen ~> 1.2.1 (OPTIONAL: not needed if you're only using Vagrant)
* ChefDK ~> 0.7.0 (download and install from https://downloads.chef.io/chef-dk/)
* vagrant-omnibus ~> 1.4.1 

  From the commnad line:
  
  ```sh
  vagrant plugin install vagrant-omnibus
  ```
* vagrant-berkshelf ~> 4.0.4 
  
  From the command line:
  
  ```sh
  vagrant plugin install vagrant-berkshelf
  ```
  If it says it was installed, ignore warnings that say to install Chef DK
* After cloning this project, place author-4502.jar and license.properties files in the root of this project where the Vagrantfile is located. You can get them here: https://git.soma.salesforce.com/webdev/aem-author


### To Provision the VM with *AEM 6.0* Using Vagrant

You have a few options -

#### Option 1. (recommended) Use the fully loaded box

##### Step 1:

Make a copy of the config_local_aem6_code_content.yaml as config_local.yaml

##### Step 2:

From the root folder for this project:

```sh
$ vagrant up
```

#### Option 2. Start with aem6 hotfixes uploaded

From the root folder for this project:

```sh
$ vagrant up
```

#### Option 3. Start with aem6 hotfixes uploaded and installed (nothing else - you need to deploy your own code & content)

##### Step 1:

Make a copy of the config_local_aem6_hotfixesonly.yaml as config_local.yaml

##### Step 2:

From the root folder for this project:

```sh
$ vagrant up
```

#### Option 4. Start with an empty box, install aem6 and upload hotfixes

##### Step 1:

Make a copy of the config_local_aem6-dev-base.yaml as config_local.yaml

##### Step 2:

From the root folder for this project:

```sh
$ vagrant up
```


### To Provision the VM with *AEM 6.1* Using Vagrant

You have a few options -

#### Option 1. (recommended) Use the box with AEM6.1, hotfixes and ACS commons installed

##### Step 1:

Make a copy of the config_local_aem61_hotfixesonly.yaml as config_local.yaml

##### Step 2:

From the root folder for this project:

```sh
$ vagrant up
```

#### Option 2. This is ONLY for creating a new AEM 6.1 Vagrant base box

##### Step 1:

Make a copy of the config_local_aem61-dev-base.yaml as config_local.yaml

##### Step 2:

From the root folder for this project:

```sh
$ vagrant up
```
### Vagrant Box - Tips

#### How to increase/decrease memory

You can edit the config_local.yaml file and tweak the values below

```yaml
    memory_size: 8096

    aem_options:
      CQ_HEAP_MAX: "2048"
      CQ_HEAP_MIN: "1024"
      CQ_PERMGEN: "256"

```

After tweaking the values as appropriate you can run the following commands:

```sh
$ vagrant provision
$ vagrant reload
```

#### How to access vagrant instances via dispatcher

In our fully loaded boxes there is a single AEM Apache server with virtual hosts for author and publish.

To be able to access the instances via dispatcher you must update your local /etc/hosts file and add the following
entries

```sh
127.0.0.1       author.sfdc.local
::1             author.sfdc.local
127.0.0.1       sfdc.local
::1             sfdc.local
```

Now you can access your local author instance by visiting:
http://author.sfdc.local:8000

To access the publish instance you can use: http://sfdc.local:8000


### Code Packages

Vagrant uploads the following packages (they must be manually installed through the package manager):

* AEM service pack 2
* hotfix-6167
* hotfix-5916
* hotfix-6561 (Oak 1.0.15; this is installed automatically)
* hotfix-6009
* hotfix-6044
* hotfix-6048
* hotfix-6445
* hotfix-6450
* hotfix-7353
* ACS commons

### Finishing the setup

#### Expanding your VirtualBox HD

You will need to expand your VirtualBox VM's available hard drive space—otherwise the 20GB default will be overrun by AEM within a few days. Follow the [Instructions for adding new disk space to a Vitrual Box VM v2](https://docs.google.com/a/salesforce.com/document/d/1u72_Vy1ZjiD19v4fpBmzmQKCVCN08XNl6mOQGkQOeYw/edit?usp=sharing) instructions.

#### Installing Packages in the Package Manager

After the installation completes, you can access AEM via the following URLs:

* [Author](http://localhost:4502/)
* [Publish](http://localhost:4503/)

You will need to manually install the AEM code packages uploaded by Vagrant, and replicate them, using the [Package Manager](http://localhost:4502/crx/packmgr/index.jsp). Look for all of the packages which have the __Install__ blue bar to the right of their names. Starting with the one furthest down on the page, click on the Install button and follow the installation steps. 

After the installation of a package, click on the __More > Replicate__ link, to send the package to you publish server.

Follow these steps for each non installed package.

##### When a restart is required
Some of the packages will prompt you to restart the AEM server. To do so, you will need to connect to your CentOS VM from __Terminal__:

```sh
vagrant ssh
```

Once you are connected, to restart your Author instance:

```sh
sudo service aem-author restart
```

To restart your Publish instance:

```sh
sudo service aem-publish restart
```

#### Configuring the Dispatcher Flush Agent

1. Go to the [Dispatcher Flush (flush)](http://localhost:4502/etc/replication/agents.author/flush.html) agent page.
2. Click the __Edit__ link.
3. Check the __Enabled__ checkbox.
4. Click on the __Transport__ tab.
5. Change the __URI__ field to `http://localhost:80/dispatcher/invalidate.cache`.
6. Click the __OK__ button.
7. Click the __Test Connection__ link, and you shoud see a success message similar to:

   ```
   20.10.2015 18:47:24 - Create new HttpClient for Dispatcher Flush
   20.10.2015 18:47:24 - * HTTP Version: 1.1
   20.10.2015 18:47:24 - adding header: CQ-Action:Test
   20.10.2015 18:47:24 - adding header: CQ-Handle:/content
   20.10.2015 18:47:24 - adding header: CQ-Path:/content
   20.10.2015 18:47:24 - deserialize content for delivery
   20.10.2015 18:47:24 - No message body: Content ReplicationContent.VOID is empty
   20.10.2015 18:47:24 - Sending GET request to http://localhost:80/dispatcher/invalidate.cache
   20.10.2015 18:47:24 - sent. Response: 200 OK
   20.10.2015 18:47:24 - ------------------------------------------------
   20.10.2015 18:47:24 - Sending message to localhost:80
   20.10.2015 18:47:24 - >> GET /dispatcher/invalidate.cache HTTP/1.0
   20.10.2015 18:47:24 - >> CQ-Action: Test
   20.10.2015 18:47:24 - >> CQ-Handle: /content
   20.10.2015 18:47:24 - >> CQ-Path: /content
   20.10.2015 18:47:24 - >> Referer: about:blank
   20.10.2015 18:47:24 - >> Content-Length: 0
   20.10.2015 18:47:24 - >> Content-Type: application/octet-stream
   20.10.2015 18:47:24 - --
   20.10.2015 18:47:24 - << HTTP/1.1 200 OK
   20.10.2015 18:47:24 - << Date: Tue, 20 Oct 2015 18:47:24 GMT
   20.10.2015 18:47:24 - << Server: Apache
   20.10.2015 18:47:24 - << X-Frame-Options: SAMEORIGIN
   20.10.2015 18:47:24 - << Vary: Accept-Encoding,User-Agent
   20.10.2015 18:47:24 - << Content-Length: 13
   20.10.2015 18:47:24 - << Content-Type: text/html
   20.10.2015 18:47:24 - << 
   20.10.2015 18:47:24 - << 
   20.10.2015 18:47:24 - Message sent.
   20.10.2015 18:47:24 - ------------------------------------------------
   20.10.2015 18:47:24 - Replication (TEST) of /content successful.
   Replication test succeeded
   ```

### Notes

The memory on the Author VM is set to 2GB, please make sure your local workstation has sufficient memory for this. 

Occasionally the VM fails to start successfully due to a timeout while waiting for AEM to start up. Adding additional memory to the VM may decrease this occurance, although simply re-running the provisioning usually works.

## Supported Platforms

CentOS

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['sfdc-aem']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### Test Kitchen/Vagrant

To use a local VM, make sure you have a copy of author-4502.jar and license.properties in the root directory of this cookbook.

### sfdc-aem::default

Include `sfdc-aem` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[sfdc-aem::default]"
  ]
}
```

## Local Vagrant configs
If you place a file named .user_vagrant.rb in the base directory, it will be executed as ruby in the context of the provisioner.  This means that you can set log levels, modify the json object (the initial attributes), and anything else you could do in that part of the Vagrantfile.

To add to or modify any of the attributes in the config.yaml file, you can create a config_local.yaml, which will get merged in when you reload your vagrant box.

## License and Authors

Author:: DigitalLync, Inc. (<YOUR_EMAIL>)
