# Minecraft Server Deployment (Part 2)

> **High-level tutorial** — skip the “type this, then that”; everything is scripted in Terraform & Ansible.

---

##  Background

We’ll build a **dedicated Minecraft server** on AWS by:

1. **Terraform**: Provisioning VPC networking, subnet, IGW, route table, security group, EC2 instance + Elastic IP.
2. **Ansible**: Installing Java (Amazon Corretto 21), downloading Minecraft, accepting the EULA, and wiring up a `systemd` service for auto-start.

---

##  Requirements

* **AWS account** with IAM permissions for VPC, EC2, Security Groups, EIP, etc.
* **AWS CLI** installed & configured:

  ```bash
  aws configure
  # or set AWS_PROFILE + ~/.aws/credentials
  ```
* **Terraform** ≥ 1.0
* **Ansible** ≥ 2.9
* **Pre-created EC2 key pair** in your target region

  ```bash
  export TF_VAR_minecraft_key_name="my-mc-key"
  ```
* (Optional) Set region explicitly:

  ```bash
  export AWS_DEFAULT_REGION="us-west-2"
  ```

---

##  Repository Layout

```
.
├── ansible
│   ├── inventory.ini          # dynamic via Terraform output
│   └── playbook.yml
├── docs
│   └── architecture.png       # diagram of pipeline steps
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

---

##  Architecture Diagram

![Pipeline Overview](./docs/architecture.png)

1. **Terraform** provisions network & instance
2. **Ansible** configures OS, Java, and Minecraft server
3. **You** connect at `<ELASTIC_IP>:25565`

---

## 🚀 Step-by-Step Commands

### 1. Terraform: Provision infrastructure

```bash
cd terraform
# 1.1 Initialize working directory
terraform init

# 1.2 Create or update AWS resources
terraform apply -auto-approve

# 1.3 Grab the public IP
export MC_IP=$(terraform output -raw minecraft_ip)
echo "Server IP: $MC_IP"
```

### 2. Ansible: Configure server

```bash
cd ../ansible

# 2.1 Generate dynamic inventory (you can also write the IP manually)
cat > inventory.ini <<EOF
[mc]
$MC_IP ansible_user=ubuntu ansible_ssh_private_key_file=../terraform/my-mc-key.pem
EOF

# 2.2 Run the playbook
ansible-playbook -i inventory.ini playbook.yml
```

> **Playbook does**:
>
> * Installs `curl`, `wget`, `tar`
> * Downloads & unpacks Amazon Corretto 21
> * Sets Java via `alternatives`
> * Creates `/opt/minecraft`
> * Downloads `minecraft_server.1.21.5.jar`
> * Writes `eula.txt`
> * Deploys `minecraft.service` (systemd)
> * Enables & starts the service

---

##  Verifying & Connecting

1. **Check systemd status**

   ```bash
   ssh -i terraform/my-mc-key.pem ubuntu@$MC_IP \
     'systemctl status minecraft'
   ```

2. **Connect from your Minecraft client**

   * Launch Minecraft → **Multiplayer** → **Add Server**
   * **Server Address**: `$MC_IP:25565`
   * Click **Join Server**

---

##  Cleanup

When you’re done, tear everything down in one go:

```bash
cd terraform
terraform destroy -auto-approve
```

---

##  Further Reading

* [GitHub Markdown Syntax](https://docs.github.com/en/get-started/writing-on-github/basic-writing-and-formatting-syntax)
* [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Ansible Documentation](https://docs.ansible.com/)

---

*Happy crafting!*
