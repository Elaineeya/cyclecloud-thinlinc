# Thinlinc CycleCloud Project

ThinLinc is a powerful remote desktop server solution for Linux environments, offering seamless access to applications from various clients with robust security and high performance. See the [ThinLinc site](https://www.cendio.com/) and [documentation](https://www.cendio.com/thinlinc/docs/) for an overview and detailed information.

This project integrates Azure CycleCloud with ThinLinc to ensure seamless operation of ThinLinc on CycleCloud cluster nodes. 

Please reference the [CycleCloud Projects page](https://docs.microsoft.com/en-us/azure/cyclecloud/projects) dives into
greater detail on the concepts and examples.

## A quick step-to-step guides to use this project

### 1.1 pre-requisites

* have a valid Azure subscription and a service principal ready
* have a valid Azure CycleCloud installed

### 1.2 Uploading this Thinlinc CycleCloud project into the storage locker

Please note that one of the steps in setting up an Azure CycleCloud installation is the creation of an Azure storage account and an accompanying blob container. This container is the *"Locker"* that the CycleCloud server uses to stage CycleCloud projects for cluster nodes. CycleCloud cluster nodes orchestrated by this CycleCloud server are configured to download CycleCloud projects from this locker as part of the boot-up process of the node.

* To see what locker is set in your cyclecloud, use the `cyclecloud locker list` command:

  ```sh
    (venv) xuan@dhcp-130:~$ cyclecloud locker list
    cendio-elaine-ansible-storage (az://cendiocyclecloud/cyclecloud)
    (venv) xuan@dhcp-130:~$ 
  ```

  In this example, the storage account name is `cendiocyclecloud`, and the blob container name is `cyclecloud`. 

Prepare the credentials to access the blob container associated with the locker: 

* Edit the cyclecloud configuration file `~/.cycle/config.ini`:

  ```sh
    (venv) xuan@dhcp-130:~$ vim ~/.cycle/config.ini
  ```

* Add the section below, with `subscription_id`, `tenant_id`, `application_id`, `application_secret` matching those in the service principal used when setting up your cyclecloud. Also replace the storage account name `cendiocyclecloud` with the output of the `cyclecloud locker list` command:

  ```ini
  [pogo azure-storage]
  type = az
  subscription_id = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  tenant_id = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  application_id = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  application_secret = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  matches = az://cendiocyclecloud/cyclecloud
  ```

  _You can locate your Subscription ID using the Azure CLI (`az` command) to list the accounts:_ `az account list -o table`

* Your `~/.cycle/config.ini` should now look something like this

  ![config ini](images/cyclecloud-config-ini.png)

* Upload the project from its directory using the `cyclecloud project upload` command

  ```sh
    (venv) xuan@dhcp-130:~/cyclecloud-thinlinc$ cyclecloud project upload
    Job 3945e310-e3e6-9149-5969-cadfd55cd117 has started
    Log file is located at: /home/xuan/.azcopy/3945e310-e3e6-9149-5969-cadfd55cd117.log
    
    INFO: azcopy: A newer version 10.25.1 is available to download
    
    0 Files Scanned at Source, 0 Files Scanned at Destination
    
    Job 3945e310-e3e6-9149-5969-cadfd55cd117 Summary
    Files Scanned at Source: 5
    Files Scanned at Destination: 0
    Elapsed Time (Minutes): 0.0333
    Number of Copy Transfers for Files: 5
    Number of Copy Transfers for Folder Properties: 0 
    Total Number Of Copy Transfers: 5
    Number of Copy Transfers Completed: 5
    Number of Copy Transfers Failed: 0
    Number of Deletions at Destination: 0
    Total Number of Bytes Transferred: 1738
    Total Number of Bytes Enumerated: 1738
    Final Job Status: Completed
    
    
    Upload complete!
    (venv) xuan@dhcp-130:~/cyclecloud-thinlinc$
  ```

### 1.3 Create a new Cluster with the Thinlinc Project

Having uploaded the Thinlinc project into the CycleCloud locker, you can now create a new cluster in CycleCloud and specify that each node should use the `cyclecloud-thinlinc:default` spec. 

* Import cluster template by referencing the sample template located at /templates/single-nodearray_template_1.0.0.3.txt. Make the necessary adjustments accordingly.

  ```sh
    (venv) xuan@dhcp-130:~/cyclecloud-thinlinc$ cyclecloud import_template single-nodearray -f ./templates/single-nodearray_template_1.0.0.3.txt
    Importing template single-nodearray....
    -----------------------------
    single-nodearray : *template*
    -----------------------------
    Resource group: 
    Cluster nodes:
        my-tl: Off -- --  
    Total nodes: 1
    (venv) xuan@dhcp-130:~/cyclecloud-thinlinc$
  ```


* From the Cluster page of your Azure CycleCloud web portal, use the "+" symbol in the bottom-left-hand corner of the page to add a new cluster, select "single-nodearray" template created in the last step:
  ![Browse Specs](images/cluster-template.png)


* Input the cluster name and complete the other required fields. 

* Navigate to the *Advanced Settings* section. Under the *Software* section, click on the "Browse" button for "Cluster-Init" which will open a file selector dialog, You will see a folder named `cyclecloud-thinlinc/`. Open it by double-clicking it. Then open the `1.0.0/` folder. Finally, select the `default/` folder by clicking on it once and pressing the "Select" button on the bottom of the dialog window. After pressing "Select" the file selector dialog will close. This selects the `default` spec of version `1.0.0` of the project `cyclecloud-thinlinc`.

* Under the *Thinlinc* section, for `Enable Web Interface` choose to enable or disable ThinLinc web interface access (default is disabled), we recommend to enable it. Once selected, input your web interface port number in the `Web Port` field (default is 443). 

  *Note: Please ensure your network security or firewall rules allow inbound access on this port.*

* In the `Connection Mode` dropdown, select the mode for the client connect from, the three options are:
  **Public IP**: Connect trhough a public IP address.
  **Private IP**: Connect through a VPN with direct connectivity to the Cluster.
  **SSH Tunnel**: Connect through a bastion host. 

  ![Browse Specs](images/advanced-settings.png)

* Save the cluster and start it. When the master node turns green, connet to it using Thinlinc client to verify that it is  configured correctly.
