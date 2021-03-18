# Boundary: A Pratical Use Case including Desktop App



In 2020 Hashicorp has announced Boundary as a new product to their already amazing portfolio. Boundary allows us managing the remote access to our infra using a granular policy-based access control. Despite being in its early ages, Boundary looks like a promising tool and with a lot of room for growth.

As a very novice tool, the practical documentation, including use cases, are still scarce and spread. The goal for this Guide is introducing the readers to a fictional, realistic though, scenario and go over the configuration steps, always with IaC approach in mind.

If you happen to get here, I'm assuming that you already know what Boundary is and what is is for. In case you don't, you can get to know Boundary by checking the [Boundary Project](https://www.boundaryproject.io/) site. In a nutshell Boundary provides a programmatic and code-based approach for remote access management.

![image-20210318075747916](/Users/lucasjr/temp/github/boundary/boundary-labs/images/image-20210318075747916.png)

Source: [Boundary Project](https://www.boundaryproject.io/) 



### Fictional Scenario

The fictional scenario for this guide can be found described right below:

![image-20210318075826997](/Users/lucasjr/temp/github/boundary/boundary-labs/images/image-20210318075826997.png)



* Organization (**MyCorp**) with a single project (scope) called **Core_Infra**;
* **Accounts** managed using Boundary built-in Password IdP, which is the only auth method currenttly supported, although there a more to come, as per [roadmap](https://www.boundaryproject.io/docs/roadmap); 
* **Users** mapped to IdP accounts (with the same for demostration purposes). Worth to mention that a single user can be mapped to one or more accounts. Also, the users are not required of being created in advance, but this is a more advanced discussion;
* Users will be added to **Groups** based on OS (Windows and Linux), but choose the one that better suits your needs;
* **Roles** with associated grants and making reference to **Groups** as Principals;
* **Hosts** grouped in **HostSets** (Windows and Linux) inside a **Host Catalog**;
* **Targets** based on protocol (SSH and RDP) and linked to their respective **HostSets**;



### Installation Steps:

Boundary setup will be made on top of Ubuntu 18.04, although it should work on any supported OS. Since Hashicorp has their our Apt repository, Boundary installation on Ubuntu can be performed using the script below:

```bash
$ scripts/boundary_install.sh
```

For Dev mode, Docker is also required. It can be installed on Ubuntu using the official steps (which includes removing previous versions):

```bash
$ scripts/docker_install.sh
```

Alternatively, you can use Rancher Docker installation script, that works like a charm. 

``` bash
$ curl https://releases.rancher.com/install-docker/19.03.sh | sh
```



### Starting Boundary

Since this is not a production environment, Boundary will be started in Dev Mode:

```bash
$ sudo boundary dev -api-listen-address=0.0.0.0 \
-cluster-listen-address=0.0.0.0 \
-proxy-listen-address=0.0.0.0 \
-worker-public-address=$(curl -s ifconfig.co)

==> Boundary server configuration:
...
     Controller Public Cluster Addr: 0.0.0.0:9201
             Dev Database Container: vigorous_bhabha
                   Dev Database Url: postgres://postgres:password@localhost:49153/boundary?sslmode=disable
         Generated Admin Login Name: admin
           Generated Admin Password: password
           Generated Auth Method Id: ampw_1234567890
          Generated Host Catalog Id: hcst_1234567890
                  Generated Host Id: hst_1234567890
              Generated Host Set Id: hsst_1234567890
             Generated Org Scope Id: o_1234567890
         Generated Project Scope Id: p_1234567890
                Generated Target Id: ttcp_1234567890
...

```



### Boundary Config using Terraform

The configuration can be automated using Terraform and the definition files for the presented scenario can be found on GitHub. Since Terraform out of the scope for this guide, I'm assuming that the reader has Terraform already installed and also some background in how to use it. The definitions were based on [this](https://learn.hashicorp.com/tutorials/boundary/getting-started-config) tutorial published by Hashicorp. However, the Hashicorp definitions were not fully functional, so I decided to add some improvements to the code. 

The definitions used on this guide are fully functional using any rolled user. After cloning the repo, make sure that you update the *provider.tf* file with your endpoint settings. The default password for Boundary is *password* (in case you haven't changed it).

```
...
provider "boundary" {
  addr                            = "http://<BOUNDARY_ADDR>:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "<PASSWORD>"
...
```

Once the definitions are updated, Terraform needs to be inititated and applied:

```
$ terraform init
$ terraform plan
$ terraform apply
```

After the configuration is completed, you must be able to open the WebUI and see the new corp **MyCorp**. You must be able also of being authenticated using one of the created users using WebUI or CLI.



#### CLI

```bash
$ export BOUNDARY_ADDR=http://<BOUNDARY_ADDR>:9200

# Don't forget to replace the AMPW_ID
$ boundary authenticate password -auth-method-id=<AMPW_ID> -login-name=lilian -password=password -format=json | jq -r ".token"
<TOKEN>

$ export BOUNDARY_TOKEN="<TOKEN>"  

$ boundary scopes list
Scope information:
  ID:                    o_1234567890
    Version:             1
    Name:                Generated org scope
    Description:         Provides an initial org scope in Boundary
    Authorized Actions:
      read

...
```



For an CLI walk-through, refer to a follow-up to this guide.



#### WebUI:

![image](/Users/lucasjr/temp/github/boundary/boundary-labs/images/111313112-3ccd4500-8660-11eb-8e4f-bf87af3c06eb.png)



Until few weeks ago, the only option for connecting to remote targets using Boundary was through the CLI, since the vendor didn't provide any Desktop UI. However, Hashicorp has just announced a [Desktop app](https://www.boundaryproject.io/docs/api-clients/desktop) (Alpha), only for MacOS user for now. The .dmg file can be downloaded [here](https://releases.hashicorp.com/boundary-desktop).

After the App is installed, on the first opening the users will be requested to provide the endpoint - http://<BOUNDARY_ADDR>:9200. On the following page, they will be asked to provide their username and password. **Don't forget to switch to "MyCorp" organization at the top**.

Once authenticated, the users will be presented to the available targets. For connecting to one of the targets, just click connect and take note of the port number informed and move to a terminal or open a RDP client app.

![image](/Users/lucasjr/temp/github/boundary/boundary-labs/images/111515113-b6456000-8752-11eb-941a-5a035af78da2.png)



For SSH, open a SSH session pointing to localhost and using the session port previously noted and the SSH user. Bear in mind that the session will expire after the first use (no matter if the SSH session was open or not), but this can be adjusted on Boundary using *session_connection_limit* parameter.

```bash
$ ssh 127.0.0.1 -p 53704 -l username
```

At this point, you have a functional Boundary setup, however there are still some improvements to be made, specially on the roles, since they are pretty permissive yet. But this was a first step and I hope you can move forward from this point.



I hope you find this useful and really appreciate your feedbacks.



------



